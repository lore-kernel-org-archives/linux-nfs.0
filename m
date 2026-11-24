Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.53
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795506038;
	b=etIsV58snQv38qE8rotyHwvXIxVLOzXbb6MXktMkJC00sKvngOsPsbnNsZ/CapAxNNld
	 ZVK4AAbPN4EOTKK7HV68gfFjAfIHVnRJkvlBFD6omZ9bmUF+6AZTr1otm39Uk0XUSUrU6
	 nBPmGekcSRdjQ4ost+vNogP+Ar1wZNHn1lABAGK6zMhupsROmz8kSs6Jkbt9Eqp4IGPDe
	 oeIYdDtnzAmjJdckvmTWAuItOOLz00Wd5TCqni84NXa00BrzNb4bUNAyzsvg0bmo2vDlP
	 MzLL8UulTVxrvbmelxlayLunWzT1j11wFdpub9SNOL+ZYg4yDP2qjbnhjp2UDiZecyA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795506038;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=4CXeOR2kr0QWxwXVJ8kgxv8jpZ3ULeKkBDrgo80WNA8=;
	b=JrsPwsi+ov1xNT4FMAWmt6xK1Md/P9YZfsY+3iufwaXDkD88c1ITqlfXMy6NuJh/ed5Q
	 S1x006vL6ahRsExw7T6XKaUGIagKPyIjD74SRtKN8W4W4arMrO7MIWySG2a9eaxuPXrtY
	 zA4DmHxtVd7niVeCvXHSOs6iscMzb3D8xGTxflZIdcl5YU0GIGHQD/hKr5YEim+xm+i6X
	 4Kjlo2483IZrbrZMaeVwaFfCMUQI4eYOPnb4Te8/7P7qMu2BFwKUCGnBfHYBrJM4CLRPa
	 YDB7wsXQgNkWg47rQy9Ol1lpTkvwMCVz/BgO+kiEGxiYut7j0W+gPtKOFuwBxP6Z+dw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=oxkH3z6S;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.53
Received: from mail-ed1-f53.google.com (mail-ed1-f53.google.com [209.85.208.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC26B606A322
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 07:40:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EC26B606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=oxkH3z6S
Received: by mail-ed1-f53.google.com with SMTP id 4fb4d7f45d1cf-6ba1e22ff4dso4801050a12.2
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 23:40:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795506036; cv=none;
        d=google.com; s=arc-20260327;
        b=NjyQ3OFM98LBYkmNTvNGlV4hV2c3NEPo6x7nC3SOLPqrp1w75tMrrEWJJl5DO25joX
         cqdNbdTqk7FG7asJQhPgT9pIedxJFGDdYTqO7zyZULgN842XKR9SYWhuI2kL7V1OkBWr
         aniOE+1uZaw/KUgu43y6ryT0I/noRqSDU/993OUL7IQBiwlVy2eX+dkc+PadrbwdtB+3
         +2D+7XYPmg6epVrr+nes26oJDbFJ3VuXB/tDYYwKv1iJvT8JqGvTnHU4QBbdNOz7nqXW
         xlgoW++eoH7Ttk/XbyvZ7XOwlCh0d/YlgcOpLGbXc8lT44QKTrvc677Gjgjws9kfZwwy
         zhAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=4CXeOR2kr0QWxwXVJ8kgxv8jpZ3ULeKkBDrgo80WNA8=;
        fh=B2gS8eMI93lIVLnkz/tBZx5ZLWA2539TOOQbkhXuaf4=;
        b=FgcR9my9yO3JB5waBzuubdfrkZyqRrBSliN/l1fdVPN23YzF3ij0wxT7kcT2v4003M
         AjC6OM+XB9kKiwxzRWzFbPYpYkUs9gplGIILx3mGLTHIkAaft1K6OIjzg5F1rWLd7BL/
         D4zOGLCiiccVMPkJ6zC2t4KLJZ1H3tqeLOFkXgJ1E32oK/dkirmbWo6L0hN93hLSUqcS
         jOPgpM4+OTNfkVADG+m/Tm3WbGzAWOqLlxtr1ueKg9VLjKh+CZPXZeEa8CTYz2k+5ss8
         TYJ4siGmeWYkpOkzaL8A1nE1jjMoKdu4OOCn6Q5h7kP+NoRegO7/gPQP4dBZPOCN580s
         /HxQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795506036; x=1796110836; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=4CXeOR2kr0QWxwXVJ8kgxv8jpZ3ULeKkBDrgo80WNA8=;
        b=oxkH3z6S5oobQJgtcXfQH0GuAqd/cenjkfGF1tqjc2+bcqwAyKj8T7knhO8Wa1HZ8J
         uHfRO40Eae11V11jsAbdsmulEYbPqQhxYRMLo1h9iaHOAO4jYvm0wj0QlDzhsxzvvxSN
         I5pFOem1W3Se5Tbtt8oQA1wjRqxkCkU2/v1La2JpxDv/tFUTE0O5Ws3eaBWAJZrqe8a3
         ARZvrho7IB/gJodkTfuzAUlT5BqaCnVdmjMEHe1Ys8XmrqZFl8aqpXNQcqzLj4N24S/w
         9ueWzbVdR8tQh8YGttAdCgtLjPNNCKA2Z1Uosr8S569Tg7/c3OBwQfq4sovDsqeJ3hXl
         B69g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795506036; x=1796110836;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=4CXeOR2kr0QWxwXVJ8kgxv8jpZ3ULeKkBDrgo80WNA8=;
        b=r8RW5b/vlBZliotG9CC4wzSbE8EqPRUxoMu3u5Ugdy7ZbQ1V1uJleGG+mk8Jx0VZaL
         aHowgGf6Pq8zyOWPLN3gPL8F+lEF5HYbUcwtaAc+JJDqRHFL9VmcWITRa8WK/DObVGWP
         k0jzBqullory/TOdzM1oKyrfF+ZzKaXbenEqepKZlfzZxURbbsZNxZGGRHFCh/yhzgC3
         fLZK+M5AYTV01Azvv/JemKzDg6FYZQ/hMk2T5LmkTPu2wTcIHu4NCISRwUU990LPYnp/
         3Z7nhAKQLh8oXriXU/rGT5YE4X5F17sGRRrc73SAmP8rk1zzRg8WgP/znLi9fQxPlVyi
         VibQ==
X-Forwarded-Encrypted: i=1; AL+hErFFhSMxty8V1hi1yzl/pN5nG4CHNfbruLlNtUhb2RMLaoYk36FeweY+HvHrN1gWsL9rw8fAihUK78g=@vger.kernel.org
X-Gm-Message-State: APuU4Z/FMovn5XPuR1bRz6LnKfYbxjnUtp/LK4+mJx5QAhsHHW8QAGq8
	l3PWs2l3LvU4RWtLlB5IrtaWvjTsnWvO5DfB4bs6SLlgyPfpTWgGEEx8m0fVVllnh8EUaUCeowP
	X9S3lz66/lHkW3oJB1MFC3rmnxFyxheg=
X-Gm-Gg: AZFdTZd7tyeAOmnnml+BwFlXkuqUnwSF773hIHsLB3LUhT17YSvXNMDjPLHPq2ZediN
	8J76gEAEAWeEvzY6cGECekz8B8lz8f0Dxjc4QjjeLs4EccTrm8zqb6jJWCp43yEszTa0Cd6nA6/
	dEkz/+Bz29FX07HAiREGr+bQwJhuQsTPxpUByWR+78wdCW4dqfFoVVR+PCYOiOUZXAGsPwldv70
	POSJId6Votkf42+C+qXEnSU/7McvePP/Rv+lslMesmnEbn2shoDUVK/RkmWvT9MlhVPLf4AL7Zp
	XIkaPiBsy7sOZ9Bzy4UyWOD753ERb+61pVjrnEmn28LtpivYkpjYOoajqghT4/t9S3sgpS5TzLK
	bYNFVtQyfsASlvNCmrnWFFVduekZJZKyrEE5c04CDuROJYHF9+PYEDF89ayL6fRIAP0bD6lE=
X-Received: by 2002:a05:6402:90d:b0:6ba:6654:6a6f with SMTP id
 4fb4d7f45d1cf-6ba66546ba7mr5596605a12.10.1795506036198; Mon, 23 Nov 2026
 23:40:36 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org> <20261123-delegts-fixes-v2-4-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-4-960ce0fb2fed@kernel.org>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Tue, 24 Nov 2026 08:39:00 +0100
X-Gm-Features: Aa3M54pDAnp4nzuVx3_sk6ZGaLciZePtabVFiusFMvgfv9iLGaYf856NyG1jvWs
Message-ID: <CA+1jF5rbGGB3iqc5FObbTYLyhT_gN18f1QfHRCuuOuBeJXLitw@mail.gmail.com>
Subject: Re: [PATCH v2 04/11] nfsd: don't grant write delegations to NFSv4.0
 clients on CLAIM_PREVIOUS
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Christian Brauner <brauner@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 23, 2026 at 1:59=E2=80=AFPM Jeff Layton <jlayton@kernel.org> wr=
ote:
>
> nfs4_open_delegation() refuses delegations for NFSv4.0 write opens on
> CLAIM_NULL and CLAIM_FH, as its comment explains, but CLAIM_PREVIOUS
> skips the check. An NFSv4.0 client reclaiming a write open during grace
> can therefore get a write delegation, and NFSD can never complete a
> GETATTR that the client sends before DELEGRETURN in the same compound.
>
> Apply the same check to CLAIM_PREVIOUS.
>
> Fixes: 1d3dd1d56ce8 ("NFSD: Enable write delegation support")
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/nfs4state.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 5c2151b329c4..4b28553efc8d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -7533,6 +7533,9 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct=
 nfsd4_open *open,
>         open->op_recall =3D false;
>         switch (open->op_claim_type) {
>                 case NFS4_OPEN_CLAIM_PREVIOUS:
> +                       if (open->op_share_access & NFS4_SHARE_ACCESS_WRI=
TE &&
> +                           clp->cl_minorversion =3D=3D 0).

Thank you.

You can add a Reviewed-By: Aur=C3=A9lien Couderc
<aurelien.couderc2002@gmail.com>, please

Aur=C3=A9lien
--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
