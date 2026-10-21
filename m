Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792550269;
	b=yIkJGqxOG1e/C7opZX3DMnTeGcYPRIa4Da/xL8jlDDeKSxelizg2PgKu2Hxe5H+VsRB5
	 HGbliKBkyaae7nj7Q4zo4yNB7sQloLkNPhKGQz83Kiyh8VNP0z9iT7fSnYfhL6eRLiNFw
	 12f8BXboLNHy8h3b8xZAcTD2pdlRkkAIjB70Rp7t8hurvYZ7Ap4fcM1Z2OCjRVzsk9uBt
	 ltzSRpIlsYIcTWNkWZuVrwkd6xNG8EoBnoqz/6T+uxVfp2S4T5zoQ1bCXIBSYCoCxFW4v
	 L//+eB5oBg0ne/jSoOXNwZvYtIyoydUwEvAbO95BUBrwIoWvPYBbdDZgOzCwQ5mxrRA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792550269;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=FpZc+8ubBDCMtZDWxsPNubFaGS3JiUnCD4SYOTvBTss=;
	b=1fqPdtCo+CotoOK8UeaxxIDQky3/O0Pfu/gARZ4dZwjvPjuAErmxt3FkteAI0Fg3uj17
	 gFr8CezjQNPIC4W6KjG1zn0eABqOStb1Z4MXX8Z0S7wdYcMxO9EX9YKZxdH5X5+1S1iPs
	 RYNY6npzXuS3w7mbV+Ctgi1gFk/ZbxEp1QWTG4nJrYb+WCon70pb7cE++N8mX2jUKeaF9
	 S+js1X1psYw8YzJ/W2YmGFjeqbkeDJqIWWR0qDzlSv+T3G7dKwcRWaAnBDeYnX641vrM9
	 GY8Kcq5DwY7NGq3l9S2Uixd7ArHLR2AnYRaMYGDo+KimzYBhnsDGPA/liP01XHDowJg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=d4WGkEtg;
	arc=none smtp.remote-ip=74.125.82.45
Received: from mail-dl1-f45.google.com (mail-dl1-f45.google.com [74.125.82.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5816D606A31D
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 02:37:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5816D606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=d4WGkEtg
Received: by mail-dl1-f45.google.com with SMTP id a92af1059eb24-16079d54c17so503280c88.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 19:37:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792550268; x=1793155068; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=FpZc+8ubBDCMtZDWxsPNubFaGS3JiUnCD4SYOTvBTss=;
        b=d4WGkEtgYjT9FPw0LenT848WVmz+lD49zl4yFoDt52v8dcjTxUqHJgFpBoCCF+cbSL
         1sVOgxl3LyhJmrLTz8mStV9YgsY1y4HVRuEyz6JdZO6sriJ7/YD2H4J4gHJ7/Syk76Q3
         IWZDGvIoagyBI5YBwadFMJWJG1H+MDupQYuV5F9gTmGf0mOfBqNicE0QUHRS2BwPi7Tl
         p5uKJJcOvXN49HhlkcXoOGpQNPUNNH5iwzBX+9WuSXSkOxIZ74HckdS8OmQ0PMQLWlKw
         kDYUk3xzE1tBZcjxQeOyzwIxaVNhPaBOJSothLf17jeVAntebHESTOuWvHA4vwt52mip
         tgnQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792550268; x=1793155068;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=FpZc+8ubBDCMtZDWxsPNubFaGS3JiUnCD4SYOTvBTss=;
        b=i7bxCWvuEIh6FhDnTJdodDjOYi5UQ8CL0ax/H/v3qVjb+fvvDIBegheRAWys4aqgxX
         ggIgsI27j04Ebaal617/65Ci2sscIUrDyPIewPdmPE5Egf8bAyEtwoUTkuOPDAk3zv8l
         EX/a7NnVRN9OwD+vIIhWvvT5JkKmvCXfjqoRzmob8odBNJYb9W4BQqBv2PBfumsd1T39
         CPiTFVtw6XZkVr2FQ4Xq3417jdTBpCD7udPQnt92sUBBZrFTrp0BltG9cYc8+pqV2prQ
         ZihP1X1ose9OvfD9N24gatEyB8jW3Ig2Yx7SHh/7eQGw2vvc0XPebncVCzbqwcPc0ja3
         zZcg==
X-Gm-Message-State: AFq9FYKoxqNjb1jH35Z07Q9hY6xdrEkSd7g9TTFWi8YqAmLSjKIJQt2m
	9fVbb/sw66gX4FYyurjrr9TKt1kloUeGHsKg11tLHqvDsyGOFZTOZSoC
X-Gm-Gg: AYBFou3Ed2hSWmvYBDOV3ubmAMzKJ7HTXsDIA4cKPl5CKvRtUHbRuvNsiFZF/p17Xzk
	6VyhRvnszIg/QTcYW/CvaKGyXrWwP6Q7COPnOS9NiUy/VKNHy4JbLoMzufZfPgoh+ubzE3R7C3j
	eHkwaNBdG4SFYPoGW6yulA9jsToLsfMWIwYEH6vQtO2P4LT1GBfLTAkhVdQNALCdzk7zRYsDXKt
	QN01RPg4UFjbDqA+0rkSkQ0Ai2NsWxR+ooLRzPJ9lDtwLtdID17nCPPluPKalBGGE45m7uJyqIC
	GmT30S7bh5tfQTIzea54I/Z/LQN8xg/ZFN466ytDLsy8RlX3f4CeeQKqrsb8KW4SB1VNBDtHlkI
	Sdr9wNnL40YLqtytKbfKsN+Krk2/8XqJ62whwn4frbcgeaxvDCP2YZVbJF/o02JBuPRTbMnxWMU
	nvNElLv2k+ZTuM4QzM78sBsHxX/Y0PPywz9gjN2lXTdLu8NGkS8CMjCAsPPxs1QshITYgHC6mRm
	ZF+pl+/g/WpsxZHvDUBErgFnoyJhlIFWmi5xtJg2KG9l1F5XEGt/UqEvQ5DMGKA6gmO0a51lEd2
	0vEcx49YgJxz7990bp49Hh6oiRDPR2g6K1M6orAa1Jk=
X-Received: by 2002:a05:7022:6613:b0:151:d6e5:596b with SMTP id a92af1059eb24-190a4f064ddmr1285033c88.9.1792550268259;
        Tue, 20 Oct 2026 19:37:48 -0700 (PDT)
Received: from muumthf.localdomain ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1903bb7f098sm3354183c88.12.2026.10.20.19.37.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 19:37:47 -0700 (PDT)
From: Hyunsol Mun <muumthf@gmail.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	bobtobabz@gmail.com
Subject: [PATCH] nfsd: truncate LISTXATTRS replies on error
Date: Wed, 21 Oct 2026 11:37:15 +0900
Message-ID: <20261021023715.315727-1-muumthf@gmail.com>
X-Mailer: git-send-email 2.53.0
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

nfsd4_encode_listxattrs() reserves 12 bytes for the reply cookie and
array count before it starts encoding attribute names. If the first user
attribute name does not fit in the client's maxcount, the encoder returns
NFS4ERR_TOOSMALL without initializing the reservation.

The generic COMPOUND encoder does not truncate replies for this error, so
the reserved bytes are transmitted after the operation status and can
disclose stale reply-buffer contents.

Save the XDR length on entry and restore it whenever the LISTXATTRS
encoder returns an error. This also discards partial output from other
errors after encoding has started.

Validation used nfsd-testing b4e06bef3884. On the unpatched x86_64
kernel, all 1,000 NFS4ERR_TOOSMALL replies contained the extra 12-byte
body. The leaked windows reconstructed another client's exact session ID
and enabled cached OPEN replay, stateid use, creation of a new session
for the victim client, and callback-state modification.

With this patch, two runs totaling 2,000 NFS4ERR_TOOSMALL replies
contained no extra body or leak window, so session reconstruction
failed. The victim's cached OPEN completed normally in both runs.

A patched-kernel smoke run also completed a successful LISTXATTRS
through an NFSv4.2 mount. NFSv4.2 and NFSv3 read/write/unmount tests
passed. All test kernels built with GCC 13.3 and CONFIG_WERROR, and no
kernel warning, Oops, or panic occurred. The reproducer and complete
logs are available privately on request.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 23e50fe3a5e6 ("nfsd: implement the xattr functions and en/decode logic")
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Hyunsol Mun <muumthf@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c4fd840da4d9..c7c2be555b59 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -6438,6 +6438,7 @@ nfsd4_encode_listxattrs(struct nfsd4_compoundres *resp, __be32 nfserr,
 {
 	struct nfsd4_listxattrs *listxattrs = &u->listxattrs;
 	struct xdr_stream *xdr = resp->xdr;
+	unsigned int starting_len = xdr->buf->len;
 	u32 cookie_offset, count_offset, eof;
 	u32 left, xdrleft, slen, count;
 	u32 xdrlen, offset;
@@ -6545,6 +6546,8 @@ nfsd4_encode_listxattrs(struct nfsd4_compoundres *resp, __be32 nfserr,
 out:
 	if (listxattrs->lsxa_len)
 		kvfree(listxattrs->lsxa_buf);
+	if (status)
+		xdr_truncate_encode(xdr, starting_len);
 	return status;
 }
 

base-commit: b4e06bef38843c8b909d0b4317dfaaf87dba6d72
-- 
2.50.1 (Apple Git-155)

