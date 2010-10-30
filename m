Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3753 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752298Ab0J3VJk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Oct 2010 17:09:40 -0400
From: Joe Perches <joe@perches.com>
To: Jiri Kosina <trivial@kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 24/39] fs/nfsd: Update WARN uses
Date: Sat, 30 Oct 2010 14:08:41 -0700
Message-Id: <189d2bf83b31931f2ba04c488475522156ef537e.1288471898.git.joe@perches.com>
In-Reply-To: <cover.1288471897.git.joe@perches.com>
References: <cover.1288471897.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add missing 1 as first argument.
Align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/nfsd/nfs4state.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 56347e0..0d57eed 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1235,7 +1235,8 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 					(char *)resp->xbuf->head[0].iov_base;
 	if (read_bytes_from_xdr_buf(resp->xbuf, base, slot->sl_data,
 				    slot->sl_datalen))
-		WARN("%s: sessions DRC could not cache compound\n", __func__);
+		WARN(1, "%s: sessions DRC could not cache compound\n",
+		     __func__);
 	return;
 }
 
-- 
1.7.3.1.g432b3.dirty

