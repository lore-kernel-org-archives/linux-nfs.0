Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:62756 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaGNB56 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 21:57:58 -0400
Received: by mail-qc0-f181.google.com with SMTP id w7so24387qcr.40
        for <linux-nfs@vger.kernel.org>; Sun, 13 Jul 2014 18:57:57 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 4/7] sunrpc: xdr_get_next_encode_buffer can be static
Date: Sun, 13 Jul 2014 21:57:41 -0400
Message-Id: <1405303064-9102-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 net/sunrpc/xdr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 23fb4e75e245..13b7dd0d38e6 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -509,7 +509,8 @@ void xdr_commit_encode(struct xdr_stream *xdr)
 }
 EXPORT_SYMBOL_GPL(xdr_commit_encode);
 
-__be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr, size_t nbytes)
+static __be32 *
+xdr_get_next_encode_buffer(struct xdr_stream *xdr, size_t nbytes)
 {
 	static __be32 *p;
 	int space_left;
-- 
1.9.3

