Received: from mail.synology.com (mail.synology.com [211.23.38.101])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E32863B8BD4
	for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2026 06:05:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=211.23.38.101
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781244364; cv=none; b=WNB/VxSvlUMyMHyxT8FWXublwqRXtZ2NwiFQ5NRyFKwBKDSR4bJMaxEyfU6+YMAHotQnToIHfXT4FsS+ZStHL8DUFBF2EXkev4SvOJlzpYSlX6DOqYjDHwf6rZOwngBCuHKORGxuOgxDrFzOhJuBPV1L+45Cj874EMNd/1VKx8I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781244364; c=relaxed/simple;
	bh=CEIWwopG7VCj3AryexCOCAn/MSclU7rTs3elimyiFL8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=nxX3MSzebaufUmW9N+4cMLMemKRTFIa5gCcHs2Tpe/k65h8pj86p311bdDtbMBXXgbcBYn41VnLA1lZ1oTpQHPx0zpLaojkx3zG0Med7kQbZTvhf1wnxhn62vlJhXVYnc9cKYwCkFy82M9up0aQ6rFdsq4O3ur0FtoGo1DPijMk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=synology.com; spf=pass smtp.mailfrom=synology.com; dkim=pass (1024-bit key) header.d=synology.com header.i=@synology.com header.b=GrhZYejD; arc=none smtp.client-ip=211.23.38.101
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=synology.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=synology.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=synology.com header.i=@synology.com header.b="GrhZYejD"
From: robbieko <robbieko@synology.com>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=synology.com;
	s=123; t=1781244351;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=D4rViTvpIdvG2pVgyr7e5p+In0RCQPMguEXHbX6TVHc=;
	b=GrhZYejDNSwSDrV3sdg1DjqKNVJpjA7NyLL4LugD+nTngAMUQDIKPhAnzaVEWf21v03Hfr
	/3o0ZDlZAaoUEw4wyfJ4EZBeQPAh8G4T6H7jpyJe3xIjy+vIDNc0CrO2dFKz6jSEJ6jhIi
	plxNUuPlHJlCNws714otVThhPe4HvN8=
To: linux-nfs@vger.kernel.org
Cc: Robbie Ko <robbieko@synology.com>
Subject: [PATCH 2/2] nfsd: use NSEC_PER_SEC in nfsd4_decode_nfstime4()
Date: Fri, 12 Jun 2026 14:05:09 +0800
Message-ID: <20260612060539.4137523-2-robbieko@synology.com>
In-Reply-To: <20260612060539.4137523-1-robbieko@synology.com>
References: <20260612060539.4137523-1-robbieko@synology.com>
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

nfsd4_decode_nfstime4() open-codes the nanoseconds upper bound as the
literal (u32)1000000000. Use the named constant NSEC_PER_SEC instead,
matching the out-of-range check added for the NFSv2/NFSv3 setattr path
and improving readability. No functional change.

Signed-off-by: Robbie Ko <robbieko@synology.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2a0946c630e1..f88c26cd459f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -244,7 +244,7 @@ nfsd4_decode_nfstime4(struct nfsd4_compoundargs *argp, struct timespec64 *tv)
 		return nfserr_bad_xdr;
 	p = xdr_decode_hyper(p, &tv->tv_sec);
 	tv->tv_nsec = be32_to_cpup(p++);
-	if (tv->tv_nsec >= (u32)1000000000)
+	if (tv->tv_nsec >= NSEC_PER_SEC)
 		return nfserr_inval;
 	return nfs_ok;
 }
-- 
2.43.0


Disclaimer: The contents of this e-mail message and any attachments are confidential and are intended solely for addressee. The information may also be legally privileged. This transmission is sent in trust, for the sole purpose of delivery to the intended recipient. If you have received this transmission in error, any use, reproduction or dissemination of this transmission is strictly prohibited. If you are not the intended recipient, please immediately notify the sender by reply e-mail or phone and delete this message and its attachments, if any.
