Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 884214A6CDF;
	Tue, 15 Sep 2026 18:05:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789495532; cv=none; b=scEk3jaJqbfeet0JDqfFF0hblNplzvmS+1lPz5NwnsVrm4u1kVOCfExiYi/g6Hcz/08l4v56diz5hEAm6GLeiPHgwD5vF0ECUh6ZHM6V+9zH5qgIzxHNOxKGwTLx8eYsV+cO0V34F90js4GWpfA4rKUMxDgVeEre50pX0LwffPE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789495532; c=relaxed/simple;
	bh=V6K4OlMCnUsCbDMREVaUa2vUImH9KQWys0wgaxngXJA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=gfuPf03J7lxn0tqT5OuVYHZ4DS/aVd4KrSy2EDRM8b982EshWCpuzHWUr+D9KdPANs83cOFX09kIsaIw7aDm2lEcsp6xot0jmqiCR0NzNGmwbnunVarZnX3eiEP4fnf2GnWnQ/YsopuMzFiqjYgckczMy+23ng8N45508TCOPxI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jTo4X3Om; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jTo4X3Om"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C9A331F000FF;
	Tue, 15 Sep 2026 18:05:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789495529;
	bh=mPeI+6lTU/Y8EitQI5ZfnrfapFmX8wWN22xo6A7UJaE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=jTo4X3Om6pjYJxMpPsXGw742bcwi+fNKt1WirPMCjMB3CN4+QeGCMAad0HowUYo27
	 zkPX73/bpXrtYTMe0XsfHOKvy0auvvNyZSnejxr33FwP5Y4EAzd8YeVUzA5p/dgDEw
	 5cFlE/iE3GLNGT0ByRP+/biS9WQfT2P4HJ97Jm9P9K/qgKyfL5uH3H46GOijU3awQE
	 U05QkDGXb1dMAlMiuCtrF46H69n28W2iJaBayGHH26y3LSBp2/268of5pUNUCjMz6C
	 lP5HOIiL9QmsIGugbJJQ+XSzW3eNNY7uy3+IQE3mKC77JsHqvgv78X1PoCadcnYcJG
	 U7RPeBeWp4lDg==
Date: Tue, 15 Sep 2026 11:05:29 -0700
From: Kees Cook <kees@kernel.org>
To: Bill Wendling <morbo@google.com>
Cc: linux-kernel@vger.kernel.org, Russell King <linux@armlinux.org.uk>,
	Huacai Chen <chenhuacai@kernel.org>,
	WANG Xuerui <kernel@xen0n.name>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	"James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>,
	Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@kernel.org>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>, Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	Tony Luck <tony.luck@intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <mripard@kernel.org>,
	Thomas Zimmermann <tzimmermann@suse.de>,
	David Airlie <airlied@gmail.com>, Simona Vetter <simona@ffwll.ch>,
	Matthew Brost <matthew.brost@intel.com>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas.hellstrom@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Matthias Schwarzott <zzam@gentoo.org>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Tony Nguyen <anthony.l.nguyen@intel.com>,
	Przemek Kitszel <przemyslaw.kitszel@intel.com>,
	Andrew Lunn <andrew+netdev@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Arend van Spriel <arend.vanspriel@broadcom.com>,
	Rob Herring <robh@kernel.org>,
	Saravana Kannan <saravanak@kernel.org>,
	Krzysztof Kozlowski <krzk@kernel.org>,
	Sylwester Nawrocki <s.nawrocki@samsung.com>,
	Peter Griffin <peter.griffin@linaro.org>,
	Alim Akhtar <alim.akhtar@samsung.com>,
	Linus Walleij <linusw@kernel.org>,
	Anil Gurumurthy <anil.gurumurthy@qlogic.com>,
	Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>,
	"Martin K. Petersen" <mkp@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Jiri Pirko <jiri@resnulli.us>, Simon Horman <horms@kernel.org>,
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Mike Rapoport (Microsoft)" <rppt@kernel.org>,
	Kanglong Wang <wangkanglong@loongson.cn>,
	Tiezhu Yang <yangtiezhu@loongson.cn>,
	Qiang Ma <maqianga@uniontech.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Pengpeng Hou <pengpeng@iscas.ac.cn>,
	Ard Biesheuvel <ardb@kernel.org>, Breno Leitao <leitao@debian.org>,
	Thorsten Blum <blum@kernel.org>,
	Harshit Mogalapalli <harshit.m.mogalapalli@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Lyude Paul <lyude@redhat.com>,
	Ashutosh Desai <ashutoshdesai993@gmail.com>,
	Imre Deak <imre.deak@intel.com>,
	Dmitry Baryshkov <dmitry.baryshkov@oss.qualcomm.com>,
	Johan Hovold <johan@kernel.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Miri Korenblit <miriam.rachel.korenblit@intel.com>,
	Alexander Stein <alexander.stein@ew.tq-group.com>,
	Cryolitia PukNgae <cryolitia@uniontech.com>,
	Jiaming Zhang <r772577952@gmail.com>,
	Will Porter <mrwillporter@gmail.com>,
	Cen Zhang <zzzccc427@gmail.com>,
	=?iso-8859-1?Q?C=E1ssio?= Gabriel <cassiogabrielcontato@gmail.com>,
	Rong Zhang <i@rong.moe>, Arun Raghavan <arunr@valvesoftware.com>,
	nikitash.mariiaw@gmail.com, linux-arm-kernel@lists.infradead.org,
	loongarch@lists.linux.dev, linux-mips@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-edac@vger.kernel.org,
	dri-devel@lists.freedesktop.org, intel-xe@lists.freedesktop.org,
	linux-input@vger.kernel.org, linux-media@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, brcm80211@lists.linux.dev,
	brcm80211-dev-list.pdl@broadcom.com, devicetree@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org, linux-gpio@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-nfs@vger.kernel.org,
	devel@lists.orangefs.org, linux-hardening@vger.kernel.org,
	linux-sound@vger.kernel.org
Subject: Re: [PATCH 00/28] Replace remaining strlcat() call sites with
 snprintf()/seq_buf()
Message-ID: <202609151055.AFC6267@keescook>
References: <20260915081910.4142719-1-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260915081910.4142719-1-morbo@google.com>

On Tue, Sep 15, 2026 at 08:18:17AM +0000, Bill Wendling wrote:
> strlcat() is deprecated: like strcat(), it requires re-scanning the
> destination string from the beginning on every call, which is O(n^2)
> when used to build up a string incrementally, and its truncation
> behavior is easy to get wrong. See:
> 
>   https://github.com/KSPP/linux/issues/370
> 
> This series removes the remaining strlcat() call sites in the tree
> (plus the one inside fortify-string.h's strcat() implementation
> itself), replacing each with snprintf(), scnprintf(), or the seq_buf()
> API, whichever best fits the surrounding code.

Thanks for tackling this!

A few global notes:

- This series almost certainly needs to be sent as separate single
  patches to each subsystem maintainer (rather than a giant CC list).

- As others noted already, we don't want to do anything as just an
  open-coded strlen/sprintf; this doesn't gain us anything. If we can't
  use seq_buf or some other solution, we need to figure out what we _can_
  do for a given use.

- There are some collisions with other in-flight patches, e.g.  Mariia's[1]

- The "Assisted-by:" trailer doesn't need the level of detail you've
  got, which changed recently[2]. Now the desired trailer would just be:
    Assisted-by: LLM

- Please avoid including the Cc list in the email body (above or below
  the "---" line), as it ends up being redundant.

I'll go look through the individual patches...

-Kees

[1] https://lore.kernel.org/all/27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com/
[2] https://git.kernel.org/linus/816d9992d9ed ("coding-assistants: simplify attribution")

-- 
Kees Cook
