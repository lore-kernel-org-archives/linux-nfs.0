Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42760 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675AbaBTGjK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:39:10 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:36:48 +1100
Subject: [PATCH 4/4] statd: add options to set port number of lockd.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220063648.6548.77075.stgit@notabene.brown>
In-Reply-To: <20140220063616.6548.42556.stgit@notabene.brown>
References: <20140220063616.6548.42556.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Even though lockd is a totally separate process to statd, they
depended on each other: statd much be running for lockd to be useful.
So an easy way to set the port numbers used by lockd is to get statd
to set them.
This patch add --nlm-port and --nlm-tcp-port to that end.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/statd/statd.c   |   57 ++++++++++++++++++++++++++++++++++++++++++++++---
 utils/statd/statd.man |   24 +++++++++++++++++++--
 2 files changed, 76 insertions(+), 5 deletions(-)

diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 8f3111173887..51a016e935e1 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -60,6 +60,8 @@ static struct option longopts[] =
 	{ "notify-mode", 0, 0, 'N' },
 	{ "ha-callout", 1, 0, 'H' },
 	{ "no-notify", 0, 0, 'L' },
+	{ "nlm-port", 1, 0, 'T'},
+	{ "nlm-udp-port", 1, 0, 'U'},
 	{ NULL, 0, 0, 0 }
 };
 
@@ -209,7 +211,32 @@ static void run_sm_notify(int outport)
 	exit(2);
 
 }
-/* 
+
+static void set_nlm_port(char *type, int port)
+{
+	char nbuf[20];
+	char pathbuf[40];
+	int fd;
+	if (!port)
+		return;
+	snprintf(nbuf, sizeof(nbuf), "%d", port);
+	snprintf(pathbuf, sizeof(pathbuf), "/proc/sys/fs/nfs/nlm_%sport", type);
+	fd = open(pathbuf, O_WRONLY);
+	if (fd < 0 && errno == ENOENT) {
+		/* probably module not loaded */
+		system("modprobe lockd");
+		fd = open(pathbuf, O_WRONLY);
+	}
+	if (fd >= 0) {
+		if (write(fd, nbuf, strlen(nbuf)) != (ssize_t)strlen(nbuf))
+			fprintf(stderr, "%s: fail to set NLM %s port: %m\n",
+				name_p, type);
+		close(fd);
+	} else
+		fprintf(stderr, "%s: failed to open %s: %m\n", name_p, pathbuf);
+}
+
+/*
  * Entry routine/main loop.
  */
 int main (int argc, char **argv)
@@ -218,6 +245,7 @@ int main (int argc, char **argv)
 	int pid;
 	int arg;
 	int port = 0, out_port = 0;
+	int nlm_udp = 0, nlm_tcp = 0;
 	struct rlimit rlim;
 
 	int pipefds[2] = { -1, -1};
@@ -239,7 +267,7 @@ int main (int argc, char **argv)
 	MY_NAME = NULL;
 
 	/* Process command line switches */
-	while ((arg = getopt_long(argc, argv, "h?vVFNH:dn:p:o:P:L", longopts, NULL)) != EOF) {
+	while ((arg = getopt_long(argc, argv, "h?vVFNH:dn:p:o:P:LT:U:", longopts, NULL)) != EOF) {
 		switch (arg) {
 		case 'V':	/* Version */
 		case 'v':
@@ -275,6 +303,26 @@ int main (int argc, char **argv)
 				exit(1);
 			}
 			break;
+		case 'T': /* NLM TCP and UDP port */
+			nlm_tcp = atoi(optarg);
+			if (nlm_tcp < 1 || nlm_tcp > 65535) {
+				fprintf(stderr, "%s: bad nlm port number: %s\n",
+					argv[0], optarg);
+				usage();
+				exit(1);
+			}
+			if (nlm_udp == 0)
+				nlm_udp = nlm_tcp;
+			break;
+		case 'U': /* NLM  UDP port */
+			nlm_udp = atoi(optarg);
+			if (nlm_udp < 1 || nlm_udp > 65535) {
+				fprintf(stderr, "%s: bad nlm UDP port number: %s\n",
+					argv[0], optarg);
+				usage();
+				exit(1);
+			}
+			break;
 		case 'n':	/* Specify local hostname */
 			run_mode |= STATIC_HOSTNAME;
 			MY_NAME = xstrdup(optarg);
@@ -337,12 +385,15 @@ int main (int argc, char **argv)
 		}
 	}
 
+	set_nlm_port("tcp", nlm_tcp);
+	set_nlm_port("udp", nlm_udp);
+
 #ifdef SIMULATIONS
 	if (argc > 1)
 		/* LH - I _really_ need to update simulator... */
 		simulator (--argc, ++argv);	/* simulator() does exit() */
 #endif
-	
+
 	if (!(run_mode & MODE_NODAEMON)) {
 		int tempfd;
 
diff --git a/utils/statd/statd.man b/utils/statd/statd.man
index c3c53548f35d..896c2f8a98ce 100644
--- a/utils/statd/statd.man
+++ b/utils/statd/statd.man
@@ -12,7 +12,11 @@
 .SH NAME
 rpc.statd \- NSM service daemon
 .SH SYNOPSIS
-.BI "rpc.statd [-dh?FLNvV] [-H " prog "] [-n " my-name "] [-o " outgoing-port "] [-p " listener-port "] [-P " path " ]
+.BI "rpc.statd [-dh?FLNvV] [-H " prog "] [-n " my-name "] [-o " outgoing-port ]
+.ti +10
+.BI "[-p " listener-port "] [-P " path ]
+.ti +10
+.BI "[--nlm-port " port "] [--nlm-udp-port " port ]
 .SH DESCRIPTION
 File locks are not part of persistent file system state.
 Lock state is thus lost when a host reboots.
@@ -225,7 +229,23 @@ if gets port succeed, set the same port for all listener socket,
 otherwise chooses a random ephemeral port for each listener socket.
 .IP
 This option can be used to fix the port value of its listeners when
-SM_NOTIFY requests must traverse a firewall between clients and servers.
+SM_NOTIFY requests must traverse a firewall between clients and
+servers.
+.TP
+.BI "\-T," "" " \-\-nlm\-port " port
+Specifies the port number that
+.I lockd
+should listen on for
+.B NLM
+requests.  This sets both the TCP and UDP ports unless the UDP port is
+set separately.
+.TP
+.BI "\-U," "" " \-\-nlm\-udp\-port " port
+Specifies the UDP port number that
+.I lockd
+should listen on for
+.B NLM
+requests.
 .TP
 .BI "\-P, " "" \-\-state\-directory\-path " pathname
 Specifies the pathname of the parent directory


