Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68305456DFD;
	Tue, 15 Sep 2026 20:00:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789502404; cv=none; b=bGrX/RexBaNbY0TNx1b8pj01XYRab3ZUekbOCuGvnlebo3HhqbkfUsbkTkQbfkFBdB7Dytorq1p87LXttqF4PySfeXJQ869AxnmDzwjJeLofzEZ7uT8c+e+5YnXM1Hof3K+eFGEKXk+U8Et/f8m+MbhJkwzpMB8SYk/Zqq0bFqY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789502404; c=relaxed/simple;
	bh=Ozqb8Nlqcx4jTJr4HzpCRa4epQHmJdVAuT7sAYodQSg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=h8BQceOegfJr5rqgsF5zv+89DQxUeabk43C2i48Tedj7+86EOj2E/POVUrGyZDf2UACoFu9/dBhkB7NbemcKPj6dAGB7Yst/ZUQFeE4MENnoZjcprAUMyPV/TKnJAv00dQg7J1RIUtzU4y5SJwNHewx9ZJ3TnuVKuq5xMAYrG8I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FdbC7ZRX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FdbC7ZRX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C5C491F00893;
	Tue, 15 Sep 2026 20:00:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789502401;
	bh=060FvzlSY1s+NjIuTsRc9Ny+zBNXkBYeefHqKI9hLNs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=FdbC7ZRX+1TiNHMrUcD7N4WRBQ/NBC44xG38qVsD4V3M/U7dzFW46zEr0Qqn4DBLh
	 81RKjIK0hX+oSanD1EeeT6znv1ZtBO/6T6T7l+OJxv5Yjxxv9BT8ktV29/rB30EWHC
	 c+RL+Of48d0+QGfwFlFJq1vhsZlRvuqgPfpC9olT9jyBc9sTGaqI9QWaWclhTAl5Hu
	 5P4bGjufQY9JEgSfSZG/wO7fQtWggHhb9+25I22lIZPV9Ncafbm0EQDnHB8Lk9OHuM
	 PQfHziufJ1UQPWbtu5g/SXxENVthrlOlzHfeF29fBmutwBTvRudzpbz+yF0NXoZn8I
	 fZ+V/V+bB/K3g==
Date: Tue, 15 Sep 2026 13:00:00 -0700
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
Subject: Re: [PATCH 25/28] EDAC/thunderx: Replace strlcat() with seq_buf
Message-ID: <202609151258.5FC01072@keescook>
References: <20260915081910.4142719-1-morbo@google.com>
 <20260915081910.4142719-26-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260915081910.4142719-26-morbo@google.com>

On Tue, Sep 15, 2026 at 08:18:42AM +0000, Bill Wendling wrote:
> index e7c335ca0c36..4e3781815b6d 100644
> --- a/drivers/edac/thunderx_edac.c
> +++ b/drivers/edac/thunderx_edac.c
> @@ -20,6 +20,7 @@
>  #include <linux/atomic.h>
>  #include <linux/bitfield.h>
>  #include <linux/circ_buf.h>
> +#include <linux/seq_buf.h>
>  
>  #include <asm/page.h>
>  
> @@ -47,12 +48,17 @@ static void decode_register(char *str, size_t size,
>  {
>  	int ret = 0;
>  
> +	if (size > 0)
> +		str[0] = '\0';
> +
>  	while (descr->type && descr->mask && descr->descr) {
>  		if (reg & descr->mask) {
>  			ret = snprintf(str, size, "\n\t%s, %s",
>  				       descr->type == ERR_CORRECTED ?
>  					 "Corrected" : "Uncorrected",
>  				       descr->descr);
> +			if (ret < 0 || ret >= size)
> +				break;
>  			str += ret;
>  			size -= ret;
>  		}

Seems like seq_buf would be better her? But yes, at the very least, this
needs to be scnprintf, not snprintf (or add the checks as you have
here).

The rest of the seq_buf conversions look right.

-- 
Kees Cook
