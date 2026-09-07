Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 23DE620010A
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 01:13:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788743616; cv=none; b=lYTy0DaPcADBOx8zBDVjEJXVvFBwyKu2xNl4dguFsuaNMEdstgKSDhz1bzopj6Lq7jWBf+a1he4mgDAWi1T70JTyP5jkpkex80dYvU8x7CJuLJKhAhK3lhKK7V2qh63Hmqh0poTyyqXERg5hwXUwYBUaSFp6GebB6bIVfUwzMCg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788743616; c=relaxed/simple;
	bh=Qu3hhD7C28QERVFkV+sM6V+chEo4voHhnWfelbxZvss=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GTGqvZmuKc7bTzhcvcIim9k+fqHRb7fLLGJbDBBDP6brKvQZDJ3SXMMiimTmdreOroXTbqphCW43W8oJW03MU3J9mzUJyILscsGosmEeH6NnzNE3tYmwuXBsRDQr8CjiLDu/L4qpscajZtvFT+vUOgwQ8IYwonvb93/ClbYdn+k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=N2GZAYUN; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="N2GZAYUN"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788743613;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=sRoNrx/kABkDr7NEE3NrWfIY05jSJ4I6G8E0ml8CD28=;
	b=N2GZAYUN6nn9SFDzF5/t/1yuxwj6+pO4o6JDsY3D7xC/yWC2yfiaKN5yHGP+B0r9ux9zoe
	/vqR5p3KROc00+O2zsnTEV8fsg/lEGP0Xm497ctQSIJDT+cM5BovO05mumsnwPsAts7Hsb
	BYiCl/lcqpd/wmZ1IaHigl/6FZKUDXk=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-154-SjYVfEXnPOKMzUaGBwJrog-1; Sun,
 06 Sep 2026 21:13:32 -0400
X-MC-Unique: SjYVfEXnPOKMzUaGBwJrog-1
X-Mimecast-MFC-AGG-ID: SjYVfEXnPOKMzUaGBwJrog_1788743611
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id AA3531956057
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 01:13:31 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.64.31])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 14E661800348;
	Mon,  7 Sep 2026 01:13:30 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] libtirpc: limit XDR decode node count
Date: Sun,  6 Sep 2026 21:13:27 -0400
Message-ID: <20260907011328.21425-3-okorniev@redhat.com>
In-Reply-To: <20260907011328.21425-1-okorniev@redhat.com>
References: <20260907011328.21425-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

xdr_pmaplist(), xdr_rpcblist_ptr() and xdr_rpcb_entry_list_ptr()
decode linked lists with no upper bound on element count. A malicious
server can stream arbitrarily many list nodes, forcing unbounded heap
allocation in any client that decodes the response (rpcinfo,
rpcb_getmaps() callers).

Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 src/pmap_prot2.c |  9 ++++++++-
 src/rpcb_prot.c  | 16 ++++++++++++++++
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/src/pmap_prot2.c b/src/pmap_prot2.c
index 7611bd5..d043f34 100644
--- a/src/pmap_prot2.c
+++ b/src/pmap_prot2.c
@@ -39,6 +39,8 @@
 #include <rpc/xdr.h>
 #include <rpc/pmap_prot.h>
 
+/* Cap decoded list length to prevent memory exhaustion from malicious data */
+#define PMAPLIST_DECODE_MAX_NODES 1024
 
 /*
  * What is going on with linked lists? (!)
@@ -87,7 +89,7 @@ xdr_pmaplist(XDR *xdrs, struct pmaplist **rp)
 	 * xdr_bool when the direction is XDR_DECODE.
 	 */
 	bool_t more_elements;
-	int freeing;
+	int freeing, node_count = 0;
 	struct pmaplist *next = NULL;
 	struct pmaplist *next_copy;
 
@@ -102,6 +104,11 @@ xdr_pmaplist(XDR *xdrs, struct pmaplist **rp)
 			return (FALSE);
 		if (! more_elements)
 			return (TRUE);  /* we are done */
+		if (xdrs->x_op == XDR_DECODE &&
+			++node_count > PMAPLIST_DECODE_MAX_NODES) {
+			return (FALSE);
+		}
+
 		/*
 		 * the unfortunate side effect of non-recursion is that in
 		 * the case of freeing we must remember the next object
diff --git a/src/rpcb_prot.c b/src/rpcb_prot.c
index 809feb0..0b0574f 100644
--- a/src/rpcb_prot.c
+++ b/src/rpcb_prot.c
@@ -89,6 +89,9 @@ xdr_rpcb(
  * serialize the rpcb elements.
  */
 
+/* Cap decoded list length to prevent memory exhaustion from malicious data */
+#define RPCBLIST_DECODE_MAX_NODES 1024
+
 bool_t
 xdr_rpcblist_ptr(
 	XDR *xdrs,
@@ -101,6 +104,7 @@ xdr_rpcblist_ptr(
 	 */
 	bool_t more_elements;
 	int freeing = (xdrs->x_op == XDR_FREE);
+	int node_count = 0;
 	rpcblist_ptr next;
 	rpcblist_ptr next_copy;
 
@@ -113,6 +117,10 @@ xdr_rpcblist_ptr(
 		if (! more_elements) {
 			return (TRUE);  /* we are done */
 		}
+		if (xdrs->x_op == XDR_DECODE &&
+		    ++node_count > RPCBLIST_DECODE_MAX_NODES) {
+			return (FALSE);
+		}
 		/*
 		 * the unfortunate side effect of non-recursion is that in
 		 * the case of freeing we must remember the next object
@@ -178,6 +186,9 @@ xdr_rpcb_entry(
 	return (TRUE);
 }
 
+/* Cap decoded list length to prevent memory exhaustion from malicious data */
+#define RPCB_ENTRY_LIST_DECODE_MAX_NODES 1024
+
 bool_t
 xdr_rpcb_entry_list_ptr(
 	XDR *xdrs,
@@ -190,6 +201,7 @@ xdr_rpcb_entry_list_ptr(
 	 */
 	bool_t more_elements;
 	int freeing = (xdrs->x_op == XDR_FREE);
+	int node_count = 0;
 	rpcb_entry_list_ptr next;
 	rpcb_entry_list_ptr next_copy;
 
@@ -202,6 +214,10 @@ xdr_rpcb_entry_list_ptr(
 		if (! more_elements) {
 			return (TRUE);  /* we are done */
 		}
+		if (xdrs->x_op == XDR_DECODE &&
+		    ++node_count > RPCB_ENTRY_LIST_DECODE_MAX_NODES) {
+			return (FALSE);
+		}
 		/*
 		 * the unfortunate side effect of non-recursion is that in
 		 * the case of freeing we must remember the next object
-- 
2.52.0

