Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43954 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751091AbcLHE2E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:28:04 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:25 +1100
Subject: [PATCH 03/10] nfsd: add /etc/nfs.conf support for nfsd.port option.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117124486.31271.2529245859270914389.stgit@noble>
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/nfs.conf.man |    5 ++++-
 utils/nfsd/nfsd.c    |    4 +++-
 utils/nfsd/nfsd.man  |    3 +++
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 03f1f2be534d..23aa4ea7d2f9 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -104,6 +104,7 @@ for details.
 .B nfsd
 Recognized values:
 .BR threads ,
+.BR port ,
 .BR grace-time ,
 .BR lease-time ,
 .BR udp ,
@@ -120,8 +121,10 @@ Version and protocol values are Boolean values as described above,
 and are also used by
 .BR rpc.mountd .
 Threads and the two times are integers.
+.B port
+and
 .B rdma
-is a service name or number.  See
+are service names or numbers.  See
 .BR rpc.nfsd (8)
 for details.
 
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index d8f873ba3717..7c72bf096d13 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -72,7 +72,6 @@ main(int argc, char **argv)
 	int lease = -1;
 
 	progname = basename(argv[0]);
-	port = "nfs";
 	haddr = xmalloc(sizeof(char *));
 	haddr[0] = NULL;
 
@@ -83,6 +82,9 @@ main(int argc, char **argv)
 	count = conf_get_num("nfsd", "threads", count);
 	grace = conf_get_num("nfsd", "grace-time", grace);
 	lease = conf_get_num("nfsd", "lease-time", lease);
+	port = conf_get_str("nfsd", "port");
+	if (!port)
+		port = "nfs";
 	rdma_port = conf_get_str("nfsd", "rdma");
 	if (conf_get_bool("nfsd", "udp", NFSCTL_UDPISSET(protobits)))
 		NFSCTL_UDPSET(protobits);
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 7b9fbf21a947..bc00464b3517 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -131,6 +131,9 @@ The grace time, for both NFSv4 and NLM, in seconds.
 .B lease-time
 The lease time for NFSv4, in seconds.
 .TP
+.B port
+Set the port for TCP/UDP to bind to.
+.TP
 .B rdma
 Set RDMA port.  Use "rdma=nfsrdma" to enable standard port.
 .TP


