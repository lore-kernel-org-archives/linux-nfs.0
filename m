Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793823133;
	b=dsDtIQNIfGQtJzqSVlSzjHl59wjU57Czi/+EAyCbMH4zSgodA38eiiROBgiQdD4eT4D0
	 izYBZv1ToR8X4VRvPlYy0aUZQICIePXHp/BEXZs2UYkQfhf1WO2C8eWwSGoOK0XzwYI+/
	 C8RKyB2vVLaH5/iHCv6XbDfbMgvZjPWve0A16jl52pp8vDxIxpnUE+SdqbWgDPnaE6w2z
	 hjS0FxzY3dmOKwYIIKDwNFqtuBLlH6cDKyndDj1f3V2qH9yyjbGDeqZW7ekswCN0QaCvy
	 vo46MrY36AgvM6CsHxhYP5D6VmSQzt1Xs9txwiVc3ODBB2wqrXCddNwZ4lCeXAiHvaA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793823133;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Received:X-Forwarded-Encrypted:X-Received:MIME-Version:References:
	 In-Reply-To:From:Date:X-Gmail-Original-Message-ID:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type;
	bh=LCqiLHf1DIbfKNXx3ccWkvqxBhOdwo3yYkazQxIGarg=;
	b=5fRONpy8+3lLG73us5QqJVnDYkgYn/Z6S7Ha+lCcXNJ7wfXwVkhDlSvwBIZ6oPgnEOO2
	 7CBtBGJBM3ykSSEdaxXw5iOlkdRf6P6BssgOnTLQp4XSiWI6rhXgcD47zcAxYCUlF/75p
	 04a9f4HfyTwkBGNpL0z/yyx2N0d9XGtszS7G/SgOWbsdVQvKLZ71QlWfcZp7owI1TwYdg
	 yolt4FmGSD9ZCOPc1mRm6FaoGxvVybNJiToYwM3cIXVRx7j+sPxDqJ5sdHgHdJXq7BrOo
	 jBlwHFYbSzXe6FzdoxmdIY3hAP7wCY5SKWVZAVtDr8B5plWKMUIiRoIM66NdMHNb30w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=linux-foundation.org;
	spf=pass smtp.mailfrom=linuxfoundation.org;
	dkim=pass header.d=linux-foundation.org header.i=@linux-foundation.org header.a=rsa-sha256 header.s=google header.b=IzCCgcHN;
	arc=none smtp.remote-ip=209.85.218.47
Received: from mail-ej1-f47.google.com (mail-ej1-f47.google.com [209.85.218.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B61A8607E91D
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 20:12:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B61A8607E91D
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linuxfoundation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux-foundation.org header.i=@linux-foundation.org header.a=rsa-sha256 header.s=google header.b=IzCCgcHN
Received: by mail-ej1-f47.google.com with SMTP id a640c23a62f3a-c4550d8ab15so176931666b.2
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2026 12:12:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1793823131; x=1794427931; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=LCqiLHf1DIbfKNXx3ccWkvqxBhOdwo3yYkazQxIGarg=;
        b=IzCCgcHNOb90cC+5Q+ouCET2Ny/4OiV7kgTbqK9AwEzkljILe+XDlcUbDFGh8BPDe+
         7DVkvl6I5YUFCiMEdEVe6c/azmspFcH1SeG4bgZWXvdkJA9vLnXvq7u3Ev4AZ3VL0QTx
         O1eeIB6aKuVi570PnFB99wRsvvZFGcbpvON0Y=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793823131; x=1794427931;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=LCqiLHf1DIbfKNXx3ccWkvqxBhOdwo3yYkazQxIGarg=;
        b=raiNPGRTEjR/OkStcoSkf0MRPPWFH60dPfusawysvwG8+w/gMOp8l3lN0c35tTAyRE
         KfreohYL9mi9rTTCLy1ajxPadi8MAMYdGJ6UWxPMOVjieRcb07/5lhyQvd1MziWqyx01
         c2u+vd/S9E6FoQSB5oyTr2uyAvr3GuVscYZI+ImO30iicdFnbppQDlvJhgPoClvZwcts
         4aJoZh/N234yEmLk7Xm0pImN/a7tenUC14ZQIunvOqzCzwfo/0/h1ODOcjH32+0qmC6s
         cLC3RdziVG2W4w5dJGwbRY0heqmiSC3RH6StzwtFhnh/b6hJGk2FP5no3MgKzQsUFRbP
         1doA==
X-Forwarded-Encrypted: i=1; AKwUvBzVOWHnZbt/cfwHYqXCzFHtZjxyGxfxyI0ramDTNokjOb0ZOYerspWAsSK0KxLO7gKCUw6mKaVEjss=@vger.kernel.org
X-Gm-Message-State: APuU4Z91sepw90+hTMc5YldOUhq7MTju/AKn4LevJjZPW8zd6ysQY/Pq
	KOjYTdf4IIq2ItwvLkT/XddXGXFbtdqHznM1hhFdiUoCrvMFCRc3ZSAjl/OLEdmrS9wzOtFlYG6
	vyU1zrt8acQ==
X-Gm-Gg: AYBFou186IWyxpBxHp/Pr7Q8GfoSWs+S3VnbNqOkRGZ2piroBKwbHm8MM1Vya4CtEdF
	5RZsMNj12hVaGrlAyqq7vlsuZDTxqJldYlw1c+Y74dQ4nhUPnvz4mCG4dnf86sDqJJj1FP9QgBU
	IzuHloQdqnaewX9zZeJYInzV0lkfSLCloEAswDY6TmYV5PohH9EL1/QbSs6f/W8U6avpIZfLsIt
	m3UWV7CbSHoEAOT8J9emtC4kgp/+gtXtDDwcu2p2RdVtpdlXFJRB/XTiq+5zBOokk3TyOw9ZdSS
	GaAf7n2OJ91MNEEqEiCvnsjkLTVVxreUX/imDm1P0J4VeyKhMd3e6KFyyE6de6sgdBXDSifH+Tk
	9aOqxp4yWlr6Sh11vcxtPZks/G1HVnIWbzhSm8laYg4irN+GNYvoj0OMSEToKhUWoAc7FryawgQ
	0KDXCK1EViQA/v4Ejmu2J645fqDcu4UN5qSBeElNFZ715E/v+LHBSo6LqTyRc/qLwl8bym0OMgn
	Vf4rntmAEzHKurYYwn8OVGL/UUu6/3UBF1bYXrxo3bP4AQIoyC0TX9bheHiYNsAsDgSn+rJkPjR
	C/ZTvAbNs7+zwb49oL1ODU8u2xF9/I7pUqUVD7UAR0mcJf2J4QtawEyRed86oMnkIizd7dnWoKW
	Nig==
X-Received: by 2002:a17:906:7315:b0:c2e:2944:d6cb with SMTP id a640c23a62f3a-c4ca7a54a6cmr1546745166b.13.1793823131111;
        Wed, 04 Nov 2026 12:12:11 -0800 (PST)
Received: from mail-ej1-f41.google.com (mail-ej1-f41.google.com. [209.85.218.41])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c4d0e466175sm105158866b.47.2026.11.04.12.12.10
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 04 Nov 2026 12:12:10 -0800 (PST)
Received: by mail-ej1-f41.google.com with SMTP id a640c23a62f3a-c445c95d553so164920866b.1
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2026 12:12:10 -0800 (PST)
X-Forwarded-Encrypted: i=1; AKwUvByI/6HCr9xoDEWUqULBgu3HYFF+aGjP2sYjFG4wpht7VYwtTUADjavzpNhnX2A6CI1KrTvcPT3PtQE=@vger.kernel.org
X-Received: by 2002:a17:907:60c8:b0:c49:a4b1:9cb1 with SMTP id
 a640c23a62f3a-c4ca795fa50mr1973235866b.3.1793822725121; Wed, 04 Nov 2026
 12:05:25 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261104-work-procfs-v2-0-b45cd5789ac5@brauner> <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
In-Reply-To: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 4 Nov 2026 12:05:08 -0800
X-Gmail-Original-Message-ID: <CAHk-=wj9Y9NcOesBBm+jhPjYa7qO00fD7g7uwX+H-k0-R2difA@mail.gmail.com>
X-Gm-Features: AclHuK9j_YIgrwhhpWOlnull6heAULBd4dgTqoOhUQQjFm_MgoIgrL1vgPfefvI
Message-ID: <CAHk-=wj9Y9NcOesBBm+jhPjYa7qO00fD7g7uwX+H-k0-R2difA@mail.gmail.com>
Subject: Re: [PATCH RESEND v2 00/30] proc: convert the fs, kernel and mm
 entries (Part 5/7)
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>, 
	Josef Bacik <josef@toxicpanda.com>, Chris Mason <mason@kernel.org>, 
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

On Wed, 4 Nov 2026 at 11:49, Christian Brauner <brauner@kernel.org> wrote:
>
> Part 5/7 of "proc: move procfs to what kernfs does", on top of part 2

Christian - way too many patches, re-sent much too often, cc'd to way
too many people.

Nobody is going to read these repeated resends, and all you are doing
is clogging up peoples mailboxes.

             Linus
