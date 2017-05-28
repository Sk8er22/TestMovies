//
//  ViewController.swift
//  TestPeliculas
//
//  Created by PEDRO ARMANDO MANFREDI on 27/5/17.
//  Copyright © 2017 Pedro Manfredi. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import SwiftyJSON

class ViewController: UITableViewController {
    
    //declaración del searchController
    var searchController: UISearchController!
    
    //Init de las variables de peliculas populares
    var peliculas = [ClassPeliculas]()
    var pagina = 1
    
    //Init de las variables de peliculas buscadas
    var searchPeliculas = [ClassPeliculas]()
    var searchPagina = 1
    var lastSearch = ""
    
    //Init de controladores extra
    var loadingStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configuramos y seteamos el SearchController
        self.searchController = UISearchController(searchResultsController: nil) //aquí deberia pasar la vista
        self.searchController.searchResultsUpdater = self //delegate
        self.searchController.dimsBackgroundDuringPresentation = false //quitar un efecto
        self.tableView.tableHeaderView = self.searchController.searchBar //asignar searchbar a tabla
        
        //Empezamos haciendo un request de las peliculas más populares
        self.request(pagina: pagina)
        
        //Auto asignación de tamaño para la tabla
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TABLEVIEW
    //Número de rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive{ //Si esta la busuqeda activa
            return searchPeliculas.count //devuelve el count sobre la variable para la busqueda
        } else {
            return peliculas.count //en caso contrario devuelve la variable de peliculas populares
        }
    }
    
    //Número de secciones
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Devolver celda
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //defino la reutilización de mi celda customizada
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPeliculas", for: indexPath) as! CellPeliculas
        let pelicula: ClassPeliculas //defino variable a ser inizializada dependiendo si:
        if self.searchController.isActive{ //la busqueda esta activa
            pelicula = searchPeliculas[indexPath.row] //devuelve sobre las variables de search
        } else {
            pelicula = peliculas[indexPath.row]
        }
        //Seteamos los valores de la row -> celda
        cell.titleLabel.text = pelicula.title
        cell.overviewLabel.text = pelicula.overview
        cell.yearLabel.text = pelicula.release_date
        //Utilizamos la libreria Kingfisher para el donwload/cache/update de las imagenes
        let url = URL(string: "http://image.tmdb.org/t/p/w130/\(pelicula.poster_path)")!
        cell.posterImage.kf.indicatorType = .activity //seteamos el activity indicator
        cell.posterImage.kf.setImage(with: url)
        return cell
    }
    
    //Detectamos el scroll al final de la tabla.
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            // Nos fijamos de que no este cargando nada
            if (!loadingStatus){
                //Este if es un tanto inusual, obviando la parte si la busqueda esta activa el segundo termino se utiliza para comprobar de que esta en una página con 20 items, lo cual indicaria con mucha seguridad que hay una siguiente página, en caso de no ser así y ser una última página con 20 objetos a la siguiente iteración ya no irian sincronizados el searchpeliculas y searchpagina.
                //Todo esto me lo podía haber ahorra si decidia pillar la variable "total_pages" de la api, pero me puse creativo.
                if (self.searchController.isActive && (self.searchPeliculas.count / 20 == searchPagina)){
                    searchPagina += 1
                    self.request(pagina: searchPagina, search: lastSearch)
                } else if (!self.searchController.isActive && (self.peliculas.count / 20 == pagina)){
                    pagina += 1
                    self.request(pagina: pagina)
                }
            }
        }
    }
    
    // REQUEST WEB con argumento opcional de Search
    func request(pagina: Int, search: String? = ""){
        self.loadingStatus = true //semaforo loading
        let url : String
        if self.searchController.isActive{ // configuracion de la url dependiendo si estamos en busqueda...
            url = "https://api.themoviedb.org/3/search/movie?api_key=93aea0c77bc168d8bbce3918cefefa45&language=es-ES&page=\(pagina)&include_adult=false&query=\(search!)"
        } else {
            url = "https://api.themoviedb.org/3/movie/popular?api_key=93aea0c77bc168d8bbce3918cefefa45&language=es-ES&page=\(pagina)"
        }
        //Consulta
        Alamofire.request(url) .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)//utilizamos alamofire+swiftyJSON para obtener la respuesta
                for i in 0..<json["results"].count{ //cogemos el [diccionario] results y lo recorremos instanciando
                    let pelicula = ClassPeliculas(dictionary: json["results"][i].dictionaryObject as! [String : AnyObject])
                    if self.searchController.isActive{
                        self.searchPeliculas.append(pelicula)
                    } else {
                        self.peliculas.append(pelicula)
                    }
                }
            case .failure(let error):
                print(error) // en caso de que falle nos da el error
            }
            //enviamos a la cola main que actualize la tabla.
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
                self.loadingStatus = false
            }
        }
    }
    
    //En vuestro enunciado pedia cancelar las busquedas anteriores, en alamofire se realiza así
    func cancelrequests(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
        //reseteamos el semaforo tambien
        self.loadingStatus = false
    }
}

// Modificamos la función que detecta los cambios es la search Bar
extension ViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if var searchText = searchController.searchBar.text{
            searchText = searchText.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed )!
            self.cancelrequests()
            self.lastSearch = searchText
            self.searchPagina = 1
            self.searchPeliculas.removeAll()
            self.request(pagina: searchPagina, search: lastSearch)
        }
    }
}

