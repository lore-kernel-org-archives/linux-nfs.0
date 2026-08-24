Received: from mail-ej1-f54.google.com (mail-ej1-f54.google.com [209.85.218.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 423E742125A
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 16:12:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.54
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787587963; cv=pass; b=H2SW6hnjSqcjwHgbmJoqChm+mAp8/xeZNkwvqBcxzTSyjunW9ueIJ4xWNmsH8QcZ0yAxRae9ybJ1EeE1ROnB+6VqV5wPNDOVnopQx+gqkg3655/llL+tdB7MN+/XwIt8kpsofr2zJdcH209gjz8ygtEfoTc2FSmXy9zzKbukPOQ=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787587963; c=relaxed/simple;
	bh=upeiVkj1KjgWaSEPSM6wBhsUQiXS1SCs4E5bSq0CyKQ=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=kug+dhM4TtQNFGAl/s3GqFQGtM76f8LDBETEGL9YsP/V3thDfo4F74u3nmKD7/iKatqzSksYaLIVpCobDXKEr8nDBiBPYozdig3q1VSq4ldUlfBcIPZWO9e+byco4T2s5+RnIDZ/RqkNIsdU5RTsr/YH7dLGvvAfaKz8Ht9kE5k=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=QLwKNBpO; arc=pass smtp.client-ip=209.85.218.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QLwKNBpO"
Received: by mail-ej1-f54.google.com with SMTP id a640c23a62f3a-c2022323c37so580185166b.0
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 09:12:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787587959; cv=none;
        d=google.com; s=arc-20260327;
        b=Z+ix5xqCRsMOiZeCaPUTpFzLVbxl/s/S4779CA4QglIU2jVMHCl66z9kUNyYY3cUV+
         DkHfSEahOxoZJzkCjdiTF6EpXniuiesJbJBn500ubxt5JIBS7OcpBmFoD491Kw/HlpT9
         kb78cJms917eLvjQ48Wb6DGwwuW3poMETD17kMwkgwOBtA23u94Lot1Gw1GOg/AV5n0P
         8Fwy1eTULK9e+mYtRa3pcGVEHn23AJbdxXbJ9hDetm5pQszKAAnbYhzUMZmetXu2cxAH
         rc56ycMO/iAamyqq6jy407PRHcPwm7/OQABlIsOq+HvPubda88pgTmr2SpXnMXUwNbKu
         qTIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=upeiVkj1KjgWaSEPSM6wBhsUQiXS1SCs4E5bSq0CyKQ=;
        fh=dAmjiugBOi1qdp35VPh6fiWzJzmayQ24VuwwCs1ULIs=;
        b=drPtRnE5HpybmP2tAsqX/IJB/DTOw9pDK1Dts6oXi6As/CTYVsA4wCyPY3+yg3yx+k
         eAnZhdXcvKc5oGXHs3ChCpmeY9CS4d+v5e3JQE534pWlgqJYbVyvLqF2fPu/Mmn95eCW
         qnACmmy3u1DjGyvxQN01CCPFZd6qp1PqrS9Eryb3BFs5tqeweG0Q8X6/W+LPSat6P/Xs
         LXm7YIr0H/TdgEUQWY1UAO3GhugTbVSdPQtXbZPQ04Wm1kq+ri0L0CqSzYgdtt8EmfRy
         4P0VP+IYFLEBDxtAhlVoY+bs6HBCD7VUHcW2KBlgxqb6Z6bvACSkozx+pSTfngdu+DHL
         lvSw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787587959; x=1788192759; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=upeiVkj1KjgWaSEPSM6wBhsUQiXS1SCs4E5bSq0CyKQ=;
        b=QLwKNBpOWkxuPivcCAoQLngmbse/NpRpeUmg0aBqHDj/jPrD5rpojZ9P+xY2VrmP+k
         cxZ/BR4GkW31z2JWxHS5hf05sP0euTsy1Lm4SyPo8ujM/tJbs7uAwPgDbgfyFPM7cHsM
         +vP+jk6Eqc/yOZW/ap/1e1nwMoey61p9TAWj4HCp7IWukkfuTZsDjeky1j5G4oRFPZzs
         m7mz/2OtiWGJSfa1iDK1kLc6aRtuWD9JHTKBVRF5QVlMC/w90RpJKHL4NzD6UpNKbQ6g
         IVnwWTl9HHZ6K5QcoXUQX6FMIKoZFuRtX2/miTmccrDXF5+vGMBTiRvwpE+WMukEPkzm
         YinA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787587959; x=1788192759;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=upeiVkj1KjgWaSEPSM6wBhsUQiXS1SCs4E5bSq0CyKQ=;
        b=beVIq1rBa/Z2zVp+MiawzIZntYOWSFwBJMNaF3v083tmxWnoxcIm4hBNhDLLKnVu6P
         NrKS7XOQNo9ok00Ne/NeDvQn/1AacBMPIeyam1TO0YKZoYrAXBIL1fUNalJ73gAbomTl
         nZc5LZR10I3D9H9YReUm0LEVzNx+NGHQltYc6jME8HklvaR4eLNtHZf1/jAB7/HZQcVe
         DU/mTiQNce69bG7+zG9DxwQyYjobzGvr8kxv90bTzkyU0HHRVbRLdcdfpV83eBTVbVvQ
         l6CovBJLUHr48DlbvUpIdSMNhZFDM1eYoSPUntTcXfH6ZjxhgvUY5VuqqilxhX0orKxs
         1EqA==
X-Gm-Message-State: AFuF++kAMnNkYrYLr5V+i5ozaP/hFWBfxcB10bU97zW9sjyAq9Qp6hYl
	Hb72Guv42ZpPRu0G+ZJnWC/wvYr/CsqUdSZ+GKzIc5+3EJqmibmsU4/kqd4O/PnWWc0GMvfxPAw
	AsQxE5pVY2Wod12qMT6JvuLo3oE9Irs8=
X-Gm-Gg: AR+sD10z469pwQ/kE/Di3GaLutvD16KzNyCxLv2CTawWHsHQhb6E2W8v6CZwExvue6X
	wWfI7E1ouadeBECV+UyNbJ5TeGBH5ZuQNoHVXtBd+5Djy2tybVzSNnFc9AeVHGt5F0h7qYhzsYi
	vFPmXao78pstQLSJ18pXmbZ2adGbHflS8NB9etoYF+i9TkQ051uB85DeXBwXmSAKT4FIjo38uF+
	QHEeUq5cV6lsxSomkoTAZ3pbw627jDJA3LJA+avp+nf4ZLBqpAo7cEeVVeeLnXXaNU1nOaOf1YM
	BcWZm7yVTnf5Tv5dNSLD+qTHkz0bzB7m0iY4JTDEIb7rlA4y0t0beDsORE9rsTTDcOzKaQx/LRD
	u
X-Received: by 2002:a17:907:c30c:b0:c1f:9cdb:9965 with SMTP id
 a640c23a62f3a-c246a2eb836mr3251486766b.2.1787587959170; Mon, 24 Aug 2026
 09:12:39 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <1759357733-64526-1-git-send-email-dai.ngo@oracle.com>
 <CA+1jF5rAMkb44Pu8XGDnu9WUE54sHVf5TurMsQXfrUrmu0Ojjw@mail.gmail.com>
 <CA+1jF5qAbz2pMSAnSdJVo0P1d=jM5ysDsUi6BpW_+v9LgaLsPQ@mail.gmail.com> <00efd625-90e0-4ddb-b996-69a952d4d420@app.fastmail.com>
In-Reply-To: <00efd625-90e0-4ddb-b996-69a952d4d420@app.fastmail.com>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Mon, 24 Aug 2026 18:12:01 +0200
X-Gm-Features: AcwNN1XQ0fWpUzzaGN7dVAhrmvQt5rLogIgurM_hAyO0TFaM75vsQjzjK8ByBaI
Message-ID: <CA+1jF5oa5v+6_ML=QMXuJ_H=ckgYnQhF5Lf18-GSq7hucEy1oQ@mail.gmail.com>
Subject: Re: READ_PLUS broken in Linux 6.12, worked in Linux 5.10! Re: [PATCH
 1/1] DIO: add NFSv4.2 READ_PLUS support for nfstest_dio
To: Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 24, 2026 at 5:57=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
>
> On Mon, Aug 24, 2026, at 11:40 AM, Aur=C3=A9lien Couderc wrote:
> > Reminder: This is still broken in Linux 7.2.
> >
> > Aur=C3=A9lien
> >
> > On Thu, Oct 2, 2025 at 10:22=E2=80=AFAM Aur=C3=A9lien Couderc
> > <aurelien.couderc2002@gmail.com> wrote:
> >>
> >> On Thu, Oct 2, 2025 at 12:29=E2=80=AFAM Dai Ngo <dai.ngo@oracle.com> w=
rote:
> >> >
> >> > From: Oracle Public Cloud User <opc@dngo-nfstest-client.allregionali=
ads.osdevelopmeniad.oraclevcn.com>
> >> >
> >> > Check for nfs_version >=3D 4.2 and use READ_PLUS instead of READ.
> >>
> >> FYI READ_PLUS is **BROKEN** for sparse files. It was working in Linux
> >> 5.10, but as soon as we switched to Linux 6.12 it reported only data
> >> and no holes in sparse files. We're back to Linux 5.10 and cannot
> >> upgrade because of this.
>
> Aur=C3=A9lien, "broken" is not an actionable bug report. It's a
> complaint.
>
> Do you mean that NFSD returns READ_PLUS responses that contain only
> data segments, never holes? That is perhaps not optimal, but it is
> 100% spec-compliant, as far as I am aware.
>
> NFSD was changed to do this because there is no common race-free
> way to detect holes in files on Linux filesystems. If kernel VFS
> developers know of a way to do this, please reach out to me.

Why is this a job of the VFS? On the NFS server side? If someone wants
a race-free hole listing he has to lock (shared lock) that file on the
NFS client side, NFS server handles THAT lock. Problem solved.

Aur=C3=A9lien
--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
