Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795116210;
	b=FeirrclynKjq7kEF7FsPm10skQ2GIfZlyvNPQJ23ufHGJ7X2NT+kJG9s71x0kMsGPnky
	 iMk/zzrDNrGg+Tr8MlXlifjmVdkyDKYEv5wvM78RdJ20qzPyZohvQ2b6Pm/yIMLFjzOqR
	 e0+ydAsNhZ9qOZJxYegDgB1Awmc82QQjfptbzzahzx3zSf//t88ELUC/1GPs22cN/1ynp
	 dpG7VCNGx9eN+On5xGY3GTNLbFatPT/cKWNWaqI8x9Go97+9n/dzVBkYqCLyjZohUFFyl
	 ldLc9n2eTY0YcUHTF1Oxtjr5rLotgEDCpoRRir9gkw4UJe+djF/Hyi/rg+yhwyD4/JQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795116210;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:Mime-Version:
	 X-Mailer:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=pjYfQ81PZU2CFiiYQ2gYm1soQxv3DExtHCJIP+CLZtA=;
	b=0ypPIqCbmTUcH6nU4eHPrw4FjCpNjkwMvhGbs4aXjbAJnaVs4z6jIogqg3JK85g+MMzY
	 4dOeu0nBHbBucTT/XM7B+lq+TBVyfvc/cRc8MyndWkp10C+H23fEodgwjBd+0q2BPSNlJ
	 ZWL8K1FviYNIOVhOWzY+zmZPLzdYcFCIufDnzJhhdCG+BdlSu6xrQcDfRdgl2PDJfXyaB
	 RXa9DzPHaq+FBFlnrNizxNChLCcsNEZeSMEdeLHwnbiva6Zp39MxRA7uHT3kxatTnQpzq
	 SXo8UgliBlQgH+vBiUZjBWeBE7VZplcNA/uswRqoql38Bjpg4H2fYzlWx96nhOEE0gQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=P5COiSnH;
	arc=none smtp.remote-ip=209.85.221.70
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7FE6606A32A
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 19:23:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B7FE6606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=P5COiSnH
Received: by mail-wr1-f70.google.com with SMTP id ffacd0b85a97d-490d2ac331bso48827f8f.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 11:23:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795116208; x=1795721008; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=pjYfQ81PZU2CFiiYQ2gYm1soQxv3DExtHCJIP+CLZtA=;
        b=P5COiSnHVnyJlqJn+Gkp2tIT8M+xlpmOlvKpMNVrqlK8rhh4uN37Y+HZk4zCPXJFyg
         x0Fhvt3Eb/QV6GN4qdDunDMgkwhgJ171RxgBu/mSuFjLZ+TdDkKVQ3c0ao5N2bkYce4A
         FieKZfcbiihLMXIobD7n/oUBUrf29vhPkyLT+ZlLilvbSgIfyWxSefnCRrKOk85PHrvs
         mrYqnQQoGC+3fD6F8w+dSiPFqde3MoRnLFrABdxoEdLrtktZMRfunnc/DJHLQOwEK553
         Vet96jyRJU3BdaAdmAwlmxS/XO9QX0UCtGMRs4v1WFXuNZP2JO4GtB5ZFR32+bsBwQRG
         09Kw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795116208; x=1795721008;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=pjYfQ81PZU2CFiiYQ2gYm1soQxv3DExtHCJIP+CLZtA=;
        b=gPjwMc4YG1Tb1NyRZGLpxRuoN4mC3UYO/junt1AYOS+HQ6QaY89Mh0PItSboJxzZrz
         age6UtrD8RS4Fzhuy4M09Ss0DY6nA1vDKSHPC8SuXl8LcOM5V+yd8nKRpOz4xJvUXBcO
         h5K5+kxShH0vdtLxbsYs6/5WmpTtFRdDjoG7jAJAckgQXjxVw4td+DzrJV7G1PNl6rtO
         elctSJXWJZSUsA9O33HkEeFpxY0PSy8kD1x4hFZSAO1oxtwv97skLwqbHl4v8pIHs+cj
         yBF/kKT+5NToq2A50jI3tA4NwW358H9FxOQVMVD2YS31vCkrbxq9mUBw78vmauGSznI7
         ti6Q==
X-Forwarded-Encrypted: i=1; AL+hErEKT7AhfK5SclNX5jOL8BK+oDKIoRwZR4lxuQC7DKsMD4SaN0K/s1gUq1Ep6Y9Uje5kE+6YSt6SMHk=@vger.kernel.org
X-Gm-Message-State: APuU4Z/FZVsJ0uxCmzAif9xfchlGOU83D8UvwneNu0X2x7IKE99ad4Qd
	ieunS2B3Mx9xcLZVFhXkoHmasW5QgBhnN0Zli7Si0DSKsSHkmJGvSHk8SWhokn00Vj/qvyhgyw=
	=
X-Received: from wmrm12.prod.google.com ([2002:a05:600c:37cc:b0:4a1:f979:6cec])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:600c:1d8c:b0:4a1:c5eb:b445
 with SMTP id 5b1f17b1804b1-4bb88820436mr11131045e9.35.1795116208204; Thu, 19
 Nov 2026 11:23:28 -0800 (PST)
Date: Thu, 19 Nov 2026 20:23:27 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
X-Mailer: git-send-email 2.56.1.809.ga0b61035b5-goog
Message-ID: <20261119192327.2693868-1-dmnk@google.com>
Subject: [PATCH] nfsd: only set RD_STATE in nfsd4_setattr() for sole TIME_DELEG_ACCESS
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
	Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, dmnk+artist@google.com, 
	Dominik Maier <dmnk@google.com>
Content-Type: text/plain; charset="UTF-8"

In nfsd4_setattr(), whenever FATTR4_WORD2_TIME_DELEG_ACCESS is set in
sa_bmval[2], RD_STATE is unconditionally ORed into flags alongside
WR_STATE before calling nfs4_preprocess_stateid_op(), even when other
attributes are also requested in the same SETATTR operation.

Because nfs4_check_delegmode() accepts a read delegation whenever
RD_STATE is present in flags, an NFSv4.2 client holding only an
OPEN_DELEGATE_READ_ATTRS_DELEG delegation (and ordinary UNIX write
permission on the file) can combine FATTR4_WORD2_TIME_DELEG_ACCESS with:

- ATTR_SIZE or FATTR4_WORD2_TIME_DELEG_MODIFY to truncate the file or
  modify delegated mtime without a write stateid, bypassing another
  client's OPEN4_SHARE_DENY_WRITE share reservation; or
- non-delegated attributes (such as FATTR4_WORD1_MODE, OWNER,
  TIME_MODIFY_SET, ACL, or SECURITY_LABEL), which execute with
  ATTR_DELEG set on the shared iattr and cause notify_change() to skip
  try_break_deleg() against other clients' concurrent read delegations.

Only set RD_STATE in nfsd4_setattr() when FATTR4_WORD2_TIME_DELEG_ACCESS
is the sole attribute set across sa_bmval[0..2].

This issue was discovered by an AI-assisted code review tool (ARTIST)
and validated in QEMU against an unmodified v7.4-rc3 kernel without
kernel modifications or error injection. A standalone reproducer is
available on request. The fix was build-tested with KCFLAGS=-Werror and
checked with checkpatch.pl --strict.

Fixes: 7e13f4f8d27d ("nfsd: handle delegated timestamps in SETATTR")
Cc: stable@vger.kernel.org
Signed-off-by: Dominik Maier <dmnk@google.com>
---
 fs/nfsd/nfs4proc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a82af3..9b348bf 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1353,7 +1353,15 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (deleg_attrs || (setattr->sa_iattr.ia_valid & ATTR_SIZE)) {
 		int flags = WR_STATE;
 
-		if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS)
+		/*
+		 * Only allow a read delegation stateid when setting
+		 * TIME_DELEG_ACCESS alone. Any other attribute requires
+		 * write state (and must not carry ATTR_DELEG under a read
+		 * delegation, which would suppress delegation recall in
+		 * notify_change()).
+		 */
+		if (!setattr->sa_bmval[0] && !setattr->sa_bmval[1] &&
+		    setattr->sa_bmval[2] == FATTR4_WORD2_TIME_DELEG_ACCESS)
 			flags |= RD_STATE;
 
 		status = nfs4_preprocess_stateid_op(rqstp, cstate,
-- 
2.56.1.750.gf70dc682cf-goog
