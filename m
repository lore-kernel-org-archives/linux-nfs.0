Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793340713;
	b=PR9wU9cnw2YE4HJ6ouuOUHnSpjgpWkBc7Sm3/2m4mM++3no1BV1tDH22lAx5GUKUlyBd
	 aXh8VNxThnnC0/oPc9gXPzhCpiqtLUuFn3vAefGXoRJHtpZI0PIEW7HMMGyWiMW5kjpaW
	 mxUGrMrHBGRyXT5o+oRqxkiUR0v/zAciqRjzRoimX/LeQ5uosy7oL4bU3L436DtZ0/xUD
	 kcgtE8tWevaQxEtun38Ud+WzVMH1AjRr60VgBwy1Fu8xgqzWYc8NrDQzez1DKG0K6/dK7
	 T5sOz0yDYtBLpIpbqVJGN7zM9gmP1GliUsAHGtPMji5RT34CWm6uhT9WKHYkcFeTeew==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793340713;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=kmIzHb05k2QelXmG1lNmER/oasgGXTDA1Z4/XkET+c0=;
	b=CftQV94EL+xo83LUVYENhBoN2Zfu9KoacT9By6LVwaVkacCiU022gfPbMjRZKxHaQU6O
	 GWOLxAbb7gkYds8zB0ndkFcJmFZashJuMDb802JTmCRbXxmzTFRHri3SPSLLXj76/Vtn8
	 0aDzAk3FQzriTc8dTTj2wCmVxW4DsvpzK0wbgiPjVR4Tsnghy7qNmIFqk5lzhtiijiQ5R
	 /FTYfweq82bCd/oGKxPpQ8q+K29+Ne6i419n5SJq5nLjkotY9MFNWSNrGvj0w/pULy8A6
	 eFsyr0G1dvOAKrS7wWKx7hN5+3I03Ufbi9apK7OtYAZ5ObxjQ3HU9yUzywxZrYDpCFQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=M2kky83m;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB2A3606A31E
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 06:11:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BB2A3606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=M2kky83m
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1793340711;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=kmIzHb05k2QelXmG1lNmER/oasgGXTDA1Z4/XkET+c0=;
	b=M2kky83mfuemNGPOJOE63QnuApADn4myhMQpEfxZa2a8AmN/Xvs+WMDDTCP9R7fAuyU1z8
	lr6SMc/4dEnf9oKZ8S6bDLs/KQX8MtZsfpjjD3mN1nRawSAWpjxoUziRco+DNwPG1oEsmM
	FwEiwdcZNloylg2yENhygvGiCDR3dOs=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-449-r1PFyLZQOZe3zbj3bT0wxQ-1; Fri,
 30 Oct 2026 02:11:42 -0400
X-MC-Unique: r1PFyLZQOZe3zbj3bT0wxQ-1
X-Mimecast-MFC-AGG-ID: r1PFyLZQOZe3zbj3bT0wxQ_1793340701
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 5EAED195604D;
	Fri, 30 Oct 2026 06:11:41 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 843F530002C9;
	Fri, 30 Oct 2026 06:11:40 +0000 (UTC)
From: Abhinandan Ekande <aekande@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: dhowells@redhat.com,
	linux-nfs@vger.kernel.org,
	aekande@redhat.com
Subject: [PATCH v2 1/2] NFS: Accumulate transferred bytes on netfs read completion
Date: Fri, 30 Oct 2026 02:11:37 -0400
Message-ID: <20261030061138.237833-2-aekande@redhat.com>
In-Reply-To: <20261030061138.237833-1-aekande@redhat.com>
References: <20261030061138.237833-1-aekande@redhat.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

When netfs retries a read subrequest that already made progress, it
resets subreq->start and subreq->len to the full original extent and
leaves subreq->transferred holding the byte count read so far.

nfs_netfs_alloc() is called on every ->issue_read(), including retries,
and kzalloc()s netfs->transferred to zero. nfs_netfs_read_completion()
only tracks the bytes read during the current ->issue_read() call.
nfs_netfs_put() then assigns that value to sreq->transferred rather than
adding to it.

The subrequest therefore reports less than it holds. If it hit EOF,
nfs_netfs_read_completion() has set NETFS_SREQ_CLEAR_TAIL and the
collector calls netfs_clear_unread(), which zeroes data that was already
read and then marks the subrequest complete, with no error reported.
Otherwise netfs_read_subreq_terminated() sees subreq->transferred <
subreq->len with no error and, as NFS never sets
NETFS_SREQ_MADE_PROGRESS, fails the read with -ENODATA.

Accumulate instead of assigning. The min_t() clamp is kept and now bounds
the cumulative total.

The retry is reached when a NETFS_READ_FROM_CACHE subrequest fails after
a partial transfer and netfs reissues it against the server. It is masked
today because nfs_netfs_issue_read() reads the whole folio for every
subrequest, so the accumulator exceeds sreq->len on its own and the clamp
arrives at the right answer by accident. Next patch in this series
restricts the read to the subrequest's range and removes that masking.

Fixes: ee4cdf7ba857 ("netfs: Speed up buffered reading")
Cc: stable@vger.kernel.org
Signed-off-by: Abhinandan Ekande <aekande@redhat.com>
---
 fs/nfs/fscache.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/fscache.h b/fs/nfs/fscache.h
index 9d86868f4998..1ab6b8ab6b4f 100644
--- a/fs/nfs/fscache.h
+++ b/fs/nfs/fscache.h
@@ -73,6 +73,7 @@ static inline void nfs_netfs_put(struct nfs_netfs_io_data *netfs)
 	 * length, and thus avoid netfs's "Subreq overread" warning message.
 	 */
 	netfs->sreq->transferred = min_t(s64, netfs->sreq->len,
+					 netfs->sreq->transferred +
 					 atomic64_read(&netfs->transferred));
 	netfs->sreq->error = netfs->error;
 	netfs_read_subreq_terminated(netfs->sreq);
-- 
2.55.0

