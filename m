From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/7] NFS: nfs_parsed_mount_options can use unsigned int
Date: Mon, 18 Aug 2008 19:33:29 -0400
Message-ID: <20080818233328.1214.62818.stgit@manray.1015granger.net>
References: <20080818233128.1214.48603.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21571 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbYHSMG7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 08:06:59 -0400
In-Reply-To: <20080818233128.1214.48603.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

