Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440Ab0HMVcF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:05 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/50] sunrpc: define xdr_decode_opaque_fixed
Date: Fri, 13 Aug 2010 17:31:14 -0400
Message-Id: <1281735122-1496-3-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-2-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
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
index 35cf2e8..23dc117 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -131,6 +131,13 @@ xdr_decode_hyper(__be32 *p, __u64 *valp)
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
1.6.2.5

