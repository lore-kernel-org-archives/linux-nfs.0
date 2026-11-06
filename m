Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.216.98
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794008303;
	b=oqvCOzCyVJztI0LYHLUlvVZdLPOOmrcTOzX/pCDZyrgHDmy9GBROOWPHPLgaA72/gYsJ
	 nj8QwXoMvbJPSfyrK5kLSc+7u5D/lwMR+u3FJ50hU4DwkAku+AAOz7wHRBxgIkjEZJIo3
	 0X0tflT+KRntrCMSZ3oyQ0x0f2foctdSKLXIr3F3jUxqadRLNPp4pFfTBQ8eRMEZ8EYaS
	 h/lZETB64OEtIP5G3QpKwTrq5cOyo6YMC8BRgfIO/dc1NZUipTEN9zzBdq3QkyGpnJse0
	 iHoUaDZznG1PpS/L71nxml8yV1QHHoSKYThleZkTz26VUYLWsp/ZC2AHzXnJiS2tmUg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794008303;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=N4DPvPiEv18XL9E0HU5NSnRDXM9pLl3JEb1r3sKAKNM=;
	b=W/5AlT297pHC1xgluyx7I8u6CL7wcbY0eprr5X8zWK/q/20wHe6GRDSCDpScIRjk7O4r
	 IvMoVaG7UZHVxoDGkkkAPIJFXfJDEBrQDUMojsvmoSgCOzHJadkB+pYW6/rLLYgsKXcy9
	 VDjn9+soSSSLjVDXFGUCSOFvRA7M90K6lnuBZ9g+4kixHDpOXsapulTtpMKlbDYXSGPt5
	 6Z/V6Yu1lwB9vjMPbAWHQ8IuQxjd2lV1Vp5c9GN3830G5XHBqpv1eEOr1/Mha2J1Gxsrt
	 qxchNdmjqaL1D65XwC2tShYajAOZWgsr5HsIG4eIKuA7vC2rAqZELLccdEc2TPSRxYQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b="uft3M/kZ";
	arc=none smtp.remote-ip=209.85.216.98
Received: from mail-pj1-f98.google.com (mail-pj1-f98.google.com [209.85.216.98])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92943606A32D
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 23:38:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 92943606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=uft3M/kZ
Received: by mail-pj1-f98.google.com with SMTP id 98e67ed59e1d1-3b08cf16decso799680a91.0
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 15:38:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1794008302; x=1794613102; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=N4DPvPiEv18XL9E0HU5NSnRDXM9pLl3JEb1r3sKAKNM=;
        b=uft3M/kZNtWMfwjzHoEKEfcv0xeGY1LFpaLGdGijed3dylbSlMh+emOTfhlOLh9Zq7
         nRMyZWZfjTGaYcPX06pV0RViMhCeTv8CWuIbhw4/6gVn/bAtaz2dytdvNQkNPQzEi1eR
         KJ1vTeL5wSX8wMJkHUrNB2uDIaD4LVcxIZ1D7OVRGudzTX6qPX4I8Pnihx7TY6G9gs2K
         yj4u4DHfb7ZVkZS0LemR7LfNMhynMHLYil9YIsnRFPzFo5/usB1LpGMPhb+jwerJwIBk
         zqFTppoT9BI3Qz2q7fEeWTnYDxr8eHrOxbhwyV4M3Ui4UKUawhy/7UkCMCGBFotUEzRz
         pfVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794008302; x=1794613102;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=N4DPvPiEv18XL9E0HU5NSnRDXM9pLl3JEb1r3sKAKNM=;
        b=MHK93jtsenIcjuHf7HnQfI9ZKV9+wcDSWvzcp5UfcWcHNLoXqyz71qJfJD5RpnVFQO
         RlMSp0opRG70IPn5+K5Rntv7WeLZBOChqzh56C1if4v85kezUsnn92ccaJpsp559IEB1
         0zzOMF/cq/+93BfKIJM5fFUVCSnumzBQecM1jexIkpVJp8SchiDYRtzR+vs66ho1PnCQ
         LWiEF2cUjnehudnBA15Zr7clcEqPPzE0EXbLVs4uUU1/6PxXb8K8UO2+vNrYodk3uQaF
         guBblPb8kKSHgMY4LO1deP3DAxYQ/iWrvr02FGq9pHbEhmANUunU2H3ziM/4aqGdXUbi
         6H2A==
X-Forwarded-Encrypted: i=1; AL+hErGJ66AJOgJQb89kY/tLqf2w3kdtPx1ssQU+eDWDFSCegXUiMOlJko1hotSD1GghcNrxPoNJdJT4JiI=@vger.kernel.org
X-Gm-Message-State: APuU4Z8FjKOWGmNu/XUeRWUKtJgJLeOutb4yy6rxtSB7u81CcfMkw0Hc
	oH0mVIna/rKj1zBgpgm1YblMj1aq2syRL568UPjz5sML2G3GbnyhOIwkYHrifUAp0Nzw/73mqSE
	oHfCm0aCKph+nsMQ+AIKcNJZ8j3JJvfPbBdtk
X-Gm-Gg: AYBFou1qp6ytRPmQJ9Aulf3yJBI00rfaEFQzLRSYdEBGM06rfItdnDlT1aUALGjbQop
	uY9rJLloNZOQ3yg/j1sPJLnI3+FjYITzKkxY4xK2t8oOWGmNCepOJRCX/GlGJs6EbQAwmyopqZG
	8jl3jdVILScSiC1gaGrP3uQ7FINgZuNssRxjvCRp7YDMK4NBPudIGRsD+lu6WkGP/MbuJCsBFr8
	hSsnyIs5AB0f4+A5kls9JC8x0irNeXe8zJ5ihrIpj49Xn4rkWsQDmmEg0YnPkhkTgiNPVfM1fPw
	ETVZ6WHE/BD9AhHNOUFlEt0MCyHTpya5P8wFi6Bo4sYu9Bn4GnpRMJdS5Dp2BKVOM109JLGEMx7
	BD5p/rSWWKJj6ybZh3K6DLayjwJq7OFa5zqstLZk=
X-Received: by 2002:a17:90b:1c0f:b0:3a4:b8dd:1447 with SMTP id 98e67ed59e1d1-3b0db6f69aamr3787723a91.34.1794008301864;
        Fri, 06 Nov 2026 15:38:21 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-3b1058d66absm412329a91.4.2026.11.06.15.38.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Nov 2026 15:38:21 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 1C11634039C;
	Fri,  6 Nov 2026 15:38:21 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: cel@kernel.org,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	jlayton@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	slingappa@everpuredata.com
Subject: Re: [PATCH v2 1/2] SUNRPC: add request-scoped disconnects when cancelling tasks
Date: Fri,  6 Nov 2026 23:38:20 +0000
Message-ID: <20261106233820.2182993-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261105170653.3200815-1-tmenninger@everpuredata.com>
References: <20261105170653.3200815-1-tmenninger@everpuredata.com>
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

> Would retaining the request/connection-generation scope, while removing
> the additional unconditional lock acquisition from xprt_release(), be a
> reasonable direction?

I've posted v3 with the additional unconditional lock acquisition
removed:

    https://lore.kernel.org/all/20261106232844.2176820-1-tmenninger@everpuredata.com

There is still a broader question about when we should cancel I/O in the
first place. This series does not change those cancellation decisions. I
still think the narrower disconnect scope is useful independently of how
we resolve that broader question. Where cancellation does require a
disconnect, it should not also tear down unrelated transports or a
replacement connection generation that did not carry the affected
requests.

I posted v3 to put that narrower change forward for review, not to
suggest that the cancellation-policy question is settled.
