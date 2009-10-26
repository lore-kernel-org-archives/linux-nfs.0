From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] nfs-utils: introduce new statd testing simulator
Date: Mon, 26 Oct 2009 08:52:44 -0400
Message-ID: <1256561565-5909-2-git-send-email-jlayton@redhat.com>
References: <1256561565-5909-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63790 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974AbZJZMwm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Oct 2009 08:52:42 -0400
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9QCqlUl018549
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2009 08:52:47 -0400
Received: from localhost.localdomain (vpn-10-19.rdu.redhat.com [10.11.10.19])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9QCqj0T021864
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2009 08:52:46 -0400
In-Reply-To: <1256561565-5909-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc.statd is often prone to subtle, difficult to detect breakage. When
it has problems, they're often invisible and only manifest themselves
as failed lock recovery.

This program is intended to function as part of a test harness for
statd. It's a multicall binary that serves as a synthetic NSM client
program, and a daemon that can simulate lockd for purposes of testing
the NSM to NLM downcall.

A new top level "tests/" directory is also added to nfs-utils to start
as a repository for automated tests of nfs-utils components.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 Makefile.am                    |    2 +-
 configure.ac                   |    4 +-
 tests/Makefile.am              |    5 +
 tests/statdtest/Makefile.am    |   45 ++++
 tests/statdtest/README         |   12 +
 tests/statdtest/nlm_sm_inter.x |   43 ++++
 tests/statdtest/statdtest.c    |  462 ++++++++++++++++++++++++++++++++++++++++
 7 files changed, 571 insertions(+), 2 deletions(-)
 create mode 100644 tests/Makefile.am
 create mode 100644 tests/statdtest/Makefile.am
 create mode 100644 tests/statdtest/README
 create mode 100644 tests/statdtest/nlm_sm_inter.x
 create mode 100644 tests/statdtest/statdtest.c

diff --git a/Makefile.am b/Makefile.am
index b3a6e91..ae7cd16 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -2,7 +2,7 @@
 
 AUTOMAKE_OPTIONS = foreign
 
-SUBDIRS = tools support utils linux-nfs
+SUBDIRS = tools support utils linux-nfs tests
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/configure.ac b/configure.ac
index d8ba6b3..ae91615 100644
--- a/configure.ac
+++ b/configure.ac
@@ -418,6 +418,8 @@ AC_CONFIG_FILES([
 	utils/nfsd/Makefile
 	utils/nfsstat/Makefile
 	utils/showmount/Makefile
-	utils/statd/Makefile])
+	utils/statd/Makefile
+	tests/Makefile
+	tests/statdtest/Makefile])
 AC_OUTPUT
 
diff --git a/tests/Makefile.am b/tests/Makefile.am
new file mode 100644
index 0000000..997ac51
--- /dev/null
+++ b/tests/Makefile.am
@@ -0,0 +1,5 @@
+## Process this file with automake to produce Makefile.in
+
+SUBDIRS = statdtest
+
+MAINTAINERCLEANFILES = Makefile.in
diff --git a/tests/statdtest/Makefile.am b/tests/statdtest/Makefile.am
new file mode 100644
index 0000000..f7fc48f
--- /dev/null
+++ b/tests/statdtest/Makefile.am
@@ -0,0 +1,45 @@
+## Process this file with automake to produce Makefile.in
+
+GENFILES_CLNT	= nlm_sm_inter_clnt.c
+GENFILES_SVC	= nlm_sm_inter_svc.c
+GENFILES_XDR	= nlm_sm_inter_xdr.c
+GENFILES_H	= nlm_sm_inter.h
+
+GENFILES	= $(GENFILES_CLNT) $(GENFILES_SVC) $(GENFILES_XDR) $(GENFILES_H)
+
+
+check_PROGRAMS	= statdtest
+statdtest_SOURCES = $(GENFILES) statdtest.c
+
+BUILT_SOURCES = $(GENFILES)
+statdtest_LDADD = ../../support/nfs/libnfs.a \
+		       ../../support/nsm/libnsm.a
+
+if CONFIG_RPCGEN
+RPCGEN	= $(top_builddir)/tools/rpcgen/rpcgen
+$(RPCGEN):
+	make -C ../../tools/rpcgen all
+else
+RPCGEN = @RPCGEN_PATH@
+endif
+
+$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN)
+	test -f $@ && rm -rf $@ || true
+	$(RPCGEN) -l -o $@ $<
+
+$(GENFILES_SVC): %_svc.c: %.x $(RPCGEN)
+	test -f $@ && rm -rf $@ || true
+	$(RPCGEN) -m -o $@ $<
+
+$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
+	test -f $@ && rm -rf $@ || true
+	$(RPCGEN) -c -o $@ $<
+
+$(GENFILES_H): %.h: %.x $(RPCGEN)
+	test -f $@ && rm -rf $@ || true
+	$(RPCGEN) -h -o $@ $<
+
+MAINTAINERCLEANFILES = Makefile.in
+
+CLEANFILES = $(GENFILES)
+
diff --git a/tests/statdtest/README b/tests/statdtest/README
new file mode 100644
index 0000000..034fbba
--- /dev/null
+++ b/tests/statdtest/README
@@ -0,0 +1,12 @@
+The statdtest program is a multicall binary intended for testing statd.
+It has the ability to act as a synthetic NSM client for sending
+artificial NSM calls to any host you choose.
+
+It also has an NLM simulator that implements the call that statd uses to
+communicate with lockd. The daemon simulator will start itself up,
+register as an NLM service and listen for upcalls from statd. When it
+gets one, it will log a message.
+
+Note that lockd will need to be down when using the daemon simulator, it
+also does not implement the entire NLM protocol and is only really
+useful for testing statd.
diff --git a/tests/statdtest/nlm_sm_inter.x b/tests/statdtest/nlm_sm_inter.x
new file mode 100644
index 0000000..d62e09c
--- /dev/null
+++ b/tests/statdtest/nlm_sm_inter.x
@@ -0,0 +1,43 @@
+/*
+ * Copyright (C) 1995, 1997-1999 Jeffrey A. Uphoff
+ * Modified by Olaf Kirch, 1996.
+ * Modified by H.J. Lu, 1998.
+ * Modified by Jeff Layton, 2009.
+ *
+ * NLM similator for Linux
+ */
+
+#ifdef RPC_CLNT
+%#include <string.h>
+#endif
+
+/*
+ * statd rejects monitor registrations for any non-lockd services, so pretend
+ * to be lockd when testing. Furthermore, the only call we care about from
+ * statd is #16, which is the downcall to notify the kernel of a host's status
+ * change.
+ */
+program NLM_SM_PROG { 
+	/* version 3 of the NLM protocol */
+	version NLM_SM_VERS3 {
+		void	 NLM_SM_NOTIFY(struct nlm_sm_notify) = 16;
+	} = 3;
+
+	/* version 2 of NLM protocol */
+	version NLM_SM_VERS4 {
+		void	 NLM_SM_NOTIFY(struct nlm_sm_notify) = 16;
+	} = 4;
+} = 100021;
+
+const  SM_MAXSTRLEN = 1024;
+const  SM_PRIV_SIZE = 16;
+
+/*
+ * structure of the status message sent back by the status monitor
+ * when monitor site status changes
+ */
+struct nlm_sm_notify {
+	string mon_name<SM_MAXSTRLEN>;
+	int state;
+	opaque priv[SM_PRIV_SIZE]; /* stored private information */
+};
diff --git a/tests/statdtest/statdtest.c b/tests/statdtest/statdtest.c
new file mode 100644
index 0000000..790823c
--- /dev/null
+++ b/tests/statdtest/statdtest.c
@@ -0,0 +1,462 @@
+/*
+ * statdtest.c -- multicall binary for testing statd
+ *
+ * Copyright (C) 2009  Red Hat, Jeff Layton <jlayton@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor,
+ * Boston, MA 02110-1301, USA.
+ *
+ * Very loosely based on "simulator.c" in the statd directory. Original
+ * copyright for that program follows:
+ *
+ * Copyright (C) 1995-1997, 1999 Jeffrey A. Uphoff
+ */
+
+#ifdef HAVE_CONFIG_H
+#include "config.h"
+#endif
+
+#include <errno.h>
+#include <getopt.h>
+#include <netdb.h>
+#include <signal.h>
+#include <string.h>
+#include <rpc/rpc.h>
+#include <rpc/pmap_clnt.h>
+#include <rpcmisc.h>
+#include <sys/socket.h>
+#include <sys/types.h>
+#include <unistd.h>
+#include "nfslib.h"
+#include "nfsrpc.h"
+#include "sm_inter.h"
+#include "nlm_sm_inter.h"
+#include "xcommon.h"
+
+static void daemon_simulator(void);
+static void sim_killer(int sig);
+static int statdtest_crash(char *);
+static int statdtest_mon(char *, char *, char *, char *, int, int);
+static int statdtest_stat(char *, char *);
+static int statdtest_notify(char *, char *, char *);
+static int statdtest_unmon(char *, char *, char *, int, int);
+static int statdtest_unmon_all(char *, char *, int, int);
+
+extern void nlm_sm_prog_4(struct svc_req *rqstp, register SVCXPRT *transp);
+extern void svc_exit(void);
+
+/*
+ * default to 15 retransmit interval, which seems to be the default for
+ * UDP clients w/ legacy glibc RPC
+ */
+static struct timeval retrans_interval =
+{
+	.tv_sec = 15,
+};
+
+static struct option longopts[] =
+{
+	{ "help", 0, 0, 'h' },
+	{ "host", 0, 0, 'H' },
+	{ "name", 1, 0, 'n' },
+	{ "program", 1, 0, 'P' },
+	{ "version", 1, 0, 'v' },
+	{ NULL, 0, 0, 0 },
+};
+
+static int
+usage(char *program)
+{
+	printf("Usage:\n");
+	printf("%s [options] <command> [arg]...\n", program);
+	printf("where command is one of these with the specified args:\n");
+	printf("crash\t\t\t\ttell host to simulate crash\n");
+	printf("daemon\t\t\t\t\tstart up lockd daemon simulator\n");
+	printf("notify <mon_name> <state>\tsend a reboot notification to host\n");
+	printf("stat <mon_name>\t\t\tget status of <mon_name> on host\n");
+	printf("unmon_all\t\t\ttell host to unmon everything\n");
+	printf("unmon <mon_name>\t\t\ttell host to unmon <mon_name>\n");
+	printf("mon <mon_name> <cookie>\t\ttell host to monitor <mon_name> with private <cookie>\n");
+	return 1;
+}
+
+static int
+hex2bin(char *dst, size_t dstlen, char *src)
+{
+	int i;
+	unsigned int tmp;
+
+	for (i = 0; *src && i < dstlen; i++) {
+		if (sscanf(src, "%2x", &tmp) != 1)
+			return 0;
+		dst[i] = tmp;
+		src++;
+		if (!*src)
+			break;
+		src ++;
+	}
+
+	return 1;
+}
+
+static void
+bin2hex(char *dst, char *src, size_t srclen)
+{
+	int i;
+
+	for (i = 0; i < srclen; i++)
+		dst += sprintf(dst, "%02x", 0xff & src[i]);
+}
+
+int
+main(int argc, char **argv)
+{
+	int arg, err = 0;
+	int remaining_args;
+	char my_name[NI_MAXHOST], host[NI_MAXHOST];
+	char cookie[SM_PRIV_SIZE];
+	int my_prog = NLM_SM_PROG;
+	int my_vers = NLM_SM_VERS4;
+
+	my_name[0] = '\0';
+	host[0] = '\0';
+
+	while ((arg = getopt_long(argc, argv, "hHn:P:v:", longopts,
+				  NULL)) != EOF ) {
+		switch (arg) {
+		case 'H':
+			strncpy(host, optarg, sizeof(host));
+		case 'n':
+			strncpy(my_name, optarg, sizeof(my_name));
+		case 'P':
+			my_prog = atoi(optarg);
+		case 'v':
+			my_vers = atoi(optarg);
+		}
+	}
+
+	remaining_args = argc - optind;
+	if (remaining_args <= 0)
+		usage(argv[0]);
+
+	if (!my_name[0])
+		gethostname(my_name, sizeof(my_name));
+	if (!host[0])
+		strncpy(host, "127.0.0.1", sizeof(host));
+
+	if (!strcasecmp(argv[optind], "daemon")) {
+		daemon_simulator();
+	} else if (!strcasecmp(argv[optind], "crash")) {
+		err = statdtest_crash(host);
+	} else if (!strcasecmp(argv[optind], "stat")) {
+		if (remaining_args < 2)
+			usage(argv[0]);
+		err = statdtest_stat(host, argv[optind + 2]);
+	} else if (!strcasecmp(argv[optind], "unmon_all")) {
+		err = statdtest_unmon_all(host, my_name, my_prog, my_vers);
+	} else if (!strcasecmp(argv[optind], "unmon")) {
+		if (remaining_args < 2)
+			usage(argv[0]);
+		err = statdtest_unmon(host, argv[optind + 1], my_name, my_prog,
+					my_vers);
+	} else if (!strcasecmp(argv[optind], "notify")) {
+		if (remaining_args < 2)
+			usage(argv[0]);
+		err = statdtest_notify(host, argv[optind + 1],
+					argv[optind + 2]);
+	} else if (!strcasecmp(argv[optind], "mon")) {
+		if (remaining_args < 2)
+			usage(argv[0]);
+
+		memset(cookie, '\0', SM_PRIV_SIZE);
+		if (!hex2bin(cookie, sizeof(cookie), argv[optind + 2])) {
+			fprintf(stderr, "SYS:%d\n", EINVAL);
+			printf("Unable to convert hex cookie %s to binary.\n",
+				argv[optind + 2]);
+			return 1;
+		}
+
+		err = statdtest_mon(host, argv[optind + 1], cookie, my_name,
+					my_prog, my_vers);
+	} else {
+		err = usage(argv[0]);
+	}
+
+	return err;
+}
+
+static CLIENT *
+statdtest_get_rpcclient(const char *node)
+{
+	unsigned short		port;
+	struct addrinfo		*ai;
+	struct addrinfo		hints = { .ai_flags	= AI_ADDRCONFIG };
+	int			err;
+	CLIENT			*client = NULL;
+
+#ifndef IPV6_ENABLED
+	hints.ai_family	= AF_INET;
+#endif /* IPV6_ENABLED */
+
+	/* FIXME: allow support for providing port? */
+	err = getaddrinfo(node, NULL, &hints, &ai);
+	if (err) {
+		fprintf(stderr, "EAI:%d\n", err);
+		if (err == EAI_SYSTEM)
+			fprintf(stderr, "SYS:%d\n", errno);
+		printf("Unable to translate host to address: %s\n",
+			err == EAI_SYSTEM ? strerror(errno) :
+			gai_strerror(err));
+		return client;
+	}
+
+	/* FIXME: allow for TCP too? */
+	port = nfs_getport(ai->ai_addr, ai->ai_addrlen, SM_PROG,
+			   SM_VERS, IPPROTO_UDP);
+	if (!port) {
+		fprintf(stderr, "RPC:%d\n", rpc_createerr.cf_stat);
+		printf("Unable to determine port for service\n");
+		goto out;
+	}
+
+	nfs_set_port(ai->ai_addr, port);
+
+	client = nfs_get_rpcclient(ai->ai_addr, ai->ai_addrlen, IPPROTO_UDP,
+				   SM_PROG, SM_VERS, &retrans_interval);
+	if (!client) {
+		fprintf(stderr, "RPC:%d\n", rpc_createerr.cf_stat);
+		printf("RPC client creation failed\n");
+	}
+out:
+	freeaddrinfo(ai);
+	return client;
+}
+
+static int
+statdtest_mon(char *calling, char *monitoring, char *cookie, char *my_name,
+		int my_prog, int my_vers)
+{
+	CLIENT *client;
+	sm_stat_res *result;
+	mon mon;
+	int err = 0;
+
+	printf("Calling %s (as %s) to monitor %s\n", calling, my_name,
+		monitoring);
+
+	if ((client = statdtest_get_rpcclient(calling)) == NULL)
+		return 1;
+
+	memcpy(mon.priv, cookie, SM_PRIV_SIZE);
+	mon.mon_id.my_id.my_name = my_name;
+	mon.mon_id.my_id.my_prog = my_prog;
+	mon.mon_id.my_id.my_vers = my_vers;
+	mon.mon_id.my_id.my_proc = NLM_SM_NOTIFY;
+	mon.mon_id.mon_name = monitoring;
+
+	if (!(result = sm_mon_1(&mon, client))) {
+		fprintf(stderr, "RPC:%d\n", rpc_createerr.cf_stat);
+		printf("%s\n", clnt_sperror(client, "sm_mon_1"));
+		err = 1;
+		goto mon_out;
+	}
+
+	printf("SM_MON request %s, state: %d\n",
+		result->res_stat == stat_succ ? "successful" : "failed",
+		result->state);
+
+	if (result->res_stat != stat_succ) {
+		fprintf(stderr, "RPC:%d\n", rpc_createerr.cf_stat);
+		err = 1;
+	}
+
+mon_out:
+	clnt_destroy(client);
+	return err;
+}
+
+static int
+statdtest_unmon(char *calling, char *unmonitoring, char *my_name, int my_prog,
+		int my_vers)
+{
+	CLIENT *client;
+	sm_stat *result;
+	mon_id mon_id;
+	int err = 0;
+
+	printf("Calling %s (as %s) to unmonitor %s\n", calling, my_name,
+		unmonitoring);
+
+	if ((client = statdtest_get_rpcclient(calling)) == NULL)
+		return 1;
+
+	mon_id.my_id.my_name = my_name;
+	mon_id.my_id.my_prog = my_prog;
+	mon_id.my_id.my_vers = my_vers;
+	mon_id.my_id.my_proc = NLM_SM_NOTIFY;
+	mon_id.mon_name = unmonitoring;
+
+	if (!(result = sm_unmon_1(&mon_id, client))) {
+		fprintf(stderr, "RPC:%d\n", rpc_createerr.cf_stat);
+		printf("%s\n", clnt_sperror(client, "sm_unmon_1"));
+		err = 1;
+		goto unmon_out;
+	}
+
+	printf("SM_UNMON state: %d\n", result->state);
+
+unmon_out:
+	clnt_destroy(client);
+	return err;
+}
+
+static int
+statdtest_unmon_all(char *calling, char *my_name, int my_prog, int my_vers)
+{
+	CLIENT *client;
+	sm_stat *result;
+	my_id my_id;
+	int err = 0;
+
+	printf("Calling %s (as %s) to unmonitor all hosts\n", calling, my_name);
+
+	if ((client = statdtest_get_rpcclient(calling)) == NULL) {
+		printf("RPC client creation failed\n");
+		return 1;
+	}
+
+	my_id.my_name = my_name;
+	my_id.my_prog = my_prog;
+	my_id.my_vers = my_vers;
+	my_id.my_proc = NLM_SM_NOTIFY;
+
+	if (!(result = sm_unmon_all_1(&my_id, client))) {
+		fprintf(stderr, "RPC:%d\n", rpc_createerr.cf_stat);
+		printf("%s\n", clnt_sperror(client, "sm_unmon_all_1"));
+		err = 1;
+		goto unmon_all_out;
+	}
+
+	printf("SM_UNMON_ALL state: %d\n", result->state);
+
+unmon_all_out:
+	return err;
+}
+
+static int
+statdtest_crash(char *host)
+{
+	CLIENT *client;
+
+	if ((client = statdtest_get_rpcclient(host)) == NULL)
+		return 1;
+
+	if (!sm_simu_crash_1(NULL, client)) {
+		fprintf(stderr, "RPC:%d\n", rpc_createerr.cf_stat);
+		printf("%s\n", clnt_sperror(client, "sm_simu_crash_1"));
+		return 1;
+	}
+
+	return 0;
+}
+
+static int
+statdtest_stat(char *calling, char *monitoring)
+{
+	CLIENT *client;
+	sm_name checking;
+	sm_stat_res *result;
+
+	if ((client = statdtest_get_rpcclient(calling)) == NULL)
+		return 1;
+
+	checking.mon_name = monitoring;
+
+	if (!(result = sm_stat_1(&checking, client))) {
+		fprintf(stderr, "RPC:%d\n", rpc_createerr.cf_stat);
+		printf("%s\n", clnt_sperror(client, "sm_stat_1"));
+		return 1;
+	}
+
+	if (result->res_stat != stat_succ) {
+		fprintf(stderr, "RPC:%d\n", rpc_createerr.cf_stat);
+		printf("stat_fail from %s for %s, state: %d\n", calling,
+			monitoring, result->state);
+		return 1;
+	}
+
+	printf("stat_succ from %s for %s, state: %d\n", calling,
+		monitoring, result->state);
+
+	return 0;
+}
+
+static int
+statdtest_notify(char *calling, char *mon_name, char *statestr)
+{
+	CLIENT *client;
+
+	stat_chge stat_chge = { .mon_name	= mon_name };
+
+	stat_chge.state = atoi(statestr);
+
+	if ((client = statdtest_get_rpcclient(calling)) == NULL)
+		return 1;
+
+	if (!sm_notify_1(&stat_chge, client)) {
+		fprintf(stderr, "RPC:%d\n", rpc_createerr.cf_stat);
+		printf("%s\n", clnt_sperror(client, "sm_notify_1"));
+		return 1;
+	}
+
+	return 0;
+}
+
+static void sim_killer(int sig)
+{
+#ifdef HAVE_LIBTIRPC
+	(void)rpcb_unset(NLM_SM_PROG, NLM_SM_VERS4, NULL);
+#else
+	(void)pmap_unset(NLM_SM_PROG, NLM_SM_VERS4);
+#endif
+	exit(0);
+}
+
+static void daemon_simulator(void)
+{
+	signal(SIGHUP, sim_killer);
+	signal(SIGINT, sim_killer);
+	signal(SIGTERM, sim_killer);
+	/* FIXME: allow for different versions? */
+	nfs_svc_create("nlmsim", NLM_SM_PROG, NLM_SM_VERS4, nlm_sm_prog_4, 0);
+	svc_run();
+}
+
+void *nlm_sm_notify_4_svc(struct nlm_sm_notify *argp, struct svc_req *rqstp)
+{
+	static char *result;
+	char	    priv[SM_PRIV_SIZE * 2 + 1];
+
+	bin2hex(priv, argp->priv, SM_PRIV_SIZE);
+
+	printf("state=%d:mon_name=%s:private=%s\n", argp->state,
+		argp->mon_name, priv);
+	return ((void *)&result);
+}
+
+void *nlm_sm_notify_3_svc(struct nlm_sm_notify *argp, struct svc_req *rqstp)
+{
+	return nlm_sm_notify_4_svc(argp, rqstp);
+}
-- 
1.6.2.5

