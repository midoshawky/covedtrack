class DataModel{
  String countryName,recovered,infected,deaths,newInfected,newDeaths;
  DataModel(String CName,Recv,Infc,Dths,newInfc,newDths){
    this.countryName=CName;
    this.recovered=Recv;
    this.infected=Infc;
    this.deaths=Dths;
    this.newInfected=newInfc;
    this.newDeaths=newDths;
  }
}