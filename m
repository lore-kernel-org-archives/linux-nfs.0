Received: from mail.synology.com (mail.synology.com [211.23.38.101])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 507513D47C6
	for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2026 05:40:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=211.23.38.101
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781588440; cv=none; b=bNBes8QUl18CXnFe3jYTtoIfe2jt6kwrnnWC3BtAdSQHkaGAMm20rKPKxFkcHmiCW9Yq9FpFqoBcM5o7oWbDNS9kIGMXlsuIQq3o2zIeHxx+PG1NVHsrCn1XOUzV0XNeHW5Isq4U1QfxAnpZI14at8EUAhzDogFNBm++L2NeEUY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781588440; c=relaxed/simple;
	bh=a+Mk0j4v+kR/I4EtWIZPKBmEOfFDyBIskaXAZhUgxqQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=Q3J4T6/vX5t7FwjHFL9/iMAGnQo36WNYF3bljdhv/5Xr3luumnf7L0aGCRwl+GJ6+FVu8pxjlSdKeGW77XhLHnTgzHBfq5tyhV2Ts3oF556DXsdnUd3XvTOsBoP5lKOfY87PJtMCXLW+JesHSdOFLeStXido9KlbQYIqThr8BsQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=synology.com; spf=pass smtp.mailfrom=synology.com; dkim=pass (1024-bit key) header.d=synology.com header.i=@synology.com header.b=Nz4GEqia; arc=none smtp.client-ip=211.23.38.101
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=synology.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=synology.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=synology.com header.i=@synology.com header.b="Nz4GEqia"
From: robbieko <robbieko@synology.com>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=synology.com;
	s=123; t=1781588433;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=IHPd5k7g0vSdHd/ErAdZjkMp+KXeHv95oi/fQ7Renpo=;
	b=Nz4GEqiaCVymKoTRt7ExV3A1qISnWBosrt6w/OZ6sSvoMBvW2Ncyycr3mi6Y8lTXOMAr8k
	xE6WrdI/UzHxg8142ogEAiGzSApubOIeARdEv2NbbvTpnBsVCMLsy/XRtPautCg+uE8smP
	zeZsyDnHsUxW3yQqj4EFthH0YC6x9rs=
To: linux-nfs@vger.kernel.org
Cc: Robbie Ko <robbieko@synology.com>
Subject: [PATCH v3 1/3] nfsd: reject out-of-range useconds in NFSv2 SETATTR/CREATE
Date: Tue, 16 Jun 2026 13:39:58 +0800
Message-ID: <20260616054027.2360930-1-robbieko@synology.com>
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

The NFSv2 sattr decoder converts the wire useconds to nanoseconds in
svcxdr_decode_sattr():

	iap->ia_atime.tv_nsec = tmp2 * NSEC_PER_USEC;

tmp2 is a u32 and NSEC_PER_USEC is 1000, so the product is computed in
unsigned long. On ILP32 that is 32 bits, and an out-of-range useconds
value such as 4294968 wraps to tv_nsec == 704. The corruption therefore
happens during decode, before any proc function can inspect the value,
and a later range check on tv_nsec would see an in-range result and
accept it.

Guard the raw useconds before the multiplication and reject values
greater than 1000000. useconds == 1000000 is kept: it is the Sun
convention for "set to the current server time", and the in-tree Linux
NFSv2 client emits it in both the atime and the mtime field for a plain
touch / utimes(file, NULL) (see encode_sattr() and
xdr_encode_current_server_time() in fs/nfs/nfs2xdr.c). Rejecting 1000000
would turn that common operation into a hard decode failure for both
SETATTR and CREATE. 1000000 * NSEC_PER_USEC is 10^9, which does not wrap
on ILP32, so the Sun convention value passes through safely; only
genuinely out-of-range values (> 1000000) are rejected. The atime and
mtime guards are therefore symmetric.

The decoder only applied the Sun convention in the mtime block, which
clears ATTR_ATIME_SET|ATTR_MTIME_SET when mtime useconds == 1000000. If a
client puts 1000000 in the atime field but not in the mtime field, the
atime block stored an out-of-range tv_nsec (10^9) and left ATTR_ATIME_SET
set, so the bogus value reached the filesystem. Apply the convention in
the atime block as well, clearing ATTR_ATIME_SET so the server uses its
current time and ignores the value. Only ATTR_ATIME_SET is cleared there;
the mtime block keeps its existing behavior, where 1000000 means "set
both atime and mtime to now".

Signed-off-by: Robbie Ko <robbieko@synology.com>
---
 fs/nfsd/nfsxdr.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index ae71e0621317..48a4e89a5f41 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -172,14 +172,45 @@ svcxdr_decode_sattr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	tmp1 = be32_to_cpup(p++);
 	tmp2 = be32_to_cpup(p++);
 	if (tmp1 != (u32)-1 && tmp2 != (u32)-1) {
+		/*
+		 * Guard the raw useconds before the unit conversion below.
+		 * tmp2 * NSEC_PER_USEC is computed in unsigned long, which is
+		 * 32 bits on ILP32, so an out-of-range value would wrap and
+		 * silently produce a bogus in-range tv_nsec. useconds ==
+		 * 1000000 is the Sun "set to current server time" convention
+		 * (see the mtime block below); allow it and reject anything
+		 * larger. Note 1000000 * NSEC_PER_USEC is 10^9, which does not
+		 * wrap on ILP32.
+		 */
+		if (tmp2 > 1000000)
+			return false;
 		iap->ia_valid |= ATTR_ATIME | ATTR_ATIME_SET;
 		iap->ia_atime.tv_sec = tmp1;
 		iap->ia_atime.tv_nsec = tmp2 * NSEC_PER_USEC;
+		/*
+		 * The Linux NFSv2 client emits useconds == 1000000 in the
+		 * atime field too (touch / utimes(file, NULL) sets ATTR_ATIME
+		 * without ATTR_ATIME_SET). Apply the Sun convention here so
+		 * the server uses its current time and ignores the bogus
+		 * tv_nsec, instead of storing an out-of-range value when the
+		 * mtime field does not also carry 1000000. Only ATTR_ATIME_SET
+		 * is cleared; the mtime block keeps its own handling, where
+		 * 1000000 means "set both atime and mtime to now".
+		 */
+		if (tmp2 == 1000000)
+			iap->ia_valid &= ~ATTR_ATIME_SET;
 	}
 
 	tmp1 = be32_to_cpup(p++);
 	tmp2 = be32_to_cpup(p++);
 	if (tmp1 != (u32)-1 && tmp2 != (u32)-1) {
+		/*
+		 * useconds == 1000000 is a valid Sun convention here (see
+		 * below); anything above that is out of range. Guard it before
+		 * the unit conversion to avoid the ILP32 wrap described above.
+		 */
+		if (tmp2 > 1000000)
+			return false;
 		iap->ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
 		iap->ia_mtime.tv_sec = tmp1;
 		iap->ia_mtime.tv_nsec = tmp2 * NSEC_PER_USEC;
-- 
2.43.0


Disclaimer: The contents of this e-mail message and any attachments are confidential and are intended solely for addressee. The information may also be legally privileged. This transmission is sent in trust, for the sole purpose of delivery to the intended recipient. If you have received this transmission in error, any use, reproduction or dissemination of this transmission is strictly prohibited. If you are not the intended recipient, please immediately notify the sender by reply e-mail or phone and delete this message and its attachments, if any.
