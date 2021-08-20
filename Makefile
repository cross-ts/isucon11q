APPLICATION_NAME := app_name
LANGUAGE := ruby

COMMON_SERVER := isucon1

.PHONY: monitor
monitor:
	@ssh $(COMMON_SERVER) "sudo systemctl list-unit-files --type service" | tee monitor/results/list-unit-files.txt
	@ssh $(COMMON_SERVER) "ps auxf" | tee monitor/results/ps-aufx.txt
	@ssh $(COMMON_SERVER) "lscpu" | tee monitor/results/lscpu.txt
	@ssh $(COMMON_SERVER) "free -h" | tee monitor/results/free.txt
	@ssh $(COMMON_SERVER) "sudo sysctl -a" | tee monitor/results/sysctl.txt

.PHONY: alp
alp:
	@ssh $(COMMON_SERVER) "sudo alp -c /home/isucon/git/monitor/config/alp.yml ltsv" | tee monitor/results/alp.md

.PHONY: pt
pt:
	@ssh $(COMMON_SERVER) "sudo pt-query-digest /var/log/mysql/slow.log" | tee monitor/results/pt-query-digest.txt

.PHONY: clean
clean:
	@ssh $(COMMON_SERVER) ": | sudo tee /var/log/mysql/slow.log"
	@ssh $(COMMON_SERVER) ": | sudo tee /var/log/nginx/access.log"
	@ssh $(COMMON_SERVER) "ls /home/isucon/stackprof | xargs -IXXX sudo rm -fr /home/isucon/stackprof/"
	@ssh $(COMMON_SERVER) "ls /dev/shm/ | xargs -IXXX sudo rm -fr /dev/shm/XXX"
	@ssh $(COMMON_SERVER) "sudo systemctl restart nginx"

.PHONY: log
log:
	@ssh $(COMMON_SERVER) "sudo journalctl -f -u $(APPLICATION_NAME).$(LANGUAGE)"

.PHONY: ansible
ansible:
	@ansible-playbook \
		-i ansible/inventory/host \
		ansible/playbook.yml

.PHONY: deploy
deploy:
	@ansible-playbook \
		-i deploy/inventory/host \
		deploy/playbook.yml
