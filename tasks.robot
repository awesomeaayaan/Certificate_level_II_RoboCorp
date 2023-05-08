*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${FALSE}   
Library    RPA.Tables
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.JavaAccessBridge
Library    RPA.Archive


*** Variables ***
${url}    https://robotsparebinindustries.com/#/robot-order   
${reciepts_path}=    ${CURDIR}${/}output${/}reciept${/}
${image_path}=    ${CURDIR}${/}output${/}images${/}
${zip_path}=    ${CURDIR}${/}output${/}
*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    download the csv file
    ${orders}=    get orders
    Maximize Browser Window
    FOR    ${order}    IN    @{orders}
        Log    ${order}
        close the popup modal
        fill the form for each robot    ${order}
        preview the robot
        Wait Until Keyword Succeeds    5x    2s   order the robot
        create pdf    ${order}[Order number]
        take screenshot of robot    ${order}[Order number]
        Embeed robot image to receipt pdf    ${order}[Order number]
        next order
    END
    create archive
*** Keywords ***

get orders 
    ${orders}=    Read table from CSV    orders.csv
    RETURN     ${orders}

download the csv file
    Download    https://robotsparebinindustries.com/orders.csv
Open the robot order website
    #ToDo: Implement your keyword here
    Open Available Browser    ${url}

close the popup modal
    Click Button    OK

fill the form for each robot
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    XPath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    XPath://*[@id="address"]    ${order}[Address]

preview the robot
    Click Button    Preview

order the robot
    Click Button    order
create pdf
    [Arguments]    ${filename}
    Wait Until Page Contains Element    id:receipt  
    ${html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${html}    ${reciepts_path}${filename}.pdf

take screenshot of robot
    [Arguments]    ${filename}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    
    ...    ${image_path}${filename}.png
next order 
    Click Button    xpath://button[@id='order-another']


Embeed robot image to receipt pdf
    [Arguments]    ${filename}
    Add Watermark Image To Pdf    
    ...    ${image_path}${filename}.png    
    ...    ${reciepts_path}${filename}.pdf
    ...    ${reciepts_path}${filename}.pdf

create archive
    Archive Folder With Zip    ${reciepts_path}    ${zip_path}receipts.zip