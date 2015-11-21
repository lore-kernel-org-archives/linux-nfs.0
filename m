Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44752 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbbKUK3E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Nov 2015 05:29:04 -0500
Date: Sat, 21 Nov 2015 13:28:50 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: [patch] nfsd: fix a warning message
Message-ID: <20151121102850.GA7002@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The WARN() macro takes a condition and a format string.  The condition
was accidentally left out here so it just prints the function name
instead of the message.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6b800b5..7af023f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2240,7 +2240,8 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	base = resp->cstate.data_offset;
 	slot->sl_datalen = buf->len - base;
 	if (read_bytes_from_xdr_buf(buf, base, slot->sl_data, slot->sl_datalen))
-		WARN("%s: sessions DRC could not cache compound\n", __func__);
+		WARN(1, "%s: sessions DRC could not cache compound\n",
+		     __func__);
 	return;
 }
 
