Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.214.226
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793314848;
	b=BMTXsXkuEiilH3C55YeCPSI+BQaBwjIsFbk/fx/aKxfSqAak3KpDqvh2h3Y+d6ZcAh4V
	 T/lKlbi05FSktPznhz6d6y8LHOqk2wMjrhyWiGFUuDJZ/jsDRm58taAQczUJ2GpRp915u
	 dLdI4I4+pPGfsp7WDJCAOR12rUsPLtutTLHYeUATfAVyoiY2Vbwv/OIMbIJ31MIx5BnIv
	 X70ztOZnWt6486JWE1U62f5pcKVIH7q6qZR0r20YmRLT6EZa0HvenqGcfmqCsm7dRh91B
	 RvWyzjsKzqRcQY3TeCNjUeciQxEHSiomqUItdxxMhrxO5Z0JM8eRTQXB73ecmS5WEog==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793314848;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=wAkmuO04uLZ+w6vmRTOyMcrwMg7+Yeu0ajM/FtCfLDw=;
	b=oESRMs0Ov+5NBWFeWRVttQ0CsMhbirG5PwPiR0luJNiTzrtEbTD1DBa5Dv8a/tr+APqg
	 0QIWqwBOKzJRN27RIn2keukVlkHQ+Tcpcw11Sw+WkiDHelDtTWC5d3vEZ3OEnEpMh9Tdo
	 u1eeVPbyzTIt6NH2ePk+t04kCjKzxdECTxBdmtRvcTA1959oo7wE7U/yemumDVjAAsWSV
	 hVVmZhdaFLXJ4ekljzzLdOGPymPjfoZme/L8LYIrS+IKbKo0iQkQ8D9Mvy6rOIf7/OQlH
	 hLA9/2gAcsLL8K7erEqdEqQAfbgsGf3Sny5lbMKIXFenifWQ7YysN1kI3UZNQo66gmw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=GCbi1D1U;
	arc=none smtp.remote-ip=209.85.214.226
Received: from mail-pl1-f226.google.com (mail-pl1-f226.google.com [209.85.214.226])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED365606A31D
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 23:00:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org ED365606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=GCbi1D1U
Received: by mail-pl1-f226.google.com with SMTP id d9443c01a7336-2e8246b13cbso1120415ad.2
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 16:00:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1793314846; x=1793919646; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=wAkmuO04uLZ+w6vmRTOyMcrwMg7+Yeu0ajM/FtCfLDw=;
        b=GCbi1D1UmJ92ke82TBFSwVWyiHVpUnp9ZTyC42iQ4udcBo2eCz0oMhXae06qQwsX+P
         3oBx8srzu9/J7nk03R0ySyKWycHTO+M3NzGbKv/uVDHnsBdnBDDIz6jnNC9lZK/Pn5Lh
         kRPv/tigWoF2fkhBDWUXfkSxbIlt60RKTEkdqWLw0UQtSJ4xF3CyqYP6ZAqA93PyqUoG
         3HrACz/6h768x1TrrVNUTaxhOo4Ze0zrCpCvaHLAewuGOWwqn7UQll1IgIRsXClhhgZ0
         D1i0NBlWyal5k7cAgRXHqD3BvWWm3BQe3Mcft0g1a+LXnxL41jEA86NxSCFJ1ToF+g7P
         9Acg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793314846; x=1793919646;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=wAkmuO04uLZ+w6vmRTOyMcrwMg7+Yeu0ajM/FtCfLDw=;
        b=o6CmX46cW706iQxrQy/31VaXaVvlp74OS+Qs+ga1QWux2HvIlNeIX+5Lg9WzSGhz85
         jetBm1E3eGEBjiiOs9AHTRbBs4ff72pbKp3UtRK8FFEVEbzvyN7WFYZ2Pp2NIXe4P0Vj
         iNmVRZbNXcsyvSaKAfXYPK0vwy7TE+zY2OmxGvGCEPGNgcYbOiZwj9cQReJoGHrTxnYs
         jSMOR3bGjKM3AAgSSutZKGwqnbneyzKged7zhQcO6KTwvKP1CySa70UGhc2hzMWQ1vBF
         wx3cBpTMI44wNRqAz6HMA44xCTwE/cj0bE1kjN87BdWDUJtgxqQxgI1rjnWz/8kUAubn
         agSg==
X-Forwarded-Encrypted: i=1; AKwUvBxS9gnW9Nolz5J9BcCWVr4A/x7y4HzkQUi4LZtq/k3THr1FZJvDSnhGRC2RwFQtVk7ImXHwLmkW+U0=@vger.kernel.org
X-Gm-Message-State: AFq9FYKqvfiDI3be4Kutu7V01Mm/Ui4HLcZxSBWN6UFGKRWOYzIdYmrq
	fW1c6//piuOooxK1y4Zws/ZxR6P+R91BSFS/Vx46k4Wc2YA0+dD5R0Du9uoR7QRoZjLdrBbczFA
	UXQTiZIjJ2qk+UA9LDa+Z9m2ZNKlyWLO73cyN
X-Gm-Gg: AYBFou0VjLin/pZrx9kcIlnx+6FnfW6ve5GeKTvZqWt6vHvqJD0TZ4uHSDpnf7XgIni
	LF8mzYxNBzouMGfz2cbTX9DU1ygXOZ4sp9ITebttEeYFpScqr+4FJudLeT9GGj0kF/PU6wR4K6B
	7HXNhvZgZvSCAUk+8fUDAHEJCRXUzvuQMK6PKM7QcVuyCyqpCDGvZBSC7EhtiAP3ZjQV1bs1GQu
	/I/Desg5hEivzurxvzF6p/uEh1VfmN1+/5Y8eVSJ8FQ0Qa7zWkO+yvl5n5Z2/yC+CNn/fCs856S
	+Ccf2qdwf9NXmPBN5gwfjg47yD3FU7Oa9JgmnHXmLw6OL2lGWCbV23RMa08BDq/mM8Injjr5M67
	WKR6dPkVpeBQ28p/9F8agS3KwbnR7fAQjNmh09EM=
X-Received: by 2002:a17:90b:5827:b0:3ab:be66:ddb7 with SMTP id 98e67ed59e1d1-3ae897bae26mr304143a91.47.1793314845971;
        Thu, 29 Oct 2026 16:00:45 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-3ae6e88749csm2871364a91.7.2026.10.29.16.00.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 16:00:45 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 22C0E3417A8;
	Thu, 29 Oct 2026 16:00:45 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: sashal@kernel.org
Cc: broonie@kernel.org,
	anna@kernel.org,
	anna.schumaker@hammerspace.com,
	trondmy@gmail.com,
	trond.myklebust@hammerspace.com,
	cel@kernel.org,
	ymu@everpuredata.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org
Subject: Re: [PATCH linux-next] xprtrdma: fix up the nfs/nfs-anna merge of the Write chunk head trim
Date: Thu, 29 Oct 2026 23:00:44 +0000
Message-ID: <20261029230045.1259914-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261020161346.3711926-1-sashal@kernel.org>
References: <20261020161346.3711926-1-sashal@kernel.org>
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

I applied this fixup and A/B tested it with my reproducer. Both
configurations pass.

I agree with the merge resolution; keeping the head trimming and
buflen adjustment together in rpcrdma_inline_fixup() makes sense.

Tested-by: Tim Menninger <tmenninger@everpuredata.com>
Reviewed-by: Tim Menninger <tmenninger@everpuredata.com>
