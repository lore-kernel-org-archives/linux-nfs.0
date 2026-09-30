Received: from mail-pj2-f43.google.com (mail-pj2-f43.google.com [74.125.227.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7368335DA63
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 05:52:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790747565; cv=none; b=H8BrgAiy20CbQY0U2iPCfviuytJiDYhNscfdNzG/Rh+s+CPYavIzMaTeohpJ8l+4iJeMbalRWO9Brc15nxfeiQQg3fCWMbbJywHYxvccULyNvzyXd6FwNCxtg1ioXFiuwNnWdYdEllExCAJAdEdz4SNdBtD/KUQm3UtrFpUG7Cw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790747565; c=relaxed/simple;
	bh=6wb43ADyYognT1p/xJV+cSqzctJv1mOQTI6afHoezOY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Jnu893caSkWpNFBz4Om4UtADSDomN20cTdZ6cEle9XC04/FRVBHDRB85N8JeK7z3vAyfES2vkAnByUTuyjHwcmE960RYKPALvFq49XonoQjgi2Ouo4ZQf2i41399tzF6UwKMICC5yCjq6sMGpsKEsxcBnUdloJo4C0BsTO0m/hk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=AKlVf/N4; arc=none smtp.client-ip=74.125.227.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AKlVf/N4"
Received: by mail-pj2-f43.google.com with SMTP id d9443c01a7336-2d747ee1f38so22060665ad.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 22:52:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790747564; x=1791352364; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=6U/GCi21xHgKGW6jXj/fbh8CwDtK6EGodKCafzOq+uc=;
        b=AKlVf/N41Djj1tnQKLWDfW4gTgb0bxD5qiLbMpy9TYqB3ZvFy2zfWHzw0COJSWMTV9
         SaoJhOSk1K0250cElvnRTRNtASB0DRpaqj5mXWSkI9hQpEQr5GUCDSA1KJbqeqjnp7zg
         mfi0g4amjOHX51SknKtwqsUWb8IVXJzSFfHaPDC32czq69YYbXx5+zSOyFROKbiTX+Q7
         HZshpPtIb7tJWHFZ1glkZI1M22nueph5fnsdJEJ9TbNKlNk2p0xeUC1dedyZigOAy1If
         yNUNnhO/uUdYnS2etleJHis6rlMhgrpijI99r6mrkN0rSWQ2QAg7YJNK9LcP/nc4+Fy2
         b3LQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790747564; x=1791352364;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6U/GCi21xHgKGW6jXj/fbh8CwDtK6EGodKCafzOq+uc=;
        b=QU1iJ0k+A8K4JkNRe8JzCahiUstbxgzr3UjzxxvhZikaLa9m6cf5xyMYwOG7G4bMxs
         8RaND38Itt17J6qRcKSSdArdSDJw+l2UbgVHAhh78mrwxs5VZGmItjSzGu0uxko/W6F+
         H52ajdsI76lpBOf9BvoyKky9ZFAN7k99aRfWF+dOzKPZqNMru3ae4HaMkaR195hreHpR
         ixfqTEBLuD4kL4yJmhivGfJirkySbsL5F7k2Pdulp1Fx+1SOewpxuQ2NnWWEqOCuzgHX
         UEkz920N5CO8DzYJC+dJS9SZXatLlfOHw9USDOLh84Xd8NZ8ACPPEvWeHUl5juZx+KYK
         P6Mw==
X-Gm-Message-State: AFq9FYLJvQ2x7YsxMhJUqZRc23eYE1ifz+cXj7eTTpw9lwXJBNNfW6Co
	yJbO/zYoJLBxOF7Mur0eOyny4Wb3kqphvHF65pPtRiJ+75nqNJSK7iJ0+eIAvPPTWcQ=
X-Gm-Gg: AYBFou0RG9B+kb+WGeE+c6BWIk5F5KHQmFTZ+NGACBVbnKBxoTTNXLkTvBWyvJDDev0
	ODdFbRE5otvvixBtfj8eXD39VoJPIEs0E3blfI0uLa1Q20EvXO9eaJdNVUQ5Im75CadCz4Of/Lm
	7/aDiPG70e2z2N0znJ6H8yL2lVUlaZJ08xRk5x2ZeqNlTwZkSnPRrk2f/pd50to/Dx0IC/NQp/B
	bjiXbS4Npete9zyj8fZH9srRD3Z/lWK7wY2oNsJSLH+8xxeZMPeQw4BlSsaNEsliXExMadN1MDi
	fjVJvXEeBVBXI+zq2Vg+qK6+Cud1oBgRjiiTdQXmC+4YUXjHYnotyi1+PgCsqV4MekNnfWvjk9d
	EvT4rrFHm5q/PmthPrSXJiyn01QDXSOppvqozGE9Fl85BST1Si6P51vpO2ymko7D0T6r4fiF0gp
	JgZHX1uB2TkPQ5TWFwoP5E24bs3oe3nedxrssE2jhdkXILI3/KEBujJb3FAHHJQMm+DxpaAkzEs
	jbprUb1m+3cL3c=
X-Received: by 2002:a17:903:234c:b0:2dd:c100:7cc1 with SMTP id d9443c01a7336-2e2e4a27f5fmr3664145ad.61.1790747563591;
        Tue, 29 Sep 2026 22:52:43 -0700 (PDT)
Received: from bintable.tail83b815.ts.net ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2e2e5b89e29sm1423445ad.23.2026.09.29.22.52.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 22:52:43 -0700 (PDT)
From: Jinpyo Lee <bint4b13@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Willy Tarreau <w@1wt.eu>,
	bobtobabz@gmail.com,
	Jinpyo Lee <bint4b13@gmail.com>
Subject: [PATCH v2] nfsd: hash only the supplied client-owner bytes
Date: Wed, 30 Sep 2026 14:52:35 +0900
Message-ID: <20260930055235.135503-1-bint4b13@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

NFSv4 client-owner strings are variable-length XDR opaque data, but
clientstr_hashval() unconditionally hashes eight bytes. A valid owner
shorter than eight bytes therefore makes the reclaim lookup read beyond
the allocated string.

An ordinary NFSv4.1 client can supply a one-byte owner and issue
EXCHANGE_ID, CREATE_SESSION, and RECLAIM_COMPLETE during startup grace.
Generic KASAN reported a one-byte slab out-of-bounds read immediately
after the one-byte allocation in nfsd4_find_reclaim_client(). No
disclosure of the adjacent bytes or other production security impact was
demonstrated.

Pass name.len to opaque_hashval() so hashing is bounded by the length
validated by the XDR decoder.

Validation used the nfsd-testing base recorded below. On the unmodified
KASAN kernel, the one-byte client completed EXCHANGE_ID, CREATE_SESSION,
and RECLAIM_COMPLETE, then triggered the slab-out-of-bounds read in
nfsd4_find_reclaim_client(). With this patch, the same sequence returned
status 0 with two operations and produced no KASAN report.

The full KASAN kernel built with CONFIG_WERROR without a compiler
diagnostic. Basic NFSv4.2 and NFSv3 read/write/unmount smoke tests also
passed. A source reproducer and the complete KASAN logs are available
privately on request.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 6b1891052a3f ("nfsd: make nfs4_client_reclaim use an xdr_netobj instead of a fixed char array")
Assisted-by: LLM
Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
---
Changes in v2:
- Describe the baseline and patched runtime results explicitly.
- Add full-build and NFSv4.2/NFSv3 smoke-test results.
- No code changes.

 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bbc16dd22..e818c032a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1649,7 +1649,7 @@ static unsigned int clientid_hashval(u32 id)
 
 static unsigned int clientstr_hashval(struct xdr_netobj name)
 {
-	return opaque_hashval(name.data, 8) & CLIENT_HASH_MASK;
+	return opaque_hashval(name.data, name.len) & CLIENT_HASH_MASK;
 }
 
 /*

base-commit: 32eb1a60b456980761cf7a9cee8f907fdc08afb8
-- 
2.50.1 (Apple Git-155)
