Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37920 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbbFIXoL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 19:44:11 -0400
Received: by igblz2 with SMTP id lz2so22131145igb.1
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jun 2015 16:44:10 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Michael Skralivetsky <michael.skralivetsky@primarydata.com>,
        chuck.lever@oracle.com
Subject: [PATCH v3 1/5] nfs: increase size of EXCHANGE_ID name string buffer
Date: Tue,  9 Jun 2015 19:43:56 -0400
Message-Id: <1433893440-3988-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433893440-3988-1-git-send-email-jeff.layton@primarydata.com>
References: <1433893440-3988-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current buffer is much too small if you have a relatively long
hostname. Bring it up to the size of the one that SETCLIENTID has.

Cc: <stable@vger.kernel.org>
Reported-by: Michael Skralivetsky <michael.skralivetsky@primarydata.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/linux/nfs_xdr.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 93ab6071bbe9..e9e9a8dcfb47 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1142,7 +1142,7 @@ struct nfs41_state_protection {
 	struct nfs4_op_map allow;
 };
 
-#define NFS4_EXCHANGE_ID_LEN	(48)
+#define NFS4_EXCHANGE_ID_LEN	(127)
 struct nfs41_exchange_id_args {
 	struct nfs_client		*client;
 	nfs4_verifier			*verifier;
-- 
2.4.2

