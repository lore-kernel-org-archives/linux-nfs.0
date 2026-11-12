Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794512552;
	b=eyVWH4Y3+1zgNwwRgNw+4vWzywYcZmFDceEz7oWZlfRWNJ9IxvrkWifhmpxEVttXYK1L
	 WD96p/9xvkPUgNFcvMvrL76oN6808ZzuczI5ZioSKCUS6f7V9xXynaZkqQ8zxcoMovcHZ
	 K+kpHS0g0eonufBvdrtmm2/qB8bokCGzgvr2KGfEMJhOYE7/VOxmJdZ/NsIXAHdC2K3mr
	 hif/Iwp52Ns/OH7yK96MwEr91MtMuxQqPysjLubdnXfwsTcisJuudvyhDrgEBFNADAwaS
	 C2/8cZSPWZc3c1M+40gbT1zfI4ZzhtyVOWfn4n0FvMDFhcfPBMi55znEhl0HEDqZiBg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794512552;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=G39iVuHC1pIYeehKs+QcqB/zWbvfEpdq1Nc6kMtnSHo=;
	b=gX8Vupif3VDSs0LElDjtYnzfG7jS0oJDMd3KII7atFsD8iwpr5GegUHDzZzPqkW81ZFe
	 k7b8YbuS/cApQd2MYscSlba45u7A1agOwwFnE19dBqnXAAEDaaUNlCa2A04OHV5Bm0nW6
	 Zr6kEKUSSvAak04rBosWtEQPuPmXfF45Dn5F730sy/y8uXyg+HH2Y769GmQCO3JfOng8g
	 n33xZ2PIUM9WDKnbTVPtzR2oqemY3HHnBOfSBdKsboqdVk9HE7ape8IeZKxv+VlQFH4TA
	 tjOXITz7hV0XQKG18a0vcezNMmv73STR+WSDI2id5RzAtlwS2RZns1rCrpa6aDpNiVA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=IMudVcxp;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 518CC606A327
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 19:42:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 518CC606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=IMudVcxp
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794512551;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=G39iVuHC1pIYeehKs+QcqB/zWbvfEpdq1Nc6kMtnSHo=;
	b=IMudVcxp1O0+g3iz2gJijDEJHsMaIMHPQWZYd8XJwLeMSZhl6RBaJ+2mUSB3ko3pSyykv9
	jAKI90BJ3bi3nKYemsNQvXu/65SHjHvTRBCwwm9P1uvd9De5HySICDQtU5AZ1vAfWMP6KI
	KSLvbNnD2UKe1W7K3wYl+vEg8L0R9uM=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-250-hvr3pOjXN9KaNUg4Mt9uEA-1; Thu,
 12 Nov 2026 14:42:27 -0500
X-MC-Unique: hvr3pOjXN9KaNUg4Mt9uEA-1
X-Mimecast-MFC-AGG-ID: hvr3pOjXN9KaNUg4Mt9uEA_1794512547
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id CECF019560BF;
	Thu, 12 Nov 2026 19:42:26 +0000 (UTC)
Received: from okorniev-mac.redhat.corp (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 32A5418004FC;
	Thu, 12 Nov 2026 19:42:26 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pNFS: don't set NFS_LAYOUT_DRAIN when there is nothing to drain
Date: Thu, 12 Nov 2026 14:42:23 -0500
Message-ID: <20261112194224.34455-2-okorniev@redhat.com>
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

A task can get stuck indefinitely in pnfs_update_layout() waiting on
NFS_LAYOUT_DRAIN, with the layout header showing plh_flags = 0x640
(NFS_LAYOUT_INVALID_STID | NFS_LAYOUT_HASHED | NFS_LAYOUT_DRAIN) and
plh_outstanding = 0.

NFS_LAYOUT_DRAIN is only ever cleared by nfs_layoutget_end(), when the
last outstanding LAYOUTGET completes. Setting it once plh_outstanding
has already reached zero leaves it set with nothing left that could
clear it.

Commit 5248d8474e59 ("pNFS: fix a missing wake up while waiting on
NFS_LAYOUT_DRAIN") addressed one instance of this by making
pnfs_mark_layout_stateid_invalid() a no-op when NFS_LAYOUT_INVALID_STID
was already set, so the bit could not be set twice for an already
invalid layout. That guard is lifted as soon as a LAYOUTGET succeeds:
pnfs_layout_process() calls pnfs_set_layout_stateid(), which clears
NFS_LAYOUT_INVALID_STID, and it does so before pnfs_update_layout()
calls nfs_layoutget_end(). The original race then reopens:

  1. cpu a: waiter tests NFS_LAYOUT_DRAIN (1) and plh_outstanding (1)
  2. cpu b: pnfs_layout_process() clears NFS_LAYOUT_INVALID_STID, then
            nfs_layoutget_end() clears NFS_LAYOUT_DRAIN and wakes
  3. cpu c: pnfs_mark_layout_stateid_invalid() sets NFS_LAYOUT_DRAIN
            again, now with plh_outstanding == 0
  4. cpu a: calls wait_on_bit() and sleeps forever

In the vmcore this was found in, cpu c was a data server I/O completing
with an "invalidate layout" error, reaching
pnfs_mark_layout_stateid_invalid() through
filelayout_async_handle_error() -> pnfs_destroy_layout(). The surviving
layout segment had pls_seq == 1, matching both plh_stateid.seqid and
plh_barrier, showing a LAYOUTGET had completed successfully and cleared
NFS_LAYOUT_INVALID_STID before it was set again.

Rather than extending the NFS_LAYOUT_INVALID_STID guard, enforce the
invariant the bit relies on: only set NFS_LAYOUT_DRAIN when there is an
outstanding LAYOUTGET to drain. Callers hold inode->i_lock, which stops
plh_outstanding from growing, but nfs_layoutget_end() runs without it
and may be dropping the last reference concurrently, so re-check
plh_outstanding after setting the bit and clear it again if that
LAYOUTGET got there first.

initiate_file_draining() sets the bit under the same lock with the same
constraint, so convert it as well.

Fixes: 880265c77ac4 ("pNFS: Avoid a live lock condition in pnfs_update_layout()")
Assisted-by: Claude Opus 5
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/nfs/callback_proc.c |  2 +-
 fs/nfs/pnfs.c          | 34 +++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h          |  1 +
 3 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 9d836cb72e78..47ec0f95a465 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -299,7 +299,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		rv = NFS4_OK;
 		break;
 	case -ENOENT:
-		set_bit(NFS_LAYOUT_DRAIN, &lo->plh_flags);
+		pnfs_set_layout_drain(lo);
 		/* Embrace your forgetfulness! */
 		rv = NFS4ERR_NOMATCHING_LAYOUT;
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6dc00233e837..21f3c684d196 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -446,6 +446,38 @@ bool nfs4_layout_refresh_old_stateid(nfs4_stateid *dst,
 	return ret;
 }
 
+/*
+ * Ask any LAYOUTGETs that are still in flight to be forgotten, and make
+ * new callers of pnfs_update_layout() wait for them.
+ *
+ * NFS_LAYOUT_DRAIN is only ever cleared by nfs_layoutget_end(), when the
+ * last outstanding LAYOUTGET completes. Setting it once plh_outstanding
+ * has already reached zero would leave it set with nothing left that
+ * could clear it, and a waiter that reaches wait_on_bit() would never be
+ * woken again.
+ *
+ * Callers hold the inode->i_lock, so plh_outstanding cannot grow here,
+ * but nfs_layoutget_end() runs without it and may be dropping the last
+ * reference concurrently. Re-check once the bit is visible, and clear it
+ * again if that LAYOUTGET got there first.
+ *
+ * Note that caller must hold inode->i_lock.
+ */
+void pnfs_set_layout_drain(struct pnfs_layout_hdr *lo)
+{
+	if (atomic_read(&lo->plh_outstanding) == 0)
+		return;
+	set_bit(NFS_LAYOUT_DRAIN, &lo->plh_flags);
+	/* Pairs with the atomic_dec_and_test() in nfs_layoutget_end() */
+	smp_mb__after_atomic();
+	if (atomic_read(&lo->plh_outstanding) == 0 &&
+	    test_and_clear_bit(NFS_LAYOUT_DRAIN, &lo->plh_flags)) {
+		/* Order the clear against the waitqueue check in wake_up_bit() */
+		smp_mb__after_atomic();
+		wake_up_bit(&lo->plh_flags, NFS_LAYOUT_DRAIN);
+	}
+}
+
 /*
  * Mark a pnfs_layout_hdr and all associated layout segments as invalid
  *
@@ -471,7 +503,7 @@ pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		pnfs_clear_lseg_state(lseg, lseg_list);
 	pnfs_clear_layoutreturn_info(lo);
 	pnfs_free_returned_lsegs(lo, lseg_list, &range, 0);
-	set_bit(NFS_LAYOUT_DRAIN, &lo->plh_flags);
+	pnfs_set_layout_drain(lo);
 	if (test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags) &&
 	    !test_and_set_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags))
 		pnfs_clear_layoutreturn_waitbit(lo);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2774d4adf4c3..9331206cd250 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -325,6 +325,7 @@ int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				const struct nfs4_deviceid *devid);
 int pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		struct list_head *lseg_list);
+void pnfs_set_layout_drain(struct pnfs_layout_hdr *lo);
 bool pnfs_roc(struct inode *ino, struct nfs4_layoutreturn_args *args,
 	      struct nfs4_layoutreturn_res *res, const struct cred *cred,
 	      bool sync);
-- 
2.55.0

