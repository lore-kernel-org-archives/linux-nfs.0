Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.46
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795427938;
	b=CuiwjRFvCp7UomAXS0FU7sjKwLZBPjnsBO7jS2Q2jd/pICNnSNTo2vDPPLsSJAGH/BVc
	 w/v4g8GR1YHNCbGet8kltJ673aOvVvIssNGKngpcyMvGEubDtRgOCThIkPQOeOuE5EVl6
	 XRpntLm3TzazT18uG2V9WXfMpPSW9NzR/9u59DdAvJxLSG8YZXm5KAfda7bvn0NXRnNOn
	 DPaZgLJn99mtQrrLM+z38G/mhQxr5TZgOuitVUIwzlYHbS93aYoIu+y885TOT000pJsld
	 9v9cJqWGzk2pUJRAQiCY+ML00kP8e+1PPyVfYpSP24ylmrUWEquiV4201vQE2eFqAcA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795427938;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=w5YofJsZvwYfdZe+sQWDwSRZ1WPmdjTiSg3anH3B9G4=;
	b=HvsiMZsw37bejQRSZ4nStahS22jhhnieM/BTvkCOmhuSUclxn93AADlJ8BH8KZhRKc7T
	 OT219/B2h/IxwBtuMpxS4DmwzkObvQt1DJyvYTYj0I1Dmr7w56ZpsGnisHuwHMTRA8Lhi
	 /V5KbkBRL/ukSuZ3lnSglRyEWM1c62NQ3k2fJYOvC0YoqLsKZCMTHuD1gNamXXgLhsqNP
	 XDd77uqmPKYXj9VBufS6yPinkeNk/5pDpi5JsNrnTLwe0J1NyBs8NxfJqw6w28FOKg3q4
	 Nxdl7qKjnyrLASB2Ue65O7r6J+r5R53Rw08kQ/k/IFbuyvvKR3PzpahLFsnS1D3+ONg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="LcKY7/ll";
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.46
Received: from mail-ed1-f46.google.com (mail-ed1-f46.google.com [209.85.208.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D3F8B606A31E
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 09:58:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D3F8B606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=LcKY7/ll
Received: by mail-ed1-f46.google.com with SMTP id 4fb4d7f45d1cf-6b8b20b2538so3538573a12.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 01:58:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795427936; cv=none;
        d=google.com; s=arc-20260327;
        b=GkJxjGF0BGtkuMTmKATlf1XAFlNQrprZQNhUhgdpe1ENtftCq+E8kbONCXpT+HSJmh
         GvFUnmi/sFDu+ZZHIV1ebPHHv9vUZhxcVmsTJZxaHq/xgGZYlE6Y+yCAgMoBjzsmMxU9
         Cr8ZB70O18E/DjqqRqCDhMp+uq484JCCUrQfBZTug69XBje+4lZD8tQfOcSr/FWgO1Gj
         SgYtwdnBFfxCzCkRL8eeq31sxAISefNRedyKlBg5UHX2hVs/VY2gvtzJ09KqBW/eAL5J
         ifJ7MyXpiezfx5AMOvWu6g6EZzjWpkrK+kVb+0Xv/X8O6/z+f6t4Jcl/L0KpF7VtqmcF
         wG4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=w5YofJsZvwYfdZe+sQWDwSRZ1WPmdjTiSg3anH3B9G4=;
        fh=wmRuk6KMaGpSmGxFwomAc/4CS9hGkHJ+7s25EAj4ru0=;
        b=K/OEQFHOlDe2WjscvxgEb+UI0r3/lgDf9GtVsuKJs1OHet7BJAI/QBgds8PhdwpGzn
         an4xp0XG7yn2xm/rCFaWG0nmR+m5ZqWlfKhGFeIKYUipEp14L1CinISsX7RLK8Jay6XA
         Zj6StPxQM99lPe2M5DJ/bnTYbDvI3i6LJbvrSgOxIVTYgOhP3wHIlP0g0LW8C1zS3psI
         RD0Vv6X1TDaKM7UCEV9cDe6YvqsdJVPCCVrsn43qER8tR93jacnP/SYQj4IqS4Wzz/S3
         hLoQrLF+yzxe3URi8uJ7RevSwGMasO/Mw6nTJLZ7ZZxtX00X6iWsGQoIf8aC0xphfvCy
         peYA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795427936; x=1796032736; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=w5YofJsZvwYfdZe+sQWDwSRZ1WPmdjTiSg3anH3B9G4=;
        b=LcKY7/ll/3itDCYLlLkTyocYZVEBKP2Oq9ohI0PNIQcGSnqdnGuopWwTRUWTZyeXBc
         r1futrUG0ldl+quR4RHUkW3LGekHgSz0Gh4nmtGZH5UDbwC5axbtcrFdyv647IDwUTQ2
         SLLNFa/IZwZ8FS+KriETAyqFg8x99hN3F+2w9RLhTwmVMZ7ZX4YrFx1PNKNcaVXQfHXd
         yUTbQ1IaBT92n3ccZTe0inMowWUxcYhKl9kAgX6VJvc31ddtnoOf/g3yxLeKPux/n6Vw
         JR6XlWijKRJ7CJntnxxUTU09NUqaXdXNMG8IGWaDIVvpiJxnIqT3KzEEx97rxBN4fQZR
         3URQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795427936; x=1796032736;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=w5YofJsZvwYfdZe+sQWDwSRZ1WPmdjTiSg3anH3B9G4=;
        b=XwvZB4ytOh9wZqcOsLcvuJJgKCfIbeNojiEEq0C2vJkRarDcmtfHluzUmyXSyxKLtx
         my80thR5gPJtl3WwlzlEPWkJmvIybOAbgD6MP9pbUycnHsTGAEmSkCRdsy4XmM/gY1Bp
         8P7HWVtIxdXETsxN1q8ev8ST9tI6CeWQuJPPb+ALxbp6gTJq/z3rj4kVT/KmRYMjwZWw
         PIj/I4NltrRNyawCouhT7dIwoKcxWl9Tx/0YzGdn4PtY/n9HgRoGNDDbuLCd0xw0aUYc
         cgWBbbSlPVi5Kyj46p2yPgjOCQcr7klpMkjSE5nfhUgZJHgdtcgnDf43eww4CXSeIoz3
         EV3Q==
X-Forwarded-Encrypted: i=1; AL+hErGfsbgxuAt1U2zqdPLhc/2FdhGha1N5WAc4MhkhktJlHep9+1I4C9DymKWAg4pJgrnIo7tr9wytxic=@vger.kernel.org
X-Gm-Message-State: APuU4Z9pOsvyCOTSJP/4dKiAvM/A0PsS+E/OoUUouM8bWgTjOjXDXJky
	Z3ozppOBA7uJlBHFXO2yOI1Kl1pJZC0T2fsinCZKa9iKU5l0cFeS74fjAhIMmc9F6nsAcH1uFXO
	+jXrm13Pfk4dfbdONurPTsLEn+OttAl8=
X-Gm-Gg: AZFdTZePbFwmNqnP5/6ywD4dxKVaV4Mh8JM867loyAxKGDx+TIGrS0aDU6ATApkSveS
	lLM5nW3/7MPWy61M3xB+/A1tRf+jtIyHDsJZxq3oOXbUjjhetMNPiEAcuLQmXK2iaEQdAEGZMPN
	3o92CMDeB5xfmoPPMM9KdFLTIfBKvkMjXPGtjCIHKKbFEw+qKCPMdZV7LOWnWqXSfbjodnihvjw
	oYEl5vfPgeDhaGadlgqIc32N4r9No70nYgPbEnWYnl0dpuQx59WMvPaXPXjdkDZklEzgjcVux77
	Jt+oyzgz3KiZxao7u+xWhusHk0FWxiIapf/iED56livdFAUmj0dZkO94wfjqW9dt61Mn98cGmwW
	DcVzow3UTO41jA+crhvATNNmcVf3WhKUm5LJN5eK5dYoow497cLfJoTpQ2DDQetCa2lUZIOg=
X-Received: by 2002:a05:6402:1953:b0:6b5:6546:f7f2 with SMTP id
 4fb4d7f45d1cf-6ba37ec6b64mr7620058a12.37.1795427935994; Mon, 23 Nov 2026
 01:58:55 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261119-nfsd-copy-same-file-v1-1-ef18e53a00d0@kernel.org>
 <CA+1jF5rurDObkiP0pg3Kp1vgB+sdxU6FYBaUUPWLJoHsoJ_6oQ@mail.gmail.com> <03349d0b6b8b3cd2069f216871046093d75b17be.camel@kernel.org>
In-Reply-To: <03349d0b6b8b3cd2069f216871046093d75b17be.camel@kernel.org>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Mon, 23 Nov 2026 10:58:18 +0100
X-Gm-Features: Aa3M54qe_hfenKjzwiWJU9rEuXo_c7VWvMSAGUxL1_WNayADhwIzCknkL-LGf40
Message-ID: <CA+1jF5rOz0QVzK7AkzA+sTSpeSFTDtMG5K4CQzE1B_h4fBYYWQ@mail.gmail.com>
Subject: Re: [PATCH] NFSD: Reject a COPY whose source and destination are the
 same file
To: Jeff Layton <jlayton@kernel.org>
Cc: nfsv4@ietf.org, Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 20, 2026 at 10:16=E2=80=AFPM Jeff Layton <jlayton@kernel.org> w=
rote:
>
> On Fri, 2026-11-20 at 08:55 +0100, Aur=C3=A9lien Couderc wrote:
> > On Thu, Nov 19, 2026 at 6:44=E2=80=AFPM Jeff Layton <jlayton@kernel.org=
> wrote:
> > >
> > > RFC 7862 Section 15.2.3 says that COPY MUST fail with NFS4ERR_INVAL
> > > when SAVED_FH and CURRENT_FH refer to the same file, whatever the
> > > ranges. NFSD never checks for this. A same-file COPY with
> > > non-overlapping ranges succeeds, and one with overlapping ranges fail=
s
> > > only because the VFS rejects it.
> > >
> > > The overlap-only rule applies to CLONE (Section 15.13.3), so leave
> > > nfsd4_verify_copy() alone. Instead, check in nfsd4_setup_intra_ssc(),
> > > after both stateids are verified. For an inter-server copy, SAVED_FH
> > > names a file on another server, so that path is not affected.
> > >
> > > The Linux client never sends a same-file COPY, so this does not chang=
e
> > > its behaviour. Found by pynfs COPY11.
> >
> > Why should COPY within the same file be blocked?
> >
> > For example: Windows FSCTL_OFFLOAD_READ+FSCTL_OFFLOAD_WRITE is used
> > exactly like that by databases like Oracle. Even advertised as a
> > "database accelerator" feature...
> >
> > Better tix the NFSv4.2 COPY spec at RFC level then...
> >
>
> It does seem a bit restrictive, but that's way the RFC is written
> today. If you want to lead an effort to update the RFC, then be my
> guest!

Does anyone know why the restriction was made?

Aur=C3=A9lien
--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
