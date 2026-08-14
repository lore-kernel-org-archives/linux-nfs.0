Received: from mail-yw1-f174.google.com (mail-yw1-f174.google.com [209.85.128.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C479A1EEA31
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 22:25:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786746352; cv=none; b=YeQW51cU8Rrbknr5x+9mVkkLjWYGDRq965KYLKpZ8ptS1RLb6H9IE36RE+mVfg7HjQWyRUUXZ6yqTE1Lv7x7BzyVWYjWUfQNmAQcDxpa87MQtELf+dfXOz5voh5k32jxN9QvsY/s6FFjVo7Jxf/AZ5RCanI7bzJhWFUTEUptBPM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786746352; c=relaxed/simple;
	bh=Bv00FDpsRNeRWCLCsp9n8XqpgbExu26SCnvgROenxBw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=R6Yw/Uom6QFLOCfXsZKecrGIHDXXwabaqNhO0NbxeUvCSp91fDJpxKVpaadNwMz4sijHWGH983BZIwv5xjDoGR8vY4gNzoxB2uGUWy1vzWBuUKXrLgvljCKEACSICZdQR6DjyMKzfaelLgOD5APjuKPwGsFmY/C6qwQ3b0yiCSs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=Io4psCIX; arc=none smtp.client-ip=209.85.128.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="Io4psCIX"
Received: by mail-yw1-f174.google.com with SMTP id 00721157ae682-836c91bd782so23016237b3.0
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 15:25:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1786746350; x=1787351150; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ZTN+B4kFzqTAI1BrFvQTa93RZ8Fx5/03UErkDUDNG0U=;
        b=Io4psCIXiCv1H/8dhcCIeKKRcljjknW1QTjGTV0cv+u8v1X2ZCbogSF80GMHRDgcYa
         ZNDw37iG7JbrJ3jarld7E9urYUhALdwJOIGszcKAk5NJ7uohPREct3LilYpUdhpFruBz
         xAzEmjHDJYA824DXbZpiJ/Id5gWG55/kPBsr1nUztLxiaxzOoWpLGnIhldGr3utSz5LN
         rQXAKgW5PvyNuoQKlh3+/5F3hIyjPgvZ/2G/4aF5T8KGGo2CIAZ+cDVBMLZgc36RzLvE
         aTsQQgRHpcx2w/NqwZNBNoPYz0cdw/RUwP6Vu5L4vikXFLJPNMF6ktJqWcVhVTyFUph0
         Z/4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786746350; x=1787351150;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=ZTN+B4kFzqTAI1BrFvQTa93RZ8Fx5/03UErkDUDNG0U=;
        b=NRrTVP/+pFwM+DKnirmm+djUY1EmEqgDGO90tQAAGkIrwtFZH532c8bFvwIfk65h4y
         fWsQ2ltV0dYrpQITXEcoHdfk1awzV237GSpVpdUU3Gm+e6YFfSsnyWNK7BDVLiEOZxW4
         YX//SHbZOnyU8SQ0thDkHBF1xQqAf/xOqPzFyrNIEJkzS0q8zo8BPiy7O3SH+GYadAAg
         jCUOQvuVj5kZ3DxczjuWlV4sy4YBhIDYujQauYdpBT2Xkz1yYE47u4jUk79hl+57Jq4s
         DUbbxhNR3roXObsylwE6m88aN2LP+F2Lw7QsAqjhNtiRKh8gUHLfxsuRYvcT0dEcPK7y
         ZLnQ==
X-Gm-Message-State: AOJu0YxVA2tSZrCVMrlWA/mrQfoIA7MgFFr43kGdeLE8J+sJ9PC7EP3u
	Rxm2cliVq2mmHC6afvpXRki8w/0k1IDv4KsmOMVG0Abg2QOqB5lyH09xeCiJozr7pw==
X-Gm-Gg: AR+sD12RY5Wcex4hgu14hHp5XCWZNBt3DUtrIDBT5XSulwMjsX2C/v6UPR+n+/2HlV6
	iINKZ/YM+e2A8CVZb2VDb3vP3GQf2XRRSApy7k2q227pVGAc9mRLIN036ignn8OVwevFe7QjQYF
	ssNLWxsmdGSgCQNhBBcyLlX5IoWOWi2DhMrBJIu+KratKB3Uar6GguXZ4jQh4jop9ZNFwMVLaGn
	7prahVYHdRpWM5sI/fqeFXyGogmDKdUccjhZw8zSJTBMHsRrzeWVnlL81cADBKoScUCwcnGhNSU
	JUJVutNajH7sSIYbcyXLdXgDbtE8FsKro/y32MUNFu0ngKF/JzKSOuhWqJU/VJVeB4sYac7dM2g
	aBGSPzkYwPbZljJaSzJuugXOd5RVDUMF84h37JZF3sFyi69LTyv+QzUnSc1CYCBWRwDkP8EUjzP
	mj0dvvSpmxEVtljpNaCZc2Q/w7q2wtWFJ7CwJEiYBLhW5ru7glLzjUXFmUjd5+
X-Received: by 2002:a05:690c:e507:b0:821:e0a:6cd9 with SMTP id 00721157ae682-83712da963bmr32775117b3.17.1786746349699;
        Fri, 14 Aug 2026 15:25:49 -0700 (PDT)
Received: from hamza-PC ([124.29.197.38])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-836c1777c5esm19859857b3.26.2026.08.14.15.25.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 14 Aug 2026 15:25:48 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	ameer.hamza@truenas.com
Subject: [PATCH v2 2/2] sunrpc: honor the netlink unix_gid NEGATIVE flag
Date: Sat, 15 Aug 2026 03:19:53 +0500
Message-ID: <20260814221953.108837-3-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260814221953.108837-1-ameer.hamza@truenas.com>
References: <20260814221953.108837-1-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The unix_gid netlink upcall protocol has an explicit
SUNRPC_A_UNIX_GID_NEGATIVE attribute for failed group lookups, and
mountd sends it, but sunrpc_nl_parse_one_unix_gid() only allocates
an empty group list for a flagged reply without propagating the
flag into the entry, so it installs a valid positive entry with
zero groups. Such an entry strips the uid of all supplementary
groups until it is refreshed or expires: the same defect the
previous patch fixes on the classic channel, on a transport that
can say "lookup failed" explicitly.

Set CACHE_NEGATIVE for flagged replies, as the netlink ip_map
path already does for its negative flag. An empty GIDS list
without the flag remains a positive entry.

Fixes: 0850e8603cd7 ("sunrpc: add netlink upcall for the auth.unix.gid cache")
Assisted-by: Claude:claude-fable-5
Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
---
 net/sunrpc/svcauth_unix.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 2f592ba54a366..4dd28749bd5de 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -737,6 +737,8 @@ static int sunrpc_nl_parse_one_unix_gid(struct cache_detail *cd,
 			   boot.tv_sec;
 
 	if (tb[SUNRPC_A_UNIX_GID_NEGATIVE]) {
+		/* failed lookup: keep the credential's own groups */
+		set_bit(CACHE_NEGATIVE, &ug.h.flags);
 		ug.gi = groups_alloc(0);
 		if (!ug.gi)
 			return -ENOMEM;
-- 
2.53.0

