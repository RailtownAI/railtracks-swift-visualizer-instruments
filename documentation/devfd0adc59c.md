[]{#devfd0adc59c}

<figure class="topicIcon">
<img src="GlobalArt/AppIconDefault.png" width="30" height="30" />
</figure>

# Create an Instruments Package project

To create a custom instrument, you first create an instruments project
from the Instruments Package template.

:::: {#dev3346e4129 .Task .no-header}
::: {#aria-dev3346e4129 .TaskBody role="region" aria-hidden="false"}
1.  In Xcode, choose File \> New \> Project.

2.  In the sheet that appears, select macOS.

3.  Under Other, select Instruments Package, then click Next.

    ![](Art/gs_create_project.png){height="315" width="438"}

4.  In the next sheet, enter information in the text fields, choose
    options from the pop-up menus, then click Next.

    Enter a [product name](dev5afef3d84.html#dev5afef3d84){.xRef .Aside}
    and [organization identifier](devc21d76564.html#devc21d76564){.xRef
    .Aside} to continue to the next sheet. Also enter an [organization
    name](dev0b24b8b35.html#dev0b24b8b35){.xRef .Aside} (if you don't
    belong to an organization, enter your name as the organization).

5.  Specify a location for the project (optionally, select "Create Git
    repository on my Mac" to use source control), then click Create.

    The project will contain an [instruments package
    file](dev67cb5abd5.html#dev67cb5abd5){.xRef .Aside} that you edit to
    define the instrument using the Instruments Package Definition
    elements.
:::
::::

Alternatively, add a target to an existing project. Choose File \> New
\> Target, select macOS, then select Instruments Package under Other.

::: LinkUniversal
**See also**[Create an instrument based on signpost
data](devbe5c72066.html#devbe5c72066){.xRef .AppleTopic}
:::
