Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:47650 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab3CPT4N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2013 15:56:13 -0400
Received: by mail-ie0-f182.google.com with SMTP id k14so5666971iea.27
        for <linux-nfs@vger.kernel.org>; Sat, 16 Mar 2013 12:56:13 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 14/15] NFS: Try AUTH_UNIX when PUTROOTFH gets
 NFS4ERR_WRONGSEC
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Date: Sat, 16 Mar 2013 15:56:11 -0400
Message-ID: <20130316195611.27329.97676.stgit@seurat.1015granger.net>
In-Reply-To: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
References: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most NFSv4 servers implement AUTH_UNIX, and administrators will
prefer this over AUTH_NULL.  It is harmless for our client to try
this flavor in addition to the flavors mandated by RFC 3530/5661.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ddbebfe..12f7318 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2468,6 +2468,7 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 		RPC_AUTH_GSS_KRB5P,
 		RPC_AUTH_GSS_KRB5I,
 		RPC_AUTH_GSS_KRB5,
+		RPC_AUTH_UNIX,			/* courtesy */
 		RPC_AUTH_NULL,
 	};
 	int status = -EPERM;

