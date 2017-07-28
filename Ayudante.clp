
;;;======================================================
;;;   	Ayudante de Celular
;;;
;;;     Este sistema funciona como cortana o siri, dando indicaciones o
;;;     generando una conversacion
;;;
;;;     Para ejecutar cargue el buffer, resetee y corralo.
;;;======================================================

;;****************************
;;* DDEFINICION DE FUNCIONES *
;;****************************

(deffunction preguntar (?pregunta $?valores-aceptados)
   (printout t ?pregunta)
   (bind ?respuesta (read))
   (if (lexemep ?respuesta) 
       then (bind ?respuesta (lowcase ?respuesta)))
   (while (not (member ?respuesta ?valores-aceptados)) do
      (printout t ?pregunta)
      (bind ?respuesta (read))
      (if (lexemep ?respuesta) 
          then (bind ?respuesta (lowcase ?respuesta))))
   ?respuesta)

(deffunction si-no (?pregunta)
   (bind ?respues (preguntar ?pregunta si no s n))
   (if (or (eq ?respues si) (eq ?respues s))
       then si 
       else no))

;;;***************
;;;* QUERY RULES *
;;;***************
   
(defrule determinar-estado-animo ""
   (estas-bien si)
   (not (aconsejar ?))
   =>
   (assert (esta-bien (si-no "Te encuentras bien (si/no)? "))))


(defrule determinar-suenio ""
   (estas-bien no)
   (not (aconsejar ?))   
   =>
   (assert (esta-bien (si-no "Dormiste bien (si/no)? "))))
   
(defrule determine-sluggishness ""
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-sluggish (yes-or-no-p "Is the engine sluggish (yes/no)? "))))
   
(defrule determine-misfiring ""
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-misfires (yes-or-no-p "Does the engine misfire (yes/no)? "))))

(defrule determine-knocking ""
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-knocks (yes-or-no-p "Does the engine knock (yes/no)? "))))

(defrule determine-low-output ""
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-output-low
               (yes-or-no-p "Is the output of the engine low (yes/no)? "))))

(defrule determine-gas-level ""
   (engine-starts no)
   (engine-rotates yes)
   (not (repair ?))
   =>
   (assert (tank-has-gas
              (yes-or-no-p "Does the tank have any gas in it (yes/no)? "))))

(defrule determine-battery-state ""
   (engine-rotates no)
   (not (repair ?))
   =>
   (assert (battery-has-charge
              (yes-or-no-p "Is the battery charged (yes/no)? "))))

(defrule determine-point-surface-state ""
   (or (and (engine-starts no)      
            (engine-rotates yes))
       (engine-output-low yes))
   (not (repair ?))
   =>
   (assert (point-surface-state
      (ask-question "What is the surface state of the points (normal/burned/contaminated)? "
                    normal burned contaminated))))

(defrule determine-conductivity-test ""
   (engine-starts no)      
   (engine-rotates no)
   (battery-has-charge yes)
   (not (repair ?))
   =>
   (assert (conductivity-test-positive
              (yes-or-no-p "Is the conductivity test for the ignition coil positive (yes/no)? "))))

;;;****************
;;;* REPAIR RULES *
;;;****************

(defrule normal-engine-state-conclusions ""
   (runs-normally yes)
   (not (repair ?))
   =>
   (assert (repair "No repair needed.")))

(defrule engine-sluggish ""
   (engine-sluggish yes)
   (not (repair ?))
   =>
   (assert (repair "Clean the fuel line."))) 

(defrule engine-misfires ""
   (engine-misfires yes)
   (not (repair ?))
   =>
   (assert (repair "Point gap adjustment.")))     

(defrule engine-knocks ""
   (engine-knocks yes)
   (not (repair ?))
   =>
   (assert (repair "Timing adjustment.")))

(defrule tank-out-of-gas ""
   (tank-has-gas no)
   (not (repair ?))
   =>
   (assert (repair "Add gas.")))

(defrule battery-dead ""
   (battery-has-charge no)
   (not (repair ?))
   =>
   (assert (repair "Charge the battery.")))

(defrule point-surface-state-burned ""
   (point-surface-state burned)
   (not (repair ?))
   =>
   (assert (repair "Replace the points.")))

(defrule point-surface-state-contaminated ""
   (point-surface-state contaminated)
   (not (repair ?))
   =>
   (assert (repair "Clean the points.")))

(defrule conductivity-test-positive-yes ""
   (conductivity-test-positive yes)
   (not (repair ?))
   =>
   (assert (repair "Repair the distributor lead wire.")))

(defrule conductivity-test-positive-no ""
   (conductivity-test-positive no)
   (not (repair ?))
   =>
   (assert (repair "Replace the ignition coil.")))

(defrule no-repairs ""
  (declare (salience -10))
  (not (repair ?))
  =>
  (assert (repair "Take your car to a mechanic.")))

;;;********************************
;;;* STARTUP AND CONCLUSION RULES *
;;;********************************

(defrule system-banner ""
  (declare (salience 10))
  =>
  (printout t crlf crlf)
  (printout t "The Engine Diagnosis Expert System")
  (printout t crlf crlf))

(defrule print-repair ""
  (declare (salience 10))
  (repair ?item)
  =>
  (printout t crlf crlf)
  (printout t "Suggested Repair:")
  (printout t crlf crlf)
  (format t " %s%n%n%n" ?item))

