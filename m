Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:33989 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbbFGMx5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Jun 2015 08:53:57 -0400
Received: by qcej9 with SMTP id j9so42439867qce.1
        for <linux-nfs@vger.kernel.org>; Sun, 07 Jun 2015 05:53:56 -0700 (PDT)
Message-ID: <55743EDE.7070707@gmail.com>
Date: Sun, 07 Jun 2015 20:53:50 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Sean Elble <elbles@sessys.com>, kinglongmee@gmail.com
Subject: [PATCH] rpc.nfsd: add no-ipv4 and no-ipv6 options
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sean reports running rpc.nfsd with --host options without IPv6 address.
rpc.nfsd prints error message, but runs correctly for IPv4.
It is caused by that rpc.nfsd tries to bind IPv4 and IPv6 address default.

rpc.nfsd: unable to resolve nfs-server:nfs to inet6 address: Name or service not known 

This patch add no-ipv4 and no-ipv6 options to disable ipv4/ipv6 directly.

Reported-by: Sean Elble <elbles@sessys.com>
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 support/include/nfs/nfs.h |  8 ++++++++
 utils/nfsd/nfsd.c         | 27 ++++++++++++++++++++++++++-
 utils/nfsd/nfsd.man       | 10 ++++++++++
 3 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index 27054e5..2be61f0 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -47,19 +47,27 @@ struct nfs_fh_old {
 
 #define NFSCTL_UDPBIT		      (1 << (17 - 1))
 #define NFSCTL_TCPBIT		      (1 << (18 - 1))
+#define NFSCTL_INETBIT		      (1 << (19 - 1))
+#define NFSCTL_INET6BIT		      (1 << (20 - 1))
 
 #define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 1))) 
 #define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_UDPBIT) 
 #define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_TCPBIT) 
+#define NFSCTL_INETUNSET(_cltbits)    ((_cltbits) &= ~NFSCTL_INETBIT)
+#define NFSCTL_INET6UNSET(_cltbits)   ((_cltbits) &= ~NFSCTL_INET6BIT)
 
 #define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 1))) 
 #define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & NFSCTL_UDPBIT) 
 #define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & NFSCTL_TCPBIT) 
+#define NFSCTL_INETISSET(_cltbits)    ((_cltbits) & NFSCTL_INETBIT)
+#define NFSCTL_INET6ISSET(_cltbits)   ((_cltbits) & NFSCTL_INET6BIT)
 
 #define NFSCTL_VERDEFAULT (0xc)       /* versions 3 and 4 */
 #define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |= (1 << ((_v) - 1))) 
 #define NFSCTL_UDPSET(_cltbits)       ((_cltbits) |= NFSCTL_UDPBIT)
 #define NFSCTL_TCPSET(_cltbits)       ((_cltbits) |= NFSCTL_TCPBIT)
+#define NFSCTL_INETSET(_cltbits)      ((_cltbits) |= NFSCTL_INETBIT)
+#define NFSCTL_INET6SET(_cltbits)     ((_cltbits) |= NFSCTL_INET6BIT)
 
 #define NFSCTL_ANYPROTO(_cltbits)     ((_cltbits) & (NFSCTL_UDPBIT | NFSCTL_TCPBIT))
 #define NFSCTL_ALLBITS (~0)
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 201bb13..4cd1ea8 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -42,6 +42,8 @@ static struct option longopts[] =
 	{ "nfs-version", 1, 0, 'V' },
 	{ "no-tcp", 0, 0, 'T' },
 	{ "no-udp", 0, 0, 'U' },
+	{ "no-ipv4", 0, 0, 'F'},
+	{ "no-ipv6", 0, 0, 'S'},
 	{ "port", 1, 0, 'P' },
 	{ "port", 1, 0, 'p' },
 	{ "debug", 0, 0, 'd' },
@@ -135,7 +137,7 @@ main(int argc, char **argv)
 	xlog_syslog(0);
 	xlog_stderr(1);
 
-	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTUrG:L:", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTUrG:L:FS", longopts, NULL)) != EOF) {
 		switch(c) {
 		case 'd':
 			xlog_config(D_ALL, 1);
@@ -238,6 +240,12 @@ main(int argc, char **argv)
 		case 'U':
 			NFSCTL_UDPUNSET(protobits);
 			break;
+		case 'F':
+			NFSCTL_INETUNSET(protobits);
+			break;
+		case 'S':
+			NFSCTL_INET6UNSET(protobits);
+			break;
 		case 'G':
 			grace = strtol(optarg, &p, 0);
 			if (*p || grace <= 0) {
@@ -280,6 +288,16 @@ main(int argc, char **argv)
 
 	nfsd_enable_protos(&proto4, &proto6);
 
+	if (!NFSCTL_INETISSET(protobits)) {
+		NFSCTL_TCPUNSET(proto4);
+		NFSCTL_UDPUNSET(proto4);
+	}
+
+	if (!NFSCTL_INET6ISSET(protobits)) {
+		NFSCTL_TCPUNSET(proto6);
+		NFSCTL_UDPUNSET(proto6);
+	}
+
 	if (!NFSCTL_TCPISSET(protobits)) {
 		NFSCTL_TCPUNSET(proto4);
 		NFSCTL_TCPUNSET(proto6);
@@ -301,6 +319,12 @@ main(int argc, char **argv)
 		exit(1);
 	}
 
+	if (!NFSCTL_INETISSET(protobits) &&
+	    !NFSCTL_INET6ISSET(protobits)) {
+		xlog(L_ERROR, "no internet protocols specified");
+		exit(1);
+	}
+
 	if (NFSCTL_VERISSET(versbits, 4) &&
 	    !NFSCTL_TCPISSET(proto4) &&
 	    !NFSCTL_TCPISSET(proto6)) {
@@ -397,6 +421,7 @@ usage(const char *prog)
 		"%s [-d|--debug] [-H hostname] [-p|-P|--port port]\n"
 		"     [-N|--no-nfs-version version] [-V|--nfs-version version]\n"
 		"     [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] [-r|--rdma=]\n"
+		"     [-F|--no-ipv4] [-S|--no-ipv6]\n"
 		"     [-G|--grace-time secs] [-L|--leasetime secs] nrservs\n",
 		prog);
 	exit(2);
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 3ba847e..795f766 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -77,6 +77,16 @@ Disable
 .B rpc.nfsd
 from accepting UDP connections from clients.
 .TP
+.B \-F " or " \-\-no-ipv4
+Disable
+.B rpc.nfsd
+from accepting IPv4 connections from clients.
+.TP
+.B \-S " or " \-\-no-ipv6
+Disable
+.B rpc.nfsd
+from accepting IPv6 connections from clients.
+.TP
 .B \-V " or " \-\-nfs-version vers
 This option can be used to request that 
 .B rpc.nfsd
-- 
2.4.2

