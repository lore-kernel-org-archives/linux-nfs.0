Received: from mail-ed1-f99.google.com (mail-ed1-f99.google.com [209.85.208.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4454B5581F3
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 21:29:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.99
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791926957; cv=none; b=uWMT//mKPF7ymR5af1PQ5pBEb9cfrr9w4zrtqWO2mlGrcf8bIxJdGqsQPF+oAm8+/HZ5Tfzf6Jcov1SZzOKaUXIkNMpHWGO6yJKlvA0hnHUiChGxfzt9l6ElWZ5q+/r0YX3iEpzg0/N3SlItfx/Q6bMHGHdhzrUJaxPkkR8iCM4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791926957; c=relaxed/simple;
	bh=Ohf+Jpl/D7AXu0XpfGAbb99OwlB2fyEd5gSUwMdqWEo=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=Zj6kToNDnigROuR1W5zXdr+vN3DlRMjLQ/BvicaGHmSaRSUPBcs8qwh6xmgt4dqsoC2QtnLys65vUdFSIG6dCAltbicFLSLt2npwzspa0p1s5I8qi6cyosFyZVaz3CZjHyiEDsjm+4piBehQcyv/pPyzXiXrE4HkQMsLIV11Sug=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=I+GOs7IZ; arc=none smtp.client-ip=209.85.208.99
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="I+GOs7IZ"
Received: by mail-ed1-f99.google.com with SMTP id 4fb4d7f45d1cf-6afa651700eso5020936a12.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 14:29:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1791926953; x=1792531753; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Ohf+Jpl/D7AXu0XpfGAbb99OwlB2fyEd5gSUwMdqWEo=;
        b=I+GOs7IZ+Ob+n5R8RNTLBF9Bco001h25+huRSPjtcbnOZzyE7cm6UjfdWe3rfGlOdG
         ghlkGkqhQdOHyrTgtMfHkkRdkxo/v3rheKyc8QozBZ0Lb0Jznyo6ZXN3uPXnUM0+qC/X
         fMHjbllCSAaCnAj7NKMTClkfVGC82iSz0LNwFOXPArPXWcYvwRM0jmNXJPTmfGagp9tn
         PoNCBfEQ5SQkXeB0qv6z7y9aqhr+tnzBvebwLbhQ411xiCOgj1x9j9QCU4MhtAXFIAW5
         n5Y7wwKyf87P+EFPeJI5djtU5Mc6SMhCXRTCjFhabkTfqJFKvVQYZdanpWT5OPO00Vl8
         aQUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791926953; x=1792531753;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Ohf+Jpl/D7AXu0XpfGAbb99OwlB2fyEd5gSUwMdqWEo=;
        b=Nxe1BRYvDoMdwqUor9HW/vGmrTPnR2S/tzA4F6w/uWCGGEb7FI4y7E6ibO3RGBgI9b
         3PnJ1REC2Ted96+6tCd3PYRMSwPpUeWCOvUyb4/rJh8tAUCh/aGjJAEav4XZG9+8Cm7B
         aaRuBY+h5UXH54UFQ/nKtwqTZvz2oEW85b3MMfbrId2mmzCoK+vQgtDkQGkphmZAm57Y
         baOGebk0VshfkjDqgnK43tPCKDTxYH+UfqnP5j3rBp/EI2WGGAFMFmXTwlVsWzQPLpB2
         xOxYW2fbh/Bt+r16SEFysU66TvjPl0EQurmOdFY7EoOLmyvjhLgtVQET4GKbaANUCpCv
         N2pQ==
X-Forwarded-Encrypted: i=1; AKwUvBzNS1PLEkT9n8U0G6aUy60PEuapFID+xhpcF5vLqlc1rcibqYZJEiZ8eecn3THrpPHjAh9Nm2W7R/I=@vger.kernel.org
X-Gm-Message-State: AFq9FYLDfYjzQV2POMmmxB7NrsqoPIv1BWH+LmA9oiYj3bSRfq6Fv5pS
	wjjNShvRrR4L+Sce/LDDTCHQBar3YWm4EelYFygXOpBNL+xRtyqR1uR/RFrIS64efOgkDgHdGMH
	qE/mXnItl1W64mNCExvLRAaxrpKeA4dn1IGNI
X-Gm-Gg: AYBFou0G+nlxqAf6lcQ5xyxK57UdeFy9KCssFjoUbjMZ+cssbWwk/eAkn2ST1TBbTx8
	ExtWpNfhA9FozCVP3hNGAIrkpmMQNRYxcFimruXIEyCibuBM2ZaGGIuXbKXCls3d4AubMtQmpqQ
	HmODRM0LcO6+5eCYy5XCmfp0bt6O5Jnix13/PnX5sDVShQyfPFHGNNYoyvqSYl2SsVtZEkxZVhf
	cTZFXTaqETvh07AWu9BBk3Wey7g9LyHz1KLX+EDkEa3+3hR5BAj7TP67vi/DFiFqRiKtC7kevY2
	iDsEe8m8CtCtzHQVzuU1onfLuy8ixwQVRCH7w4nskjd20ANARINGF7+Wy10dsoRu+mkYjuC/qXQ
	R/YBwf0CX/O/tE5J1ZvzvbApmjVQfNZc/vUOSmlo=
X-Received: by 2002:a05:6402:44d1:b0:6b1:c6fa:c461 with SMTP id 4fb4d7f45d1cf-6b1c6fac66fmr4159999a12.9.1791926953336;
        Tue, 13 Oct 2026 14:29:13 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 4fb4d7f45d1cf-6b203832dfbsm329944a12.6.2026.10.13.14.29.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Oct 2026 14:29:13 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id B9F90341570;
	Tue, 13 Oct 2026 14:29:11 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: broonie@kernel.org
Cc: anna@kernel.org,
	trondmy@gmail.com,
	linux-nfs@vger.kernel.org,
	anna.schumaker@hammerspace.com,
	cel@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org,
	trond.myklebust@hammerspace.com,
	ymu@everpuredata.com
Subject: Re: linux-next: manual merge of the nfs-anna tree with the nfs tree
Date: Tue, 13 Oct 2026 21:29:11 +0000
Message-Id: <20261013212911.2212308-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <as4aacUf2Q78FMvY@sirena.org.uk>
References: <as4aacUf2Q78FMvY@sirena.org.uk>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

I tested the original reproducer on v7.3-rc4 and confirmed the issue was
present. I then applied the combined patch from Mark's merge resolution,
and the reproducer passed.

So at least for the issue I originally reported, the merge resolution
appears correct.

Thanks, Tim
