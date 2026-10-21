Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.52
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792586266;
	b=osozlOfu4ejJHHxYT1V1sTj/B7+fMmKARldPKrtnI75MXqMcQLAJ6ngQekVmjxUkIpAY
	 3Mpr7n/xxNEEGTy+HtRq/Oh46RQjnatLVybC0NTQNf2u6w0Mx47aQ5Z6msjq0jvc33Sw6
	 jkMMI/hdo3mzdz40T0FxQSgHphmFvDTrGBKDERoZv9GHXnlJ1+Ecpn65lY3oCS+TwwzVi
	 zgdic4W0Q6mWeRjtKHd6+A3YR0ulmFmmNZxVyY6FY5cYF7puDCj9nfFqsUE9lYknYw0/1
	 1dwE2N9PAHAobTXXyEqsEctkzlipbTmUmILPEjhiVDt3grHWyDXUNqI6j8PWnkkRomg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792586266;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Content-Type:
	 Content-Transfer-Encoding;
	bh=nwaL0A5IIu7ROpD/hVLzppGzy1JYwU6upC4ODlCJkzI=;
	b=N3Xa0p/DHSEoPE25VoBMMPgqcVe88UwQIdTzqGyh4wJysikkMWBRqM7qVI/hOU480H0D
	 726ZmCb2/xtPVD93w1I0rGQMuwbA8XaVW/M5Mj8vXrRZ3oOtk4km9uw02OGhZUfEUXEYh
	 MBpd5njgI5rVf4siHfDFO93g5EWL64Nwt1e0dMNYyZgbkC2qmrWPu72S5hjWUhlyt0aUd
	 s6EfySUaR7pKhClM+kyjK3JsNj8x/XoAuKTSko3t2F1j7nrclBx9szK7BzS8ClqCSJEKC
	 aMUcW7y/ebMvOnLjyFcaWHkdwUh1qBsajzqYVuUDPaI5PxbeTOTpdXLvQyBSCizI3CQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=DpFvsEbC;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.52
Received: from mail-ej1-f52.google.com (mail-ej1-f52.google.com [209.85.218.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3522A606A321
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 12:37:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3522A606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=DpFvsEbC
Received: by mail-ej1-f52.google.com with SMTP id a640c23a62f3a-c4682977f9aso51014466b.1
        for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 05:37:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792586264; cv=none;
        d=google.com; s=arc-20260327;
        b=dwJrHC0evJwS6EIoycvSatoNgIZyIg/OBSiVr92cJ0a3Y02QKOpX8mZN5qa1GLMc4/
         IHqcdIy1qUwD0xsNhIyvM5mzhfNAxQJYhcknaQLj/J72PITW82zsNjpOlcNAQe/7dLaG
         cVxI91Jm8Bo0GXWIy8SImE1nE1mnkpdlpweUIL6cJnLs2KFv5uPHvG/eiTosAXBT+n/w
         fwWu4aQ3EfHltes4cWo35qmV8Q2ueF8Hh/GSYkUL+oQ5HSZydCQA6ED+yoZW++aIcDB0
         o6E4l4cYujTLxKtszePfe5y08otXf/knaZW5VDTDxomVp4sTN41HD/BtU90b3Y5rYTnP
         s7Pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:dkim-signature;
        bh=nwaL0A5IIu7ROpD/hVLzppGzy1JYwU6upC4ODlCJkzI=;
        fh=A3pMOUK00huGibGCZBFsLekFLVbB5hHGKjUNNKwO+5E=;
        b=WL8fXNf/AteyiyQHLQ4WIMLAs0lRvs3azfTCz3f6kujL8GEHNmgxZHPoncKtgoMibS
         kDdvsOtzB/5/ei4ULnNI9KLrunB08GPn1IEj3yPYEHLUqm12I+Q1dNWwXk93ntypZsA8
         SDh6aYmOOe0Fh5ILg/teKiJKGzggCujVGzqIs/Or+ELBMgB37hC+17YRcXdxJAt/Rk9q
         E53XTXIkWkJ1vD+bHSVaxdyVHh7znaecUNKaoZ5dyTohSrMAjTj73k7Pumi69qC24Gp7
         Kh2PbHsq46dkYditDjBHO+/AFd+l5k0KMkunOm1KtsC+3SitpxbT+v4L+/9uFRIc4sV3
         QIDQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792586264; x=1793191064; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=nwaL0A5IIu7ROpD/hVLzppGzy1JYwU6upC4ODlCJkzI=;
        b=DpFvsEbCEvziKbP5kF29S+ru1HALGNcUhSJXMhRX2+hx6AVETUy2glMeRIPaksRpkL
         Y0gPugznDYW00ucNKNH2dEmg/SmWJYvaMvSDAKHDXVlffPVzKhFoMhsM90fAQAydvf12
         gATJX9dakVJBy4ZcpRTxMnBWIcP3Gzv/P7czPSrr8+W7ZI2L8Gcd8KT6qRlnaAAAZbwe
         M80BKR9sgAmNrlkljJ4nNx1kcNrX7vbFvxkblE5bbOC6wtNxUs3oY5K6InFzEjj6hM0x
         /e8qz5gWcWSKtTnYeuZ9FCxTHDV+DuItmdeIRMnMkwPwPLzN8Lp2nTnQs8AXhFxpLqkR
         8djQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792586264; x=1793191064;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=nwaL0A5IIu7ROpD/hVLzppGzy1JYwU6upC4ODlCJkzI=;
        b=wONXKQMQguvEZYD8B++zIS0/VJlEppmhPWhTuZ+K5RYLengTb5jd8ZPGlcUyzcscxp
         dGVZ5ir3IrJr9JVoTwWgEqSx/RJnLiN0P+I2zaXkFgPwgr1JubwUiEvUBAfeV+eKZljz
         YPH6Wj5Qoz0lrPEoQBqnZhaQhHfbId9YuWNa3TkKpZO68vnG0Fl5AxL9bHVn87J3Z30x
         7ZbMgXQBHNEYLAVkFt1a9ajqg6zPa9ySgqDJdcJjSlAam7uBdlXUtxic++YBsRe7ZfJL
         AICk2NrqXMgt8CmoIoqjXt2eJELEGA1LfERF8pomoW7X89J96ZWzNMnRTQwZ/eEfg9PV
         pJKw==
X-Gm-Message-State: AFq9FYLxR+WEuJqLNJn8jlQIZjzULyv3ReAGqOai1rdbrATR91qe6pqT
	fCQIr7lkgFgTr4619uzWb5DlHejhJdYHUFz5TBj/w0cHDQTqm4H4FDjqWI3CKXEXSBV/m621VCZ
	B0rQdFenEMo4L/GwwO1z4XwApAZpV7Tkh/Q/36Cg=
X-Gm-Gg: AYBFou1ckb3cprpXl/5uZeHjQtP3cKOtilp2gHgc2w9qevFvWFLbDXoOA4q7pHxabim
	i3NOYfjmWmd/OmnoPBXgsrP0nlzfXaSHygz9xnol+lbCkHoJNUSxMA951oPfatkxK83p4bPjBcT
	8OrI/f0O9zMk2GWSZ4T/a5Zk7fUwqZSXWLl2qf0ShzaiqZ6YD8Pag4+zEK/3MVL3A3EK6eepAES
	H/pggIKTZDqXhPhOCJ1DZpnCsBGGWPdrUFAH62Q8FtfWqdSnqX33SrUrD9ctdBqgZHnQrHSbdFU
	yR15x5YetKnd7U8eg5rbZVNrpmIwv3K1khIW597b3K8fOLPIxvihaVZvl6Csj4FOZgMgK9C62Cu
	M3RR+JMdv6ONtsVSj9iryeo1da8lODKDmoWKC
X-Received: by 2002:a17:907:2d08:b0:c46:7643:ae91 with SMTP id
 a640c23a62f3a-c4679537741mr156762766b.8.1792586264433; Wed, 21 Oct 2026
 05:37:44 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: Takeshi Nishimura <takeshi.nishimura.linux@gmail.com>
Date: Wed, 21 Oct 2026 14:37:07 +0200
X-Gm-Features: AclHuK-gQiKSHcFk8aLbiAku54hsZDQYKrhwQyDUr7hQIaEMapXKjLUhAygj_-8
Message-ID: <CALWcw=H0Q7q42ExWqQek=cpNcqg6OArNgt8+eLYG8j41Q0yXxQ@mail.gmail.com>
Subject: Linux: NFSv4.1 FATTR4_OWNER_GROUP supported on file,dir,symlink creation?
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear list,

Does the Linux NFS server support NFSv4.1 FATTR4_OWNER_GROUP on
file,dir,symlink creation? Which Linux version supported this first?
--=20
Internationalization&localization dev / =E5=A4=A7=E9=98=AA=E5=A4=A7=E5=AD=
=A6
Takeshi Nishimura <takeshi.nishimura.linux@gmail.com>
