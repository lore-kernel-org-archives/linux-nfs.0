Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f173.google.com ([209.85.213.173]:62586 "EHLO
	mail-ye0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968218Ab3HIQwu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:52:50 -0400
Received: by mail-ye0-f173.google.com with SMTP id m14so1174375yen.4
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:52:50 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id i70sm12897972yhd.4.2013.08.09.09.52.49
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:52:49 -0700 (PDT)
Subject: [PATCH v2 33/33] NFS: Set EXCHGID4_FLAG_SUPP_MOVED_MIGR
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:52:48 -0400
Message-ID: <20130809165248.5362.44282.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
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
index ecf8e96..0ded41b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6325,8 +6325,14 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
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

