var express=require("express");
var mysql=require("mysql");
var bodyparser=require("body-parser");

var app=express();

app.use(bodyparser.json());
app.use(bodyparser.urlencoded({extended:true}));


var connection=mysql.createConnection({
"host":"localhost",
"database":"fluttershedule",
"user":"root",
"password":"root"
});

connection.connect();

app.get("/getslot",function(req,res){

    connection.query("select * from timeslot",function(error,results,fields){
        if(error) throw error;
        res.send({error:false,data:results,message:"get slot"})
    });


})

app.post("/updateslot",function(req,res){

    connection.query("Update timeslot set status='0' where timerange=? and userid=? ",[req.body.timerange,req.body.userid],function(error,results,fields){
      if(error)throw error;
      res.send({error:false,data:results,message:"Updated"})  
    })
})

app.listen(3000,function(){
console.log("Listen at 3000")
});

module.exports=app