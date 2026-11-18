Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.182
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794961097;
	b=jiId1Tm5ERyeppR4pQY0rzVG1/n3VFh4RfDA5gtODryxOPlfY1TAnN1N00V3DelHIn4r
	 3Gd5BhVrwJV0uxi5BY0ihrWNU4b4z2GzXLPLkeZU557M70o++NXGFy7FwshEH6iz5fBEQ
	 GxC42jHbzaf44T9hK39C7tu5fJVWLv3fSsftu2xtXhoOcfwAdL/DnpBf5K1B1MvodakWb
	 OaTxfVYZkhH51fgTOBgnC1NQgywvvy94Q503Xb0tdvquCmq9x4CqW+uHgig9rKkCwX3oQ
	 aa6vtpad/kvM2rFcfvNANk4Yv6u5S8mtXXd3kRfYzybMkMuDA0RtYehxUyLuOZxPDWw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794961097;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=X1g69bJFdd5YTWVA640/efR/98fE9PZDJM9/5i0bSL4=;
	b=IZFKuEgozzZiREFPepcu449mhp30SnAAcmOopQXB1KmfhwFVBCVTU7es2bt82ZPKYkAd
	 MbLAfDQibUiXUIn/vytrH54aCkTNppWQMAVEhyT26ScWe3qnXAzstEWEUQoFbqRgUZi4e
	 wEgwf8icPwkhiZTRfMPJVyQ6FTg1y0Jbi8npXC9nvPOaDlMJ9ixo4gFRytkoe1MB+/Vzw
	 Kt+KZtEgxZjw4L5VFT4ewp8Qvj2DCKKCWqTV6XEw4ADvxEcluAlmfnv0NIDR6TXPllYwH
	 MyjimucZAiQvmY48J9djonIiifz7X+pN9VB/ZqKd+IplgJv1sZLmqXvIn1YM3fhts7w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=kiFxEgNi;
	arc=none smtp.remote-ip=74.125.82.182
Received: from mail-dy1-f182.google.com (mail-dy1-f182.google.com [74.125.82.182])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C0B0606A31C
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 00:18:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0C0B0606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=kiFxEgNi
Received: by mail-dy1-f182.google.com with SMTP id 5a478bee46e88-36eb1cb7aabso716728eec.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 16:18:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794961096; x=1795565896; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=X1g69bJFdd5YTWVA640/efR/98fE9PZDJM9/5i0bSL4=;
        b=kiFxEgNipoiOiBGWTDHNNQElTOMMn41N/0VIqbf5fKqpdKFseTtwLKPDoQRUWLnobf
         XhpTj6F0mdHdJvPC8amm9kR1p8ehPvp2aIvKqatKkldCkSfifF9/WenmFQhY0LMgdL1U
         tFl5PNrMu/uwkGclIANOCf1CJHYaXSbf1n2PEj4Ov1K33Q3wwE7WL3Oa0M47LE2WipJO
         n68WKn/HU+/Xs2L7E+BCjEXOprIeLkdhx77QSOQ7y7qHd2hjgannYr2W+A4nP0IqEG6g
         iA/MbO7F/94GtRoQ8EXTLGomE/UNG0Aw2Q/UEfWLL2q45WGOld0EfS1IKaHdjSycJzj7
         QlCw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794961096; x=1795565896;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=X1g69bJFdd5YTWVA640/efR/98fE9PZDJM9/5i0bSL4=;
        b=kQm2Lijr+PWPpKzTLtWqZqDY7im75wxiwPQnsCfNI4vbmODALUUNo7U7kTbLJCz7p7
         Yl5m45d8sTtibKAgMp+KL0VkAo1YviiYxGfg8QV7kgPPGbNN4c6h5QIScdPJTzh1HBOE
         s4iqlyR3drn0ARgRaoUtX/WLXUI1JPsOiZH+MwyycRCgP4A/Q0E48/IgLxehBooLo76A
         uzWbLhaMGm0OYCsqr8XWMZTtFSmm2mvmt7y10jH5WRE4tLZXL4qKeG5mlhU5ZuwnyPZO
         aQw+NaNSW8G2e2ibdVXhwn3MgfANqGzpMIPjCu8NwuJn+a408G/eXplUpX/eRzNM7FWU
         wj1Q==
X-Forwarded-Encrypted: i=1; AL+hErE0DIjQ86yYjMhbzDJnXHZaYfxB364yqOLJ55M62BfnMgy5yBOwHbkoOjMRghKTy8KrUwhQoTdNKlM=@vger.kernel.org
X-Gm-Message-State: APuU4Z/AT/SumeI3ThaN+Wl14tt5NJf3/Io8YhQjnlhUtqqv/9RtqUY9
	oHWPXlB+WytAVBNfjKiYKpJ2RvhEIzYlW5+Vf6qtmmcOpBy4OlsZWwmNiZZJX7Ag71c=
X-Gm-Gg: AZFdTZcfxSJOSk/F37ZNOLhu5Tk+plcpNgwVNPQ4iqGRF/L82rGGYbzC2HyU/KBSkAW
	BVVFBSYJ829RyVCVpUyCfu6WL48VFB/xFVc7XHEdEMFjYCw8jHqe+bSXQMG02fG5m2pEcntco6T
	5Eoi91av2vs3W+ExJUJcfuImCLmWrqMajtP2KKGM4+rD5jhKmuv/EivvYkRfxOnonnPXsKoqQgv
	lPLIdt8CY23trKBTVVxeH1ciNPJ9ZoWbjkP7PcL9DQ1+KvCEnzTSi67xkam5fLupA/fDmgj15i2
	vS0qceEA+7DganAIkXtCkRPlGNWY0qvkRk47GAH6FwLiZ0sjB6S6vSdlNyqMhyv/Ln9Q/IMJ9ZZ
	qox0tX5cnXIyiAQKHdBySo2ylxSPYWKxnq+hz6VpcKrZBtxKEgT9UntuuIp9mFI5iT7bu+hn+0u
	ORL2EomvTvkhfNPJ4t44jkp86mzTy+aS2ZpHRjQ1pN2nSI43ktlF2QBx6zFHLT44tWLHtcpybHE
	3uy6fEAIGcVBMtOzHoY7XopmRPbm19i4gHslU+bda+hONCAuFyE6Do3INQPkLh/cr6ngY7+5xnd
	f1vXq4ZnHlHTbVMJXZLkFYPUd5pDjhw7meNWEBh8oi1fx3Hxi1KXCV4NJi7sVWZRIn2LohlSfA6
	1wkIS/CXzopb5ncB3C84rW+A5yYeQjMo6S2M+qr+4JmaZqQ7i0w==
X-Received: by 2002:a05:7301:301c:b0:372:33cb:fa85 with SMTP id 5a478bee46e88-38281526031mr1067938eec.29.1794961095914;
        Tue, 17 Nov 2026 16:18:15 -0800 (PST)
Received: from localhost.localdomain ([2601:646:4300:d042:3cdf:59bb:aa36:fba7])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-382a45274aesm1624664eec.2.2026.11.17.16.18.14
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Tue, 17 Nov 2026 16:18:15 -0800 (PST)
From: ozgun kultekin <ozgunkultekin@gmail.com>
To: Paula <paula@bynar.io>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4.1: fix out-of-bounds write from zero back channel ca_maxrequests
Date: Tue, 17 Nov 2026 16:18:13 -0800
Message-ID: <20261118001813.1675-1-ozgunkultekin@gmail.com>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20260819170109.8132-1-paula@bynar.io>
References: <20260819170109.8132-1-paula@bynar.io>
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

Hi Paula, Trond, Anna,

This bug is still there. We hit it independently and reproduced it on 7.3.4 with KASAN after a default vers=4.2 mount: a server that returns a back-channel ca_maxrequests of 0 and then sends CB_SEQUENCE with a large slotid gets slab-out-of-bounds reads and writes in nfs4_try_to_lock_slot(), nfs4_lock_slot() and nfs4_free_slot() at the used_slots[] bitmap of struct nfs4_session. The code is unchanged in mainline 666539eecdf4, next-20261116 and stable 5.10.274, 5.15.225, 6.1.192, 6.6.162, 6.12.117, 6.18.63, 7.2.15 and 7.3.4.

The check you add matches the one the fore channel already has. Could it go in with these tags, since every maintained branch is affected:

Fixes: 5405fc44c337 ("NFSv4.x: Add kernel parameter to control the callback server")
Cc: stable@vger.kernel.org

Thanks,
ozgun
