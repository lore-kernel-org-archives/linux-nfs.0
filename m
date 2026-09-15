Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05C6A41A4F5;
	Tue, 15 Sep 2026 18:25:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789496721; cv=none; b=H9z9+A46kDrNU1dmgQUGEb3e72nXTnSwbP2wJXWBwOdRSsAYSXLIFXv6tgoFqX93e+iG630YEgUW1Nt0P38B8hvWE9wXXMZhZFZESSyxhA8r+F8axzDbqxyu2BRU8ZJ3hVSMoL4R4eL2xt7SYiHTBxq3AQT1HnVY/+0maPBH8Xw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789496721; c=relaxed/simple;
	bh=rPLWglI5Wlm9mIFu4gjr7+scAMhxrET8MSmLgiSFf/8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=aaAwsf0h4WISv+4rXl0wVGkJDfXc5ZGgCXw/6m7P40gyfbMKAFFvI6nHMAgDJdztsZQO/R7137IGnCM19/fPLE7OGz250h/4w7QfsZGcVT3YBx992VYL4JiLlhCXv/Or+ZSK6F2iPoHueD3/NE1+A0VJyGMgvZ4Y3gd3YFZOgTg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=L8f94G9m; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="L8f94G9m"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 124D51F00893;
	Tue, 15 Sep 2026 18:25:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789496719;
	bh=hTpYvUrNZYIcwT2p8Kp9xxQTu0Fq/HJPfq19mi+/XYs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=L8f94G9mzSlNx9J6peH2jq3tNsTcUAybrSOzdJm5ksOR557E4eGHcMVdBvQoWXcMq
	 oYUWohx4rX6UR3J8jBc8XVQjQr+ber6bJ2vp50tNPAhHXUhxRHLXdtKpPq0X+kq2PU
	 gS7xFPkE8iTk1ZUf6F23/XNJ6TOWElkc+PU1etQ49xAX2Mcf5D6gOEjjFrhGeHYmwr
	 quZO6YQ0w3g8MteVh8aIX9AaqG/9TfYwvtfMkvsA6bgIrhU7eO551to4fm0v6bfd4/
	 BM4spkKqe45r4JjrhXiFS+HNsR69yIhfKoowbJLuXi0Q2cu8W8a4U8wu0elxPZcyTv
	 CP6MLWz/FZBtQ==
Date: Tue, 15 Sep 2026 11:25:18 -0700
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
Subject: Re: [PATCH 27/28] drm/xe/pf: Convert strlcat() to seq_buf in
 control_read()
Message-ID: <202609151115.33A35B7098@keescook>
References: <20260915081910.4142719-1-morbo@google.com>
 <20260915081910.4142719-28-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260915081910.4142719-28-morbo@google.com>

On Tue, Sep 15, 2026 at 08:18:44AM +0000, Bill Wendling wrote:
> diff --git a/drivers/gpu/drm/xe/xe_gt_sriov_pf_debugfs.c b/drivers/gpu/drm/xe/xe_gt_sriov_pf_debugfs.c
> index 0f242db775e1..5db7fc067c4d 100644
> --- a/drivers/gpu/drm/xe/xe_gt_sriov_pf_debugfs.c
> +++ b/drivers/gpu/drm/xe/xe_gt_sriov_pf_debugfs.c
> @@ -4,6 +4,7 @@
>   */
>  
>  #include <linux/debugfs.h>
> +#include <linux/seq_buf.h>
>  
>  #include <drm/drm_print.h>
>  #include <drm/drm_debugfs.h>
> @@ -663,15 +664,15 @@ static ssize_t control_write(struct file *file, const char __user *buf, size_t c
>  static ssize_t control_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
>  {
>  	char help[128];
> +	struct seq_buf s;
>  	size_t n;
>  
> -	help[0] = '\0';
> +	seq_buf_init(&s, help, sizeof(help));
>  	for (n = 0; n < ARRAY_SIZE(control_cmds); n++) {
> -		strlcat(help, control_cmds[n].cmd, sizeof(help));
> -		strlcat(help, "\n", sizeof(help));
> +		seq_buf_printf(&s, "%s\n", control_cmds[n].cmd);
>  	}

Yay seq_buf! I would tweak the 3 init stack variable lines into just
using the single DECLARE_SEQ_BUF:

DECLARE_SEQ_BUF(s, 128);

>  
> -	return simple_read_from_buffer(buf, count, ppos, help, strlen(help));
> +	return simple_read_from_buffer(buf, count, ppos, help, seq_buf_used(&s));

seq_buf_used() isn't correct in the case of full-buffer use. e.g. if
the help buffer ends up filled with 127 chars and a NUL terminator,
seq_buf_used() returns 128, but you want 127 here. Using strlen() ends up
being redundant, though. I think we need to add seq_buf_strlen() which
handles the same logic that seq_buf_str() does.

-Kees

-- 
Kees Cook
