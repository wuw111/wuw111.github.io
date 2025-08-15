$(document).ready(function()
{
    $(".loading-screen").fadeOut();
    
    $(window).scroll(function()
    {
        if ($(this).scrollTop() > $(".banner").height())
            $(".navbar").addClass("scrolled");
        else
            $(".navbar").removeClass("scrolled");
    });
    
    $(window).trigger('scroll');
});