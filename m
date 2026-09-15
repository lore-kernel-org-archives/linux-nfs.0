Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 761803DA7F8;
	Tue, 15 Sep 2026 15:05:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789484715; cv=none; b=n9cgZtmnJDObiTU3Dzaz31+a0VE8p5ZkvWNSAbO1BqKOoJRmIWji1QNFhKzdEI2MX0bJ9F/YXI3uyOZdhlfOELsxpQ5knNY/dhvubvT5UW5SBu9uY6EXcsd12KPYAIcKqFSX5y1I4It5zBqPrpVF2mzx2metov7nPf0Tsp3C8wk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789484715; c=relaxed/simple;
	bh=DAmlGFJZYAmgnOIvR39oev84RuA6yc2k24v0yU66UX8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Iv6os0/vSp83JQmPUZT3K8t+sCZv2X60CfX89bJcHxd7tH+hEYtWoG0HV/va1SvJDRZ2I+AyXHKMpAP7G/BJeqN4JAOpZN+SfcdLpV3ADIj9hW6BriMLtKaaFKvMPLPutnyRNXNBS0v0kDuSOoCng4cAiHqi+5c4xOXLqYRZLs4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gf5L5wnm; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gf5L5wnm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 609DE1F00893;
	Tue, 15 Sep 2026 15:05:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789484714;
	bh=92Jyv3r5iRKPp9A+0MWzJBMIdxeAT/qbE/UD5yjhWE0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=gf5L5wnmtccLwoqcVRv226Jxh21B1B//39SXNk9kc4N8OS1FTlhq9PWO0oO0C2lV5
	 /puLCofTcTcdOq9gexMECkzKA3ObUOxFvtdLZex77Bqia2hDmeu6n908Nd0hiX8iF9
	 qTYQDbAMbNgjSO8+cNHSBskD1SEuiooBkMWuneDZS5c3lKtRyIRRattmm2nfwDtRhi
	 /vDHelzWwxEEbNDJ6m9bDtWIf3Gi0xBkpoRi48jhIlvmxyg1p97zwYUvcCDIpP4GL2
	 89RyOdTBK97/VTtSVGn5HnnYF5QSg1YyyyGBUWH6C6xYN7eMiLrpeTG7VTkcG879bb
	 BqI5RrgGxycEw==
Date: Tue, 15 Sep 2026 10:05:11 -0500
From: Rob Herring <robh@kernel.org>
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
	Kees Cook <kees@kernel.org>, Jiri Pirko <jiri@resnulli.us>,
	Simon Horman <horms@kernel.org>, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
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
Subject: Re: [PATCH 10/28] of/fdt: Replace strlcat() with snprintf() in
 early_init_dt_scan_chosen()
Message-ID: <20260915150511.GB1926857-robh@kernel.org>
References: <20260915081910.4142719-1-morbo@google.com>
 <20260915081910.4142719-11-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260915081910.4142719-11-morbo@google.com>

On Tue, Sep 15, 2026 at 08:18:27AM +0000, Bill Wendling wrote:
> When CONFIG_CMDLINE_EXTEND is enabled, early_init_dt_scan_chosen() uses
> two strlcat() calls to append a space and CONFIG_CMDLINE to the command
> line buffer.
> 
> In preparation for removing the deprecated strlcat() API[1], replace the
> strlcat() calls with a single snprintf() call using the existing string
> length.
> 
> Additionally, check for a NULL initial_boot_params pointer and jump to
> "handle_cmdline" so that CONFIG_CMDLINE handling still occurs without
> dereferencing a NULL FDT pointer in fdt_path_offset().
> 
> Link: https://github.com/KSPP/linux/issues/370 [1]
> Cc: codemender-patching+linux@google.com
> Assisted-by: Assistant:Claude-3.5-Sonnet [editor_update_file, shell_command_run]
> Signed-off-by: Bill Wendling <morbo@google.com>
> ---

> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index a64afc3ded3d..311021a83f03 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -1095,6 +1095,9 @@ int __init early_init_dt_scan_chosen(char *cmdline)
>  	const void *rng_seed;
>  	const void *fdt = initial_boot_params;
>  
> +	if (!fdt)
> +		goto handle_cmdline;
> +
>  	node = fdt_path_offset(fdt, "/chosen");
>  	if (node < 0)
>  		node = fdt_path_offset(fdt, "/chosen@0");
> @@ -1133,8 +1136,12 @@ int __init early_init_dt_scan_chosen(char *cmdline)
>  	 */
>  #ifdef CONFIG_CMDLINE
>  #if defined(CONFIG_CMDLINE_EXTEND)
> -	strlcat(cmdline, " ", COMMAND_LINE_SIZE);
> -	strlcat(cmdline, CONFIG_CMDLINE, COMMAND_LINE_SIZE);
> +	{

No need for brackets.

> +		size_t len = strlen(cmdline);
> +
> +		if (len < COMMAND_LINE_SIZE)
> +			snprintf(cmdline + len, COMMAND_LINE_SIZE - len, " %s", CONFIG_CMDLINE);
> +	}
>  #elif defined(CONFIG_CMDLINE_FORCE)
>  	strscpy(cmdline, CONFIG_CMDLINE, COMMAND_LINE_SIZE);
>  #else
> -- 
> 2.55.0.1032.g73a4cd73de-goog
> 
