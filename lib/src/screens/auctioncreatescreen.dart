import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/repository.dart';

class AuctionCreateScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AuctionCreateScreenState();
  }

}

class AuctionCreateScreenState extends State<AuctionCreateScreen> {
  final _repository = Repository();
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();
  final TextEditingController _priceEditingController = TextEditingController();

  bool isNameInput = false;
  bool isDescriptionInput = false;
  bool isUploading = false;
  bool isImageChoosed = false;
  bool isPriceInput = false;
  bool isDateSet = false;
  bool isAllInputDone = false;


  String productName = '';
  String productDescription = '';
  int minBidPrice = 0;
  late DateTime auctionEndDate;
  PickedFile? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        'Create Auction',
      ),
      leading: FlatButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back, color: Colors.greenAccent,),
        splashColor: Colors.teal.withOpacity(0.25),
        highlightColor: Colors.tealAccent.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      actions: [
        FlatButton(
          onPressed: isAllInputDone ? handleSubmit : null,
          child: Text('POST', style: TextStyle(color: !isUploading ? Colors.black : Colors.grey),),
          splashColor: Colors.green.withOpacity(0.25),
          highlightColor: Colors.greenAccent.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          isUploading ? LinearProgressIndicator() : Text(''),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (String value) {
                if(value.trim() != '') {
                  setState(() {
                    isNameInput = true;
                    if(isNameInput && isDescriptionInput && isPriceInput && isImageChoosed && isDateSet) {
                      isAllInputDone = true;
                    }
                  });
                } else {
                  setState(() {
                    isNameInput = false;
                    isAllInputDone = false;
                  });
                }
              },
              onSubmitted: (String value) {
                productName = value;
              },
              controller: _nameEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                hintText: "Product Name",
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (String value) {
                if(value.trim() != '') {
                  setState(() {
                    isDescriptionInput = true;
                    if(isNameInput && isDescriptionInput && isPriceInput && isImageChoosed && isDateSet) {
                      isAllInputDone = true;
                    }
                  });
                } else {
                  setState(() {
                    isDescriptionInput = false;
                    isAllInputDone = false;
                  });
                }
              },
              onSubmitted: (String value) {
                productDescription = value;
              },
              controller: _descriptionEditingController,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                hintText: "Product Description",
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (String value) {
                if(value.trim() != '') {
                  setState(() {
                    isPriceInput = true;
                    if(isNameInput && isDescriptionInput && isPriceInput && isImageChoosed && isDateSet) {
                      isAllInputDone = true;
                    }
                  });
                } else {
                  setState(() {
                    isPriceInput = false;
                    isAllInputDone = false;
                  });
                }
              },
              onSubmitted: (String value) {
                minBidPrice = int.parse(value);
              },
              controller: _priceEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                hintText: "Minimum bid price",
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          !isImageChoosed ? Text(
            'Image is not choosed'
          ) : Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: AspectRatio(
              aspectRatio: 16/9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(File(file!.path)),
                  ),
                ),
              ),
            ),
          ),
          MaterialButton(
            onPressed: () => showPickPhotoDialog(context),
            child: Text('Pick your Product Image'),
            elevation: 5.0,
            color: Theme.of(context).accentColor,
          ),
          Text(isDateSet ? 'Auction will end at ${auctionEndDate.day}/${auctionEndDate.month}/${auctionEndDate.year}' : 'Date is not picked'),
          MaterialButton(
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2025),
              ).then((date) {
                if (date != null) {
                  setState(() {
                    auctionEndDate = date;
                    isDateSet = true;
                    if(isNameInput && isDescriptionInput && isPriceInput && isImageChoosed && isDateSet) {
                      isAllInputDone = true;
                    }
                  });
                }
              });
            },
            child: Text('Pick your Auction end date'),
            elevation: 5.0,
            color: Theme.of(context).accentColor,
          ),
        ],
      ),
    );
  }

  showPickPhotoDialog(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text('Select Image'),
          children: <Widget>[
            SizedBox(height: 5.0,),
            SimpleDialogOption(
              child: Text('Image by Camera'),
              onPressed: () async {
                Navigator.pop(context);
                file = await ImagePicker().getImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
                if(file != null) {
                  setState(() {
                    isImageChoosed = true;
                    if(isNameInput && isDescriptionInput && isPriceInput && isImageChoosed && isDateSet) {
                      isAllInputDone = true;
                    }
                  });
                }
              },
            ),
            SizedBox(height: 5.0,),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                file = await ImagePicker().getImage(source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
                if(file != null) {
                  setState(() {
                    isImageChoosed = true;
                    if(isNameInput && isDescriptionInput && isPriceInput && isImageChoosed && isDateSet) {
                      isAllInputDone = true;
                    }
                  });
                }
              },
              child: Text('Image by Gallery'),
            ),
            SizedBox(height: 5.0,),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    productName = _nameEditingController.text.trim();
    productDescription = _descriptionEditingController.text.trim();
    minBidPrice = int.parse(_priceEditingController.text);
    await _repository.createAuction(productName, productDescription, minBidPrice, File(file!.path), auctionEndDate);
    Navigator.pop(context);
  }
}