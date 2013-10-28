Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757077Ab3J1SDn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 14:03:43 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9SI3gFh009850
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 28 Oct 2013 14:03:43 -0400
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r9SI3eQE004871
	for <linux-nfs@vger.kernel.org>; Mon, 28 Oct 2013 14:03:42 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] mountd: Add the ability to disable UDP listeners.
Date: Mon, 28 Oct 2013 14:04:30 -0400
Message-Id: <1382983470-10063-3-git-send-email-steved@redhat.com>
In-Reply-To: <1382983470-10063-1-git-send-email-steved@redhat.com>
References: <1382983470-10063-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the ability to turn off UDP listeners with the
new "-u | --no-udp" flag.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/svc_create.c |  3 +++
 utils/mountd/mountd.c    | 10 +++++++---
 utils/mountd/mountd.man  |  3 +++
 3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/support/nfs/svc_create.c b/support/nfs/svc_create.c
index 9ae2965..6b9e85b 100644
--- a/support/nfs/svc_create.c
+++ b/support/nfs/svc_create.c
@@ -419,6 +419,9 @@ nfs_svc_create(char *name, const rpcprog_t program, const rpcvers_t version,
 			continue;
 		visible++;
 
+		if (!strcmp(nconf->nc_proto, NC_UDP) && !NFSCTL_UDPISSET(_rpcprotobits))
+			continue;
+
 		if (!strcmp(nconf->nc_proto, NC_TCP) && !NFSCTL_TCPISSET(_rpcprotobits))
 			continue;
 
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index f918472..9fe0f40 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -68,6 +68,7 @@ static struct option longopts[] =
 	{ "num-threads", 1, 0, 't' },
 	{ "reverse-lookup", 0, 0, 'r' },
 	{ "manage-gids", 0, 0, 'g' },
+	{ "no-udp", 0, 0, 'u' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -708,7 +709,7 @@ main(int argc, char **argv)
 
 	/* Parse the command line options and arguments. */
 	opterr = 0;
-	while ((c = getopt_long(argc, argv, "o:nFd:f:p:P:hH:N:V:vrs:t:g", longopts, NULL)) != EOF)
+	while ((c = getopt_long(argc, argv, "o:nFd:f:p:P:hH:N:V:vurs:t:g", longopts, NULL)) != EOF)
 		switch (c) {
 		case 'g':
 			manage_gids = 1;
@@ -782,6 +783,9 @@ main(int argc, char **argv)
 		case 'v':
 			printf("%s version " VERSION "\n", progname);
 			exit(0);
+		case 'u':
+			NFSCTL_UDPUNSET(_rpcprotobits);
+			break;
 		case 0:
 			break;
 		case '?':
@@ -849,7 +853,7 @@ main(int argc, char **argv)
 		listeners += nfs_svc_create("mountd", MOUNTPROG,
 					MOUNTVERS_NFSV3, mount_dispatch, port);
 	if (version23() && listeners == 0)
-		xlog(L_FATAL, "mountd: could not create listeners\n");
+		xlog(L_WARNING, "mountd: No V2 or V3 listeners created!");
 
 	sa.sa_handler = killer;
 	sigaction(SIGINT, &sa, NULL);
@@ -907,6 +911,6 @@ usage(const char *prog, int n)
 "	[-p|--port port] [-V version|--nfs-version version]\n"
 "	[-N version|--no-nfs-version version] [-n|--no-tcp]\n"
 "	[-H ha-callout-prog] [-s|--state-directory-path path]\n"
-"	[-g|--manage-gids] [-t num|--num-threads=num]\n", prog);
+"	[-g|--manage-gids] [-t num|--num-threads=num] [-u|--no-udp]\n", prog);
 	exit(n);
 }
diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index b60dc90..e59a559 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -181,6 +181,9 @@ threads are usually only needed for NFS servers which need to handle
 mount storms of hundreds of NFS mounts in a few seconds, or when
 your DNS server is slow or unreliable.
 .TP
+.B  \-u " or " \-\-no-udp
+Don't advertise UDP for mounting
+.TP
 .B \-V " or " \-\-nfs-version
 This option can be used to request that
 .B rpc.mountd
-- 
1.8.3.1

