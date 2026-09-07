Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BBA2C1CAA6C
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 01:13:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788743615; cv=none; b=k3YIPLdZHB5XxEmh7g3AxzPZK2ZNWeqTLRVbtAyVwrkcHFv7kQx+5mDFz655d0RbgIkcNziQNC2GGA0UHKbohBfchjYdqB12ELZxexa6jmUcRy9+g0Y2fTLXbiynalnBaKWj2uB2QrH2q7O1lCcDGFKRHqbM/KZEHwqNECgXsQY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788743615; c=relaxed/simple;
	bh=wa06Bgf7kuIoP6io7v7fPjqK+Vwg366Gp8/PvlpRNPg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=r+zvK7fFUrnOjoEeNPZp6cWzIWLfG+r/VE3t9f7QbzFkIjKCuzQtI4Po75P7VXivrPbRJj6laD8WSjgIJntvB780d5hE94zVLKVP5JMjFqjIeCGwbXV+C619StKaZFJoKJueJBNj8DSCnJPPtSffFkPCMnPEJF/ace8XT5TyDMU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=aG6jA8Au; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="aG6jA8Au"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788743612;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=XXQUvZHVaJJIVAj86CVcHsUlqVoeyb7V9xOUksfcfpk=;
	b=aG6jA8AuCaINUTUsgWM83xWn4Bd2mx27eYWTI5eSDfRZKchWMZQmzgs4US2Zlci7Dp5RdJ
	FLktJr5LDjt7QYKWSJz16aMaW7g1tbwN/9ZruYeD8qqpNwXnvMUbO4KTEGColS9B2QqZlA
	aN6Dtn5941gN+JczJ3WjslHX3Z+qDN4=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-50-cminwtkgP1WVmmz-fURZAA-1; Sun,
 06 Sep 2026 21:13:31 -0400
X-MC-Unique: cminwtkgP1WVmmz-fURZAA-1
X-Mimecast-MFC-AGG-ID: cminwtkgP1WVmmz-fURZAA_1788743610
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id D11231954232
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 01:13:30 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.64.31])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 46C011800347;
	Mon,  7 Sep 2026 01:13:30 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] libtirpc: Fix use-after-free in xdr_pmaplist() XDR_FREE path
Date: Sun,  6 Sep 2026 21:13:26 -0400
Message-ID: <20260907011328.21425-2-okorniev@redhat.com>
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

The XDR_FREE loop saved a pointer to the pml_next field inside the
struct being freed (next = &((*rp)->pml_next)), then dereferenced it
on the next iteration. This reads freed memory.

Adopt the same pattern xdr_rpcblist_ptr() already uses: save the
value of the next pointer before freeing, then point rp at a stack
copy.

Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 src/pmap_prot2.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/src/pmap_prot2.c b/src/pmap_prot2.c
index bbac74f..7611bd5 100644
--- a/src/pmap_prot2.c
+++ b/src/pmap_prot2.c
@@ -88,7 +88,8 @@ xdr_pmaplist(XDR *xdrs, struct pmaplist **rp)
 	 */
 	bool_t more_elements;
 	int freeing;
-	struct pmaplist **next	= NULL; /* pacify gcc */
+	struct pmaplist *next = NULL;
+	struct pmaplist *next_copy;
 
 	assert(xdrs != NULL);
 	assert(rp != NULL);
@@ -107,11 +108,16 @@ xdr_pmaplist(XDR *xdrs, struct pmaplist **rp)
 		 * before we free the current object ...
 		 */
 		if (freeing)
-			next = &((*rp)->pml_next); 
+			next = (*rp)->pml_next;
 		if (! xdr_reference(xdrs, (caddr_t *)rp,
 		    (u_int)sizeof(struct pmaplist), (xdrproc_t)xdr_pmap))
 			return (FALSE);
-		rp = (freeing) ? next : &((*rp)->pml_next);
+		if (freeing) {
+			next_copy = next;
+			rp = &next_copy;
+		} else {
+			rp = &((*rp)->pml_next);
+		}
 	}
 }
 
-- 
2.52.0

