Received: from mail-lf1-f42.google.com (mail-lf1-f42.google.com [209.85.167.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1CDF120C00A
	for <linux-nfs@vger.kernel.org>; Mon,  6 Apr 2026 04:22:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.167.42
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775449352; cv=pass; b=j4IuNnPqUmQ5wpKr2WCrco8smJlGhDnM9mNSy5rSPGJddZvmevQf8skPJw/NcdwLwP3zNY9UA2wci7CkaNhHTaBlBXNYdYYVGjszg22CLqtCcwcZyYwopqiN1K1bnptefn1vlc7x1UQr0z4L3x99SuoIrjJ2m8HxPArel/+cuhU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775449352; c=relaxed/simple;
	bh=1Z2+dlnI1iEBecdsH/XCSQ0KQWuVx3RbDCtT0XO2pIU=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=OVIneT0uY4j1zLjx9PNliPhGEA2BXrZkTWsuA3PrjwYdcKmFP3G2D8SKjraFbCWTDM93YZXWMNH5i+juaVjcGJKaYk4OFDtPgR61Nye6psrz6UXZZHL+XmQKVNjUNPPgLy//Df0EXJc1EEhriksXjeadE6J5AAzNUj7Mn5LNV84=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TISr/n3l; arc=pass smtp.client-ip=209.85.167.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TISr/n3l"
Received: by mail-lf1-f42.google.com with SMTP id 2adb3069b0e04-5a3cd6f0447so2592287e87.2
        for <linux-nfs@vger.kernel.org>; Sun, 05 Apr 2026 21:22:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1775449349; cv=none;
        d=google.com; s=arc-20240605;
        b=cXD0Stl86XrJpzJBp2Nb4tPpSgubd996U+RPTIEAuVGjMuTy/BRl2tk8rQvGDNrWKP
         sucFia46OeHHODrRbkxzKh/d2SE4yVlmYHV3BDhWdILEO89x/6U0MiTFnVEZRPX71foR
         vn2oqx251j1bPLp0WfJYdPQdlWONRB82J6t1rHdvbOeCAncJF+ocKVsx8pHR9kN9yjkw
         1+zckdOu5nDMFUpJmPV+YE+F8tcUkV/lHH/GQt9595C53swk1XZb/hTaRy5PacPC3IyD
         Fnj1MY3jNj9GYw4hsIea4EgK8SKzATzZCrHsDp9igzab4hCYTP66GmLcmm3Bk6g84V4s
         GB4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=EyMlI8n0C/euCqMJ//rDGLkv5/KCTm3M4f8QrF+4zDE=;
        fh=soBZ4z6rOOq+fMpsmYxnZXfEKbWcTG96XLkb/GGLMbA=;
        b=LWHLslNf0Z2o4EbZTcGDLeqIoJF4lVZ6h6R0hzDNo6E5iaNDVZR8z7bT7tY/YEWNzZ
         qKjDSwshoPvxgoKdfvsuY4F7LSRq6UmD10zHBrzswLVDVAS11WpHSc1qv6gOnJkgFs54
         CLoVdaK3ty0G3qlH3K0cKoF7gzP+svRHqPWD+DOONNoY8R0nsDQudZw02qfvqinyTtER
         zFcj85dm5U0qfgBuLr3rpQr8PBzyXOeFCs2dQ2SEIVLtb5TKgZ3G0d9d0KwpoJ1gKPLp
         ngq0otL6K/6I3L3H2EGBk8A23ihajjo9xbKBUJ7OIPlv+E7Rpcg1cMkJaKMytdp0lfC2
         J8/g==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1775449349; x=1776054149; darn=vger.kernel.org;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=EyMlI8n0C/euCqMJ//rDGLkv5/KCTm3M4f8QrF+4zDE=;
        b=TISr/n3ljlbMI7iBE9fU4hZ5Brsc/ASKgouSqKnjZvCYWKExM1uOsKkTou9rKH5GX+
         ccfyYulzCPFULnHkQ08CnMN+bN5frktLjIhDYYLfJPLHgDhyjGUfFxRZquz4YErVWDJP
         +W/u/S+06GPpyhzvE4fMSNIJDdSwpYtT+XHZY8h7cXfASwrXYBQHHh8FAQ/ssOYBO4OC
         3dJevq0FB2J+N1gnN2rrZOb88QEnrLvpWzQfP6UCwmTbVv5Hbky0zZVIMOBLkwTpySpO
         Ck1/9laOy4F27l6d6P49WjLuikWBYQaMkD6FtV20A7wO3FEhZlS2t7yIHSqG85XbfJth
         UeLQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1775449349; x=1776054149;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=EyMlI8n0C/euCqMJ//rDGLkv5/KCTm3M4f8QrF+4zDE=;
        b=S1WbbV0Vf0gxnZMBDoPjEUrjzdO66eXIyJoGDGh6scDVMKG2fC54RHubz4kUQ6mZIt
         pl8ccl+I7Q028g0LGv12g/hIpN062Ld7YON7eLT3gpgp8BgZOPFKKbSule30MtKrHxLg
         D5aLIL2Rqgu+trkUIPqC+OEWORT9mXm066yG7kG2FieGUBqW7QmunfTWtHGNMxVkaZWL
         FkvtGcKuIMesTPKbzKxvlnflY6CSwBAQ4V04SW8HiAtxeb8JPO5LcjA0HaE6PbrIJX79
         szOsCui0QwIAh9s7TCBTEjtp9vjsIlLPwJWhy7kVtYKZK4GSJa54kLT2NTOfhyMWi9Hk
         +IDg==
X-Gm-Message-State: AOJu0Yw0e5BA0C6366Fovq+Xa3PqhCg69FYKVvotjMN18m6sUp0OLaH6
	0UbCUyQC7IfayZ3Hj0tOK0NS3D2lKLp+8/+nLebiT0r1qMLE75w3VicC4fIec99VElJ9/yK1LNz
	rYCn6TeSr/rdMMNBIamj1/cWP95U7S4jAV4+h
X-Gm-Gg: AeBDietHQxroYioY4be5GejWAt4hbZAQebaKKAOYRY+hSV4tf3Vd+7S5+x1YCA3sMXn
	dPG7K+WNeCk1+CO0dSjgsPpncMwZXpc4HXXHKWyyXtuceOjFhzt5GY0tUDvfrgza5uX1BVzfOhc
	Wf51omjvazDpbV789Oj64TiCLKI7OclCi1O4DiW6fGUK+bVRazW8qQoiDuVn3W6AHyBnwRnYcJM
	DrCy9zBK0WiZVvqO71nfg5RpiTuInPzCLWu90S+9SXXpQMVy4wZshxR8CX2HHef+koC3kKpkHpI
	1nDK5SoQ5JbVfJG6bmJRO2kpbbYcG/f6cVeSEool
X-Received: by 2002:a05:6512:110d:b0:5a1:2e0c:86f0 with SMTP id
 2adb3069b0e04-5a33758f31emr2819910e87.37.1775449348803; Sun, 05 Apr 2026
 21:22:28 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CA+Tq-RqDP_BAroLX6wVrNY1BMwC9BOZ-UorLje=TXBdEOj8hjQ@mail.gmail.com>
In-Reply-To: <CA+Tq-RqDP_BAroLX6wVrNY1BMwC9BOZ-UorLje=TXBdEOj8hjQ@mail.gmail.com>
From: Hiroyuki Sato <hiroysato@gmail.com>
Date: Mon, 6 Apr 2026 13:22:17 +0900
X-Gm-Features: AQROBzAj7VPIDU9mjxXeXlFi5QXpxkrb0Bgl7s7blngF9Ji_EFZG3B5orUGj2NU
Message-ID: <CA+Tq-RouZ784rWHjwSz6GoJc4f5f66A2mr2-PdyFJ2bK2Y20wA@mail.gmail.com>
Subject: Re: [Q] NFSD: COMPOUND reply tag padding not zeroed? (e.g. \xff\xff)
To: nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Helo,

I can reproduce the same behavior on Linux 7.0-rc7 as well.
(591cd656a1bf5ea94a222af5ef2ee76df029c1d2)
The COMPOUND reply tag padding sometimes contains non-zero bytes
(e.g. 0x69, 0xff) instead of zero, which appears to be the same
issue as previously reported.

Would a change like the following make sense here?
It seems to zero-fill the XDR padding explicitly for the reply tag.

With this change applied, the padding appears to be zeroed
consistently in my testing.

Best regards,

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9d2349131..b33e031bf 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -6377,16 +6377,18 @@ nfs4svc_encode_compoundres(struct svc_rqst
*rqstp, struct xdr_stream *xdr)
 {
        struct nfsd4_compoundres *resp =3D rqstp->rq_resp;
        __be32 *p;
+       size_t padded_len;

        /*
         * Send buffer space for the following items is reserved
         * at the top of nfsd4_proc_compound().
         */
        p =3D resp->statusp;
+       padded_len =3D XDR_QUADLEN(resp->taglen) * XDR_UNIT;

        *p++ =3D resp->cstate.status;
        *p++ =3D htonl(resp->taglen);
-       memcpy(p, resp->tag, resp->taglen);
+       memcpy_and_pad(p, padded_len, resp->tag, resp->taglen, 0);
        p +=3D XDR_QUADLEN(resp->taglen);
        *p++ =3D htonl(resp->opcnt);

2026=E5=B9=B44=E6=9C=885=E6=97=A5(=E6=97=A5) 13:17 Hiroyuki Sato <hiroysato=
@gmail.com>:
>
> Hello,
>
> 1. Observed behavior
>
> * When sending a COMPOUND request with the tag "create_session" (14 bytes=
),
>   the reply is expected to include XDR padding to a 4-byte boundary,
>   i.e. "create_session" + "\x00\x00".
> * On 5.14.0-611.45.1.el9_7.x86_64 (AlmaLinux 9), the padding bytes
>   are sometimes observed to be non-zero (e.g. "\xff\xff").
> * From inspection of recent upstream code, nfs4svc_encode_compoundres()
>   also appears not to explicitly zero-fill the padding.
>
> 2. Questions
>
> * Is this understanding correct?
> * If so, is this a known issue or something that should be fixed?
>
> 3. Analysis
>
> * In nfsd4_proc_compound(), space for taglen + tag + opcnt is reserved vi=
a:
>   xdr_reserve_space(resp->xdr, XDR_UNIT * 2 + args->taglen);
> * In nfs4svc_encode_compoundres(), only the tag payload is copied:
>   memcpy(p, resp->tag, resp->taglen);
> * The pointer is then advanced using: p +=3D XDR_QUADLEN(resp->taglen);
> * but the padding bytes do not appear to be explicitly zeroed.
> * As a result, it seems possible that uninitialized data remains in
>   the padding region, which may explain why non-zero values
>   such as \xff\xff appear on the wire.
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/f=
s/nfsd/nfs4proc.c#n3055
>
>
> ```C
> /*
>  * COMPOUND call.
>  */
> static __be32
> nfsd4_proc_compound(struct svc_rqst *rqstp)
> {
>     // snip
> /* reserve space for: taglen, tag, and opcnt */
> xdr_reserve_space(resp->xdr, XDR_UNIT * 2 + args->taglen);
> ```
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/f=
s/nfsd/nfs4xdr.c#n6389
>
>
> ```C
> bool
> nfs4svc_encode_compoundres(struct svc_rqst *rqstp, struct xdr_stream *xdr=
)
> {
>     // snip
> memcpy(p, resp->tag, resp->taglen);
> p +=3D XDR_QUADLEN(resp->taglen);
> ```
>
> 4. Additional observations
>
> * A packet capture excerpt (attached separately via gist) shows:
>   (https://gist.github.com/hiroyuki-sato/8ab30dffbbd2499e8b4741d89fd383be=
)
> * The issue is not deterministic: when repeatedly sending CREATE_SESSION,
>   it was observed roughly once every ~5 attempts.
> * This was discovered while implementing an NFSv4 client in Rust.
>
> Best regards,
>
> --
> Hiroyuki Sato



--=20
Hiroyuki Sato
