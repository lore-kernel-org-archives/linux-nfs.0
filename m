Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 216D643BDB0;
	Tue, 15 Sep 2026 18:30:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789497023; cv=none; b=UrbuLHUZ/DWUitNC2KlhDW+TWonkBWZFuB2UDs3s3+1mnqscNoa7FBlWmzUqxW4iYlL/WVVsD8uarFny6RJLhosVi5veBMEZK5s1O61LPjAFODZA8E1xLuZzOHQbi/2x+veueZs/6Z7zvAk5n0zEmOKrcqB0xCGBjR0g+0xhhgA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789497023; c=relaxed/simple;
	bh=pKH8xO25YwnfpC2mXfUbhQkwTcYQqjJEajFuWg/A4u8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=nQ+nuCzFOZKDcvdE/W2DtkdCK07ZQ9EOB7PXALXokMT9HzIlJBXxT/IyCvPHxHCEEiNXsM7hCCDg1Pw9IYFKz0ONc5yTNZFh/LYBT6qVQkKe7LblnsNkXqdFHd9pgXj/loAgW2Uyum8X98wS2Q9A6j3bQ7M6PiqnDWKBSnqn5Lc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FtG1AIAh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FtG1AIAh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CC7911F00893;
	Tue, 15 Sep 2026 18:30:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789497021;
	bh=zCJx1lMoPaoDeiIN5oezRLV8MqYpA3JhuUg8Z+dhoag=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=FtG1AIAh8Ifu90TvPASnvJLKq/3hHoybYyG8CBtKd2A3Tko5EoQZmhxlykHybSWCY
	 H6+cZEX9BUB3VzICpj+OZxPJ673u94nnolr9H+SDA6dBcoGGYAc9yHJcjV+Ep8BP0l
	 el5biVBlyvnMpvBBdnmFKteUXHpcuI8Bb8Pu3nE8NtDNIpu6JJu8fFsiOvrLa3Qrgq
	 NkHBRSaDsJkBM6eE9SQ++npMsQoPqmrvJCP6/7TZu7tvF19A4a5+2+kwcqpI8v/iuX
	 YN51bg9WV0sHN4tZ47tD/7Vxl/N2tA6azTTrtrat6edEQApqlwzt/pVbGgznFVhGNY
	 okL3wnYQoU9Ng==
Date: Tue, 15 Sep 2026 11:30:21 -0700
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
Subject: Re: [PATCH 28/28] drm/xe/pf: Refactor strlcat() to seq_buf in
 sched_group_engines_read()
Message-ID: <202609151126.29464A5E1@keescook>
References: <20260915081910.4142719-1-morbo@google.com>
 <20260915081910.4142719-29-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260915081910.4142719-29-morbo@google.com>

On Tue, Sep 15, 2026 at 08:18:45AM +0000, Bill Wendling wrote:
> diff --git a/drivers/gpu/drm/xe/xe_gt_sriov_pf_debugfs.c b/drivers/gpu/drm/xe/xe_gt_sriov_pf_debugfs.c

This is the same file touched as
https://lore.kernel.org/all/20260915081910.4142719-28-morbo@google.com/
and doing the same thing, roughly? I think it'd be best to combine
these, especially since one depends on the other's addition of seq_buf.h

> index 5db7fc067c4d..548a50f74422 100644
> --- a/drivers/gpu/drm/xe/xe_gt_sriov_pf_debugfs.c
> +++ b/drivers/gpu/drm/xe/xe_gt_sriov_pf_debugfs.c
> @@ -377,8 +377,10 @@ static ssize_t sched_group_engines_read(struct file *file, char __user *buf,
>  	struct xe_hw_engine *hwe;
>  	enum xe_hw_engine_id id;
>  	char engines[128];
> +	struct seq_buf s;
> +	const char *s_str;
>  
> -	engines[0] = '\0';
> +	seq_buf_init(&s, engines, sizeof(engines));

As with the others, DECLARE_SEQ_BUF should be used.

>  	if (group < num_groups) {
>  		for_each_hw_engine(hwe, gt, id) {
> @@ -386,15 +388,14 @@ static ssize_t sched_group_engines_read(struct file *file, char __user *buf,
>  			u16 guc_logical_instance = xe_hwe_guc_logical_instance(hwe);
>  			u32 mask = groups[group].engines[guc_class];
>  
> -			if (mask & BIT(guc_logical_instance)) {
> -				strlcat(engines, hwe->name, sizeof(engines));
> -				strlcat(engines, " ", sizeof(engines));
> -			}
> +			if (mask & BIT(guc_logical_instance))
> +				seq_buf_printf(&s, "%s ", hwe->name);
>  		}
> -		strlcat(engines, "\n", sizeof(engines));
> +		seq_buf_puts(&s, "\n");
>  	}
>  
> -	return simple_read_from_buffer(buf, count, ppos, engines, strlen(engines));
> +	s_str = seq_buf_str(&s);
> +	return simple_read_from_buffer(buf, count, ppos, s_str, strlen(s_str));

While this is the correct length, it does illustrate why I think we need
a new seq_buf helper to get the strlen result detected from NUL
termination like seq_buf_str().

-Kees

-- 
Kees Cook
