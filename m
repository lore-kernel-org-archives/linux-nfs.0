Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51ABB3E49D7
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 13:48:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.44
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791899326; cv=pass; b=PfwLOxR/r9zje49cF0jv9JVuImK6cx3wcW8GJZE/4xEIQgKQiZY0F7xrB3MqiGrIrCyxEy3BxTPzpzCDZIGAkwV1nflKjiwhCEow941dxY6/Eco6cZTq0tSH25fH1F70rcbY79HqTd8WvIZZgY9tAtBCpimV7NsNlKS3hJA0UaM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791899326; c=relaxed/simple;
	bh=w1aEzXh0/kDb2C6+j3V0GKa9E0LvwVfGTcAW+zABdKM=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=EwT1kL/pn3rIbMNQxHufIpPKk7VW7P9CBEe1uiVcwmDmOSae10f7DuRl20ao6Vzvv11xMqRXChNQmPTVmWMn+hhPhzQEQs8aDggsAb55Ty8eN8ZAjXXFhr11A4EXQrGZ0fK93fpkm8G1HBb9fL30uLsZ7WmwKyeWZMsuIh+2vZc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=OMSuGYIe; arc=pass smtp.client-ip=209.85.208.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OMSuGYIe"
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-6a642495d81so3914839a12.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 06:48:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1791899323; cv=none;
        d=google.com; s=arc-20260327;
        b=LUEkP8bX105uOPDwV+ngCFuJaRJvXFip9g4408qqcGgrSSNIQ4cAkupLjKtpKeor3S
         3b1h+iE778SsncKcPHpzoLypgR5q0ZU9LPUlaRXNaRdS8FneIAIquN/2fteiNjwjjGjf
         v7zoFPQXlX9X6v+kPvxecwgh8RvxmZm1yXJKNd/Rt5iOugalfM99cTOgGXf0HoL2p7KH
         42Vc6mb14gzGh5KE1qmLwoFTv0rr2UgskuZMyuiwOI9a1w7VSgIOwLnMhJNX9yA3sF7X
         j4uM8NlK2C+iXI4p6DKafdVoQsXuQuoWqdYX9o3KSV/ugDrudYEouBbpjbaZmx105ws2
         MFcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=vzeLtt55t3NJAjayFuV52ZCMalKqzgv1gbi0MjPuKIw=;
        fh=dM41e0qMiRltnzUDa1JphFyZL7z56IcdZV/uKMNOE3M=;
        b=fGL72R7uQ7Kp9cbIQl7ZozmksxoNHSVAcDHXfikDkApC3Q68NHzvIK2B4pqrblpGT6
         uNEqR2sNn9zi3rC9uJT7FZkp89++2Plo2qdebSWPLSzU2L2fZnAC6qJWh3mowDR9CdPY
         1NoTXGOaggKLXThuaVF365YcidAoFsnmUx5PUN/KUo8IenYKFw1l/1pI0Lx4LtknzHhX
         2wuKW03pr4dF78DtVWXVZ8Ojvl7J0Nj4u0FaT1+a8WTOPeFPQXROqa27SXBfeaApsqSK
         0b7DdQsr6QbxgV+CNhopxgukxF/8xgO1H+ex06LR0vjKkO3cDrXOZkoqYUbaQ1AWtuDk
         HqFQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791899323; x=1792504123; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=vzeLtt55t3NJAjayFuV52ZCMalKqzgv1gbi0MjPuKIw=;
        b=OMSuGYIeP5iTOKYsdbGKN8VdEbgfqYP3wkPDUVcSuSE8UbpOv9K1bJp5BTf+ro0N/9
         PZIugaLr/e05N93svjfkY/Y4E90IXsZrrnzhB0rQrA9WAQOnHxNNLp6xfLXO+TmV1LEM
         OIWJ+OqfaIImYnEYBSH5W43DXgfGMk9ln2nPWdA/opEU/JTIhvqgkWh+zkFMtHMdcbgh
         mq+Z5RSV/etg/V97mnvmYXORJ1Z6By3YALo4yHF3rxB2MbfRwbYLZPU070chHGGpqlkY
         M9WU/qM8dzDTK75m0/s3pkKR91YnecwYOsb5urxNbKxT1LExXv1fRO2Jdaf8u7+rGiEt
         0ljA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791899323; x=1792504123;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=vzeLtt55t3NJAjayFuV52ZCMalKqzgv1gbi0MjPuKIw=;
        b=Mk2R0x6mqDOq07gb1eMQnyR0V4bh4FlWQYFkgIceg5LR4GpqRs9vI2dwmqDAdRV5mX
         DbcCJ12P0YciZUT0M/YPDDG/AjrJtQOoAU/HZi4OQ+hOPRdxiHsiUA1iQXSGhLsWSx41
         P5fjJ2/QkK2vImTu33cHJNBNuUuRgXMVkbal6mfALX1IvdrZd2qKr4ua36AjVe6L8ReM
         b0aSHKO9fhYQo7aNjXzyubjWcEnT2BvJZCI59r4Or2xEmSad9f9YCa+v4ssQcsgtTyCu
         54hqgeFO/7zngEKVZQX5+hHMnQHLRpgr/VADocURoTkF3IAd3UJXFsKW9VVqnQEkqhEy
         2IpQ==
X-Forwarded-Encrypted: i=1; AKwUvBy2ZFjr73yJwjhISohkuQR2niQU0ZsMuSkV3Mz8IPRi74Eyt4ZqVDgCx7/X7hEHJvBP/G0YUJkRHNQ=@vger.kernel.org
X-Gm-Message-State: AFq9FYJ40sC6CXtcYfOaOZBUIJmSmrtkIGovE7ZhhB5YI8aFeOzrCpCq
	XSqLucTOXokTBYQTDX9qT2sJ4vxBK3BkbHJ/hBms6mTtzwKPDHPd5oYy2diMdS/H1QHFhYQdtSE
	yg5QBnRBatVznA6sVLfVABTIxqWOLBXc=
X-Gm-Gg: AYBFou12zkFmE1pmNP44ZQ2WBL2P7wsNJWOwLozIcy7FMnsEsL2jenV1vmoxDsJ9qgo
	dIyw8Ylg5NW8Ap5tQDBy+3snduxu81GhPaqaBatUUW/MM2KLOfNXASr7kKdjDNnyBSK7sdbpwFT
	lxEAmCo4l/vY5r/3+WB+fQVRfBy8WlFKBytf2oK1cuTnKaRx/+0hvq/BR7++p+44uilwHuEpUBU
	T6OElrrSpCqe047SQ4OaLqTqBxHB8W8a/Nx38PhiC31+wDrk+q9FQSMuTxvKG1V8kuEKwrHs+Y8
	cyYfFloyAWtAAi9qniYVQaT6JFS2jelTgl7mNBNFRv1Jl64sEuskRKYm1nDW83tK5SN39ryki+m
	NI/a2M9t6nDPCpw==
X-Received: by 2002:a17:907:d8f:b0:c29:d31f:7d73 with SMTP id
 a640c23a62f3a-c31a9fd5dc1mr1223547166b.9.1791899323118; Tue, 13 Oct 2026
 06:48:43 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Tue, 13 Oct 2026 15:48:06 +0200
X-Gm-Features: AclHuK8Wkr70Pw7CPje7lC_I66okQgYHGXwxQCXzN-fJtkDoeipxzijCX5MQykA
Message-ID: <CA+1jF5oOrcgNuPQNspzNEArM4Z_L9j+C26N5A2kowUZq00c7nQ@mail.gmail.com>
Subject: Re: [PATCH pynfs v3 0/9] pynfs tests for setting ACL+MODE
To: Chuck Lever <cel@kernel.org>
Cc: Calum Mackay <calum.mackay@oracle.com>, linux-nfs@vger.kernel.org, 
	Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 9, 2026 at 6:35=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
> There are plenty of corner cases when an NFSv4 client requests
> setting an NFSv4 ACL and POSIX mode bits in the a single SETATTR
> request. It's even worse for NFS server implementations that have
> to translate NFSv4 ACLs to POSIX ACLs.
>
> Note that the in-kernel Linux NFS client itself does not support
> NFSv4 ACLs since Linux is a POSIX ACL ecosystem. I believe it will
> never send an OPEN(create) or SETATTR that sets an NFSv4 ACL and
> mode bits simultaneously, relying on only user space tooling to set
> the ACL. So we must depend on only pynfs for testing this particular
> NFSD facility.
>
> pynfs didn't have many tests in this particular category when I set
> out to troubleshoot a recently reported ACL+MODE bug in NFSD. So
> I've written a handful to exercise this specific case.
>
> Claude and sashiko review found a number of issues in this old
> series. Resending with fixes.
>
> ---
> Changes in v3:
> - Compare ACE who fields as bytes in acl2mode_rfc8881(), make_test_acl()
> - Run testMixed's RFC 8881 mode check before pass_warn(), which raises
> - Compare ACE flags in verify_acl()
> - Let verify_acl() skip ACEs the server inserts before requested ones
> - Let verify_acl() search past a matching ACE whose mask falls short
> - Derive the expected mode from the requested ACL, not the returned one
> - Fold SATT20/21 into SATT19 and drop the pass_warn() that always fired
> - Require MODE in attrsset in SATT30, as SATT19 already does
> - Mask the mode with 0o777, not 0o7777, in SATT22 and SATT30
> - Warn rather than fail on the SHOULD clauses in SATT29 and SATT32
> - Fail OPEN12 and OPEN8b when the REQUIRED suppattr_exclcreat is missing
> - Verify the whole ACE, not just who, in testSetattrACLNamedPrincipals
> - Fold OPEN9/10 and OPEN15-18 into OPEN14, which covers all create modes
> - Rewrite the OPEN(create) patch description
> - Correct the SATT30 item and test list in the SETATTR patch description
> - Link to v2: https://lore.kernel.org/linux-nfs/20251125194936.770792-1-c=
el@kernel.org/
>
> Changes in v2:
> - De-duplicate code shared between NFSv4.0 and NFSv4.1
> - Remove named principals tests for now
> - Replace incorrect usage of binary strings
> - Add missing patch descriptions
>
> ---
> Chuck Lever (9):
>       Add helper to report unsupported protocol features
>       Add helper to format attribute bitmaps
>       Add a helper to compute POSIX mode bits from NFSv4 ACLs
>       Add access_mask_to_str() helper to nfs4.0/nfs4acl.py
>       Add make_test_acl() helper to nfs4acl modules
>       Add verify_acl() helper to nfs4acl modules
>       Add verify_mode_and_acl() helper to nfs4acl modules
>       Add tests for SETATTR with MODE and ACL
>       Add tests for OPEN(create) with ACLs
>
>  nfs4.0/nfs4acl.py                   | 193 ++++++++++
>  nfs4.0/servertests/st_setattr.py    | 728 ++++++++++++++++++++++++++++++=
+++++-
>  nfs4.1/nfs4acl.py                   |   1 +
>  nfs4.1/nfs4lib.py                   |   8 +
>  nfs4.1/server41tests/environment.py |   3 +
>  nfs4.1/server41tests/st_open.py     | 463 ++++++++++++++++++++++-
>  6 files changed, 1392 insertions(+), 4 deletions(-)
> ---
> base-commit: cd4701827a8261fedbfb4c6e39029fb9671321a6
> change-id: 20261008-acl-mode-f3c35108c597

Please add me in the "Reviewed-by: Aur=C3=A9lien Couderc
<aurelien.couderc2002@gmail.com>" line.

Aur=C3=A9lien
--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
