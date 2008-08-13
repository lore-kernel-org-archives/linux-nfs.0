From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] NFS: nfs_parsed_mount_options can use unsigned int
Date: Wed, 13 Aug 2008 18:39:38 -0400
Message-ID: <20080813223937.13068.47032.stgit@manray.1015granger.net>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com,
	trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30798 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbYHMWlp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 18:41:45 -0400
In-Reply-To: <20080813223653.13068.9467.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eliminate mixed sign comparisons in nfs_compare_remount_options().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 24241fc..275a692 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -32,11 +32,11 @@ struct nfs_clone_mount {
  */
 struct nfs_parsed_mount_data {
 	int			flags;
-	int			rsize, wsize;
-	int			timeo, retrans;
-	int			acregmin, acregmax,
+	unsigned int		rsize, wsize;
+	unsigned int		timeo, retrans;
+	unsigned int		acregmin, acregmax,
 				acdirmin, acdirmax;
-	int			namlen;
+	unsigned int		namlen;
 	unsigned int		bsize;
 	unsigned int		auth_flavor_len;
 	rpc_authflavor_t	auth_flavors[1];

