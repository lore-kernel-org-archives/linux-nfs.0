Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8564E54CF69
	for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2026 13:49:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790084948; cv=none; b=PqYo86cqgsygNxRk1BCl7auR/0v+AYMfaKygpiu9v84atUKD++c4rwBjTyAs1dvl2vXaB/bt33XpcAlqCqdGmTsFIEU2evbPkppbMzd//s0cHNGEFYD6ajrhQzTyPvD4hmU00bg78HK/I9Y9FHh22IwuoObQZ+XWwhKgSE5hEX8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790084948; c=relaxed/simple;
	bh=mxyubcKPkYDGv8WilvPgtIFncNfvowqK/Jndalvx+oo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=i9OOYxiQGBUXkZBZGyXn7bLWMfZnAaml3k4BU0e/nKdxlD3f7TooniM5lF9VJibgKzCFsYywmT42nLuXEcECgnAl6XHeBWH1CgCeR6oLdotapTke/PSuqQ+NutZUF1pTj3guhQy1+B9EIJ4jxT6tHoLQah9G/PdndQtX/HyYySo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=iA1XHIlo; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="iA1XHIlo"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790084945;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=eJ/1f3iL2ktEuOOlvx/Nwus8G4DR31dEGBcv/JTPxmo=;
	b=iA1XHIlogiGs98WipfzzDj0WXjGgXawH75NZ4EZGbfmOHQKnHcti8UFpZv4SdUKXJKOPhp
	j7jA3F2xwrlfV5uJFMeApAYnDNjYI7/I7ZNVUzBuKP327NqYbx64/0/v8VUOurMB2kk8DQ
	W/s5bfjkCigYRpqX7g+QL13UQeRCoAE=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-441-HIAiTUq5P9uskqDFeMc63w-1; Tue,
 22 Sep 2026 09:49:02 -0400
X-MC-Unique: HIAiTUq5P9uskqDFeMc63w-1
X-Mimecast-MFC-AGG-ID: HIAiTUq5P9uskqDFeMc63w_1790084940
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 8A8F41945CB3;
	Tue, 22 Sep 2026 13:49:00 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 9A2A13000225;
	Tue, 22 Sep 2026 13:48:59 +0000 (UTC)
From: Abhinandan Ekande <aekande@redhat.com>
To: cel@kernel.org,
	jlayton@kernel.org
Cc: neilb@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: in svcauth_gss_wrap_integ() resync rq_next_page after the GSS wrap
Date: Tue, 22 Sep 2026 09:48:58 -0400
Message-ID: <20260922134858.2219136-1-aekande@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

For a page-aligned READ payload, xdr_reserve_space_vec() leaves the
encode cursor with p == end and page_ptr still on the last payload page.
nfsd4_encode_operation() then resyncs rqstp->rq_next_page = xdr->page_ptr + 1,
so rq_next_page points at the first page past the payload.

The GSS MIC is encoded later, after the last operation, and nothing resyncs
rq_next_page after that. Because p == end, the MIC's xdr_reserve_space()
falls into xdr_get_next_encode_buffer(), which increments page_ptr into
the next page — the page rq_next_page points at. After the send,
svc_rqst_release_pages() releases only 'rq_next_page - rq_respages' pages,
so that page sits one past the release range and is never released. The
next reply from the same nfsd thread writes its MIC into the same physical
page while TCP still holds a MSG_SPLICE_PAGES reference to the previous
reply, so that reply is transmitted carrying the wrong MIC.

mmap + fscache workloads hit this consistently because their READ payloads
end exactly on a page boundary.

Before the commit 'd7de37d6d7cc', xdr_truncate_encode() ran after the
reserve. For the page-aligned case xdr_truncate_encode() correctly
recomputed page_ptr to point at the page after the payload. Therefore the
later MIC encode had room and never crossed page boundary. That protection
was a side effect rather than by design. The underlying hazard of MIC page
falling outside the release range existed before the commit as well; for
example payload that ends with fewer than a MIC's width of room left before
the page boundary. The commit did not introduce the bug, it widened the
trigger from that rare case to the page-aligned one.

The fix for this issue is to make the MIC page always fall inside the
release range regardless of payload alignment - that is resync rq_next_page
after the GSS wrap, for example, rqstp->rq_next_page = xdr->page_ptr + 1;
at the end of svcauth_gss_wrap_integ().

Fixes: d7de37d6d7cc ("NFSD: Relocate the xdr_reserve_space_vec() call site")
Suggested-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Abhinandan Ekande <aekande@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 967e9d53080d..06d75f98e954 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1820,6 +1820,9 @@ static int svcauth_gss_wrap_integ(struct svc_rqst *rqstp)
 		goto wrap_failed;
 	xdr_commit_encode(xdr);
 
+	if (xdr->page_ptr + 1 > rqstp->rq_next_page)
+		rqstp->rq_next_page = xdr->page_ptr + 1;
+
 out:
 	return 0;
 
-- 
2.55.0

