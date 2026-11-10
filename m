Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794273280;
	b=HAWjNYyPB9wyQmmu+Ncelyev6HkexD6nVEpvDQ6y5B0JcXtOPmErxtf2iR+3rr+FTVq6
	 BlA9nEKAj6iWVxjcPrrXiJ9o8943T+vQzwAm8wd3nLLby+mAkxwe+/xJklmLah5t4fpX4
	 j3UhhJZijHMx8xm/mRRMCKPEfsEBUTfQ23BbnaqSyuIo0+hAARauY9ToE1e2zj6zHfeqL
	 G4iJeryRBw3RDZPWZRGhgFGUKFDWl6NBFJqQuujxltiYHDnG4t6QNsZuwogxjQ8jwCdoQ
	 MWOeGASaicUWb9Z3j1/slGjUfxdsfVTaS87IkOWSkv7wVLI+VUInjhbm+1hqDpqwxnQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794273280;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Received:X-Forwarded-Encrypted:X-Received:MIME-Version:References:
	 In-Reply-To:From:Date:X-Gmail-Original-Message-ID:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type;
	bh=m2qXctBTC0OPADf0V2KkMb6r2GA0JgabIuFAMe6ERzQ=;
	b=Hmldup3Ei5h9ItY2vqrDpd5ztu28XzRPuE5vRo23Qjr7h4WTNcD2oW8Rpt2/lk8FQHbr
	 0m9DkWRtXvr8K2a6HJcOv2utBbWxWuosTyj2EZfFRymd1Dk/gxCGICi5riZUGyPUrlusK
	 do1TGQjCooG1Q1p1Uop5G3Q334E/orHSkC/XfLgANrFwhSwrFfTTyQwB3w+VTQfuWVqD4
	 pNPG7ZejYT5UpldApnD/PaBEsCWPgxhns9HArJVUYpiuby9bLu9Yb1SihjdYkwKW7vkIg
	 Hp43YEjQieNoVFwWIQt0xzs8z1w3QRkKm7EKWBYn+tdH86cWmITnp+nojm76mKOnapA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=linux-foundation.org;
	spf=pass smtp.mailfrom=linuxfoundation.org;
	dkim=pass header.d=linux-foundation.org header.i=@linux-foundation.org header.a=rsa-sha256 header.s=google header.b=c3HPZ9w3;
	arc=none smtp.remote-ip=209.85.128.44
Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CB8FB606A331
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 01:14:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CB8FB606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linuxfoundation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.a=rsa-sha256 header.s=google header.b=c3HPZ9w3
Received: by mail-wm1-f44.google.com with SMTP id 5b1f17b1804b1-4b79502c27aso15171545e9.1
        for <linux-nfs@vger.kernel.org>; Mon, 09 Nov 2026 17:14:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1794273278; x=1794878078; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=m2qXctBTC0OPADf0V2KkMb6r2GA0JgabIuFAMe6ERzQ=;
        b=c3HPZ9w3X3vdF/+J+vaP+PQYAUd2+9JOKWwj6JMce2A8a3XTTDedjlXPO55cC45zjl
         2hZf2gArAaC7b2VANcAz9siQ8hXOL0yOpee0+28IQ4U11h71kiwdUMjW00TOftz1OChD
         IA4Fb2sqqSoZR8rQ6NvDOj7SKOizFmF/BfqF0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794273278; x=1794878078;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=m2qXctBTC0OPADf0V2KkMb6r2GA0JgabIuFAMe6ERzQ=;
        b=gkfKDxWQ49H4eNCAdupnzzkdF4Wn24MSe9N0RkN8dsoGFO9uOEq2npVH8WGS91Udq9
         yIOqcYTeKdmhxBnEJDy/IWWviUCv6OKWJn66mKlcX6aDdjx/7hv51gtmTXo1LFh5Auja
         Tl9tlq+IreE+JHHOyUEHI50Q1P7L1sA6dYhizaYed4K49PBAv+l9lfVQVU9zbLYFIm9C
         H79hU6dHv+rgNRRi6epn7zu+sbSHeIcvfnPc4vFthnheA/jaC4VcCxCJcYBHA9nIaUpr
         jj4f+kbRX7gneq7h8iJf9Js/axGhuBe82tvmax1TgQ2dqzhA6M/lQfjDOcEv8C78S7wX
         HybA==
X-Forwarded-Encrypted: i=1; AL+hErEa4FIHekqJnHZgF4Jmw3p4ohK1QgVMOz3EoS2Qh0Ot9WKfdLkhP6K63996SqRL0we0ng+0ogT80js=@vger.kernel.org
X-Gm-Message-State: APuU4Z/Iuc5gt3iJCyGI9BnSOu27UbKce85rfUfanPOfzDc0pfrXKNXn
	Z6H6BwWaMl1E00fU7F05AcfRolRToc6al9VwliXNEqFsskziA2T2wjcLn72FvL+TqPI49y3X89s
	VBRu6yF0omg==
X-Gm-Gg: AYBFou1ERye5SuSs/7svimkf4X6FYo+PIG8Uw3d7G7s4JNfii4wxbdiWQf0xrIoskj6
	6ArEQzqPMA+qzSjtXw2WRETibJOcKXPqkeDGBahVx5JKlDWf0qyM2xqU3wzJPq0VlbMktxPibs+
	Att12uxS+NOgU1j2TQ01owJ95vt0MeQZ8cTbYI+ITF8jjWDgdLaVJ/jcPc/E7e81BCbDRD5HSis
	e0qLDPPUbd/RpIWx6qALUp9woNEntmwEIusSnOz1faz02q8Vb8AGauIqZ/NnqrzxPPTy8T8D/yc
	3tiqNuCzd/II18LaUaOpn4dedMLVIXidENmuQD7gDDVlHCpwzIThUanPL06373F8SPF8O4Wu0H0
	3D1ZkRMGvuAmIZUEu3q0M+xCIZNZWmiOD1O5MgqHd3OA/7CyCmnF6UbB+WX4RNtqHX24rDX5snz
	zgLM6BLq2DeOxwoaDvKa639QGh5o6IPDh1yWdxWq3Pqrm4It7Yn7xL+zSZen55E4DrZqeW8Ysq0
	RjZSQuh39RhMQ0ze9fFKVrIPCqisioRXrIDlxhsdAm+HB/OSK8oEg2BV35eifSa+2+VAv0COJvM
	d0O3+2UxpT9OCJC9bbrWXDf9rgAmiajCjuYGi40U0z1kEYMhST2WCAi+ZKN5uK7Z0AC4LfAprhb
	CpHgmIWzwPNpdIG4TRrKsZ0w=
X-Received: by 2002:a05:600c:5246:b0:49f:ce78:356d with SMTP id 5b1f17b1804b1-4ba0235612bmr14392595e9.30.1794273278283;
        Mon, 09 Nov 2026 17:14:38 -0800 (PST)
Received: from mail-ej1-f53.google.com (mail-ej1-f53.google.com. [209.85.218.53])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49895f4e6ffsm395242f8f.16.2026.11.09.17.14.36
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 09 Nov 2026 17:14:37 -0800 (PST)
Received: by mail-ej1-f53.google.com with SMTP id a640c23a62f3a-c4c9abc1824so221233566b.1
        for <linux-nfs@vger.kernel.org>; Mon, 09 Nov 2026 17:14:36 -0800 (PST)
X-Forwarded-Encrypted: i=1; AL+hErEuWKMDKmF5TQQvliVbwyhyjDiTCGMztKfCsfA8UrhvMv8QSoLrfXo7fFbVHQH8j9EUk5jDX+2uX4A=@vger.kernel.org
X-Received: by 2002:a17:907:9451:b0:c41:1750:59a2 with SMTP id
 a640c23a62f3a-c50495dfbd5mr87253466b.12.1794273275844; Mon, 09 Nov 2026
 17:14:35 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261104-work-procfs-core-v2-14-76ace653a773@kernel.org>
 <CAMuHMdVfakapgBK6TBhO1iWX8qzvLDk8jzRS=t2MVa5G=MCUeg@mail.gmail.com>
 <20261107-akteur-gemieden-eckdaten-21304d085e35@brauner> <20261108185953.28054fb3@pumpkin>
 <alpine.DEB.2.21.2611090504170.17804@angie.orcam.me.uk> <20261109214558.0d9d5228@pumpkin>
In-Reply-To: <20261109214558.0d9d5228@pumpkin>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 9 Nov 2026 17:14:19 -0800
X-Gmail-Original-Message-ID: <CAHk-=whsA3tKcUCBJDj_vmJ11rVGT9rivgnKjGRgMO21CPmCxg@mail.gmail.com>
X-Gm-Features: AclHuK-x8jcOOQUqd2amGoGEAKER9jIFGaeL4LxxWAd0cGV7dz_RR64PtDogpPU
Message-ID: <CAHk-=whsA3tKcUCBJDj_vmJ11rVGT9rivgnKjGRgMO21CPmCxg@mail.gmail.com>
Subject: Re: [PATCH RESEND v2 14/23] proc: let procfs copy in writes before
 pinning the entry
To: David Laight <david.laight.linux@gmail.com>
Cc: "Maciej W. Rozycki" <macro@orcam.me.uk>, Christian Brauner <brauner@kernel.org>, 
	Geert Uytterhoeven <geert@linux-m68k.org>, linux-fsdevel@vger.kernel.org, 
	Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, Chris Mason <mason@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Eric Dumazet <edumazet@kernel.org>, 
	Thomas Gleixner <tglx@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, 
	Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, Greg Kroah-Hartman <gregkh@suse.de>, 
	Joel Granados <joel.granados@kernel.org>, Kees Cook <kees@kernel.org>, Jan Kara <jack@suse.cz>, 
	Jan Kara <jack@suse.com>, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
	linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, 
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, ntfs3@lists.linux.dev, 
	platform-driver-x86@vger.kernel.org, coreteam@netfilter.org, 
	kexec@lists.infradead.org, linux-pci@vger.kernel.org, 
	linux-sound@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	dri-devel@lists.freedesktop.org, ibm-acpi-devel@lists.sourceforge.net, 
	jfs-discussion@lists.sourceforge.net, linux-alpha@vger.kernel.org, 
	linux-arm-kernel@lists.infradead.org, linux-cifs@vger.kernel.org, 
	linux-fbdev@vger.kernel.org, linux-hwmon@vger.kernel.org, linux-mm@kvack.org, 
	linux-sh@vger.kernel.org, linux-usb@vger.kernel.org, 
	samba-technical@lists.samba.org, sparclinux@vger.kernel.org, 
	linux-m68k@lists.linux-m68k.org, linux-doc@vger.kernel.org, 
	linux-serial@vger.kernel.org, linux-atm-general@lists.sourceforge.net, 
	Takashi Iwai <tiwai@suse.de>, linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
	linux-debuggers@vger.kernel.org, Chuck Lever <cel@kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Mon, 9 Nov 2026 at 13:46, David Laight <david.laight.linux@gmail.com> wrote:
>
> Just that the cast would have to be:
>         u8 *foo = (u8 *)bar;
> where 'bar' is 'char *', and I don't think you need a cast there when
> char is unsigned.

.. and just to clarify: 'char' is always unsigned in the kernel on all
architectures since commit 3bc753c06dd0 ("kbuild: treat char as always
unsigned") back four years ago...

            Linus
