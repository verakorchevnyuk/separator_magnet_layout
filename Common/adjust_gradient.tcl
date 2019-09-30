Octave {
    AI = placet_get_number_list("FLASH", "cavity");
    placet_element_set_attribute("FLASH", AI, "six_dim", true);
    placet_element_set_attribute("FLASH", AI, "short_range_wake", "SPARC_cav_SR");

    function E = final_energy(gradient)
      AI = placet_get_number_list("FLASH", "cavity");
      placet_element_set_attribute("FLASH", AI, "gradient", gradient);
      [E,B] = placet_test_no_correction("FLASH", "beam0", "None");
      E = mean(B(:,1))
    end

    gradient = fminbnd(@(X) abs($energy / 1e3 - final_energy(X)), 0.020, 0.040)
    placet_element_set_attribute("FLASH", AI, "gradient", gradient);
}
