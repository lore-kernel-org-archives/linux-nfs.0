Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795006303;
	b=JzECP6M3umr7Vc6m8bGvZiPDPsBoNl0aEXDtOF4iegnMpTVf6L63WxC/47lcEsJ/ktU2
	 IQmI97SvyMk82q6F95pXrv/UWLDQ8TZ+OK3Flj86msBP0xTCvX0id4Ra17buKXsGF58mJ
	 8sP0YSFA6fe+Y//ng1DUxqaHnwZxfJlPgJPNrF5chkhN+aeunOpVZ1SumD381OKamj93y
	 k7PNtsBWXFTZuZfrcNtMq7/kt/3ysUS7KwASJHnWk1jOUxwMHVsI1tQyEbHRPtkAwDQXq
	 UYXp5saxTgNz4r/U10pFWUqG4UmHYgjF+IcUjxrK/hZZyVdPPeGtj+7PkDN+b6ufYaQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795006303;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=EzlxM954LHoj76+QVAVRNyn/YTetw6xHcF9kIhsjQp8=;
	b=tPUymSQQ+GeKkesKmCIK9HmPGBp+O0TPGu0NZ/QlJBgpd6geMqRCPt9GxidesqAgwdT0
	 uCOx+qV/2h/NsZXGUFrLJ7V1oGVbV9ho6JMi61iOpZK5ncFTWc7QzzegDw13LC1xn6SBb
	 O0THLEvo6O6DogB/+OI/HqTvmIMFgFL+Me4qCm7P5otn7W9hnQz2SnVsJmx8PJt2QTBRf
	 LdLjGLBsqPJ05AfIdd4jLaWFgT22ypMXCOYSNn/aydGbHgnyLbHIsKGWrOjItLsa+oaJf
	 bKNV2x/jJX5TzHdODfGemyMV0fv5JnUV1SlYkJ1hOs4TAXHYvYWWmH1i4sU2/5fPo9w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=iiRPKDAr;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8082E606A32F
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 12:51:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8082E606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=iiRPKDAr
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795006301;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EzlxM954LHoj76+QVAVRNyn/YTetw6xHcF9kIhsjQp8=;
	b=iiRPKDArnq61FSzMXOaxhX65NJzuXbt+skmsyaoTnAVL9J0aRirtDvt6LLGzq5ysI/MgW/
	17jYs7KXDDGTyuYvngyAvXS3CPfR+doQoEi1OuHcgtCRxviP2X2G8ab49ZXsn5lWWEyZGL
	JzQCyfCxqMm7C2Kx2GzFeXln0qfzHNs=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-664-H7PnVUJSPnyZZYxhRCt2Pw-1; Wed,
 18 Nov 2026 07:51:40 -0500
X-MC-Unique: H7PnVUJSPnyZZYxhRCt2Pw-1
X-Mimecast-MFC-AGG-ID: H7PnVUJSPnyZZYxhRCt2Pw_1795006299
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id D4A6019560A2;
	Wed, 18 Nov 2026 12:51:38 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 34EF61800543;
	Wed, 18 Nov 2026 12:51:38 +0000 (UTC)
From: Abhinandan Ekande <aekande@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: dhowells@redhat.com,
	linux-nfs@vger.kernel.org,
	aekande@redhat.com
Subject: [PATCH v3 3/3] NFS: only fall back to the legacy read path when fscache is absent
Date: Wed, 18 Nov 2026 07:51:35 -0500
Message-ID: <20261118125135.1991518-4-aekande@redhat.com>
In-Reply-To: <20261118125135.1991518-1-aekande@redhat.com>
References: <20261118125135.1991518-1-aekande@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

nfs_read_folio() tries the netfs read path first and falls back to the
legacy path on any non-zero return:

      ret = nfs_netfs_read_folio(file, folio);
      if (ret)
              ret = nfs_do_read_folio(file, folio);

That fallback exists for inodes without an fscache cookie, where
nfs_netfs_read_folio() returns -ENOBUFS before doing any work. Every
other error also takes it, and that is a problem, because
netfs_read_folio() unlocks the folio on all of its error exits,
and failures during the read itself are unlocked by
netfs_unlock_read_folio() during collection. Either way
nfs_do_read_folio() is handed a already unlocked folio.

nfs_do_read_folio() issues its READ RPCs anyway. Its
folio_wait_locked_killable() returns immediately because there is no
lock to wait on, so it returns 0 to the VFS while those RPCs are still
in flight.

Fix it by taking the fallback only for -ENOBUFS, the one case it was
written for. nfs_netfs_read_folio() returns -ENOBUFS only from its own
test for a missing cookie, before netfs_read_folio() is called, and
netfs_read_folio() itself cannot return it: its single -ENOBUFS source,
netfs_begin_cache_read(), is left out of the error set that aborts the
read and instead falls through to an uncached read.
nfs_readahead() needs no equivalent change, as nfs_netfs_readahead()
returns only 0 or -ENOBUFS and its fallback is already restricted to
the no-cookie case.

Fixes: 000dbe0bec05 ("NFS: Convert buffered read paths to use netfs when fscache is enabled")
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Abhinandan Ekande <aekande@redhat.com>
---
 fs/nfs/read.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 8d73fbd59d7f..61c803fb683c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -432,7 +432,7 @@ int nfs_read_folio(struct file *file, struct folio *folio)
 		goto out_unlock;
 
 	ret = nfs_netfs_read_folio(file, folio);
-	if (ret)
+	if (ret == -ENOBUFS)
 		ret = nfs_do_read_folio(file, folio);
 out:
 	trace_nfs_aop_readpage_done(inode, pos, len, ret);
-- 
2.55.0

