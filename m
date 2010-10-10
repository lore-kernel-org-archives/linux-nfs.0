Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30726 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756086Ab0JOGRk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 02:17:40 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/12] SUNRPC: define xdr_decode_opaque_fixed
Date: Sun, 10 Oct 2010 11:22:43 -0400
Message-Id: <1286724173-8493-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
References: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

A helper for decoding a fixed length opaque value.
Returns a pointer to the next item in the xdr stream.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/xdr.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 8c1dcbb..f104f90 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -132,6 +132,13 @@ xdr_decode_hyper(__be32 *p, __u64 *valp)
 	return p + 2;
 }
 
+static inline __be32 *
+xdr_decode_opaque_fixed(__be32 *p, void *ptr, unsigned int len)
+{
+	memcpy(ptr, p, len);
+	return p + XDR_QUADLEN(len);
+}
+
 /*
  * Adjust kvec to reflect end of xdr'ed data (RPC client XDR)
  */
-- 
1.7.2.1

