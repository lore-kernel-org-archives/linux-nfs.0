Received: from mail-lj1-f171.google.com (mail-lj1-f171.google.com [209.85.208.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3234B495534
	for <linux-nfs@vger.kernel.org>; Fri,  5 Jun 2026 08:12:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.171
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780647178; cv=pass; b=FWGo0rfeubvquasjxpNydZbi1KSDRMHZTXJHrt2hm3CnTPLRAvPyWoMd3ZlZZRKKPyHHrLXFdY1S3lLA6EO14EpQRFuvucbi4QZYhgYY0xARGhb1EFz3Lh/jVvRyv0dQIrRMw42pBpHLs/0h/KuqUrS4Y9VQ98LXCWQdB5/bUkM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780647178; c=relaxed/simple;
	bh=u8Q1WXjqlC5qiRxn7sucCO95sEC38cQ31d6p2EtwTxk=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=E/QmU5UnIYtRz+BHKtRLfciWpCO8k2omvMYsdoNA/cyxSMeeavPEuPfHj2vO9WAFfW07gByENQiHjgMmPJzTBflGGzT0Gf3qTpZwBEBw3gheQLlOTFRV3GOSGjXMvu7FI+yNP76AihYWopJ4ro/XCibyKjExgtwomCeVr9l0HLk=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=CNEe9PUp; arc=pass smtp.client-ip=209.85.208.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="CNEe9PUp"
Received: by mail-lj1-f171.google.com with SMTP id 38308e7fff4ca-39676ff4674so14642161fa.0
        for <linux-nfs@vger.kernel.org>; Fri, 05 Jun 2026 01:12:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1780647175; cv=none;
        d=google.com; s=arc-20240605;
        b=ZvBS32WdRbQ1DezHA9fZX9D3yniXA8FPUriF8fjGH8p3AvHzCpyC5S2CYJA/ehdkt4
         vi5odP9C4bR2VeVuh4yQE8+KCIgeh+/9YkrE/GUSLdtvMZ8rARgrLlC8qZGglj+uGBZi
         uLCkvebiNAZXDYmBK7ZPdnWEPfyJtomwZ6B32uL9Vv0pZ6uzPOQ8NTthJofTdINvs2DM
         j/ZvkU/LMZxLGg9OCZsEt2TSRom/MJZtijzFylCLXCOC+EvHW3Q+vchKr/JTUsjA00fz
         /LZswKG/xKP4bQnTzD65BjNyoBz+tzNOXpZXCQswPpa1oGXzROSkenU1wV0KoxQxwAqI
         oS7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=UNQ7O5z6I1BYhENIlkkD1dwN4YbzeYUuGuJtBadnfug=;
        fh=ePMaMrm12VuYp/O62/4ylasA2cMYiFRlcbFW7L9I+2I=;
        b=LEitBob47jcWhKs8Mu0HPY5VykgMY+ULDrhpg4InvgkfFIRkYje+8yw5dngDw4XRcx
         6Jj2Ueu4S/Ws8GPKh7vzn/J8swQR4+c6zpuhgBaPL3Wiy30dPKKyer5z/RuUv3pTw1G3
         Dlxsn6E/PCivv+KMR2THboNl098byycGJbkhzPJ80RKs6uGrXGn8VV2ZHew/BhBM+S/j
         9iidqWilaIFmmbTBrJ5LUtQTDLzO/cwA1R30hBR+NsePvy+z+d4HnfZfcIu0L9fIeUkq
         2PrF1U+CAKusRuDoVi29q5DKntCGJia4CTcnGrZzFFcd2fGJ0bc+ocxoLDd7/Ws3r6GT
         ZHIQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1780647175; x=1781251975; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=UNQ7O5z6I1BYhENIlkkD1dwN4YbzeYUuGuJtBadnfug=;
        b=CNEe9PUpaoijwqkTIYHI94153VfVRW8M3uhHS6H1dJkNBlDd7+ha4P7nkNjD6icidz
         VGWq+BtdPAwtJxmxWIsJtsogm9MPVtD3m+pZgUkunYEUszSJOQ1HBTNB7BsTEOCG1pno
         CYd0z9BIBMWMp6ma8Ec8Xx7ru4m7bFcvtT3kDJdStgoQx4UzkA4A3ZMqSB9UwIGbM/nX
         GeM8p/P5y/Pi4Uz4TGNaMEyuOK6JxtUEUojuPh6tNHvFttcf7xwAT9aZFdx/h5RWUF5+
         MGfwfxdXxNEnky5E/hL2oameukx7OtMpy/U1U511qJPuQ6dGqxMjvEOM1HY7aHC9CiKU
         nsAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1780647175; x=1781251975;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=UNQ7O5z6I1BYhENIlkkD1dwN4YbzeYUuGuJtBadnfug=;
        b=sVOJDg93APWREWxx3ugg01lPa6zUZt0uYu/WPi8zWD0K8vYcoF/hN8EZS8cUp091GB
         oO+ATMkT3r94Y/FlZf7tpd1DT/KbxZ9dtJnUYJNLrhpLWa3rD6NPNEzgUoTvq8CIOsBS
         eba9xFJInrUcGpzyDsh0bl2BOrNj3HTm8fwFPUmPEiafzIXsNYANuoTc5HQ+dH2jB6Ac
         gZnCRtzNgutFPv7nK+fZGReNycTW6iEJRPtyGZa5+0qF3yZG5zscUYHlMqQvkWb01XW5
         2Ul8oAuwGgt3+dW1yBEqh/dKohGIqfoN/EXiPxgPlU96NEspGqkgSCIW6gwkaRUCbxiw
         XYKQ==
X-Forwarded-Encrypted: i=1; AFNElJ+4Ac5Hr9Lfz0wLdX1Pso4DFNLX3xTmJAh26h9JWOgjM3m0o2SSCCiGsIgP1lAeIvjB5oD3sk6xjdE=@vger.kernel.org
X-Gm-Message-State: AOJu0YxuOK0xQkJm9rqJQeqefUOn02lH/NJB1E7XwJwRPCcLksR7Lgan
	qpPiB/jbhwaktSk10NsyhPh6cU+6V4nE4HWPJ/R7l7u0fmBqu+seGWOtuHE0xVXiuKf4G2/ZvzI
	cf8bFSrZma+WHRdRk573+Csi7tzGT6nprllCRIEa8wg==
X-Gm-Gg: Acq92OGeKBoikgEQLmiWuHeMt5cx8xbbba7wRgrvG57i/DEC+bSbdJq+LeiMYwYCYL6
	ngtZIaexQ6Cy4DGi5MeQnu7bbCzZlMWdsIQwGUyYgZahQU6tZMqLkdIoe0+AR97CLFYBZmLt07+
	5R9/r0tmxKzdH7Vxhr/19/M6UWA/NLRmaN+/yWd1NSohvqQ1kT2pKhNXefvEBP/DXJgHu5R7TqR
	B4ObYrq6FnWCrP4/dzeG4kXXNvROspl7girq7dRHeK0KtKuK5EdZ4Ch6ftsCuILJpGJEMk+EjOE
	AjySSuQXtGkbrnYTiy+wyIH5WzcgTwmcaKrg0R9/V+0ZpmTPQpM=
X-Received: by 2002:ac2:5098:0:b0:5aa:2a75:e14b with SMTP id
 2adb3069b0e04-5aa87bc23e7mr500538e87.18.1780647175361; Fri, 05 Jun 2026
 01:12:55 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260507130117.252825-1-marco.crivellari@suse.com>
In-Reply-To: <20260507130117.252825-1-marco.crivellari@suse.com>
From: Marco Crivellari <marco.crivellari@suse.com>
Date: Fri, 5 Jun 2026 10:12:43 +0200
X-Gm-Features: AVHnY4IBbk-mtCcmYv-f3PQjt98lbgBbhfgbnsFIyJNcIJ7haAnpnTNZKfnc6Yo
Message-ID: <CAAofZF5_MRtySWTMs-J3T676FwjJiLDpYLRWmsFaSXePo3nZPg@mail.gmail.com>
Subject: Re: [PATCH v2] xprtrdma: Move long delayed work on system_dfl_long_wq
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	netdev@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, 
	Frederic Weisbecker <frederic@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, 
	Michal Hocko <mhocko@suse.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	"David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, May 7, 2026 at 3:01=E2=80=AFPM Marco Crivellari
<marco.crivellari@suse.com> wrote:
> [...]
>  net/sunrpc/xprtrdma/transport.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Gentle ping.

Thanks!

--=20

Marco Crivellari

SUSE Labs
