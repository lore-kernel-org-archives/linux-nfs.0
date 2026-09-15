Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A40E4C0402;
	Tue, 15 Sep 2026 18:39:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789497578; cv=none; b=ZSo2N/Px8h9PJHPSksLBT1WNksharmCQrODCCUJqMiIiBAvqLAvpec7ML/GUal7GPpXZ8bEwc7vtutGWj/8TArt913vYSb003kJRHRiMTUfkYh9b7f6DOMNaGGx1uNIaGzbAQTYWqLmOYnNbV2iZextnkKNuvc1clcTG/UTtbUA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789497578; c=relaxed/simple;
	bh=fqNgNFoBnVpjdChn8APMESaJQLsxtky82BWgen0Gj/g=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=RF/O7VZDROr9ZUzflp51il0JmTEc9bXArRHsODGwwRSgmlK4PxnNe0oc6W4/sEJ23fXQJ4XqozwmYuiscW4wBLvQCc1tW43cK8y9eVAOntxbyCOLD1eKUvVKZVXccdRKLtlbV0eWf7qqU64uGansZKTceRef+lPggKwYlKm2w34=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iOL9B39Y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iOL9B39Y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 103FE1F0089B;
	Tue, 15 Sep 2026 18:39:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789497575;
	bh=GJPdbx3D50uXJoO9DA6FVACvDwK6YiddMGPdvjxQNDI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=iOL9B39YLpHi8j/xTA9excdhrKO592Vs8pzjMn2WO6qs93YmBgp8kN456Jg5lMCy6
	 XJQGOVecXRri/3bcjHRJ3V1TxEOLZnGLdxEXkLCo61bSiTSWlhwLyfpSdI0g6XHGN0
	 zfnbSiswF6ZzNw024O4YR4IzccqeFVoDS+eKWav2JzrUR3XY+RCD/1Z1ycqZximCTE
	 FGEgiuUWvhoS17iVeOKscTJDytdCI3y1YEfkgwLeB5MYcxUTTV2RL6qSmZ8QgffJ33
	 paW7DU7d8WC2zDUgoqcOdITAZn2TffzdgN/2BZFlDYJ2xE6SZwoaQlfH4TZExND7F7
	 8sLdcjP8y9Ayw==
Date: Tue, 15 Sep 2026 11:39:34 -0700
From: Kees Cook <kees@kernel.org>
To: Bill Wendling <morbo@google.com>
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
Subject: Re: [PATCH 01/28] ALSA: ac97: Refactor snd_ac97_get_name() to use
 snprintf()
Message-ID: <202609151134.361FEA04@keescook>
References: <20260915081910.4142719-1-morbo@google.com>
 <20260915081910.4142719-2-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260915081910.4142719-2-morbo@google.com>

On Tue, Sep 15, 2026 at 08:18:18AM +0000, Bill Wendling wrote:
> --- a/sound/pci/ac97/ac97_codec.c
> +++ b/sound/pci/ac97/ac97_codec.c
> @@ -1850,10 +1850,12 @@ void snd_ac97_get_name(struct snd_ac97 *ac97, unsigned int id, char *name,
>  
>  	pid = look_for_codec_id(snd_ac97_codec_ids, id);
>  	if (pid) {
> -		strlcat(name, " ", maxlen);
> -		strlcat(name, pid->name, maxlen);
> +		int l = strlen(name);
> +
>  		if (pid->mask != 0xffffffff)
> -			sprintf(name + strlen(name), " rev %u", id & ~pid->mask);
> +			snprintf(name + l, maxlen - l, " %s rev %u", pid->name, id & ~pid->mask);
> +		else
> +			snprintf(name + l, maxlen - l, " %s", pid->name);
>  		if (ac97 && pid->patch) {
>  			if ((modem && (pid->flags & AC97_MODEM_PATCH)) ||
>  			    (! modem && ! (pid->flags & AC97_MODEM_PATCH)))
> @@ -1861,6 +1863,7 @@ void snd_ac97_get_name(struct snd_ac97 *ac97, unsigned int id, char *name,
>  		}
>  	} else {
>  		int l = strlen(name);
> +
>  		snprintf(name + l, maxlen - l, " id %x", id & 0xff);
>  	}
>  }

I'd rather not open-code the length math here. Can't we use seq_buf()
instead?

-- 
Kees Cook
