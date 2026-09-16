Received: from mail.alien8.de (mail.alien8.de [65.109.113.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30343369D47;
	Wed, 16 Sep 2026 01:11:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=65.109.113.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789521117; cv=none; b=d6sZhWJKQywhfBDeRnzm7SjzX0ectCgILvABnGIVoeqw9ZpJ0+BvRQVlhA0xaWwp+6FsEZwtpNhRKvLuX05f7yXC0uXs4Jshf1gYKoMHla4T67Yss7xzV32itQoiD1eSHFhnr8aps4npcRKnloSEhAqleoMcEw6tVcYbIWvcRNU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789521117; c=relaxed/simple;
	bh=qD7WMAo+dVVnjd0ZsNjjuy+BJVsiMK9NyvdybQvFWSI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pjVgK8V7ayfV4gYMFgiKX4hDa2c5JfKJN85p1jcuhIpDF1O2L8YXhHQrIgaAelpDvnZwWL0lJQTaqfiHo82L6e4EAaENcIsPgRTfeDUGztc4fRrU6tQaH1OGSge7YUkGDFeW/F6XBZpxGSLBCnqjuiIpop45P81zRKEsxy5QtRg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=alien8.de; spf=pass smtp.mailfrom=alien8.de; dkim=pass (4096-bit key) header.d=alien8.de header.i=@alien8.de header.b=hnodkwuX; arc=none smtp.client-ip=65.109.113.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=alien8.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=alien8.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=alien8.de header.i=@alien8.de header.b="hnodkwuX"
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.alien8.de (SuperMail on ZX Spectrum 128k) with ESMTP id 4F06440E022C;
	Wed, 16 Sep 2026 01:11:53 +0000 (UTC)
X-Virus-Scanned: Debian amavisd-new at mail.alien8.de
Received: from mail.alien8.de ([127.0.0.1])
	by localhost (mail.alien8.de [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id FYIHRxOfwfXD; Wed, 16 Sep 2026 01:11:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=alien8;
	t=1789521101; bh=3ZSg2A9Jc3tPW66xvM7m3+dRrVCDgCi9cK4YxnfVb38=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=hnodkwuXLSWfi6qopViNWmJ1DPlBw5Qh3eySg1tCSS2QD436Qt0nPX6UFExBzVDyC
	 7SyGGcsWnxzv7hOn9TLSBnJ4ro6jptALPeAa4mABB02U8A8kyDVYgQcRGWluq/fx/T
	 EMGtgYR0BJRN0noLxTL7Cqn0kUZN/e7hpblUXONwx5NZPJTHRigWmkF7fbX5MiTlCA
	 Ug3X16M/GCzJ2EvHdJ5Au6IDIT+Teyvf2UrAOoXUtxWbGbeGeSpEE7gTOLS6aVWh3O
	 QVHdu8R2pS0Kic8RVQoKePhKFLfyptiUBo3kdERUO2eAyR7oGf6dcBxiUoTp1pRM8k
	 m/r9x41iu9V1E1kuNZgnm55bT9n6FqBusi5N/v4THEAMC+1O/CgmoqbgmjA7wOtzc6
	 W7ZqppfDVVsuffyZT3M74O0p3N7ChLh7uahpi/aocg/EFvFx64JaafjbILfpcHrftc
	 VeSWvKyuAw8fZobdLPp2FioEpzYkD4+kshFyvw+tvXaJdvVomypIlYIV9a17prjpSB
	 JHHcRnkltsxttm2SQz3HffWQnaJXpVgSEO454rAL+eZ3iP64nohKluW8bKWtFst3Yl
	 /vVNOphRdFEgFwxGUoFDnKGfTct3/OisLyDq0AYpAEsYHVrTzhg/UGC8HQSC4ByBBB
	 u7UrMRdF4GDpZnl/0v0mduZE=
Received: from stx.tnic (unknown [IPv6:2600:1700:38ca:c00::e])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature ECDSA (P-256) server-digest SHA256)
	(No client certificate requested)
	by mail.alien8.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id D932740E00B9;
	Wed, 16 Sep 2026 01:09:49 +0000 (UTC)
Date: Tue, 15 Sep 2026 18:09:45 -0700
From: Borislav Petkov <bp@alien8.de>
To: Kees Cook <kees@kernel.org>
Cc: Bill Wendling <morbo@google.com>, linux-kernel@vger.kernel.org,
	codemender-patching+linux@google.com,
	Russell King <linux@armlinux.org.uk>,
	Huacai Chen <chenhuacai@kernel.org>,
	WANG Xuerui <kernel@xen0n.name>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	"James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>,
	Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>, Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	Tony Luck <tony.luck@intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <mripard@kernel.org>,
	Thomas Zimmermann <tzimmermann@suse.de>,
	David Airlie <airlied@gmail.com>, Simona Vetter <simona@ffwll.ch>,
	Matthew Brost <matthew.brost@intel.com>,
	Thomas =?utf-8?Q?Hellstr=C3=B6m?= <thomas.hellstrom@linux.intel.com>,
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
	=?utf-8?Q?C=C3=A1ssio?= Gabriel <cassiogabrielcontato@gmail.com>,
	Rong Zhang <i@rong.moe>, Arun Raghavan <arunr@valvesoftware.com>,
	linux-arm-kernel@lists.infradead.org, loongarch@lists.linux.dev,
	linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-edac@vger.kernel.org, dri-devel@lists.freedesktop.org,
	intel-xe@lists.freedesktop.org, linux-input@vger.kernel.org,
	linux-media@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	brcm80211@lists.linux.dev, brcm80211-dev-list.pdl@broadcom.com,
	devicetree@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	linux-gpio@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-nfs@vger.kernel.org, devel@lists.orangefs.org,
	linux-hardening@vger.kernel.org, linux-sound@vger.kernel.org
Subject: Re: [PATCH 25/28] EDAC/thunderx: Replace strlcat() with seq_buf
Message-ID: <20260916010945.GEaqnsWSZ-DTMyTO25@fat_crate.local>
References: <20260915081910.4142719-1-morbo@google.com>
 <20260915081910.4142719-26-morbo@google.com>
 <202609151258.5FC01072@keescook>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <202609151258.5FC01072@keescook>

On Tue, Sep 15, 2026 at 01:00:00PM -0700, Kees Cook wrote:
> Seems like seq_buf would be better her? But yes, at the very least, this
> needs to be scnprintf, not snprintf (or add the checks as you have
> here).
> 
> The rest of the seq_buf conversions look right.

This driver has been an orphan for a while now (we just made it official) so
I'd prefer it if we don't do anything here.

And yes, that mega CC list is just gross.

-- 
Regards/Gruss,
    Boris.

https://people.kernel.org/tglx/notes-about-netiquette
