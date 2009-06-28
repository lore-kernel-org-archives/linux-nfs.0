From: Joe Perches <joe@perches.com>
Subject: [PATCH 58/62] fs/nfs/callback_xdr.c: Remove unnecessary semicolons
Date: Sun, 28 Jun 2009 09:27:03 -0700
Message-ID: <e948ca285a5237a00e36183f99524e055158b1ff.1246173683.git.joe@perches.com>
References: <cover.1246173664.git.joe@perches.com>
Cc: trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1187 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755490AbZF1Q2V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jun 2009 12:28:21 -0400
In-Reply-To: <cover.1246173664.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/nfs/callback_xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index e5a2dac..76b0aa0 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -222,7 +222,7 @@ static unsigned decode_sessionid(struct xdr_stream *xdr,
 
 	p = read_buf(xdr, len);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);;
+		return htonl(NFS4ERR_RESOURCE);
 
 	memcpy(sid->data, p, len);
 	return 0;
-- 
1.6.3.1.10.g659a0.dirty

