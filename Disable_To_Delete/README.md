# Disable to Delete Process
Multiple scripts to monitor for stale Active Directory user objects</br>

<strong>Stale Group Objects</strong></br>
1.) Identify AD group objects that have not been modified i.e. users added or removed for a set duration</br>
2.) Rename stale AD group objects and move them to a holding OU</br>
3.) Identify stale AD group objects in the holding OU and then delete them if not modified for a set duration of time</br>

<strong>Stale User Objects</strong></br>
1.) Identify AD user obejects that have not logged in or had a password reset for a set duration</br>
2.) Disable stale AD user objects and move them to a holding OU</br>
3.) Identify stale AD user objects in the holding OU and then delete them if not modified for a set duration of time</br>
</br>
</br>
Similar processes could be implemented for computer obects, Exchange accounts, etc.
