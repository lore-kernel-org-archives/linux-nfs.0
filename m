Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43967 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752876AbcLHE2L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:28:11 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:25 +1100
Subject: [PATCH 04/10] nfsd: add /etc/nfs.conf support for host=
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117124502.31271.12007658221918580352.stgit@noble>
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A comma separate list of hosts can be given.
If any host name is given with "--host" or "-H", then all hosts
listed in nfs.conf are ignored.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/nfs.conf.man |    1 +
 utils/nfsd/nfsd.c    |   15 +++++++++++++++
 utils/nfsd/nfsd.man  |    7 +++++++
 3 files changed, 23 insertions(+)

diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 23aa4ea7d2f9..2713bb06c6ed 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -104,6 +104,7 @@ for details.
 .B nfsd
 Recognized values:
 .BR threads ,
+.BR host ,
 .BR port ,
 .BR grace-time ,
 .BR lease-time ,
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 7c72bf096d13..8ee8bf0fe082 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -63,6 +63,7 @@ main(int argc, char **argv)
 	char *p, *progname, *port, *rdma_port = NULL;
 	char **haddr = NULL;
 	int hcounter = 0;
+	struct conf_list *hosts;
 	int	socket_up = 0;
 	unsigned int minorvers = 0;
 	unsigned int minorversset = 0;
@@ -114,12 +115,26 @@ main(int argc, char **argv)
 		}
 	}
 
+	hosts = conf_get_list("nfsd", "host");
+	if (hosts && hosts->cnt) {
+		struct conf_list_node *n;
+		haddr = realloc(haddr, sizeof(char*) * hosts->cnt);
+		TAILQ_FOREACH(n, &(hosts->fields), link) {
+			haddr[hcounter] = n->field;
+			hcounter++;
+		}
+	}
+
 	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTUrG:L:", longopts, NULL)) != EOF) {
 		switch(c) {
 		case 'd':
 			xlog_config(D_ALL, 1);
 			break;
 		case 'H':
+			if (hosts) {
+				hosts = NULL;
+				hcounter = 0;
+			}
 			if (hcounter) {
 				haddr = realloc(haddr, sizeof(char*) * hcounter+1);
 				if(!haddr) {
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index bc00464b3517..9381cf9d30c3 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -125,6 +125,13 @@ configuration file.  Values recognized include:
 .B threads
 The number of threads to start.
 .TP
+.B host
+A host name, or comma separated list of host names, that
+.I rpc.nfsd
+will listen on.  Use of the
+.B --host
+option replaces all host names listed here.
+.TP
 .B grace-time
 The grace time, for both NFSv4 and NLM, in seconds.
 .TP


