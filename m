Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:23514 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758233Ab3JQSOG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:14:06 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HIE5jU014323
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:14:05 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HIE4f6008774
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:14:04 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 20/21] NFS: Set EXCHGID4_FLAG_SUPP_MOVED_MIGR
Date: Thu, 17 Oct 2013 14:14:04 -0400
Message-Id: <20131017181404.1073.13093.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Broadly speaking, v4.1 migration is untested.  There are no servers
in the wild that support NFSv4.1 migration.  However, as server
implementations become available, we do want to enable testing by
developers, while leaving it disabled for environments for which
broken migration support would be an unpleasant surprise.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/Kconfig    |   11 +++++++++++
 fs/nfs/nfs4proc.c |    8 +++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index b5e80b0..38c1768 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -140,6 +140,17 @@ config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
 	  If the NFS client is unchanged from the upstream kernel, this
 	  option should be set to the default "kernel.org".
 
+config NFS_V4_1_MIGRATION
+	bool "NFSv4.1 client support for migration"
+	depends on NFS_V4_1
+	default n
+	help
+	  This option makes the NFS client advertise to NFSv4.1 servers that
+          it can support NFSv4 migration.
+
+          The NFSv4.1 pieces of the Linux NFSv4 migration implementation are
+          still experimental.  If you are not an NFSv4 developer, say N here.
+
 config NFS_V4_SECURITY_LABEL
 	bool
 	depends on NFS_V4_2 && SECURITY
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d9c38cd..fbc925f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6602,8 +6602,14 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	struct nfs41_exchange_id_args args = {
 		.verifier = &verifier,
 		.client = clp,
+#ifdef CONFIG_NFS_V4_1_MIGRATION
 		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
-			EXCHGID4_FLAG_BIND_PRINC_STATEID,
+			 EXCHGID4_FLAG_BIND_PRINC_STATEID |
+			 EXCHGID4_FLAG_SUPP_MOVED_MIGR,
+#else
+		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
+			 EXCHGID4_FLAG_BIND_PRINC_STATEID,
+#endif
 	};
 	struct nfs41_exchange_id_res res = {
 		0

