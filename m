Received: from mail.synology.com (mail.synology.com [211.23.38.101])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E01DA3AD50E
	for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2026 06:05:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=211.23.38.101
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781244364; cv=none; b=Ncq0a42sez7aaNyJBy0yeuQl64mUcs65XIwUG3kwClacrBods87ndFEsm8ijA+MBwHo0y1nn1puNODdqvt93NPcakG62NpG22dQCnveCRyTvjMyyVdwKAZjiLUzFHG8AyzL0+cihSY0yWyKNDEgjKpZFoa/TRqwCctxwHxtem3E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781244364; c=relaxed/simple;
	bh=brmIKHGp0VkDmm+hzKWLZXQmDj0T3SDAKVZB5VKzEkM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=MC3hReBz6x2jxlvxof9YXrgTCAXaezxlmp1h1Ib61k6xCLSerskB1PCn/iSAW8xwUFg09mETniJ/3cFnyMjpJs7VpHv44UOgfEphv1ZFB95l7cfLylstC9hX2q9uMyRcV+VDKt44jNqqqBHGltPjhdTR5aZPwCWFv+ZTR8MjLhY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=synology.com; spf=pass smtp.mailfrom=synology.com; dkim=pass (1024-bit key) header.d=synology.com header.i=@synology.com header.b=BPPBr37X; arc=none smtp.client-ip=211.23.38.101
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=synology.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=synology.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=synology.com header.i=@synology.com header.b="BPPBr37X"
From: robbieko <robbieko@synology.com>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=synology.com;
	s=123; t=1781244348;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=8KEv6DCuT7xcY/4Bx/GLR2ejuxKSn1Gw0brPjZuFOJ0=;
	b=BPPBr37X9HW3eoIQ78l3373njFgWAye9aKU0FNx54vRiOldPfLPjrgCbEcHCJGr0TbmXjv
	upixxLXREKLRPbTUMTyEVHsvO8Br65B6tV3jH+RWbOGcgjhWbJFDS6kLDBrQJM3zkzPqGY
	ht7K43wP6yi4f/7TAMdKgqBk925XbfE=
To: linux-nfs@vger.kernel.org
Cc: Robbie Ko <robbieko@synology.com>
Subject: [PATCH 1/2] nfsd: reject out-of-range nseconds in setattr atime/mtime
Date: Fri, 12 Jun 2026 14:05:08 +0800
Message-ID: <20260612060539.4137523-1-robbieko@synology.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Synology-Spam-Status: score=0, required 6, WHITELIST_FROM_ADDRESS 0
X-Synology-Spam-Flag: no
X-Synology-Virus-Status: no
X-Synology-MCP-Status: no
X-Synology-Auth: pass
Content-Type: text/plain

From: Robbie Ko <robbieko@synology.com>

A client can send a SETATTR (and, for NFSv3, a file creation) carrying
an atime or mtime whose nseconds field is out of range. The value is
well-formed on the wire and decodes cleanly into a valid uint32, but it
is not a valid timespec64: tv_nsec must be less than NSEC_PER_SEC.

Nothing in the path clamps it. notify_change() runs the time through
timestamp_truncate(), which does not reduce tv_nsec below NSEC_PER_SEC
when the filesystem supports nanosecond granularity (s_time_gran == 1),
and the inode atime/mtime setters store it verbatim (only ctime is
normalized, via inode_set_ctime_to_ts()).

The un-normalized value then corrupts on-disk metadata. ext4's
ext4_encode_extra_time() shifts tv_nsec left by EXT4_EPOCH_BITS; an
out-of-range value overflows the 32-bit extra field and clobbers the
seconds-epoch bits, so the stored seconds (and thus the year) are wrong
on read-back. XFS with bigtime mis-stores the timestamp for the same
reason. There is no WARN_ON anywhere in the path to catch it.

Validate the client-supplied atime/mtime in nfsd_setattr(), which is
the common choke point for SETATTR and for the create paths (via
nfsd_create_setattr()), and covers both NFSv2 and NFSv3. The check is
done up front, before any resources are acquired, so no cleanup path is
involved; RFC 1813 Section 2.6 leaves error precedence to the
implementation. Return NFS3ERR_INVAL (NFSERR_INVAL for NFSv2), which
RFC 1813 lists for SETATTR and describes as the error for a value the
server 'can not store ... in its own representation'. The client maps
this to EINVAL.

Only client-supplied times are checked: SET_TO_SERVER_TIME requests
carry no client value and are filled in by the server. The NFSv2 Sun
'set both to now' convention clears ATTR_[AM]TIME_SET in the SETATTR
proc before nfsd_setattr() runs, so it is unaffected. The sattrguard3
ctime is deliberately left alone: an out-of-range guard simply never
matches the object's ctime and yields NFS3ERR_NOT_SYNC via the existing
guardtime comparison, which is the protocol-correct outcome rather than
rejecting the request.

NFSv4 already rejects such values in nfsd4_decode_nfstime4(), so they do
not reach this check on that path.

The lack of validation is long-standing and predates the git history of
this code, so no Fixes: tag is provided. This is a data-integrity fix
and is a candidate for LTS backport.

Signed-off-by: Robbie Ko <robbieko@synology.com>
---
 fs/nfsd/vfs.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index eafdf7b7890f..763ef2e8dba5 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -515,6 +515,20 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	trace_nfsd_vfs_setattr(rqstp, fhp, iap, guardtime);
 
+	/*
+	 * Reject a client-supplied atime or mtime whose tv_nsec is out of
+	 * range. Such a value is well-formed on the wire but is not a valid
+	 * timespec64; storing it verbatim can corrupt on-disk timestamps
+	 * (for example, ext4 packs tv_nsec << 2 alongside epoch bits).
+	 * Reject it before acquiring any resources. RFC 1813 Section 2.6
+	 * leaves error precedence to the implementation.
+	 */
+	if (((iap->ia_valid & ATTR_ATIME_SET) &&
+	     (u32)iap->ia_atime.tv_nsec >= NSEC_PER_SEC) ||
+	    ((iap->ia_valid & ATTR_MTIME_SET) &&
+	     (u32)iap->ia_mtime.tv_nsec >= NSEC_PER_SEC))
+		return nfserr_inval;
+
 	if (iap->ia_valid & ATTR_SIZE) {
 		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
 		ftype = S_IFREG;
-- 
2.43.0


Disclaimer: The contents of this e-mail message and any attachments are confidential and are intended solely for addressee. The information may also be legally privileged. This transmission is sent in trust, for the sole purpose of delivery to the intended recipient. If you have received this transmission in error, any use, reproduction or dissemination of this transmission is strictly prohibited. If you are not the intended recipient, please immediately notify the sender by reply e-mail or phone and delete this message and its attachments, if any.
