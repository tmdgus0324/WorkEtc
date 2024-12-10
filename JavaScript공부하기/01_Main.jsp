<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <script>
        if (getCookie("Popup") != "done"){
            function popupOpen(){
                var popupFlag = false;

                if(!popupFlag){
                    var url = "/02_Popup.jsp";
                    var target = "02_Popup";
                    var width = 500;
                    var height = 500;
                    var popLeftPos = (screen.width - width) / 2;
                    var popTopPos = (screen.height - height) / 2;
                    var popOpt = "width=" + width + ", height=" + height +", top=" + popTopPos + ", left=" + popLeftPos + ", scrollbars=No, menubar=No, resizable=Yes, status=No, toolbar=No";
                    var popup01 = window.open(url, target, popOpt + "");
                    
                    popupFlag = true;
                }
            }

            function getCookie(name){
                var nameOfCookie = name + "=";
                var x = 0;

                while ( x <= document.cookie.length ){
                    var y = (x + nameOfCookie.length);

                    if( document.cookie.substring(x,y) == nameOfCookie ){
                        endOfCookie = document.cookie.length;
                        return unescape(document.cookie.substring(y, endOfCookie));
                    }

                    x = document.cookie.indexOf(" ", x) + 1;
                    if( x == 0 )
                    break;
                }
                return "";
            }
        }
    </script>

    <title>Document</title>
</head>
<body onload="popupOpen();">
    window.open 팝업테스트 + 쿠키이용하여 1일동안 팝업창 보이지 않기 연습
</body>
</html>