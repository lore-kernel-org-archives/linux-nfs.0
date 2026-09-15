Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 045FC4CA775;
	Tue, 15 Sep 2026 18:52:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789498351; cv=none; b=alcDSUINcR6GrxpLQFSP6Uaj/3gp1BpXx133odrAtc5dn49un4Lrmr9h4xByNYw43xnHPpMM6SzoL56HIK7DUBS+zTXwDXL7qsa20eO/yM4USvvLcdXK04lchJRLxGhr+R26aaI5jhlDa+i5ayzgvXLm+FTK9zF86S4k2dKiXzA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789498351; c=relaxed/simple;
	bh=Prs0G2qMbzM31E2yP359tw1C4Ebd+MCYjUJPZTIyZus=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=jg/dibIZRwVrsyCfTynz3YocUmAmsWk3l9tHn2ehBGvCN2zY+YTKR7AFGGvM9ABdqlAqKfC0kWBnHeED7jqoeMSw90Un2c2KaKgJkR3b5QQRKb5OJSofdRNevrqduFPatoPnMbII33nUDxsb6atVhzW6A6FNDand+se+mRXN8Wc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dj46Dqgm; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dj46Dqgm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DC8B51F0089A;
	Tue, 15 Sep 2026 18:52:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789498349;
	bh=72tlQhpdmngB3szUrALiHxqSz5LmQFAfQZTFPwAJsm8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=dj46DqgmsACSwFq9HJ3ISBz0v7KQClcuynuO9qvwXog58wO/ScSuYdaGZKHgXWvfQ
	 MNIiLR6/CWGcs2B0MhbCRK2aMTRY6dtK71/bGZdxyT8HaMz+gX3i3TsfrQcfD9O/2g
	 F9R5HI4ZwuLIC/dDLbKGewTrvAWtmj2/uWtbnlwRjy3UiF9zVvG3Q4LlI0NpvD8aAJ
	 DJrMkybpP4frmHg9A0BF8idW56jNNHHMO4Q37zU7dBONYMBSpnYs1SU5pr9ZdsZbOO
	 Z8bm6ke0y1pxqCSk41Eg0cXZYLGeU6SHZOeCpu7UYnxm14Kt0coiGxiIX/45p1elM6
	 JGYqDbDSmP+rQ==
Date: Tue, 15 Sep 2026 11:52:29 -0700
From: Kees Cook <kees@kernel.org>
To: Bill Wendling <morbo@google.com>, nikitash.mariiaw@gmail.com
Cc: linux-kernel@vger.kernel.org, codemender-patching+linux@google.com,
	Russell King <linux@armlinux.org.uk>,
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
Subject: Re: [PATCH 21/28] NFS: nfsroot: Refactor root_nfs_cat() to use
 snprintf()
Message-ID: <202609151147.C5B45CB@keescook>
References: <20260915081910.4142719-1-morbo@google.com>
 <20260915081910.4142719-22-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260915081910.4142719-22-morbo@google.com>

On Tue, Sep 15, 2026 at 08:18:38AM +0000, Bill Wendling wrote:
>  fs/nfs/nfsroot.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)

This collides with:
https://lore.kernel.org/all/27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com/

> +	ret = snprintf(dest + len, destlen - len, "%s%s",
> +		       (len && dest[len - 1] != ',') ? "," : "", src);

I prefer Mariia's version because this inline ternary is difficult
to read.

I was expecting to land hers soon if the NFS folks don't pipe up. It is
one of the rare cases of still being open-coded, but the strlen() usage
was pre-existing to check for the trailing comma, so it's not a clean
seq_buf() conversion candidate...

-- 
Kees Cook
