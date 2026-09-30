Received: from mail-pz2-f37.google.com (mail-pz2-f37.google.com [74.125.228.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5AA3935DA63
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 05:54:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790747664; cv=none; b=l1nmgxlUWTlHEhZZ0zMb/M8a0FGIH8hq25uoOCKWW1XRfHdPxUW/dcEu0BTfggSe0gg2uE/ASEaQAyyW8GbQMwhC2Na1ETk7uVw7vgtQXafC3HiNPbskTnhA+2jXXjqPr2+lqXVhXfThKGZ2ZjXg76aKgcu4zAOX0LYMDg5R5yI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790747664; c=relaxed/simple;
	bh=naJhusjE/f0eW+uX9wPNfOeMPyPLkR630Hor3GTspqE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=BJj5NZWlskYI8/lgdBCAveZwvk6JhRckNOB0kU4pjba7hDViwtD6JXSd5V5n6T1zz1LvDil4m3zAPaWXIZ59+Hely0eCksksW3NF7g/MPtA7wEx53UjAHBa34QqXE77HyhoEe9kwNC5ycfaCiMy7/iP9asCIFVIVK25+G2x9OO4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=HC9rqPBm; arc=none smtp.client-ip=74.125.228.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HC9rqPBm"
Received: by mail-pz2-f37.google.com with SMTP id 41be03b00d2f7-cc7d1802740so520647a12.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 22:54:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790747662; x=1791352462; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=JdRHwJkMD5tGOAkcVqHgpo9CQbKqWdCWhh5iMZs6XYc=;
        b=HC9rqPBmnCAxy1xU1LeMKOHqB2mOTkni57cDt3Dzy3pYl2aj/+7qe95+PDJVA7B3Oh
         MZ+DT6pLIaChaFw4VA+1/44yi89gBTdsPd506QrQ3J72Je5pyPOBypgff4SL/c7V4APP
         SBjq/bjAVwMJ+3LSCVzKH5LtQly5ATkY8kr9qbkiIZeqKe5H6mtkyL5DYgmt1R04O9xt
         XnNfQi4rXEBBfhrLhn6JZLG6WcskiwVWtOqrRxx/f7tbFi3ugywEKSCh0JjmIQiTp2Wk
         TcrgTyr+7s6ukF9ZAMsBE/+MDkbiLYpff3xHno+PeTfcRzhNRv7jNtIYNUVntSwr20P4
         rEqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790747662; x=1791352462;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=JdRHwJkMD5tGOAkcVqHgpo9CQbKqWdCWhh5iMZs6XYc=;
        b=Xk+3j1bBAy4ofLTKthMJ6XdJnv1JkVXK/CnLgGH2gqjCqaRfynmTShoN0JknKGqWLs
         zucxiaXSoUy/tkEUrb5GQXW0Uc1GSeSfg9XpynxO3TWmaab+WDASt/6vFWJsd7qXwHjv
         tfdZOVBnF5qruO7SHm6N4DWc9CgIkGFoks8R3cAl4UdkdPt8ikPAyvFZptCHRCyt/hZ0
         PCtfr/BEegYWuEWdeUiGlzkMkznNNa+u4QELEaONQns1jw2AVVtrguA+2J1+Hv5pMJr0
         PWB0WYiZEN28aqFVdqxsq5HkuuU3GluBWz9mLReXzR1vZoXdL/tVoJxui0+T142DnYv1
         pxJw==
X-Gm-Message-State: AFuF++nnazFgfAlsS5AqISLxZxNYpMfTNmMB9gumMpaLdZuFsWHsOf15
	gx003sv/P/3snNe9KM1ncXagewtmFN9x/vppaPe5Ux6oizuFk3gjsMebvT2UBHiyDEk=
X-Gm-Gg: AYBFou2XCo7BGmnJCSV15qiSag5+bMcjWKutiQ8zDPhck0PPtraIXndzc2eJqe+AhnX
	HB8yv2dmwW54YnFaZGqZPF+MW9lxrFV14xl2Juv8A3YqS5hWbtKwwMkfwYN3kNM7teLssRcK9bk
	bX5HShuYN/nUHDK3H/9dA7JxrYZcylHBrcekH7Hu7ZHrs/kno7Za09/Wlrs79f6r2uEEUphgbpu
	mLqcnDRFppAPeADHYrwJ/hWHUEZCLb4F0odp4cu+/n/IbqVetc2jBmNsSZ/8TeVdzmt9W/OFlLt
	ItnlPnKKMuCLAbR5y1g+b8AmNSWF/q+4nS3zKxMY66JcjueuVAiDfORq3mYbZ/pSQOx8o4wpAxm
	gA5Jxw2Mb+Gjz2q33yAyIIrCfeOgtdgxMvYMgR2G8P2Ddxb05lDcxPFOSFWB/xA5m8WuzLaW9D+
	NfmWQiuoN4EqDBAq16/VkCiFYO7xJDgpTAdSyspG2u8d4hT0NuBPg/ZMt6wNHfDnLJyin+N5kWf
	vtML8LnLLKIRwg=
X-Received: by 2002:a05:6a20:260a:b0:3dd:a006:55a3 with SMTP id adf61e73a8af0-3de9e7ebbb7mr357536637.49.1790747662598;
        Tue, 29 Sep 2026 22:54:22 -0700 (PDT)
Received: from bintable.tail83b815.ts.net ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-88722f72a19sm255099b3a.6.2026.09.29.22.54.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 22:54:22 -0700 (PDT)
From: Jinpyo Lee <bint4b13@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	bobtobabz@gmail.com,
	Jinpyo Lee <bint4b13@gmail.com>
Subject: [PATCH v2] nfsd: bounds-check opnum before testing spo_must_allow
Date: Wed, 30 Sep 2026 14:54:14 +0900
Message-ID: <20260930055414.136306-1-bint4b13@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The NFSv4 decoder represents an unknown wire operation as OP_ILLEGAL,
whose value is outside struct nfs4_op_map. nfsd4_spo_must_allow() passes
that value directly to test_bit(), causing an out-of-bounds bitmap read
when an invalid operation follows a successfully processed operation.

For an SP4_MACH_CRED client, a set out-of-bounds bit also marks the
compound as spo_must_allowed. Validation used the nfsd-testing base
recorded below. On the unmodified KASAN kernel with an empty allow bitmap,
the out-of-bounds bit changed the export security-flavor result from
NFS4ERR_WRONGSEC to NFS4_OK for 64 of 72 client instances. A krb5i canary
read then succeeded through a sec=krb5p export. The current allocation
layout did not produce a KASAN report for this invalid bitmap access.

Reject operation numbers above LAST_NFS4_OP before testing the bitmap.

AUTH_NULL reaches the invalid load. The observed security-flavor decision
change additionally requires a valid SP4_MACH_CRED client and matching GSS
credentials; ordinary POSIX permissions remained enforced. Source
reproducers and complete logs are available privately on request. A legal
OP_CLOSE control also allowed the preceding read, so the read itself is
not claimed as a capability unique to this OOB.

With this patch, none of the 72 client instances caused the export
security-flavor check to return NFS4_OK for the invalid-operation probe,
and the canary read was denied. The legal OP_CLOSE and empty-bitmap
controls retained their expected behavior, and no KASAN report was
observed. The full KASAN kernel built with CONFIG_WERROR without a compiler
diagnostic. Basic NFSv4.2 and NFSv3 read/write/unmount smoke tests also
passed.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: ed94164398c9 ("nfsd: implement machine credential support for some operations")
Assisted-by: LLM
Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
---
Changes in v2:
- Make the current policy impact and controls self-contained.
- Add full-build and NFSv4.2/NFSv3 smoke-test results.
- No code changes.

 fs/nfsd/nfs4proc.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7df60abfb..f9e119cd0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -4293,9 +4293,10 @@ bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 	opiter = resp->opcnt;
 	while (opiter < argp->opcnt) {
 		this = &argp->ops[opiter++];
-		if (test_bit(this->opnum, allow->u.longs) &&
-			cstate->clp->cl_mach_cred &&
-			nfsd4_mach_creds_match(cstate->clp, rqstp)) {
+		if (this->opnum <= LAST_NFS4_OP &&
+		    test_bit(this->opnum, allow->u.longs) &&
+		    cstate->clp->cl_mach_cred &&
+		    nfsd4_mach_creds_match(cstate->clp, rqstp)) {
 			cstate->spo_must_allowed = true;
 			return true;
 		}

base-commit: 32eb1a60b456980761cf7a9cee8f907fdc08afb8
-- 
2.50.1 (Apple Git-155)
