Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794021162;
	b=NNnflI1lvmn+HTnfhP0KyLx9ac/B4dH+1edzScbEJQsw/zjIoL6HVCcQAU2fO93kUe+Z
	 vEcHj59s4D1seLXkVeUHm8G+b70AGCVpW9JLDmSyOAFwQZPP8a7t6F5F6EVFzCv6QsiJp
	 1i0EDnrhpdgsMSG/IYIfnZIGDYKZeM067Z5RqPth24QulU409+VSyeJRFGTOICu8ufeLm
	 HN1McZQIQq4T90e54uJVXXOJF7dw9rrrdnHkAdIbz5JgJCTdr4HSrzQYYCxZWT8vjp6WU
	 O68b1TnSlzRsuYJjbGrANUrTah/G4rdPpbJF176NjIU6rfr0Ut7Rh/kx8HSh3TgN+Ww==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794021162;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=ux79MFHwvCYXQCOOBXTOLeM1EVRNtEb+0L73/nT9cMI=;
	b=dpfQChs3kXlLtlIu5edi//OGCZDKTNkQ81lxip65DY/INhNgSk8qRKJwRz826rYBCEFq
	 wii2BSLCH3o0SoGGPatA4YzhwCUTRp90pS41v/MB7NFDhGKNqPpF303skR/7fIrt9wT88
	 pLbUJqBVWvRbhN1Rji28XV2Dkt3iJemtN02ejIfhMSUtm8uElX3cy5tbUWEp976OPRUUM
	 QBtHohdroPAx+Gt9LSID1Be7ZljJGBrhA7KmjjJanT7u91rujvwBVYd1bRP/rGZpG66n6
	 JHBFqlBaX52Dzx4SZeTNXeQo7q7kRpaTwYQKIiSCtCIg0Apv4idB1Oud7uIumaYUvYg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=cS86wMqq;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 724E8606A32F
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 03:12:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 724E8606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=cS86wMqq
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794021160;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ux79MFHwvCYXQCOOBXTOLeM1EVRNtEb+0L73/nT9cMI=;
	b=cS86wMqqZEN0ebgHNZLC681ORLP5YGoO3s6QBiyIFBVe0P+9L3cLZC9pn1A2FvUDPM90/4
	zM8+Eh/BAa2YZ6inzGXAlcXMo7bAylk65chu8AOuTL/KaRa2UwFMmXEaFwMf3O7rWcyYyG
	QUyefW2iLgi+fqJbE0n6B1C46Jn8yBw=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-621-PdDSB3U1Nf-Vs4MmArErqw-1; Fri,
 06 Nov 2026 22:12:37 -0500
X-MC-Unique: PdDSB3U1Nf-Vs4MmArErqw-1
X-Mimecast-MFC-AGG-ID: PdDSB3U1Nf-Vs4MmArErqw_1794021156
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 2AFC2180057B;
	Sat,  7 Nov 2026 03:12:36 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.64.6])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 79A5A187C364;
	Sat,  7 Nov 2026 03:12:35 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: remember that the server may send CB_NOTIFY_LOCK
Date: Fri,  6 Nov 2026 22:12:32 -0500
Message-ID: <20261107031232.97464-3-okorniev@redhat.com>
In-Reply-To: <20261107031232.97464-1-okorniev@redhat.com>
References: <20261107031232.97464-1-okorniev@redhat.com>
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

Two processes contending for a POSIX lock on one file see occasional
acquisitions of almost exactly 1, 3 or 7 seconds when the client holds a
delegation, although the holder releases within microseconds.

nfs4_retry_setlk() only parks a waiter on clp->cl_lock_waitq when
NFS_STATE_MAY_NOTIFY_LOCK is set. Otherwise it uses
nfs4_retry_setlk_simple(), which has no waitqueue at all and sleeps on a
bare timeout starting at NFS4_LOCK_MINTIMEOUT and doubling, so a waiter
that loses one poll waits a second, then two, then four.

NFS_STATE_MAY_NOTIFY_LOCK is set in _nfs4_open_and_get_state() from the
OPEN reply rflags. It describes the server, but is recorded per
nfs4_state and can only be learned from a reply. Once a delegation is
held, further opens are satisfied from it with no OPEN on the wire, so
o_res.rflags is zero and the new state starts out believing no callback
can arrive, even though the open that obtained the delegation was told
otherwise.

Record the capability on the nfs_client the first time an OPEN reply
carries it, and apply it to every state built for that client.
nfs_client is the right scope: the flag describes one server,
CB_NOTIFY_LOCK arrives on that client's backchannel, and cl_lock_waitq
is per nfs_client.

This also covers a case the per-state flag misses. After the delegation
is recalled the state has neither NFS_DELEGATED_STATE nor
NFS_STATE_MAY_NOTIFY_LOCK, so locks go to the server and the server does
send CB_NOTIFY_LOCK, but the client is in the backoff loop and ignores
it.

Fixes: a8ce377a5db8 ("nfs: track whether server sets MAY_NOTIFY_LOCK flag")
Assisted-by: Claude Opus 5
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/nfs/nfs4proc.c         | 2 ++
 include/linux/nfs_fs_sb.h | 1 +
 2 files changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 50d36dc58fc6..2b01421edee7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3093,6 +3093,8 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	if (server->caps & NFS_CAP_POSIX_LOCK)
 		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
 	if (opendata->o_res.rflags & NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK)
+		server->nfs_client->cl_may_notify_lock = true;
+	if (server->nfs_client->cl_may_notify_lock)
 		set_bit(NFS_STATE_MAY_NOTIFY_LOCK, &state->flags);
 	if (opendata->o_res.rflags & NFS4_OPEN_RESULT_PRESERVE_UNLINKED)
 		set_bit(NFS_INO_PRESERVE_UNLINKED, &NFS_I(state->inode)->flags);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 416c6f39f31d..6e1b0332f2de 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -120,6 +120,7 @@ struct nfs_client {
 #define NFS_SP4_MACH_CRED_COMMIT   6	/* COMMIT */
 #define NFS_SP4_MACH_CRED_PNFS_CLEANUP  7 /* LAYOUTRETURN */
 	wait_queue_head_t	cl_lock_waitq;
+	bool			cl_may_notify_lock;
 #endif /* CONFIG_NFS_V4 */
 
 	/* Our own IP address, as a null-terminated string.
-- 
2.52.0

