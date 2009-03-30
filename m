From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/7] SQUASHME: nfs41: remove ifdefs around nfs_client_initdata.minorversion
Date: Mon, 30 Mar 2009 17:00:30 +0300
Message-ID: <1238421630-24989-1-git-send-email-bhalevy@panasas.com>
References: <49D0D025.2080608@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, andros@netapp.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15850 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750919AbZC3OAq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 10:00:46 -0400
In-Reply-To: <49D0D025.2080608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> This is really ugly and unnecessary. Please just remove those ifdefs,
> and have clp->cl_minorversion data->minorversion always defined, and set
> to 0.

squash intto "nfs41: Use mount minorversion option"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index bce02da..870742e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -102,9 +102,7 @@ struct nfs_client_initdata {
 	size_t addrlen;
 	const struct nfs_rpc_ops *rpc_ops;
 	int proto;
-#ifdef CONFIG_NFS_V4
 	u32 minorversion;
-#endif
 };
 
 /*
@@ -451,11 +449,9 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 		if (clp->cl_proto != data->proto)
 			continue;
-#ifdef CONFIG_NFS_V4
-		/* Match minorversion */
+		/* Match nfsv4 minorversion */
 		if (clp->cl_minorversion != data->minorversion)
 			continue;
-#endif
 		/* Match the full socket address */
 		if (!nfs_sockaddr_cmp(sap, clap))
 			continue;
-- 
1.6.2.1

