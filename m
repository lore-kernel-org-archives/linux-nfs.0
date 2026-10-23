Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.182
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792734954;
	b=VdmRT573oL2fVyGBTTjdMok3XmdafOolf4YZuUQsbs/pfvz+1LE8AS10OyGnIqMFQzc7
	 Xgg3wjYsCpAr179pSw4UaTG9BuiY205JKp4a+e33b7rdptFgarH5kPsi2FKee4j5/RQBE
	 K40A0/DEKkPgaYZx/wQ1pgosiyxFYGdBbGbsSNph7yuQlkuelBL8XFshHFXnqBcSQrblE
	 rUC2uZtTlOexRkBdyIcCkECGwEWa5zjBAhLlv8bDTvpX2eWR1CJTMhqcf0zS3nv8yCE2j
	 FRv8O9W7ABpVoX6L1Rhf3zzKibxXcNj13gNyJ1JQeULSyGmTzEYaOr6IBzXm1TG/V7w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792734954;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=NFgSsKZG0b+cmNubhqNj8B4xxbWSVMf6JHmk4Yh78t0=;
	b=MBSwvRAfpHXv3LY/0lkaWvNp5yTEQtMZRbAXZBHg3+lq1gR28sw9RM/L744xGlqnOEKQ
	 j01u9uXo+4ORv9+2AIRgo7yG/Q8VFEHLJ5Tj6JAb2tcbtiZFEe2DUBgZNrq8L8DuclDlA
	 LCQ5gEDkifV68EYqRrHrsakQ5+JjbR4pOajUiYkmpx/Vo1pbhNEFmx3sBAg5/e/xgHABG
	 iWgp/w3RztRJ7+DwBsso2yQtRvz3AMOxDwARzDtVfsqIvlQHrxEziVx+JCZGfNq2mBPzH
	 cwng27MFTAf0Vt8Vddq0vcE/r4/lIPaOEm1pWSuFdIjLWY67cO7Rm14vyf/9XCWOZ/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=nebusec.ai;
	spf=pass smtp.mailfrom=nebusec.ai;
	dkim=pass header.d=nebusec.ai header.i=@nebusec.ai header.a=rsa-sha256 header.s=google header.b=b3uaYkOx;
	arc=none smtp.remote-ip=74.125.82.182
Received: from mail-dy1-f182.google.com (mail-dy1-f182.google.com [74.125.82.182])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76685606A31D
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 05:55:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 76685606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=nebusec.ai header.i=@nebusec.ai header.a=rsa-sha256 header.s=google header.b=b3uaYkOx
Received: by mail-dy1-f182.google.com with SMTP id 5a478bee46e88-35ef6b49813so765934eec.0
        for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 22:55:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1792734954; x=1793339754; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=NFgSsKZG0b+cmNubhqNj8B4xxbWSVMf6JHmk4Yh78t0=;
        b=b3uaYkOxX+iPbBgbC/Mb48Lhc0WU3s/eKaDhvW8/cAhsbMf3yC+nMf1K3Zxgvp9XWx
         Z5eb2a7fhCJ7e27Th0eJwHmRne8qPuKR0WgyDd3IXs/04rzhnVHGFCSX4Wrt0Y5p3cFP
         eTigq59dYymy3jIS3QXtrxqYOgPpM0horoChC9+s0xvkjIgeX4Kz5xcPus0OuKop7lFG
         42LkWCxKIXaH10aCGCJVhfWUunxX1e7H21zPszKE3USgvMM+y4ZDB0Fv8kmExyB9h5lF
         G18Pzy3NGcEsZ0SZvaIpCIw5V3JzD/Qz4DhnpP1E52KMU/ZdzaMepGVdwSmBa7T5/tou
         j7VA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792734954; x=1793339754;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=NFgSsKZG0b+cmNubhqNj8B4xxbWSVMf6JHmk4Yh78t0=;
        b=d3zKxc+1wPNT2BUJbwSu/IsukRKAC1ujgnHMbjOZkywejHCjXPFP7OZJA3yvLDbP3L
         F5ZNj32S7f8zZbWUQFAqPUuEiS9/xzLukH93P17TCrfa9HKG7m90+bO2FSIGVp+C3NrH
         8n0d1C45o0GGoMnj51RsuWEPvpULn9UQ2QJqS95xbNFu6gObT1i6MlCP5HFSJAqT57ML
         Zlgmix4r13ht/Q03S0mjtDhUNECHIFsYU/E6xrFlvYwSpiciKW84sj8Smt89wzMpzMCG
         jJCuknERwQ5Qo3IExTpspgXvc9FOHmOHsVYSuEKe/P9M2MZ0Ma4e65qnOrNGlnsl8TdC
         8KDw==
X-Gm-Message-State: AFq9FYIQ0aBOjtaIn2iRgRxnTEjo0kVUEgiNFUsyUNgqksH0qjETLCA9
	dKmJMJOrImWz+a5J6M1lkuZKewIB917uHGOFLPvYkNf2wGy+dlxat1xSM/zulnuDpFXvcwhkbxK
	fwJZtLN/6g74=
X-Gm-Gg: AYBFou3ZBOmDZySSxjsfxEtFc2EXFO9A6puSPgeGm4EIAYiMGa8JcqCSFEFNWA/Msfq
	KgdlPnFhpPt2HE0Y127I9orEBG+FTx2OmFPtVwQizZdZ746+x3IKwznv6kVRdEcIntdns2NZ2bf
	/8JmafDwvR8BMx4SiH7Aj177q65X8CLQyRkrHfuEqggOo5OmmQLzCEcxAQLeCoECWC8k0jJ0nIS
	Eb230LDEtLJm5rFNq/s+AjWFgdRa40trjPT/8fV8yLJ3AA8Z+uhW82BwvbaRXiTqlYzcbAXBsoh
	SaIvRdnROllTxF8u6u29GRtZ9wLHoyUaHFP1nw71CvnscVLmHvRkj2ebpgJKZwl+6icVgL3n7n0
	hZE19UxWXeWc/uzkj9c9nDS57rSuuNTR4NVaNv5+npO2tnReWGJFuyGmPLjn+k368v3VSVllW8c
	mCXqEeAnTUc5lHJD0ZIwzYi4Zz0xao9LQLxOWvWCKoRCoVvt/6ouDWjm5eWtNiSkM+5S++HGmeF
	pzTB6EHRxMTvWejHqqWJkDd43/dW3v+/4x/y99gzOywtHkSwX6VYspY65e333TvmGj0sLKNe0pH
	i4ijv8GwE5yklqAS
X-Received: by 2002:a05:693c:894c:20b0:368:5750:9869 with SMTP id 5a478bee46e88-369d96dd67bmr1580957eec.8.1792734953544;
        Thu, 22 Oct 2026 22:55:53 -0700 (PDT)
Received: from Roxy.sysu.edu.cn ([203.175.14.54])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-369d9def334sm3656543eec.24.2026.10.22.22.55.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 22 Oct 2026 22:55:53 -0700 (PDT)
From: Zhiling Zou <zhilinz@nebusec.ai>
To: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	davem@davemloft.net,
	edumazet@kernel.org,
	pabeni@redhat.com,
	horms@kernel.org,
	vega@nebusec.ai,
	zhilinz@nebusec.ai
Subject: [PATCH net 1/1] SUNRPC: reject AUTH_TLS on backchannel requests
Date: Fri, 23 Oct 2026 13:55:35 +0800
Message-ID: <1106d411594bbf7d4ee8deb7f3a0281475c258c4.1792734713.git.zhilinz@nebusec.ai>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <cover.1792734713.git.zhilinz@nebusec.ai>
References: <cover.1792734713.git.zhilinz@nebusec.ai>
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

svc_process_bc() processes reverse-direction calls with rqstp->rq_xprt
set to NULL. A backchannel caller can supply RPC_AUTH_TLS, which selects
svcauth_tls_accept(). That handler dereferences rq_xprt while checking
for transport handshake support, causing a NULL pointer dereference
before the RPC program can reject the request.

Reject AUTH_TLS credentials when no service transport is present. The
backchannel request is then denied without accessing rq_xprt.

Fixes: 74aaf96feaca ("SUNRPC: Teach server to recognize RPC_AUTH_TLS")
Cc: stable@vger.kernel.org
Reported-by: Vega <vega@nebusec.ai>
Assisted-by: LLM
Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>
---
 net/sunrpc/svcauth_unix.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 31a1bc60a5f6d..bac38f3ce9a6c 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -1128,6 +1128,11 @@ svcauth_tls_accept(struct svc_rqst *rqstp)
 		rqstp->rq_auth_stat = rpc_autherr_badcred;
 		return SVC_DENIED;
 	}
+	if (unlikely(!xprt)) {
+		/* Backchannel requests do not have a service transport. */
+		rqstp->rq_auth_stat = rpc_autherr_badcred;
+		return SVC_DENIED;
+	}
 
 	/* Signal that mapping to nobody uid/gid is required */
 	cred->cr_uid = INVALID_UID;
-- 
2.55.0

