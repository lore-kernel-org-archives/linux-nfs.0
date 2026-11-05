Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.219.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793872913;
	b=ej/BI0Dbtg+bIBV3e/ZlXC+0Ur1r2EAy7EzvMeX27AAxw980UJRf0yVPwOWsuNCb65/R
	 zEexgkHaHoRBj0XObCIBKDlOVJ6a7xJGkTumRDrf0AMDp8PIJUpiPzu5gYs6x6ATOxwWn
	 DFxodTdN/aUhJP2cSof0dDy4HHsDV+iU0V/SbfdxbZDpRMyq88Oni0dxUPV0rnIUDW4d+
	 JUzPkOurvNU+xsOMqnR4QLWKZiG2Hp/zjMicLZAsYvBgR3JSek5dYHLDRdLXDDoZZQy/O
	 0LbjOsL/vuekX8sQmXPS61vxjUd6NflD9Uj5C28P4BczqXiD/2jndnxhGu7UG8VAeaQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793872913;
	h=DMARC-Filter:Received:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Received:
	 X-Forwarded-Encrypted:X-Received:MIME-Version:References:In-Reply-To:
	 From:Date:X-Gmail-Original-Message-ID:X-Gm-Features:Message-ID:
	 Subject:To:Cc:Content-Type;
	bh=n+1lmuZTLENNkpqKh8T8PUriZ63OKZ7RGcjsYNzzAGM=;
	b=W14McEl3YYA+rTlNZZsuctuR4UTG6KcECku/YoUYHXDnz6KGppn7S0LKvA8jwndx4r9n
	 8lk03cFy76E4Li23wgO2cZkhyNh1Htsw1kRWOxaKU0D5R3FpyY/CwHtgWMY6TVqwpQDTE
	 pxgA5JoD9wp/xTkdM9yry8Mwg43ogpVmULm0Xr8cptCoxzh/qOAb4yZK/CtKrgbwkHsd4
	 78QKqv65Fb2z7KxbG1R+gltu8oico05SyD7ypatglq6HJdCp5x+/mN+XBRGA8krJqv/jy
	 YSbAltSkVyeM/hi2/hz0ebO0LskqN5rj9/24lkv+OrLmyuj/XhnG2Rr0R6p6ZQqu7gA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=linux-m68k.org;
	spf=pass smtp.mailfrom=gmail.com;
	arc=none smtp.remote-ip=209.85.219.54
Received: from mail-qv1-f54.google.com (mail-qv1-f54.google.com [209.85.219.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AE49606A326
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 10:01:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7AE49606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-qv1-f54.google.com with SMTP id 6a1803df08f44-91c79a9a739so23694876d6.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2026 02:01:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793872912; x=1794477712;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=n+1lmuZTLENNkpqKh8T8PUriZ63OKZ7RGcjsYNzzAGM=;
        b=t9RaOc21firEjPbB4K7+LIZOIFXT0CW8/IBjKLZUdQjindXbKUZkFQdO9VtkD1FWPK
         cKmf0VhWyj+Z3qGTB7rfHi3sbaL+SzJydDxF6vc/dXuYyKjy8Kj7ONXQjdbyyiFwyA/D
         ZiOqaC9wMmtltkpvYfRqw5rDMbs1/qob14T7oU3T1NpaqjsTKM+idMjszJzq9LiGXOCb
         fQ9ermP8VoqtLNhRX8G02qqx5QCOtRY0Qc4vqOIAwhFEhlNrDQmEkX/gGMFQvgZraRJD
         6HyZnvF83B+AmeLNNHnijfjJ2spTPNhwSuSUB9nDu9eaHmAf09y32v4JZpEwnV2A24s0
         60NA==
X-Forwarded-Encrypted: i=1; AKwUvBzJnuydJ1+6dliaIdzmnIseUeoNHttXhwCT04MKCfJ3wGCcUkNKQfo7ctpl5q4f/R2qFd8GlUvBl6U=@vger.kernel.org
X-Gm-Message-State: APuU4Z9kxxdOs+djf6i/5SXTylg5R324XipmtbD11wqvEtN8A3imQ6Ic
	fbEpii8WMSOH/Jf2MsohMlIxi8ikd3GSIYnmy18zabKr+wSZvvHUnFCkPFYK7AVfbAI=
X-Gm-Gg: AYBFou0qdnJyQLWT7izKIUg8BtOFj/f39CRrZnRq/+vMq9Ltr5j3xvF3b+Vl36zVfQo
	QsC6UvBiUs6cfw++pO9OpONasngjxapm/xT/nts8YMclgSIbm5DbGcRsCIut+0jSMaD1aVFzybs
	Os63nNN/hH8IOtErDh0JVbUXAKKICuEkBMY1yqWSvisVXpRjH3q20dQ6C4CoQ+EW6g8V7RA2prN
	7SnQ2JXpP/ot7sT9VUn2Sspnu1dwwmzOcs+LTN34d7UiuCa6RJZfpfTiO1Ir8VZT0Sb9oqxAnlI
	RN7r/+UoxPezv3YZjKzAlw3CIpknFLlLmPs2RTzu+/+0LlGYvekQBVNdNmcEF06/KhDY1unxNfc
	UjPh3aXkIjWKRKGZK9z5rCFnGWeub8aJ5hzIUxiyEmoButCsyy1jbTHn+eF3iM/YzeBhbw883Vk
	k1w7mN7CugRFvWVGDZAA22pG3aBSMDwOXYp1brQ3OAtZ7mR8587xhkmV0tsmWh6YXwyCJCG4xwT
	IqwG+oGET7QdEZFOxalEMm8fEUslfWZ7nt119y92vs4uujmzmKHZl9ADlGnwRQVCPhdd2s+kaVA
	GxECWWr5QFENLr+tyRQWCqsBIoRTcWJGqVrAYj0F4OvDhF7mmKDGjpHITWp7zHGp7Q==
X-Received: by 2002:a05:6214:5248:b0:91e:8cb1:b842 with SMTP id 6a1803df08f44-91e8cb1bb8fmr51416616d6.49.1793872912433;
        Thu, 05 Nov 2026 02:01:52 -0800 (PST)
Received: from mail-qv1-f48.google.com (mail-qv1-f48.google.com. [209.85.219.48])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91e7dfe9730sm43660786d6.17.2026.11.05.02.01.51
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 05 Nov 2026 02:01:52 -0800 (PST)
Received: by mail-qv1-f48.google.com with SMTP id 6a1803df08f44-91c7a0c1617so23375906d6.0
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2026 02:01:51 -0800 (PST)
X-Forwarded-Encrypted: i=1; AKwUvByitzfhg803A9QvPk3ZD0sPgA05FdqaEfDYDyl8PE2+lizgQumrD2jil94WGtGK4GcLhXgkPtHTTDs=@vger.kernel.org
X-Received: by 2002:a05:6102:6449:b0:7cb:bc5e:7dad with SMTP id
 ada2fe7eead31-7d072baa450mr7614890137.10.1793872492413; Thu, 05 Nov 2026
 01:54:52 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org> <20261104-work-procfs-arch-v2-4-2aeb952c9597@kernel.org>
In-Reply-To: <20261104-work-procfs-arch-v2-4-2aeb952c9597@kernel.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 5 Nov 2026 10:54:40 +0100
X-Gmail-Original-Message-ID: <CAMuHMdUNBs_NyhFpXonirMXkYptUWsAizMvVpGHUDLzto1LGJg@mail.gmail.com>
X-Gm-Features: AclHuK_RsrcE7hVRjmpZezBV5tMd490Mza2XAQiqUTgUNqAiHAzRP5z7NIbtMh8
Message-ID: <CAMuHMdUNBs_NyhFpXonirMXkYptUWsAizMvVpGHUDLzto1LGJg@mail.gmail.com>
Subject: Re: [PATCH RESEND v2 04/23] m68k/bootinfo: let procfs copy out reads
 of /proc/bootinfo
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, 
	Linus Torvalds <torvalds@linux-foundation.org>, Jann Horn <jannh@google.com>, 
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

On Wed, 4 Nov 2026 at 20:36, Christian Brauner <brauner@kernel.org> wrote:
> Implement ->proc_read_buf() so procfs copies what is read to userspace
> after it unpinned the entry.
>
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
