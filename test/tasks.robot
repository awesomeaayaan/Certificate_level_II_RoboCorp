*** Settings ***
Documentation       order robot from robotsparebin industries Inc.
...                 Save the order HTML receipt as pdf
...                 Save screenshot of the robot
...                 embeed screenshot in pdf
...                 create zip archive 
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.Desktop
Library    RPA.PDF

*** Tasks ***
order processing bot
    ${orders}    Get orders
    open robot    
    fill orders    ${orders}   

*** Keywords ***
Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

open robot
    Open Available Browser     https://robotsparebinindustries.com
    Maximize Browser Window
    Click Element    xpath://a[@class='nav-link']
    handle modal box

handle modal box
    Click Element    xpath://button[normalize-space()='OK']

fill orders
    [Arguments]    ${orders}
    FOR    ${order}    IN    @{orders}
        Wait Until Keyword Succeeds    5x    2s   filling one order    ${order}  
        handle modal box     
    END
    Sleep    2

filling one order
    [Arguments]    ${order}
    Select From List By Index    name:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    xpath://input[@id='address']    ${order}[Address]
    Click Button    Preview  
    Click button    Order
    Log    nextpage
    Wait Until Keyword Succeeds    10x    2s    Screenshot image and create pdf    ${order}[Order number]
 

Screenshot image and create pdf
    [Arguments]    ${name}
    Wait Until Page Contains Element    id:robot-preview-image
    ${picture}=    Screenshot    xpath:/html/body/div/div/div[1]/div/div[2]/div[2]/div    
    Wait Until Page Contains Element    id:receipt
    ${html_pdf}=    Get Element Attribute    xpath:/html/body/div/div/div[1]/div/div[1]/div/div    outerHTML
    Html To Pdf    ${html_pdf}    output/${name}.pdf    overwrite=true
    ${pic_dir}=    ${picture}:x=0,y=0
    Open Pdf    output/${name}.pdf
    Add Files To Pdf    ${pic_dir}    output/${name}.pdf    ${True}
    Close Pdf    output/${name}.pdf
    Log    1 step done
    Click Button    Order another robot
