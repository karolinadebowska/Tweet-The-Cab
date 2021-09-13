function toggle(x) {
	var y = document.getElementById("navbar");
	if (x.className === "hamburger") {
        x.classList.add("change");
		y.classList.add("dropdown");
    } else {
        x.classList.remove("change");
		y.classList.remove("dropdown");
    }
	console.log(x);
}
