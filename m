Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793586007;
	b=lRT9uqih0mjsWmZ7saJz5TzSSl3swlaIB0g5s7wTL2/tYOpwQJrtBHSLF37mqwi3s2Jo
	 rv+6mYNT3n+aPH0Zgq+RXpOs24iTX14HZBg6syhBy51RjzHFEgX1oGD4T7Z/2JPRPdiJE
	 +gwNgkjndkKMUceZtRC23o9slvyElEhqgh++LX1wzeh9kJMqcse77PpSUQF4LnOAohRwp
	 I7Bbkr9eAk/8kZnnUQIhOPjINAxDRKg3P3PyQN+Lbh2rmCStmxryTG+DpdwUfpDqoZirQ
	 ECVh/CGgfCHtfFwljYzLZ+OLcdviKO8dwq3eGCeR8OtBeyfPNW0DsgrwzSKDbVKo8wQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793586007;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding;
	bh=rnpOPb5ycOhSNbEyFKFTmBCIRpZrtLdppFDO3OKlKYc=;
	b=j4QXUXT+oHEjNredUnrEiu08I48TAjvynVOm3YLoE769CSRQDKa2/oA7BGDvsFYv8B+l
	 fHkpz0ObsslMX1/k5YWuBshAMUjRd2nyQTkMnyk0tAxwF1L1V8JOH3jdF3kbrnH2+UsdU
	 5zXtRdPzoIWaqiIPCiphCAM5LxQaxbbARMCQIyWllyjdv3FMIk0R90TGUXyAnlWzDPY9n
	 wrGk9Mfedi51errISuTvgl98xeG1tAmNiowlbcwpj6ADFQLDXAHyde+5w+2bzFNBeEQap
	 AwBUGWjZxsEmkLDYANPm7pNl/Z4e0lmIIQ62YG4KXCJCsXQ6BJvzAqglpKl84DrWG0Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=IOFsOldk;
	arc=none smtp.remote-ip=209.85.218.45
Received: from mail-ej1-f45.google.com (mail-ej1-f45.google.com [209.85.218.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2954606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 02:20:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E2954606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=IOFsOldk
Received: by mail-ej1-f45.google.com with SMTP id a640c23a62f3a-c4cdc606b47so36677666b.0
        for <linux-nfs@vger.kernel.org>; Sun, 01 Nov 2026 18:20:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793586005; x=1794190805; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:reply-to
         :references:in-reply-to:message-id:date:subject:cc:to:from:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=rnpOPb5ycOhSNbEyFKFTmBCIRpZrtLdppFDO3OKlKYc=;
        b=IOFsOldkqrg4ase1q+zqSv0TWRD+pb85fQ5Ef/63MJbxOOlwzVuDvzRvO8w7FllhKk
         gdN7pPrf7FzOhWScYqL6ds4ig3FCGRvzcWx6SwYJtnrGdlWKTO60FfipgyDzowQjHpip
         QjK+etr/GbiBSY/COeK5ke3OyVPyPJWNBOVmMQb98DQqzURXaNGAVq/THXiQViPphKPE
         kCBX1ANMyWRAH80M9ntYnN97raWt0PpOY3g+BTYnSNmd7d7KG/QOWqRq1O7PPcbxG/Sc
         WRxH1QHPYMwmvx8ZJyv5RdPEMAtkFee10CFUKvhNUQelph+6C2BxGGOWMdgRTmbw9Qwa
         SyLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793586005; x=1794190805;
        h=content-transfer-encoding:content-type:mime-version:reply-to
         :references:in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=rnpOPb5ycOhSNbEyFKFTmBCIRpZrtLdppFDO3OKlKYc=;
        b=iFyI1Nnz7xe00A/13nHrl75CpPucrinQNC1OJxp30I1GAtLvB+g44GW8ELzA3zr//B
         vJPbiQBRB/yrMGgjelMRplKfUuH5WbKzSDwNfBA5R8OAox/ZYM85BLnYpmVlDMIiucJn
         7tmiCanNOP/hPe7lAf53v7x5G/eXavEWKwqYP4DksNE6kTZujEabOtP+Z6+Xx8Z7yEOW
         ibwMueKtxuCVxSiJx7qEF7e5cRDCs6U/tC9pEgLp/bUozol4kD4DzP56R//pVZX9TZor
         0fNdnG85Nbql1ZmYACqumbXHwdnNr6K9m5PiDB4znnpZ9Wrwwpi94qoSE2YjFsY4Wnxf
         tWxg==
X-Forwarded-Encrypted: i=1; AKwUvBwy0nHpPwEqqmb5eMV9qI0dei8z7OKfL+97oB4Ufvzj6scwPARet3jCQkmQ3F08tAudpHUn+ddA2ZA=@vger.kernel.org
X-Gm-Message-State: AFq9FYK3dUdPRnfeyLAynmpJKKejrsVz/3OftOCK9yZKZHQs/BbyG80H
	3q5gm9fB788gt/ckiYpJqmAq7dW459hjAQXJQryjnBvZbs2eU6JLtwZh
X-Gm-Gg: AYBFou24XyZ241VfAdmX5zFNVwlLOh0VBE7CmXCGO+ATAldoht5BhGxcJ9lw4QpWVxf
	Hlxm0Rv6A/h6hoauOnbMP4iyfI55Uk4cVBEvz8fZRbmw85UlcEX+L7Q+wPZ/6IMV0jSThf6Zo6R
	a9AOhP7ndHH2XCYDKKv6gXiraQciGvxyodJMihyCCG1TKmPKrAI8lxVo47Xe3bA93WWgaCkTwZe
	V9glJ61J8PIiH9Vxk+cUU8Qcte9kw3mEyd3liD0isOnhzyGCMrvd85YpXEdKYTfctSBI7yhoWHg
	BlVgb1PFRcqbGkW+yBaM32ZD+M/QpAvmWWdNBnfsB9SuTVrEv+jNGLxUz6mQ1lBPeKoZ6MhFHrT
	7FYwH82NLGOirKgMlGwdB8TRAS7Pwcf5axkDEukWHyrMyRm51HKLa5tgJ2pYSQKlc0TkmllLzae
	yJ3zdDhkza47OwkGZW7eCogMNrq1NPrm652tjCUWV8A6LGKqP0KszR5Wh6bEcmm4H0gq/t1Q+Oy
	B8Du+scSdq2E2ub5/jlNIWRUL83WP3FLws0s+kDDO7kVk8y/IJ5RfnyC0ESocll1dxGenxv8Zmf
	UxIsbsOb90lZ7UyBtHOoyDu5KRDzXwK4Giz8CX6fs7C5/pxv0+KXY1jo9itboyvEcnrCT27Y
X-Received: by 2002:a17:906:99cd:b0:c41:731c:534 with SMTP id a640c23a62f3a-c4ca7a86e67mr692218166b.24.1793586004998;
        Sun, 01 Nov 2026 18:20:04 -0800 (PST)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b4eca21224sm2648859a12.33.2026.11.01.18.20.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 01 Nov 2026 18:20:04 -0800 (PST)
From: VeroFess <coderzeng@gmail.com>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v6 0/3] NFSD: Enforce export security after a deferred PUTFH check
Date: Mon,  2 Nov 2026 10:19:22 +0800
Message-ID: <20261102021922.674421-1-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261101-verofess-v6-0-4d70097db7d3@kernel.org>
References: <20261101-verofess-v6-0-4d70097db7d3@kernel.org>
Reply-To: coderzeng@gmail.com
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit

On Sun, Nov 01, 2026 at 10:51:09AM -0500, Chuck Lever wrote:
> Changes in v6:
> - Verify the current filehandle in SECINFO_NO_NAME(CURRENT_FH) (sashiko).

Hi Chuck,

I tested all three v6 patches on the stated nfsd-testing base,
d9130c9f6535392d423351ffb5521e7689cae6b6. I built and booted
patch 1 alone, patches 1 and 2 together, and the full series in an
x86_64 KASAN guest. The full-series tests also used a second guest for
inter-server COPY and RPC-over-TLS.

I checked the v6 change directly with AUTH_SYS
PUTROOTFH; SECINFO_NO_NAME(CURRENT_FH) on NFSv4.1 and v4.2. With an
xprtsec=tls export over plain TCP, v5 returned OK and v6 returned
NFS4ERR_ACCESS at SECINFO_NO_NAME. With a secure export and a high
source port, v5 returned OK and v6 returned NFS4ERR_PERM at that
operation. PUTROOTFH succeeded in both v6 cases. A mismatched sec=
flavor still returned OK and listed krb5p, as SECINFO_NO_NAME needs
to do. The operation succeeded from a reserved port and over real
TLS 1.3 or mTLS when the export allowed the transport; TLS without
a client certificate was denied by an xprtsec=mtls export.

The original NFSv4.0 Kerberos OPEN stateid reproducer returned
NFS4ERR_WRONGSEC at PUTFH for AUTH_SYS direct and SAVEFH READ/WRITE.
The file was unchanged, and the Kerberos client could still read it.
A second guest tried the same 108 stateid candidates as in the earlier
test and obtained no data. With only patch 1, a protected saved-source
COPY succeeded and changed the destination; CLONE also returned OK. With
patch 2 added, both returned NFS4ERR_ACCESS at their own operations
and left the destination unchanged; authorized COPY and CLONE passed.

With patches 1 and 2, LOOKUPP still crossed from a sec=sys child to a
sec=krb5p parent. The full series returned NFS4ERR_WRONGSEC there
on v4.0, v4.1, and v4.2. SECINFO_NO_NAME(PARENT) remained usable on
v4.1 and v4.2. I also reran the SECINFO name and permission cases,
READDIR with and without rdattr_error or FILEHANDLE, the NFSv2/v3
CREATE cases, and NFSv4 OPEN. Their status and error placement matched
the v5 run.

The other regression tests passed: permitted Btrfs COPY and reflink
CLONE returned matching destination bytes; asynchronous inter-server
COPY completed 4096 bytes between the two guests; protected local
COPY, LINK, and RENAME were rejected; and retained stateids could not
be used after tightening the export's sec= policy. Plaintext, TLS,
and mTLS mount crossings behaved as before on v4.0, v4.1, and v4.2.
A raw v4.0 SECINFO request also succeeded over both TLS and mTLS.

The 259-case source-derived decision test passed under ASan/UBSan.
W=1 fs/nfsd/nfs4proc.o built cleanly with inter-server COPY enabled
and disabled. I saw no KASAN report or kernel Oops. I found no v6
regression in these tests.

Tested-by: VeroFess <coderzeng@gmail.com>

Thanks,
VeroFess
