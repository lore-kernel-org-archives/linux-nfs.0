Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:55767 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbeCTVDo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:03:44 -0400
Received: by mail-it0-f66.google.com with SMTP id e195-v6so4238609ita.5
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 14:03:44 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/9] NFSv4: Allow GFP_NOIO sleeps in decode_attr_owner/decode_attr_group
Date: Tue, 20 Mar 2018 17:03:07 -0400
Message-Id: <20180320210313.94429-4-trond.myklebust@primarydata.com>
In-Reply-To: <20180320210313.94429-3-trond.myklebust@primarydata.com>
References: <20180320210313.94429-1-trond.myklebust@primarydata.com>
 <20180320210313.94429-2-trond.myklebust@primarydata.com>
 <20180320210313.94429-3-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 65c9c4175145..6b08f6b1addf 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3981,7 +3981,7 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
 	bitmap[1] &= ~FATTR4_WORD1_OWNER;
 
 	if (owner_name != NULL) {
-		len = decode_nfs4_string(xdr, owner_name, GFP_NOWAIT);
+		len = decode_nfs4_string(xdr, owner_name, GFP_NOIO);
 		if (len <= 0)
 			goto out;
 		dprintk("%s: name=%s\n", __func__, owner_name->data);
@@ -4016,7 +4016,7 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
 	bitmap[1] &= ~FATTR4_WORD1_OWNER_GROUP;
 
 	if (group_name != NULL) {
-		len = decode_nfs4_string(xdr, group_name, GFP_NOWAIT);
+		len = decode_nfs4_string(xdr, group_name, GFP_NOIO);
 		if (len <= 0)
 			goto out;
 		dprintk("%s: name=%s\n", __func__, group_name->data);
-- 
2.14.3

