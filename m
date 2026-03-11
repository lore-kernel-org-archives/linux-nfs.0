Received: from mail-ej1-f43.google.com (mail-ej1-f43.google.com [209.85.218.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35EB436C9C3
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2026 14:11:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773238317; cv=none; b=PJ6T0N77mcpBenc8DbzcJlotjLVflGhpEYunZ9p74E5ZlT/Xx8iKOdwzNTOAPV7CBeQfsksuB0e3AxjonAv+1eQ1HWbF80ICG7XCQAoEnisFbVwxfb9G2k8gLrhYZv3zMoB5tmqZ4aOfd5t0ATYJZ8ibCL/p5SjP2xQeO8hayiE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773238317; c=relaxed/simple;
	bh=POUJjzeRhBIXfPGojdZfC417KH92loTKx1KmDpRcfoc=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=Xv3fFNFCZjaaRkhNRcX+9spjxQOyQYNrnjUzXHaKS/7Z27YJXpakKUZ2oXSYNFHYP802EtxlzCytSgSPq0ICC+ZuR6YLHvKyCTfxnngyFA4e7gTCVv2tVlie77QCE4fl8ArpoTrnHYPJpehMPBOZ2oJwzfaiV9OY+ds7S0GEsPU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org; spf=pass smtp.mailfrom=gmail.com; arc=none smtp.client-ip=209.85.218.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-ej1-f43.google.com with SMTP id a640c23a62f3a-b93698bb57aso170124366b.0
        for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2026 07:11:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1773238314; x=1773843114;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=wIz9Fr5w5J45ZN4rxwvT/0kjXMGfLP1VpB2aKPOax7k=;
        b=E8GHXw6tM4/U4r+Sv+05Coz2oyChg+B9Yb2mblG9S06R9ZNGJ+b4p/WVIVQ+bTd9zn
         Rrk9gFjPNs/QPARbPLSMPKZIN5S1FEh8BJvm7Te0s7WhhDLnDCMab/Qs1dMVEmabjjo6
         sr79mNCeG/A+nDeftNl1mUjOoQZ6wM4+nRzkY7qSF1Jwog6Y14QguSQr6BTSlED81PgG
         U0eENQHbu++g7BjM6StrCG0mdfyXpNpYpwWJZ+l8q7jXvYtEWE4U4FbfiLsd2Mv9S0ZF
         jB48GKT2Lhvx8gn4X4R82gJT6fDdzqnItbByVqNcw182vVeI3decrzPttTLOGiARdQLZ
         ZLCA==
X-Forwarded-Encrypted: i=1; AJvYcCXXes/B52aMVZR7RXsNvCkbfjdkjwRucVgdz4xRvB7feP5y6oh1HcCqGaWFKqqe/Mc3kjiw5PF1j24=@vger.kernel.org
X-Gm-Message-State: AOJu0YyVO4nunjlRHNPcD9iOVLcIkG+j1Kn21RrK69v/9AdvusGGUM7Y
	oVhwa3Zh10mLHGkfc3jFqwHXiC0oXgu0wO/SLhsQr60qadJ1/2ykJgCRycqrtpDn1xV6kQ==
X-Gm-Gg: ATEYQzzQmXKHiow8VndhromLtFNE1g4uPFuUfjIGaQVmrsN22M2b4r9yEwani1RClQR
	aoB8Xu6JLbijUcGn4rdw8MtH3OFZuOTgg4UJaun0HB1koefaDMZGnz4d6A7F1dz4ar4AzyGH3EU
	rp8baxzWmeDx3m2uLLvNeHHp8NZ9oazOWXmJKqR/9OQGgfSR17YdU3jOarvxpjqKbLrEp8+qJcI
	TX/Wj7XgL/pi4FxbbNFa7GPMSQIWa3v+rUM7ko6VF6CtoCujROF+xpGb5mB4HEbLhJcmaFKbHlv
	9TnOPSzMGrsJKISoCSXIspVUH+inl2tr5hkfEkfQVyaw9H9TxnYMAJPKujKSSvndxXp1xwnYIIl
	nC443IWIbI8Ut+lWkk9TTmaf9gEAShTiV2PCgwAgfXXY6c4EvE+aGu4vXLjI2ZUOLuanzeu6O+e
	W5220rS9CHbXCtmoOy3F9K8US9xY+zjktWlnesBNvP9OWteKiPSVs3olgxjUcf
X-Received: by 2002:a17:907:7211:b0:b8f:de69:b597 with SMTP id a640c23a62f3a-b972d51c4ffmr173586366b.7.1773238314235;
        Wed, 11 Mar 2026 07:11:54 -0700 (PDT)
Received: from mail-ed1-f48.google.com (mail-ed1-f48.google.com. [209.85.208.48])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-b972e14c2basm58708266b.35.2026.03.11.07.11.53
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 11 Mar 2026 07:11:53 -0700 (PDT)
Received: by mail-ed1-f48.google.com with SMTP id 4fb4d7f45d1cf-66325f30570so981658a12.1
        for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2026 07:11:53 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AJvYcCVnH/pTUNfp2xqi5b7nqTwrUAsWgbFuEGeS9ZzvL7OrgM+X1riW3bWd2DxLdtlSfqc+Ua3Oj61DVAE=@vger.kernel.org
X-Received: by 2002:a17:907:6d16:b0:b88:4f25:81da with SMTP id
 a640c23a62f3a-b97113ff0b9mr462021166b.0.1773237981235; Wed, 11 Mar 2026
 07:06:21 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260310-b4-is_err_or_null-v1-0-bd63b656022d@avm.de>
 <20260310-b4-is_err_or_null-v1-15-bd63b656022d@avm.de> <20260310100750.303af303@gandalf.local.home>
 <20260311141332.b611237d36b61b2409e66cb3@kernel.org> <20260311100332.6a2ce4b1@gandalf.local.home>
In-Reply-To: <20260311100332.6a2ce4b1@gandalf.local.home>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 11 Mar 2026 15:06:07 +0100
X-Gmail-Original-Message-ID: <CAMuHMdX4kRGLaKMzPuhS1Pmxh609eiqQW-cAS_jWBBbt-vE6SA@mail.gmail.com>
X-Gm-Features: AaiRm53WEGMMLW4z34e7P-lM1qFvsCJGZ_o4JNL5NPWbhJPKmcqz6k9bJcyL--8
Message-ID: <CAMuHMdX4kRGLaKMzPuhS1Pmxh609eiqQW-cAS_jWBBbt-vE6SA@mail.gmail.com>
Subject: Re: [PATCH 15/61] trace: Prefer IS_ERR_OR_NULL over manual NULL check
To: Steven Rostedt <rostedt@goodmis.org>
Cc: "Masami Hiramatsu (Google)" <mhiramat@kernel.org>, Philipp Hahn <phahn-oss@avm.de>, amd-gfx@lists.freedesktop.org, 
	apparmor@lists.ubuntu.com, bpf@vger.kernel.org, ceph-devel@vger.kernel.org, 
	cocci@inria.fr, dm-devel@lists.linux.dev, dri-devel@lists.freedesktop.org, 
	gfs2@lists.linux.dev, intel-gfx@lists.freedesktop.org, 
	intel-wired-lan@lists.osuosl.org, iommu@lists.linux.dev, kvm@vger.kernel.org, 
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org, 
	linux-bluetooth@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	linux-cifs@vger.kernel.org, linux-clk@vger.kernel.org, 
	linux-erofs@lists.ozlabs.org, linux-ext4@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-gpio@vger.kernel.org, 
	linux-hyperv@vger.kernel.org, linux-input@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-leds@vger.kernel.org, 
	linux-media@vger.kernel.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, 
	linux-modules@vger.kernel.org, linux-mtd@lists.infradead.org, 
	linux-nfs@vger.kernel.org, linux-omap@vger.kernel.org, 
	linux-phy@lists.infradead.org, linux-pm@vger.kernel.org, 
	linux-rockchip@lists.infradead.org, linux-s390@vger.kernel.org, 
	linux-scsi@vger.kernel.org, linux-sctp@vger.kernel.org, 
	linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, 
	linux-sound@vger.kernel.org, linux-stm32@st-md-mailman.stormreply.com, 
	linux-trace-kernel@vger.kernel.org, linux-usb@vger.kernel.org, 
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org, ntfs3@lists.linux.dev, 
	samba-technical@lists.samba.org, sched-ext@lists.linux.dev, 
	target-devel@vger.kernel.org, tipc-discussion@lists.sourceforge.net, 
	v9fs@lists.linux.dev, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Content-Type: text/plain; charset="UTF-8"

Hi Steven,

On Wed, 11 Mar 2026 at 15:03, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Wed, 11 Mar 2026 14:13:32 +0900
> Masami Hiramatsu (Google) <mhiramat@kernel.org> wrote:
>
> > Hmm, now IS_ERR_OR_NULL() is an inline function, so it is safe.
> > But if you want to use IS_ERR_OR_NULL() here, it will be better something like
> >
> > node = rhashtable_walk_next(&iter);
> > while (!IS_ERR_OR_NULL(node)) {
> >       fprobe_remove_node_in_module(mod, node, &alist);
> >       node = rhashtable_walk_next(&iter);
> > }
>
> But now you need to have a duplicate code in order to acquire "node"
>
> I think the patch just makes the code worse.

Obviously we need a new for_each_*() helper hiding all the gory internals?

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
