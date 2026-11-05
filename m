Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.222.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793872531;
	b=18VnatnCsaGNuk/TpeVvfekN7Qh7nIVvCftmn9el2f96I0FR/l6kWu59fh6jMrTtTZYZ
	 P5mtFXsgJJ9l8kGB5JWtfoUtDpUhSaLfdI80FuuAPcn8DyHqZj1MHWPKJ39J97HI6H3uL
	 lcGzGOervxnfQWVM6TIB/3NuazmCL2NcYG93us4UiukS92R9kDInkTeydlvZ8CKLdKP3V
	 l9IjrVln3yYWvALlaRd/oMHi1lHVijtUcAb/s7UJ4P7VKBwBkQw0nJ26uwaBxnbQ0aSBd
	 3iRmHivUxMrzpB91CNH5RKsj1Mn7L90HgRjnJP8/qskUrmsM9rXj7hRAxtcvLYU6QSw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793872531;
	h=DMARC-Filter:Received:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Received:
	 X-Forwarded-Encrypted:X-Received:MIME-Version:References:In-Reply-To:
	 From:Date:X-Gmail-Original-Message-ID:X-Gm-Features:Message-ID:
	 Subject:To:Cc:Content-Type;
	bh=LrgDMUrSYXpYgkAhfsYKg0ebb/uLgOfOMhqzX4yL0j4=;
	b=n2wF8Js91cNnFi9ZWow0tuhHx7MOQTXxxRaUYzGm+lBBNpoLA6wp7TXVpUHGruNlcFyt
	 N2KANHTTC9lRzsjztLkF0ZVWElVK12HGgsndafBPV0rVywweObnyCfUr8PoHOWBuBTywd
	 AZ8O1dzZFFj1/0IiwoYwdBWUIAdCrzzANlRYTYVEBaOQ012dmUUA39eWPZNRpuaFbm/C/
	 Obf4JwStWhf6dW4sqw6TBJh//x++aeWqowkFnTpTjrQXsQMCI/XBMG1lKyeBQm7q3zUqo
	 /g/F8Tk4MLOBV9LgehJR9rCRUwvFZb8UZ6QaedVhLJKiDXIIzjg5sCB867UE1pzqfaA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=linux-m68k.org;
	spf=pass smtp.mailfrom=gmail.com;
	arc=none smtp.remote-ip=209.85.222.49
Received: from mail-ua1-f49.google.com (mail-ua1-f49.google.com [209.85.222.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60974606A339
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 09:55:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 60974606A339
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-ua1-f49.google.com with SMTP id a1e0cc1a2514c-9906870a9baso789608241.0
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2026 01:55:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793872530; x=1794477330;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=LrgDMUrSYXpYgkAhfsYKg0ebb/uLgOfOMhqzX4yL0j4=;
        b=WAiwqvztv3d8tEgovbDGsYjCT970gPLJF0ATOCnXpF+tbpl2pLNJvGUniGKlLxn8oW
         ZjOcv9fjkz5cam0ZRC8YxsGj4lAQxADcXEFejNNIswE2jqTY+mllC0fl6kwaRoJH1mpV
         QknE6Ml8f2Cr2QWxkz1IGG6NNEkl3xrZlN2fNCtd+y/F6UHtkwpNDgF6VZddK8JrWw14
         R2polSqqwV8N0tAuvw0h4QNx1RYQrw97N+cy/BIyO8ujfrhD079dq6ymxkpSNIy1jqA2
         G49QImseeMjj0zCwuvzHwjZMnfODLIpIGSXU9ciN4Ei7easzuToq5ZveUTdXjasq/cOs
         XAgQ==
X-Forwarded-Encrypted: i=1; AKwUvBy03ImosrflLvm8CGZr1YzD1Du4O+l/QOR0R7ze+K3bJintYyUVZER8l8TNIYTg5rMrYl61/zYtOik=@vger.kernel.org
X-Gm-Message-State: APuU4Z9rH2aEbHWwpcxdsAc9qw4bgj2nQekTLny0ZuAxPmk/yYN0/a3A
	ZyFfgcf8aq/7XFwk55va+gcUj3+mVY9E+GdOpvGL/hx8q1DmVRMb9qjY86gIkE1fGBM=
X-Gm-Gg: AYBFou2C49mrs1pfuTJtMWbafdpXrlpVUf1WCOgmN9JXWBOxozXdPrCMUVQmsCKKAys
	QQtr1dI8Ho3VP/lojXrfWwY8nW1qTKLuocJYcv4o10KZ1fIQT8JpJrVEFgUSUZmZAA4OkwGgctk
	50SzidYGhZow+zslnWgDH+NMXWxhdIbjl4Z78wClpjsdZnts/LgG0mTv85GzK7w5LDrHmBUO/Hn
	cb2eTBQsxGVGNfuwQ04yQprxsmCUMPh6tea0n/DVbXYt874zw8VBEOET8dwyW+TWw9xgna0aMLX
	QZ9KMF40ecjZSm20W9EqeXT37JB8hH+zrDleqpwUHXxe6k3JVVL4puuhE36Pd4+FQMJGX3Z+wtJ
	XfVxKAqZsPc1oa7ecRshyAHuYdpEj4cKI5ornLUe9TqeS3UpazwWAx5noUHB+cjGgGmW0F37j6u
	yno4CL4gkT0LCOYqt/eGOLv8z12u880XpaiRUxVFKZ8qndX4O4zKxX+P3FyUx0bwTpP8KA5mCLE
	QHmDzx2S1wV4du5q1/V4A89dhABAvYpUEQj5knkmcy8sSRJ/55AaCPFT3y65BzlNB+CvyEM3FKC
	Y4ABBL0AZw35Ce4ZO9tEPc1/qrA/knkkT1r8F9fkA9jcnUziAojMXYJU20IVNW22rw==
X-Received: by 2002:a05:6102:4191:b0:7cb:fd69:4155 with SMTP id ada2fe7eead31-7d0728b1448mr9228926137.5.1793872530258;
        Thu, 05 Nov 2026 01:55:30 -0800 (PST)
Received: from mail-ua1-f46.google.com (mail-ua1-f46.google.com. [209.85.222.46])
        by smtp.gmail.com with ESMTPSA id ada2fe7eead31-7d26fef4ed3sm3820015137.11.2026.11.05.01.55.26
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 05 Nov 2026 01:55:29 -0800 (PST)
Received: by mail-ua1-f46.google.com with SMTP id a1e0cc1a2514c-99071945aa7so874588241.3
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2026 01:55:26 -0800 (PST)
X-Forwarded-Encrypted: i=1; AKwUvBzd7mE24DOb+j0j2q2K6jyR6y0NKOkZEIQ/N5kbhLKTjwavlDDqEOPKjYAmLe8Q2CgWl4/MBbWRjnk=@vger.kernel.org
X-Received: by 2002:a05:6102:5108:b0:7cc:56a:58e5 with SMTP id
 ada2fe7eead31-7d072d84a58mr8269567137.37.1793872526219; Thu, 05 Nov 2026
 01:55:26 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org> <20261104-work-procfs-drivers-v2-2-245e54e87116@kernel.org>
In-Reply-To: <20261104-work-procfs-drivers-v2-2-245e54e87116@kernel.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 5 Nov 2026 10:55:15 +0100
X-Gmail-Original-Message-ID: <CAMuHMdVHxQvKnJyKHrOZhaOg9Rn2hMeRU1JnMFFEEi31FPZaGg@mail.gmail.com>
X-Gm-Features: AclHuK_UsJ1nGicdWEWcMLQAICTi1A7pGF3yhNkxXkXRPqohle17eXAHHNBsR6k
Message-ID: <CAMuHMdVHxQvKnJyKHrOZhaOg9Rn2hMeRU1JnMFFEEi31FPZaGg@mail.gmail.com>
Subject: Re: [PATCH RESEND v2 02/26] zorro: let procfs copy out reads
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

On Wed, 4 Nov 2026 at 20:43, Christian Brauner <brauner@kernel.org> wrote:
> Implement ->proc_read_buf() so procfs copies what is read from
> /proc/bus/zorro/<slot> to userspace after it unpinned the entry.
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
