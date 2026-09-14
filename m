Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DC0D49F10D;
	Mon, 14 Sep 2026 20:43:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=51.159.188.251
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789418630; cv=none; b=KqtJu/wcDI9aWYv1kkkInGPAQKAveMQpnGn3enYfDNrgkTzlgE9XAGRCdrKWcXdWGZGy3Mjfpp4PiJQz8mvOfacipc+r1EY0p8VLAZ+Z7Raa7bmQRhii1rRVnOiHO6KBzqo1PDtljXF8e9cYe/98IU3dTR1h1PULJBSSRNywFi8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789418630; c=relaxed/simple;
	bh=K5R3t4nArzou5yu/s8rQQCeK9FyDGSzVntYeFiSAI2o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=KV5SgSyH4d5kW//75co9VeEaRB7QWUSbvWd3g5H2tKaWgTVLuXw/UwYO0K9h2HnZ150u3yCOsJJT3d6rf9tCgn2vaZdkPFXrbo9Gg47Ah8kA2X5Nj28H0YRpRbJdKXNqsUrcHvRBw/Y+RGVm4pYvJpVy6kS+FKnIZit3EcTRvII=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr; spf=pass smtp.mailfrom=oss.cyber.gouv.fr; dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b=FQen1kuU; arc=none smtp.client-ip=51.159.188.251
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b="FQen1kuU"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Unsubscribe-Post:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=8jZ3v4zlXMIKKSMaqhUDS52aesYjvtgRSCo5R9N/PW4=; b=FQen1kuU1i0rx3GB+BVZjX6Ho6
	NIwzT0028EUsxCBZPlE2pttAUy8YddSN9gW9GqnsQcdZcj4EpVO/LfRoZPWlCf7+AGaPeCDkvqiBz
	T/fUgUR5N7DoaHI5bL81sPFwtx2RR2EHnGIR0P8g315hFRYhu/t4Aih96A34H/SQ09qV3vQC/we5E
	GbDcA1fAQMYZebXtIMtv1q6JgMG0/bRz6705pI5Z0YbsoyLhQ3QxmNRWNGTny6v/rTtO85KonX1tL
	0+rWZLkNB3kb5yBOscpN98cus38pXFIET4yEIvEl26x+dM0Jk9giPscbbnskD4LgNHjxeBZFsxgl7
	UW7zNIiQ==;
Received: from [151.115.150.205] (port=60600 helo=gepetto..)
	by pf-012.whm.fr-par.scw.cloud with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.100)
	(envelope-from <Jeremy.Jean@oss.cyber.gouv.fr>)
	id 1x6DWf-00000000zwI-0vyN;
	Mon, 14 Sep 2026 22:43:40 +0200
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Subject: [PATCH] NFS: filelayout: calculate dense stripe width in 64 bits
Date: Mon, 14 Sep 2026 20:42:38 +0000
Message-ID: <20260914204237.2442333-2-Jeremy.Jean@oss.cyber.gouv.fr>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - pf-012.whm.fr-par.scw.cloud
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - oss.cyber.gouv.fr
X-Get-Message-Sender-Via: pf-012.whm.fr-par.scw.cloud: authenticated_id: jeremy.jean@oss.cyber.gouv.fr
X-Authenticated-Sender: pf-012.whm.fr-par.scw.cloud: jeremy.jean@oss.cyber.gouv.fr
X-Source: 
X-Source-Args: 
X-Source-Dir: 

filelayout_get_dense_offset() calculates the stripe width from the
stripe unit and count, where both values are provided by the server.
Their product is stored on 32 bits, and can wrap to zero despite
passing individual checks. For example, a 1 GiB stripe unit (0x40000000)
and four stripes (4) cause the following div_u64() to raise a divide
error during the first read through the dense layout.

Update u32 to u64 and use div64_u64() instead of div_u64().
stripe_unit is a u32 and stripe_count is limited to 4096, so the
product cannot overflow a u64.

Fixes: cfe7f4120f8b ("NFSv4.1: filelayout i/o helpers")
Assisted-by: Codex:gpt-5
Signed-off-by: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>
---
 fs/nfs/filelayout/filelayout.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 72e20b56fbc7..a15fca123069 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -55,12 +55,13 @@ static loff_t
 filelayout_get_dense_offset(struct nfs4_filelayout_segment *flseg,
 			    loff_t offset)
 {
-	u32 stripe_width = flseg->stripe_unit * flseg->dsaddr->stripe_count;
+	u64 stripe_width = (u64)flseg->stripe_unit *
+			   flseg->dsaddr->stripe_count;
 	u64 stripe_no;
 	u32 rem;
 
 	offset -= flseg->pattern_offset;
-	stripe_no = div_u64(offset, stripe_width);
+	stripe_no = div64_u64(offset, stripe_width);
 	div_u64_rem(offset, flseg->stripe_unit, &rem);
 
 	return stripe_no * flseg->stripe_unit + rem;
-- 
2.47.3
