Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B64FB4B5157;
	Tue, 15 Sep 2026 19:00:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789498821; cv=none; b=FDnaBcsFlabd+XjBfgNOIYpWDjq4fsMeJcCcRdIhS3FE9sFf3sgcUQKBMyISt/3VNFJPj7U8TcFTBm6JNFwksv4l2lHKtlVjZKI16YaJpZU1fp/S19Kw/HR2ZGY1GhHMjoWIkVCCr+koSVaE0jHp6A00snK8EFN8pwY2KDRYlis=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789498821; c=relaxed/simple;
	bh=/pxPtBDRL/rubNz3T85ru1lxCUdEgL1csnJGWfVKvsw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=GqmGZ+D+b0m16WrZ+LAU4nCNq7ZeqY8/MkYDWu7U8ZexwCzwKZMJHnBobpJLv1Y7OedjvbrLV4gt3JE5DLSw1kPRr7qVLfc/fQ1o+XSlxmD98yWl+6iUXp7iCHF8kKIPpRvIieZi+ah2VKfvPPY2DtWTTyfIVZV3L5Jv22r+pR0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=j0iSBaet; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="j0iSBaet"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 48ECC1F00893;
	Tue, 15 Sep 2026 19:00:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789498819;
	bh=bH9D6fx46WAVM8PGx4wEKkSYBjKGmw5AvziupNUvWGk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=j0iSBaetC/3YCi18xNuSeB+n+7VnOF+QOgAvJx7ktLSNyWzdoyXHzZ/YPBs5rtm+n
	 WA6gaCeYDOM7G68qSWfRsHvbbAN1voKYHzwbAYckQsRPEBWlfdZePBmdFPmQ1OMU/N
	 sUCxn5+r/cR7FN5oCIcXoHFsLztawdQ7lZ2pVlHqL5qvTKh/9Qqc0Ta8A275Irt74k
	 zf/eAGrgknulaZr5ylmpMNiuL5cL1xjelXuos4e0Xj/d9MPGQhh5E4WSCnRmy8X7rs
	 HaD3mC4eIWM8qko0PgiUDZhDxobQu7+Yi4Weeos/5iSyNoUm6TMJqr9E5mfS6sKjxo
	 y4BshIH81fNpw==
Date: Tue, 15 Sep 2026 12:00:19 -0700
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
Subject: Re: [PATCH 03/28] ARM: atags: Replace strlcat() with snprintf() for
 cmdline extend
Message-ID: <202609151155.CC22827@keescook>
References: <20260915081910.4142719-1-morbo@google.com>
 <20260915081910.4142719-4-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260915081910.4142719-4-morbo@google.com>

On Tue, Sep 15, 2026 at 08:18:20AM +0000, Bill Wendling wrote:
> --- a/arch/arm/kernel/atags_parse.c
> +++ b/arch/arm/kernel/atags_parse.c
> @@ -121,9 +121,10 @@ __tagtable(ATAG_REVISION, parse_tag_revision);
>  static int __init parse_tag_cmdline(const struct tag *tag)
>  {
>  #if defined(CONFIG_CMDLINE_EXTEND)
> -	strlcat(default_command_line, " ", COMMAND_LINE_SIZE);
> -	strlcat(default_command_line, tag->u.cmdline.cmdline,
> -		COMMAND_LINE_SIZE);
> +	size_t len = strlen(default_command_line);
> +
> +	snprintf(default_command_line + len, COMMAND_LINE_SIZE - len,
> +		 " %s", tag->u.cmdline.cmdline);
>  #elif defined(CONFIG_CMDLINE_FORCE)
>  	pr_warn("Ignoring tag cmdline (using the default kernel command line)\n");
>  #else

It's pretty clear we have a pattern of "simple append" that is needed,
and while strlcat() does that, it's horrible. I feel like we need an
appending scnprintf(), and it needs to return like strscpy() does (i.e.
-E2BIG on truncation).

My goal would be:

- don't open-code string length math
- never leave the destination unterminated
- allow for format strings
- yes/no return indication for "did this truncate?"

Initializing a whole seq_buf struct for these small cases is too much
overhead...

For both cases (small without seq_buf, large with seq_buf), it is also
frequently needed to know the resulting strlen. seq_buf doesn't do this
right today, and a strscpy-style return value also doesn't tell us. :(

-- 
Kees Cook
