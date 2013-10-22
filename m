Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753393Ab3JVISw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 04:18:52 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9M8Ipi0003972
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 22 Oct 2013 04:18:51 -0400
Received: from smallhat.boston.devel.redhat.com.org (vpn-59-139.rdu2.redhat.com [10.10.59.139])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r9M8Inok017257
	for <linux-nfs@vger.kernel.org>; Tue, 22 Oct 2013 04:18:51 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] mountd: Add the ability to disable UDP listeners.
Date: Tue, 22 Oct 2013 04:19:26 -0400
Message-Id: <1382429966-14531-4-git-send-email-steved@redhat.com>
In-Reply-To: <1382429966-14531-1-git-send-email-steved@redhat.com>
References: <1382429966-14531-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the ability to turn off UDP listeners with the
new "-u | --no-udp" flag.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/svc_create.c | 2 +-
 utils/mountd/mountd.c    | 8 ++++++--
 utils/mountd/mountd.man  | 3 +++
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/support/nfs/svc_create.c b/support/nfs/svc_create.c
index 9ae2965..dac17d9 100644
--- a/support/nfs/svc_create.c
+++ b/support/nfs/svc_create.c
@@ -419,7 +419,7 @@ nfs_svc_create(char *name, const rpcprog_t program, const rpcvers_t version,
 			continue;
 		visible++;
 
-		if (!strcmp(nconf->nc_proto, NC_TCP) && !NFSCTL_TCPISSET(_rpcprotobits))
+		if (!strcmp(nconf->nc_proto, NC_UDP) && !NFSCTL_UDPISSET(_rpcprotobits))
 			continue;
 
 		if (port == 0)
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 46ff05f..3d7f7f3 100644
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
@@ -785,6 +786,9 @@ main(int argc, char **argv)
 		case 'v':
 			printf("%s version " VERSION "\n", progname);
 			exit(0);
+		case 'u':
+			NFSCTL_UDPUNSET(_rpcprotobits);
+			break;
 		case 0:
 			break;
 		case '?':
@@ -910,6 +914,6 @@ usage(const char *prog, int n)
 "	[-p|--port port] [-V version|--nfs-version version]\n"
 "	[-N version|--no-nfs-version version] [-n|--no-tcp(deprecate)]\n"
 "	[-H ha-callout-prog] [-s|--state-directory-path path]\n"
-"	[-g|--manage-gids] [-t num|--num-threads=num]\n", prog);
+"	[-g|--manage-gids] [-t num|--num-threads=num] [-u|--no-udp]\n", prog);
 	exit(n);
 }
diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index c049e35..5d99659 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -178,6 +178,9 @@ threads are usually only needed for NFS servers which need to handle
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

