From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/9] SUNRPC: Trivial cleanups in include/linux/sunrpc/xdr.h
Date: Wed, 21 Apr 2010 13:43:14 -0400
Message-ID: <20100421174313.2037.98789.stgit@localhost.localdomain>
References: <20100421173628.2037.54635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36444 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978Ab0DURnQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:43:16 -0400
Received: by pvg13 with SMTP id 13so1004163pvg.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Apr 2010 10:43:16 -0700 (PDT)
In-Reply-To: <20100421173628.2037.54635.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Update the documenting comment, and fix some minor white
space issues.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xdr.h |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index f5cc089..35cf2e8 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -1,7 +1,10 @@
 /*
- * include/linux/sunrpc/xdr.h
+ * XDR standard data types and function declarations
  *
  * Copyright (C) 1995-1997 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
+ *
+ * Based on:
+ *   RFC 4506 "XDR: External Data Representation Standard", May 2006
  */
 
 #ifndef _SUNRPC_XDR_H_
@@ -62,7 +65,6 @@ struct xdr_buf {
 
 	unsigned int	buflen,		/* Total length of storage buffer */
 			len;		/* Length of XDR encoded message */
-
 };
 
 /*
@@ -178,7 +180,7 @@ struct xdr_array2_desc {
 };
 
 extern int xdr_decode_array2(struct xdr_buf *buf, unsigned int base,
-                             struct xdr_array2_desc *desc);
+			     struct xdr_array2_desc *desc);
 extern int xdr_encode_array2(struct xdr_buf *buf, unsigned int base,
 			     struct xdr_array2_desc *desc);
 

