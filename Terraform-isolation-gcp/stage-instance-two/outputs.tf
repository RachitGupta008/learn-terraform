
//this is a way to reference output variables from a remote state
output "Remote-state-1" {
  value = data.terraform_remote_state.state-instance-1.outputs.instance-details2
}