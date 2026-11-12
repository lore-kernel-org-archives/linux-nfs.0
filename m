Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794512554;
	b=l5ZAd7tJYLKMFTNL6phrUehXZIk3C5G+NR4FhtZB5kr2BRjwhr4cWNHQkJMaIDPPx84+
	 8BCSkIXv8bhIy1sefCDsgkzNz4TRZA9mSuPQkvNgV3V7Wn2XdgJxtLmdMbUYbRC6qDYlV
	 faidkO6At+f1V0p5vDe6VNKyCwHqI+YECPlL8VzdMhWPIhUJCu8Ovj0zpHd2GLQNtpszr
	 x7DkeoZK6PeA2cWS/+9Zg1VxmUmWmYgahbdoSDQrOSGdPEFWdQJCavQ6mBLrqgsloS3Gj
	 5ivUWqou/jLhyJrDzVvgJlN9DdaLFJ5Ufbyl+RiS2C5abnGhKc390vHzk9zsZszY2/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794512554;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=A5HvVi1xgUngjwpQDrEh25rS5CVp1KhxN453iZLjXWk=;
	b=rhBuKXolY9JRTvQubcLL6V8/OGzpEhFuxz5Vjsd8qIfR4I9xwjg+IpjAmrvQl9nzRdpn
	 xIqC63H4QOa+pHlhb6yOuSkktDzsSxQqntfZHaq0p5mbA4Ry4LUcaLIAyzpJTEDAhl1U5
	 qr35VlMCIAocphamNXGg4KknOtZ6TtV70FMhOdXiFGT+jya/fN7sI7kBNoJOeGSMEGa1o
	 uK2X0dGhkM8jE3BJgzNGrH0aGcBwD8Lnh7YeyZzIy4uirfJxEhU/tcZynrFzp0e3k9mQX
	 PNTwbXb6bNwwraGK2wI806ykabMDoiKVCj/o6D7S9Fn219KLbd0oAcQgeLhe9olrimA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=WULzOtUU;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5EC5606A321
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 19:42:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A5EC5606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=WULzOtUU
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794512552;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=A5HvVi1xgUngjwpQDrEh25rS5CVp1KhxN453iZLjXWk=;
	b=WULzOtUU/kw8cTiP2Abo+iqgUi55EQFwbhfVozq/HaZLfALcMeFUZtf21JAbMqeI/EpSPy
	lTGo+X2puzKE8fSrg+1tQevcfHMC0sDiL4mhlBMzYdhnToocISluRm9j8LnrzNL1NPwTO7
	o7OtVeGg3qjZ+10QMr3e5NWycpFeDgc=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-245-paj-p7rENLSaTfU_qb55Tg-1; Thu,
 12 Nov 2026 14:42:29 -0500
X-MC-Unique: paj-p7rENLSaTfU_qb55Tg-1
X-Mimecast-MFC-AGG-ID: paj-p7rENLSaTfU_qb55Tg_1794512548
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id F3506195606B;
	Thu, 12 Nov 2026 19:42:27 +0000 (UTC)
Received: from okorniev-mac.redhat.corp (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 12DD318004FC;
	Thu, 12 Nov 2026 19:42:26 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS: trace the NFS_LAYOUT_DRAIN wait in pnfs_update_layout()
Date: Thu, 12 Nov 2026 14:42:24 -0500
Message-ID: <20261112194224.34455-3-okorniev@redhat.com>
In-Reply-To: <20261112194224.34455-1-okorniev@redhat.com>
References: <20261112194224.34455-1-okorniev@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

pnfs_update_layout() can park a task on NFS_LAYOUT_DRAIN until the last
outstanding LAYOUTGET completes, but that branch emits no tracepoint, so
there is no record of a task entering the wait. The pnfs_update_layout
trace event also reports neither plh_flags nor plh_outstanding, which
are the two values that decide whether the wait is entered and when it
ends. Working out why a task is stuck there currently means reading
plh_flags and plh_outstanding out of a crash dump.

Add a PNFS_UPDATE_LAYOUT_DRAIN reason and emit it before wait_on_bit(),
and report plh_flags and plh_outstanding from the trace event.

Assisted-by: Claude Opus 5
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/nfs/nfs4trace.h   | 42 +++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.c        |  2 ++
 include/linux/nfs4.h |  1 +
 3 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index b5c89eeef2bc..a37cf706e1b4 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1982,11 +1982,38 @@ TRACE_DEFINE_ENUM(PNFS_UPDATE_LAYOUT_EXIT);
 		{ PNFS_UPDATE_LAYOUT_FOUND_CACHED, "found cached" },	\
 		{ PNFS_UPDATE_LAYOUT_RETURN, "layoutreturn" },		\
 		{ PNFS_UPDATE_LAYOUT_BLOCKED, "layouts blocked" },	\
+		{ PNFS_UPDATE_LAYOUT_DRAIN, "draining" },		\
 		{ PNFS_UPDATE_LAYOUT_INVALID_OPEN, "invalid open" },	\
 		{ PNFS_UPDATE_LAYOUT_RETRY, "retrying" },	\
 		{ PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET, "sent layoutget" }, \
 		{ PNFS_UPDATE_LAYOUT_EXIT, "exit" })
 
+TRACE_DEFINE_ENUM(NFS_LAYOUT_RO_FAILED);
+TRACE_DEFINE_ENUM(NFS_LAYOUT_RW_FAILED);
+TRACE_DEFINE_ENUM(NFS_LAYOUT_BULK_RECALL);
+TRACE_DEFINE_ENUM(NFS_LAYOUT_RETURN);
+TRACE_DEFINE_ENUM(NFS_LAYOUT_RETURN_LOCK);
+TRACE_DEFINE_ENUM(NFS_LAYOUT_RETURN_REQUESTED);
+TRACE_DEFINE_ENUM(NFS_LAYOUT_INVALID_STID);
+TRACE_DEFINE_ENUM(NFS_LAYOUT_FIRST_LAYOUTGET);
+TRACE_DEFINE_ENUM(NFS_LAYOUT_INODE_FREEING);
+TRACE_DEFINE_ENUM(NFS_LAYOUT_HASHED);
+TRACE_DEFINE_ENUM(NFS_LAYOUT_DRAIN);
+
+#define show_pnfs_layout_flags(flags)					\
+	__print_flags(flags, "|",					\
+		{ BIT(NFS_LAYOUT_RO_FAILED), "RO_FAILED" },		\
+		{ BIT(NFS_LAYOUT_RW_FAILED), "RW_FAILED" },		\
+		{ BIT(NFS_LAYOUT_BULK_RECALL), "BULK_RECALL" },		\
+		{ BIT(NFS_LAYOUT_RETURN), "RETURN" },			\
+		{ BIT(NFS_LAYOUT_RETURN_LOCK), "RETURN_LOCK" },		\
+		{ BIT(NFS_LAYOUT_RETURN_REQUESTED), "RETURN_REQUESTED" }, \
+		{ BIT(NFS_LAYOUT_INVALID_STID), "INVALID_STID" },	\
+		{ BIT(NFS_LAYOUT_FIRST_LAYOUTGET), "FIRST_LAYOUTGET" },	\
+		{ BIT(NFS_LAYOUT_INODE_FREEING), "INODE_FREEING" },	\
+		{ BIT(NFS_LAYOUT_HASHED), "HASHED" },			\
+		{ BIT(NFS_LAYOUT_DRAIN), "DRAIN" })
+
 TRACE_EVENT(pnfs_update_layout,
 		TP_PROTO(struct inode *inode,
 			loff_t pos,
@@ -2006,6 +2033,8 @@ TRACE_EVENT(pnfs_update_layout,
 			__field(enum pnfs_iomode, iomode)
 			__field(int, layoutstateid_seq)
 			__field(u32, layoutstateid_hash)
+			__field(unsigned long, layoutflags)
+			__field(int, outstanding)
 			__field(long, lseg)
 			__field(enum pnfs_update_layout_reason, reason)
 		),
@@ -2017,6 +2046,14 @@ TRACE_EVENT(pnfs_update_layout,
 			__entry->count = count;
 			__entry->iomode = iomode;
 			__entry->reason = reason;
+			if (lo != NULL) {
+				__entry->layoutflags = lo->plh_flags;
+				__entry->outstanding =
+				atomic_read(&lo->plh_outstanding);
+			} else {
+				__entry->layoutflags = 0;
+				__entry->outstanding = 0;
+			}
 			if (lo != NULL && pnfs_layout_is_valid(lo)) {
 				__entry->layoutstateid_seq =
 				be32_to_cpu(lo->plh_stateid.seqid);
@@ -2031,7 +2068,8 @@ TRACE_EVENT(pnfs_update_layout,
 		TP_printk(
 			"fileid=%02x:%02x:%llu fhandle=0x%08x "
 			"iomode=%s pos=%llu count=%llu "
-			"layoutstateid=%d:0x%08x lseg=0x%lx (%s)",
+			"layoutstateid=%d:0x%08x layoutflags=%s "
+			"outstanding=%d lseg=0x%lx (%s)",
 			MAJOR(__entry->dev), MINOR(__entry->dev),
 			(unsigned long long)__entry->fileid,
 			__entry->fhandle,
@@ -2039,6 +2077,8 @@ TRACE_EVENT(pnfs_update_layout,
 			(unsigned long long)__entry->pos,
 			(unsigned long long)__entry->count,
 			__entry->layoutstateid_seq, __entry->layoutstateid_hash,
+			show_pnfs_layout_flags(__entry->layoutflags),
+			__entry->outstanding,
 			__entry->lseg,
 			show_pnfs_update_layout_reason(__entry->reason)
 		)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 21f3c684d196..e89521128f58 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2261,6 +2261,8 @@ pnfs_update_layout(struct inode *ino,
 	 */
 	if (test_bit(NFS_LAYOUT_DRAIN, &lo->plh_flags) &&
 	    atomic_read(&lo->plh_outstanding) != 0) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
+					 PNFS_UPDATE_LAYOUT_DRAIN);
 		spin_unlock(&ino->i_lock);
 		lseg = ERR_PTR(wait_on_bit(&lo->plh_flags, NFS_LAYOUT_DRAIN,
 					   TASK_KILLABLE));
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 41b7cdcc674f..b043cb925093 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -712,6 +712,7 @@ enum pnfs_update_layout_reason {
 	PNFS_UPDATE_LAYOUT_RETURN,
 	PNFS_UPDATE_LAYOUT_RETRY,
 	PNFS_UPDATE_LAYOUT_BLOCKED,
+	PNFS_UPDATE_LAYOUT_DRAIN,
 	PNFS_UPDATE_LAYOUT_INVALID_OPEN,
 	PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET,
 	PNFS_UPDATE_LAYOUT_EXIT,
-- 
2.55.0

