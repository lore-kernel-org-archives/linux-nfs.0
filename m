Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A925CCA6F;
	Thu, 20 Aug 2026 20:54:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=51.159.188.251
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787259250; cv=none; b=NWSvHSEJ0rLWLroNHtiHSU+NWJGnzzzIt3FRSVz5JVHusUYXuSSgPFBl/mGZAAzo5lCYN8tyW+zl8Z/p4E5ZIz28XPy02DlsoQRM6LKZrEQ1xZzl5ewtg+sHJLnfcP1bWg8EGRoGcRCghRcJrDgh2mSQM2SsepjHPNWsXZ9RfkQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787259250; c=relaxed/simple;
	bh=h62+6dJD6f61+JvacRyDPv38eAEJSDKgOvVFTBrryH0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=Zd4RTAoANMr6WjRIBINB7DKWtzb1+Z5m9FxJ7YEPWY15dXyKkdKKQcKKa6WiTSGgDTCP7JrkuDHrHad1Wp2yrQYKZSB7dQ+yCZXmpo15U6gR3UuS3aNWBGDOIeD/YmoSzcrVQNRFsC/SFKF3bl/7OJmLmAkaQGTMcYoX9NPo/74=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr; spf=pass smtp.mailfrom=oss.cyber.gouv.fr; dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b=frkTCRx5; arc=none smtp.client-ip=51.159.188.251
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b="frkTCRx5"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=8v8clzRZKFsePW9Zz9P0o4DlyhxcyoitVM6xXzoe7PQ=; b=frkTCRx5bSak4ql98y6bQXy0AM
	UVMNSohsPHUswLxXiTsEXPtsala0mxcNpwMp3sUNJn+b8jhDlkiLU6YUtSEjVCE8Ltwl4a28EYbLq
	i77cWHjuk+toZt3pznrTBM8Mfdf0tKFXCxv8pvic1G7exWAfMXfWk0QjyNUYYa3Logh9fXpx3h2zp
	ubEi3fftPBI6/SS7dfyXOFaxUm2gt8/iuB+/FT3TdaSDqDL4LVmqRUqYfIKqB3K/khVMhhDDKCLaK
	6pX+l5mfXjk3q3xRvQ9rGRY0qWfnSUXVMGlXSPJC6SGdGRKRVagGGMdsIFlaSb4tWkB2P8FqGxepj
	D6HIGE5Q==;
Received: from [151.115.150.205] (port=60756 helo=gepetto..)
	by pf-012.whm.fr-par.scw.cloud with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.99.5)
	(envelope-from <Jeremy.Jean@oss.cyber.gouv.fr>)
	id 1wx9lw-00000009MGm-3H6B;
	Thu, 20 Aug 2026 22:54:00 +0200
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
To: linux-nfs@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Subject: [PATCH v2] NFSv4.1: zero referring call lists before decoding
Date: Thu, 20 Aug 2026 20:53:29 +0000
Message-ID: <20260820205328.3002197-2-Jeremy.Jean@oss.cyber.gouv.fr>
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

decode_cb_sequence_args() allocates csa_rclists with kmalloc_objs(), so
each referring_call_list starts uninitialized. decode_rc_list() assigns
rcl_refcalls only when rcl_nrefcalls is nonzero. A valid list with zero
referring calls therefore leaves the pointer uninitialized, and
nfs4_callback_sequence() later passes stale slab contents to kfree().

Allocate csa_rclists with kzalloc_objs() so every rcl_refcalls member is
NULL from the beginning, including valid empty referring call lists.

Fixes: 4aece6a19cf7 ("nfs41: cb_sequence xdr implementation")
Assisted-by: Codex:gpt-5
Signed-off-by: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>
---
Changes in v2:
- On Anna's suggestion, use kzalloc_objs() for csa_rclists instead of 
  initializing each list in decode_rc_list()

v1: https://lore.kernel.org/linux-nfs/ae822c8b-9d47-4a96-a61b-aef730c4c785@app.fastmail.com/T/

 fs/nfs/callback_xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index eec6040556c9..88e1af0fda01 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -417,7 +417,7 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 	args->csa_nrclists = ntohl(*p++);
 	args->csa_rclists = NULL;
 	if (args->csa_nrclists) {
-		args->csa_rclists = kmalloc_objs(*args->csa_rclists,
+		args->csa_rclists = kzalloc_objs(*args->csa_rclists,
 						 args->csa_nrclists);
 		if (unlikely(args->csa_rclists == NULL))
 			return htonl(NFS4ERR_RESOURCE);
-- 
2.47.3
