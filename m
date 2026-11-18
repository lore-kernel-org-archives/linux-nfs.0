Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795006301;
	b=lRIH2Kzj8lxowHdZeO05PWRADfrGvgH+KZ+QkvY7wc2Pm8XJ1fKYmJEdVcUUGqbipvGh
	 gMFoBeZBdIV8tWji8qbE7FmFcPeIBWQYwI/cIq5ejtbXVZ52Tq3K5hoPKUSPswQuaWKFo
	 MEqCc3Y5pZGRpjnScMQFWjpnKEFdVWUTt9ePfb7jyH5ZgmC41+yJ3W5I/fXPd3RLqo0iw
	 e5qnMUJvNG3TSsKsd6y2ELH3VZPd3kOyNwvHL9HpiqLNQbTnh4cNFAFJVOGr9MFtr0iZY
	 +oV4hMmW8ED6yN+SiZtGRxaQ04z10XvH9GaC2ye5tXQsFh2QqeyeBfPBUiVmxXaABsQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795006301;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=kmIzHb05k2QelXmG1lNmER/oasgGXTDA1Z4/XkET+c0=;
	b=VJ/CM221DBzQqeMYwei7pScsHxWm9bnoTSkXmVe3MurGV6wFa4MGex0RDyL4n2jYDvtv
	 5uVlZy50vdIK42Z5PwQV0FDwG8tPiwhz6hDgAlSPwG3+cQrD3a5PfBuMHDdd2UFtqbSaN
	 6zcek2mDB+qid+jOKwV6YyAbsFC2NUbm1C0bT/PTwqvByPclvE6Bzxd+6wdNcH2wJRXzP
	 3ukKuZHcmAGJe4fWm/xl/m0WV1Z1uCY9yj+KKM5icIinr6hTCdEF2WcdkPR7tdpIbvzzo
	 PkvWs3ufHQjuw/FztBk/teR5q5F3e9lSUE3VQPh+IfpeUVZPBDEyOI3l9E4e19lQUqw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=RYG1NhkI;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CF40606A320
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 12:51:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7CF40606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=RYG1NhkI
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795006299;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=kmIzHb05k2QelXmG1lNmER/oasgGXTDA1Z4/XkET+c0=;
	b=RYG1NhkIemNm149iS60Oqn58/spPNi6DZAKBvzectLQcuAB2DQOP7URgiV4IXjjHgeX01B
	7VZJX5vPzC5OZbK03pRW8SAVy41Fn6/SFEtMOueUzsSDo//91Axnd5IHsaEyxE/rxfBQku
	/gF5eiGLwxJKUj41A+cxS9yjefiLwDs=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-96-Vt_imnksMeOjuN1dn71ejA-1; Wed,
 18 Nov 2026 07:51:38 -0500
X-MC-Unique: Vt_imnksMeOjuN1dn71ejA-1
X-Mimecast-MFC-AGG-ID: Vt_imnksMeOjuN1dn71ejA_1795006297
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 3205A18005A1;
	Wed, 18 Nov 2026 12:51:37 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 831E7180054C;
	Wed, 18 Nov 2026 12:51:36 +0000 (UTC)
From: Abhinandan Ekande <aekande@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: dhowells@redhat.com,
	linux-nfs@vger.kernel.org,
	aekande@redhat.com
Subject: [PATCH v3 1/3] NFS: Accumulate transferred bytes on netfs read completion
Date: Wed, 18 Nov 2026 07:51:33 -0500
Message-ID: <20261118125135.1991518-2-aekande@redhat.com>
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

