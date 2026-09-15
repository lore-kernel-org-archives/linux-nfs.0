Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96E5C48664C;
	Tue, 15 Sep 2026 11:25:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789471504; cv=none; b=STGE8GD4DedD5zzjQFk2bkH1v7G1eMWb5BKqc4CHXREWMFvK+KsElNKFmWFJ5WMAZsQhfyyCWuQz+ksFFsgnMrtNpB/sVoJhIi3zNKWdRMTKZQ3yXrZ1bQzcClqVrzKd9o8ESHAwU6JfwyNoJduWQWoVSjkxCtMHtCuykEeFTcA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789471504; c=relaxed/simple;
	bh=0ve7/DDdcigv05770gqszO21YREHojJv3JBfh9LpjKU=;
	h=Date:Message-ID:From:To:Cc:Subject:In-Reply-To:References:
	 MIME-Version:Content-Type; b=tISN/hfHhCg3v3MWi4PlDWGqnB+oJ9mSEsnYKbwFImBSVsmnv973OqC1Hfz3gLTGUX5eZdBJgud+4QWHNz2h72nFvuNQpbVBd9Qbp3B/ZxGQmLs4n2USXnoqW9VhBEV2wdn6tYnZYoz2vkxj0aWFGit8iO+LvnR+CQdReDRSIAY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=FSRxqY26; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=aSsl2yJ1; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=HmFYlpnJ; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=FquzOGo+; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="FSRxqY26";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="aSsl2yJ1";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="HmFYlpnJ";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="FquzOGo+"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 20F5421B02;
	Tue, 15 Sep 2026 11:24:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1789471494; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=psqF+EOKBnDir7oSpdYk0cv/7bWaGxT8GNrr5rPj7yg=;
	b=FSRxqY266D0vmKnF9nLIRDyWWQM9yhSRf7SWuTSbWdHKmTZfPMBWgLsJq7H8V56FVkky//
	8MrE9PciUwBdoFcR4M6TLhf0Be1H7UyuT3X6eiMNzlMbbIthbvGQDSnAd0oqm56+IjjTWt
	ZfmEPFx5zXWF3FpvnKWoZi5XGYuzP5E=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1789471494;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=psqF+EOKBnDir7oSpdYk0cv/7bWaGxT8GNrr5rPj7yg=;
	b=aSsl2yJ1+boxtQdbyNVNOLHSB2zJu6wAGQi+9pbebbTp2ClXENyw6idF+ycsnZ57BL4LP5
	ZfcRP6lnX00QOOBw==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.de header.s=susede2_rsa header.b=HmFYlpnJ;
	dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=FquzOGo+
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1789471490; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=psqF+EOKBnDir7oSpdYk0cv/7bWaGxT8GNrr5rPj7yg=;
	b=HmFYlpnJHQnucD0Hu7XWebQts4zdFxqB6Md4UgWWqagCStl48Xajm8kE50YWip9K8RYGR6
	TjQMT6l+/cnv1Hphpj6UBRi2hgiye5AdRmKJllzK4WS/Qo3IlkmtIW20gkJR+AFYnIbRJu
	qg1C7c30pv8I0/77mryKUVsgaauSbcU=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1789471490;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=psqF+EOKBnDir7oSpdYk0cv/7bWaGxT8GNrr5rPj7yg=;
	b=FquzOGo+tVlEMPCfctD8o5e/sCS7xihfao4/ZdIf2qlfM3ZVtlvjjsESrStMfdFOYRkvvC
	9nOkOMjZr8TKGZBg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id E1B7713693;
	Tue, 15 Sep 2026 11:24:46 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 2riGLf4qqWqtagAAD6G6ig
	(envelope-from <tiwai@suse.de>); Tue, 15 Sep 2026 11:24:46 +0000
Date: Tue, 15 Sep 2026 13:24:46 +0200
Message-ID: <877bkmn4e9.wl-tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: Bill Wendling <morbo@google.com>
Cc: linux-kernel@vger.kernel.org,	Russell King <linux@armlinux.org.uk>,
	Huacai Chen <chenhuacai@kernel.org>,	WANG Xuerui <kernel@xen0n.name>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,	"James E.J. Bottomley"
 <James.Bottomley@HansenPartnership.com>,	Helge Deller <deller@gmx.de>,
	Thomas Gleixner <tglx@kernel.org>,	Ingo Molnar <mingo@redhat.com>,	Borislav
 Petkov <bp@alien8.de>,	Dave Hansen <dave.hansen@linux.intel.com>,
	x86@kernel.org,	"H. Peter Anvin" <hpa@zytor.com>,	Ian Abbott
 <abbotti@mev.co.uk>,	H Hartley Sweeten <hsweeten@visionengravers.com>,	Tony
 Luck <tony.luck@intel.com>,	Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>,	Maxime Ripard <mripard@kernel.org>,
	Thomas Zimmermann <tzimmermann@suse.de>,	David Airlie <airlied@gmail.com>,
	Simona Vetter <simona@ffwll.ch>,	Matthew Brost <matthew.brost@intel.com>,
	=?ISO-8859-1?Q?=22Thomas_Hellstr=F6m=22?=
 <thomas.hellstrom@linux.intel.com>,	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,	Matthias Schwarzott
 <zzam@gentoo.org>,	Mauro Carvalho Chehab <mchehab@kernel.org>,	Tony Nguyen
 <anthony.l.nguyen@intel.com>,	Przemek Kitszel
 <przemyslaw.kitszel@intel.com>,	Andrew Lunn <andrew+netdev@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,	Eric Dumazet
 <edumazet@google.com>,	Jakub Kicinski <kuba@kernel.org>,	Paolo Abeni
 <pabeni@redhat.com>,	Arend van Spriel <arend.vanspriel@broadcom.com>,	Rob
 Herring <robh@kernel.org>,	Saravana Kannan <saravanak@kernel.org>,
	Krzysztof Kozlowski <krzk@kernel.org>,	Sylwester Nawrocki
 <s.nawrocki@samsung.com>,	Peter Griffin <peter.griffin@linaro.org>,	Alim
 Akhtar <alim.akhtar@samsung.com>,	Linus Walleij <linusw@kernel.org>,	Anil
 Gurumurthy <anil.gurumurthy@qlogic.com>,	Sudarsana Kalluru
 <sudarsana.kalluru@qlogic.com>,	"Martin K. Petersen" <mkp@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,	Anna Schumaker <anna@kernel.org>,
	Mike Marshall <hubcap@omnibond.com>,	Martin Brandenburg
 <martin@omnibond.com>,	Kees Cook <kees@kernel.org>,	Jiri Pirko
 <jiri@resnulli.us>,	Simon Horman <horms@kernel.org>,	Chuck Lever
 <cel@kernel.org>,	Jeff Layton <jlayton@kernel.org>,	NeilBrown
 <neil@brown.name>,	Olga Kornievskaia <okorniev@redhat.com>,	Dai Ngo
 <Dai.Ngo@oracle.com>,	Tom Talpey <tom@talpey.com>,	Jaroslav Kysela
 <perex@perex.cz>,	Takashi Iwai <tiwai@suse.com>,	Andrew Morton
 <akpm@linux-foundation.org>,	"Mike Rapoport (Microsoft)" <rppt@kernel.org>,
	Kanglong Wang <wangkanglong@loongson.cn>,	Tiezhu Yang
 <yangtiezhu@loongson.cn>,	Qiang Ma <maqianga@uniontech.com>,	Randy Dunlap
 <rdunlap@infradead.org>,	Pengpeng Hou <pengpeng@iscas.ac.cn>,	Ard
 Biesheuvel <ardb@kernel.org>,	Breno Leitao <leitao@debian.org>,	Thorsten
 Blum <blum@kernel.org>,	Harshit Mogalapalli
 <harshit.m.mogalapalli@oracle.com>,	Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>,	Lyude Paul <lyude@redhat.com>,	Ashutosh Desai
 <ashutoshdesai993@gmail.com>,	Imre Deak <imre.deak@intel.com>,	Dmitry
 Baryshkov <dmitry.baryshkov@oss.qualcomm.com>,	Johan Hovold
 <johan@kernel.org>,	Johannes Berg <johannes.berg@intel.com>,	Miri Korenblit
 <miriam.rachel.korenblit@intel.com>,	Alexander Stein
 <alexander.stein@ew.tq-group.com>,	Cryolitia PukNgae
 <cryolitia@uniontech.com>,	Jiaming Zhang <r772577952@gmail.com>,	Will
 Porter <mrwillporter@gmail.com>,	Cen Zhang <zzzccc427@gmail.com>,
	=?ISO-8859-1?Q?=22C=E1ssio_Gabriel=22?= <cassiogabrielcontato@gmail.com>,
	Rong Zhang <i@rong.moe>,	Arun Raghavan <arunr@valvesoftware.com>,
	linux-arm-kernel@lists.infradead.org,	loongarch@lists.linux.dev,
	linux-mips@vger.kernel.org,	linux-parisc@vger.kernel.org,
	linux-edac@vger.kernel.org,	dri-devel@lists.freedesktop.org,
	intel-xe@lists.freedesktop.org,	linux-input@vger.kernel.org,
	linux-media@vger.kernel.org,	intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org,	linux-wireless@vger.kernel.org,
	brcm80211@lists.linux.dev,	brcm80211-dev-list.pdl@broadcom.com,
	devicetree@vger.kernel.org,	linux-samsung-soc@vger.kernel.org,
	linux-gpio@vger.kernel.org,	linux-scsi@vger.kernel.org,
	linux-nfs@vger.kernel.org,	devel@lists.orangefs.org,
	linux-hardening@vger.kernel.org,	linux-sound@vger.kernel.org
Subject: Re: [PATCH 00/28] Replace remaining strlcat() call sites with snprintf()/seq_buf()
In-Reply-To: <20260915081910.4142719-1-morbo@google.com>
References: <20260915081910.4142719-1-morbo@google.com>
User-Agent: Wanderlust/2.15.9 (Almost Unreal) Emacs/30.2 Mule/6.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0 (generated by SEMI-EPG 1.14.7 - "Harue")
Content-Type: text/plain; charset=US-ASCII
X-Spam-Level: 
X-Rspamd-Action: no action
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Queue-Id: 20F5421B02
X-Spamd-Result: default: False [-2.01 / 50.00];
	BAYES_HAM(-3.00)[99.99%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_CONTAINS_FROM(1.00)[];
	R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	FROM_HAS_DN(0.00)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	FREEMAIL_CC(0.00)[vger.kernel.org,armlinux.org.uk,kernel.org,xen0n.name,alpha.franken.de,HansenPartnership.com,gmx.de,redhat.com,alien8.de,linux.intel.com,zytor.com,mev.co.uk,visionengravers.com,intel.com,suse.de,gmail.com,ffwll.ch,gentoo.org,lunn.ch,davemloft.net,google.com,broadcom.com,samsung.com,linaro.org,qlogic.com,omnibond.com,resnulli.us,brown.name,oracle.com,talpey.com,perex.cz,suse.com,linux-foundation.org,loongson.cn,uniontech.com,infradead.org,iscas.ac.cn,debian.org,linuxfoundation.org,oss.qualcomm.com,ew.tq-group.com,rong.moe,valvesoftware.com,lists.infradead.org,lists.linux.dev,lists.freedesktop.org,lists.osuosl.org,lists.orangefs.org];
	DKIM_TRACE(0.00)[suse.de:+];
	TO_DN_SOME(0.00)[];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:106:10:150:64:167:received,2a07:de40:b281:104:10:150:64:97:from];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	RCPT_COUNT_GT_50(0.00)[110];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	TAGGED_RCPT(0.00)[netdev];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:dkim,suse.de:mid,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo]
X-Spam-Flag: NO
X-Spam-Score: -2.01

On Tue, 15 Sep 2026 10:18:17 +0200,
Bill Wendling wrote:
> 
> strlcat() is deprecated: like strcat(), it requires re-scanning the
> destination string from the beginning on every call, which is O(n^2)
> when used to build up a string incrementally, and its truncation
> behavior is easy to get wrong.

... but what many of your patches do is to replace strlcat() with
open-codes, which is more error-prone and easier to get wrong than
a single strlcat() call.

> See:
> 
>   https://github.com/KSPP/linux/issues/370

It's clear that strlcat() isn't perfect and sometimes inefficient.
But blindly deprecating without providing a good alternative doesn't
sound like a right approach to me.


thanks,

Takashi
