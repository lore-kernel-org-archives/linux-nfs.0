Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47535 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666Ab0IISKh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 14:10:37 -0400
Received: from localhost.localdomain (surajit-lxp.hq.netapp.com [10.58.50.95] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o89IAW1N002948
	for <linux-nfs@vger.kernel.org>; Thu, 9 Sep 2010 11:10:34 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/13] SUNRPC: define xdr_decode_opaque_fixed
Date: Thu,  2 Sep 2010 14:00:08 -0400
Message-Id: <1283450419-5648-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
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
1.7.2.1

