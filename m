Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751745Ab3G1Sgl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Jul 2013 14:36:41 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r6SIafeg010002
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sun, 28 Jul 2013 14:36:41 -0400
Received: from smallhat.bos.devel.redhat.com (vpn-60-122.rdu2.redhat.com [10.10.60.122])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r6SIaeKf022771
	for <linux-nfs@vger.kernel.org>; Sun, 28 Jul 2013 14:36:40 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] rpc.nfsd: No longer advertise NFS v2 support.
Date: Sun, 28 Jul 2013 14:36:37 -0400
Message-Id: <1375036598-31090-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changed the default protocol versions that rpc.nfsd
register with rpcbind to just 3 and 4. Version 2
can still be enabled with the '-V' flag, but it
will not be on by default.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/include/nfs/nfs.h | 1 +
 utils/nfsd/nfsd.c         | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index 174c2dd..5fd86f6 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -52,6 +52,7 @@ struct nfs_fh_old {
 #define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & NFSCTL_UDPBIT) 
 #define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & NFSCTL_TCPBIT) 
 
+#define NFSCTL_VERDEFAULT (0xc)       /* versions 3 and 4 */
 #define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |= (1 << ((_v) - 1))) 
 #define NFSCTL_UDPSET(_cltbits)       ((_cltbits) |= NFSCTL_UDPBIT)
 #define NFSCTL_TCPSET(_cltbits)       ((_cltbits) |= NFSCTL_TCPBIT)
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index e87c0a9..df48392 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -100,7 +100,7 @@ main(int argc, char **argv)
 	char *haddr = NULL;
 	int	socket_up = 0;
 	int minorvers41 = 0;	/* nfsv4 minor version */
-	unsigned int versbits = NFSCTL_ALLBITS;
+	unsigned int versbits = NFSCTL_VERDEFAULT;
 	unsigned int protobits = NFSCTL_ALLBITS;
 	unsigned int proto4 = 0;
 	unsigned int proto6 = 0;
-- 
1.8.1.4

