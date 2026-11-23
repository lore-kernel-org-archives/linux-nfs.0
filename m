Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.51
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795474038;
	b=XYPtXXZaRh+X1rktEUWzuo2SuXL0xfawmgf8yz//f2Ri2AiddAZ+HGB+oMARHOunZqIt
	 qwOc5kVjdtHlN8g5HvuvPveLQEH0iW+BPd1Hzqf0IhhyIBAlnEBoFlDceNMC63GSE47Kn
	 1xFlt10AeoFDS064F7nP2BO46yxOMrXSXCvQg7ChJpyBasgSULihx5BxCUkdEFqBXsZe3
	 2LS4GNJroSzjVrXVKV250eS437CdPt3adzZZ0Fv5F4ohHi5ojBEJoxh0MfcTUW2fhr+Tn
	 5aUR5A0oBuRK2j3i2f6m+7PeCSjSuFM4pf9U5DfrgiC7QsibupX4e3g3tuDSRCvUskw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795474038;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=prDmnot/bOxVS2gCc8v9HfYcjzpcvwnB8HRgvfXYsr0=;
	b=Ij8dnxV+/WvdrInWDf09uVoAog8eWhLyDYHI74L6Tc9YJZGqbadx1XdxurYe7SCjOfHe
	 /KpYo3qE+yHpAL6Q7lCgh7N0luOpCGB9BhGKLItqDP5FJlU8jvdkuqOPcM07LxhIrOzaU
	 T4E8XkHuAJbvrf9SIfhwyes9sZq72ZhfYJu0Zrh702/f9EDlkfkRTpR9mJd4Sy4VlZSWi
	 wqeZiVlbI7myABey9dQskNI/gMGzN3MkxF+3k50fxg+yCqXG510xg7dDBZi2T+CcjNHUv
	 KSjjubfUHAi6/muqtI8oO1cbJuk+0sf3d0AP44pKa1ZZ+DC26PEnb8oOgWUsD927gHw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=e9TlTdXc;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.51
Received: from mail-ed1-f51.google.com (mail-ed1-f51.google.com [209.85.208.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC772606A322
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 22:47:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EC772606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=e9TlTdXc
Received: by mail-ed1-f51.google.com with SMTP id 4fb4d7f45d1cf-6b88b74e54eso4643435a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:47:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795474036; cv=none;
        d=google.com; s=arc-20260327;
        b=Fu/g0JJZvrRVK6xnKSQc/PRcM9u6vd2TJwEfamPQrHJo5PRoNSyAuFORA3t3P84bjn
         pvCuH/O9ajErW/Xntc99z8yo98y5zJDRZ/nJvyqq7V7TwoGSpiQjsKPGjYcYVjHuzLFF
         Z7jS39/pvFYELkGGKV6XZ5NvpM/Ey/A12e6v0mqpg+M8Gomwr92Oy82PIch8IXx35QOb
         uDxMJ1m32aS0JFJBwP8AeeLuFdhZ4yABo9Uz5jtAyP/a85yBlr2f5P0xB6qrhxQmx+Hm
         zTmNFijMAC3A/0FF+E/CSYhCTdBFKenZpFz58MWOLz5qkvqWQ9rB+v86xmUIhZH0wGOo
         hDjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=prDmnot/bOxVS2gCc8v9HfYcjzpcvwnB8HRgvfXYsr0=;
        fh=uC80PHVQrU2a3z1+K2ypxydGtkEj3kTudtHOgN55ywE=;
        b=FgIL8pMrwmiyst04mY8VvE2NeSSXya6ffjhMInvDCJhgMMCdxOQbwzA3DgqRVoVY9Z
         T9p01UekwVqHvI0HP4yunuDx0G6Pi0G2+YCO5bn0sJbn0iv4h+GQZahKmD2euwm7BSKO
         oxGWJw6l3+R1ZiCOjbwlXAWsMc6kszy0oeBv5fB56m+tHdEM/xFQ/eXrqPF40WGSdkf0
         3+W0bU3CrumESg700K5llbMXLF64q6dxrfbPr6jGvsdCd8p43cGyOqgCiffzh3In/RB9
         FTMnaBSoNq0ixiv7G6Sve3ZSwBBezujmVmM0azrsvTNKsdtXy/npu3JCzuE+i8i1nqIY
         znZg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795474036; x=1796078836; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=prDmnot/bOxVS2gCc8v9HfYcjzpcvwnB8HRgvfXYsr0=;
        b=e9TlTdXc+gatXcuCFKKb7aj/RyvKZZs3Fc22DsvCbrqYMGGtwci3FfIjibOfYQ/CZW
         9N8fj6eIrKNnVRdbxmnkFIx1GgLKrWEmFGL9vOQOEa0GR8Bc8q6jIgpflc/R1WmaKkIq
         a1L/XNzQgQR2OfVdP5ZWakzu06AC21i4FBAOG3jwYP8Lhy9AUkzJO9T8iBSrC7rM4aSU
         +QCy52SpD8tCCzGsrVoCDffQdo0iiSxV39ldqNaCG7VxnqiWEDVWhmyRn5+Uk0DxMQhg
         +jgf5l52Pyk6Ega5GmFX/ULCv5YHSq3eiAljutksNIdRm4c/i9EcMfRht5xGucVDbs5/
         qj8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795474036; x=1796078836;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=prDmnot/bOxVS2gCc8v9HfYcjzpcvwnB8HRgvfXYsr0=;
        b=M3QX5xZNNJe7KJTwG06gnyjvhpf5F0R9n8WUOIRhpbWC4hyLgsXNZ0RXduOsADrzuD
         q5wL9skthuwpl162EuLJX7DXapuG4tg9nHCOZmsYre3VPiEbj1ZatOmYDnntPwWP+ITZ
         neW3LDkvKYrc0+0o2q2uGG36yrtfhLAutW6+INhHXxLxBqJYWeAkjZItmJ+2zrp1r7oa
         RTDiK1HoVzhAhyDoOWXq0F0YqBIMxXoy4UrfQzKcqFWSvDipEseUwZWVQ7OpH85Ev8rx
         M/SkLGimP2LkfRZejilwbV/b9BAGcYi1A3zbR+g+jKHAWteE0htFM2i20PMIqkgif+Yi
         2tcw==
X-Forwarded-Encrypted: i=1; AL+hErFyrjCCbECkz+n42XhAQRUdohFZYLr3BQCzGcTzETbXz2J5xUBzBCx4RTcLr0ELRSg0uSK/HnW5vNU=@vger.kernel.org
X-Gm-Message-State: APuU4Z80pDzIyRDxYKB3O5t3a7fXa6RD0rpwlCLz2H9x0Fo7+rxunDyz
	IeQtfyvlbMiVFzmkzWaH97AQ8vgh8z6zsh4Bsieb8e8zkadCnpiOECkOvc+BqXatEFF1RNAoFB/
	H907gKJKH/tx2hCxiDu9NPQiWt50tLkI=
X-Gm-Gg: AZFdTZeokstGJLqNF3USaIpO2BUE4x72YVFCAf6dKGRE87RlaZcd0TItlvbvsK8vEkd
	w9RlhSNNz10sJRwaKcptqPRx3ClNSleVCG/ezqKyY7zQKW1Iujd9YPIAFzM8IVFGe23bZjXif5r
	4qayBj2OqcP+ZZYK7/uKx7S0ZyJm4oImBJBOznK3sOiquoEW7q1RAgOKDDcfsGHV7VkuuCRK0k0
	VdNu5mCliqUnU6wM9FaBPB/o4IHtdM4kT1e/ft8DlfuRWK2ycgcAQRaeQSnThaxtkgspOb8ovlX
	dznjMhETbZCcEJIrhaZL3gctMrh07R6ORqYldXYbIclSffo5Gkxf/VP25htYGbyuMPNTUs/ZWtv
	iEyGgqIGueL71x71FbjVaB4JRgGdZj0KDMBLZjnqmpK/72p2FfB8RHyTJ7N5Youqhw6GCmA==
X-Received: by 2002:aa7:c710:0:b0:6b8:e848:d004 with SMTP id
 4fb4d7f45d1cf-6ba37e8dec5mr6855932a12.29.1795474036043; Mon, 23 Nov 2026
 14:47:16 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261122000856.536902-1-koray.fra@gmail.com> <CAOQ4uxgf2KE=Ag13EPAu5=KnrFwt7zRH=im-qmLc8+i10Tjd+Q@mail.gmail.com>
 <DN2X3RC5JUFQ.2LNGLQOUX4ZPF@gmail.com>
In-Reply-To: <DN2X3RC5JUFQ.2LNGLQOUX4ZPF@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 23 Nov 2026 23:47:04 +0100
X-Gm-Features: Aa3M54pZr_aGN97hdgjJEJclpmHDWTbmXWMujrk4s8rCr1BMot2r_DEgpbuT4T0
Message-ID: <CAOQ4uxhsv_1EEqAZ3Ebp5Uy8Q6nvEnE3EAomJjjQO86nTcW0cg@mail.gmail.com>
Subject: Re: [PATCH 0/3] Add f*_xflags_{rw,ro}_mask flags to the fileattr API
To: koraynilay <koray.fra@gmail.com>
Cc: Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jan Kara <jack@suse.cz>, 
	"Darrick J . Wong" <djwong@kernel.org>, Andrey Albershteyn <aalbersh@kernel.org>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	Lauri Gates <lauri.gates@gmail.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <dgc@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	ntfs@lists.linux.dev, linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 23, 2026 at 10:45=E2=80=AFPM koraynilay <koray.fra@gmail.com> w=
rote:
>
> On Mon Nov 23, 2026 at 2:35 PM CET, Amir Goldstein wrote:
> > On Sun, Nov 22, 2026 at 1:09=E2=80=AFAM koraynilay <koray.fra@gmail.com=
> wrote:
> >>
> >> This is a follow up patch series stemmed from [1] and [2], splitting t=
he
> >> _mask change for the fileattr API into its own separate patch.
> >>
> >> The first patch is a preparatory patch so that the code in the patch
> >> after can be formatted better.
> >>
> >> The second patch is the actual implementation, which introduces:
> >> - fa_xflags_{rw,ro}_mask fields to struct file_attr
> >> - fsx_xflags_{rw,ro}_mask fields and has_masks selector to struct file=
_kattr
> >>
> >> These masks have the following semantics:
> >> - rw_mask:
> >>   * for filesystems: advertise which xflags they support changing
> >>   * for userspace: specify which xflags it wants to modify
> >> - ro_mask:
> >>   * for filesystems: advertise which xflags they support only reading
> >>   * for userspace: ignored
> >
> > Nice!
> > I think this API description is very clear and coherent
>
> By the way, should I use this description in the commit message (and

You could use that as a short TLDR intro

> integrate it with missing information before/after the bullet points),
> or should I keep the current one?
>
> (current one:)
> > This lets filesystems advertise their support for specific xflags, like
> > statx.stx_attributes_mask does, and userspace can specify only which
> > xflags it wants to change without needing a RMW cycle:
> > - on GET: each filesystem that wants to support this new API fills the
> >   masks according to its supported and read-only xflags, then:
> >   * for boolean xflags: it fills fsx_xflags with the current on-disk va=
lue
> >   * for value xflags: it sets the xflag bit to 1 in fsx_xflags and the
> >     xflag value in the struct field;
> > - on SET: userspace fills the rw_mask with the bits of the xflags it
> >   wants to change, then:
> >   * for boolean xflags: it provides the xflag value as a bit in fa_xfla=
gs
> >   * for value xflags: it sets the xflag bit to 1 in fa_xflags and then
> >     provides the value in the struct field; if the xflag bit is set to =
0
> >     instead, this informs the kernel to unset/clear that value.

You can keep it also but tbh UAPI documentation is more useful in
comments and in Documentation than in commit messages.

Thanks,
Amir.
