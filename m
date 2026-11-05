Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.182
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793872345;
	b=lM/d83nqPS1zvImwJ2FKb0ei23iOQk+K7lS4jWhWlDRvx3mPqKw8X337kZsda8VNHq/W
	 uUXaLq/S4CnJXJU0dysNdRdx0PvXWhVxKL78fgEV7fN3mSzhm9NJDh2c2AvsQV5fkIwv8
	 NPAf6M6ZG/qMFbK6/6s2VfY4hWzknQcXs8HoKsuUM0wmWlGrUMRlyiMxjs52jusvVcldI
	 7PQI636HOznPDAV7+fQSsEGDeI+LJHvo1Lt9vtjN275CGyDD3QNr0kssuDf3maHaN8H2P
	 AHHpuDhz93ZTFHxlHbslOxgWhtCSFOE3JqmGsGNadHIR0DRiwJaGeDOMjZGLehWYcoA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793872345;
	h=DMARC-Filter:Received:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Received:
	 X-Forwarded-Encrypted:X-Received:MIME-Version:References:In-Reply-To:
	 From:Date:X-Gmail-Original-Message-ID:X-Gm-Features:Message-ID:
	 Subject:To:Cc:Content-Type;
	bh=SqrTjgENN7Dfs+HehxbKPgACeb32UvvfMAFijNHd6N4=;
	b=Y9Rm9txgQabcnAnEKoInoeU9BRqyH85s2IeWWYrPD0cFx4571X6jvuEiG55qvbwAs7+g
	 bvt39vINZqbRB8xjPwNPbSae8Y5/TmUDYaSp35/fJr2A2dBKBRjaHRPqaJe40Xk1XzS8C
	 YkiUGpDAk0gZneSCyoMq+fRLstufoAN1PbnY2GcTlDIeswcucYdbIjf7rmTyJeB4IQEM5
	 iuAkeFeQp7LfmLnKuW9Zqs03MS2adg9NMRlrQ/cg5PhvVf4M167VhUQlkCW500xZtNgWP
	 dNcYfqY0c+7Hykif6aARlwtCwYUT0IpjM5kOMjn7ytmoTvcLLUV2LlT0U9xiNBckRkQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=linux-m68k.org;
	spf=pass smtp.mailfrom=gmail.com;
	arc=none smtp.remote-ip=209.85.160.182
Received: from mail-qt1-f182.google.com (mail-qt1-f182.google.com [209.85.160.182])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27AB8606A32F
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 09:52:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 27AB8606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-qt1-f182.google.com with SMTP id d75a77b69052e-53653e30353so21938251cf.2
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2026 01:52:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793872344; x=1794477144;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=SqrTjgENN7Dfs+HehxbKPgACeb32UvvfMAFijNHd6N4=;
        b=gw8hUd1OtSrPBmPL2XFAyjlj7zjHhbNGE12ULoOyhNT/wu+1hptGNWROpM4St7yat1
         mIRgi3P+zcUVg7s7noTd9pXGLwsKftHV3H2sYWpYcbgOe0acZTIXZdU8kx2VV8rNq3WO
         SzqBCE1x8HdstNt0D+GW+mrsfpWVE8pQEiSVYqwFnNPWmuhd3yGt+wEiOOUr/vUj3l5H
         PTZXbj0Iue78tLBM3glsLMixGMEZODsrfyX3QrPIof5A16FFqoaq1Pb/LElW21AjEyv/
         wMILZF2JM/BQNaH2AkHZHQakgQnJBNaEkHmMlkyo0quyuupbAPmpbdw8C7qMf/F3y1xf
         U0Pg==
X-Forwarded-Encrypted: i=1; AKwUvBw2amB43dCMfYAnLIHUX+GrDmjoyt0288qhayGU3Hbs+n+2Hgg+lPONRgdbFrjised62utRuQB3CGQ=@vger.kernel.org
X-Gm-Message-State: APuU4Z8LNVFn6HqVcfT5BRCXAAWt2xJ9rHwGlXwMv8LupV58zb5/SXF1
	1vvumr2gEs5RLsuRGBW7Vgu3ktU4sCYbt267LEu27dutll0Hn6dVHhDoKkPm0K61SAM=
X-Gm-Gg: AYBFou3XiREhSGQAQkCCLu4yP++NOGjoQZm518/7ix26HrgM13Yp85yXuQb86BnVrua
	fWAIB1zKtV+kmvzYdPu+mJWbtyeFjWJcy3erRQ0aDSTuMhN4ZvOw/wdB3U2o4mpi2G0dFnzsaKc
	1YpjMrs7lDymHHCKb5Dbh0qsEvitsdKXcUmu/IEunHFAjYv2AzItYbVPx2bEp7xxTqmdjlRGEpI
	37T/cj4rQJKdCaOY9nHbeIYX8+7acSDDmQhqG+zlHL0ZEadyKyR3gH7t94qKJ9YRrJ6nH1sEg3H
	JCWy0ihBj2FzWtwvrFjyKdOq2OAL63xTMf9kN/2vYs99ZDCKU4UZ0OkFlcgpXyRDNfAnFRp1o43
	L3mH5dyAjp1KD5eWwWgtspPImBU9/hUetSCZiNT+abZlekJ9WqZm7xZUPWcaGeFuTa7XRVsc01Y
	r0erRbKNxBmEw7kEKIj3V/aR9Ocevn2kkWJ0W7+0RHvkQJVG90DScZhwCZMu9xsXzfTzjXE4Ii0
	wAVHZ80FgKdAjw2Q/Pg0XY1M81EUzPFYaJNfRgGo1uIYbh+DAYvCVRpAJeNjU2JPayWa64vBbY0
	RhMkxaXfgGmzmmKOM2jSPfJ5tEp8nS+knmYfGoxnOwBBMv5dJuAY4kdKaXgcGLGsBW9uMA==
X-Received: by 2002:ac8:5fd0:0:b0:533:386a:edca with SMTP id d75a77b69052e-542b639bf3amr309053101cf.16.1793872344093;
        Thu, 05 Nov 2026 01:52:24 -0800 (PST)
Received: from mail-qt1-f172.google.com (mail-qt1-f172.google.com. [209.85.160.172])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-54b1086dc29sm48090711cf.10.2026.11.05.01.52.23
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 05 Nov 2026 01:52:23 -0800 (PST)
Received: by mail-qt1-f172.google.com with SMTP id d75a77b69052e-533778ab0bdso18445201cf.3
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2026 01:52:23 -0800 (PST)
X-Forwarded-Encrypted: i=1; AKwUvBy7bbwcH3hAF14myWFZUw+IjvDJGQyO9FNGyMat/jO8wSX5kV12qFEU3E0H0juxDfphO9IvJc8rypI=@vger.kernel.org
X-Received: by 2002:a05:6102:3ec5:b0:7cc:2bb7:131d with SMTP id
 ada2fe7eead31-7d072baa484mr7324212137.9.1793871885062; Thu, 05 Nov 2026
 01:44:45 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org> <20261104-work-procfs-bugfixes-v2-10-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-10-021c84d852e0@kernel.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 5 Nov 2026 10:44:33 +0100
X-Gmail-Original-Message-ID: <CAMuHMdUy1RYKG0g8OWss3AD-jyYx3DXL0K7ABYkFUdxTxZ9VdQ@mail.gmail.com>
X-Gm-Features: AclHuK9D-nB8icBns0zdoQH8fV1cfUPJ6LOey8o_VlUZpDIGqKC4cFf8-j5-HdE
Message-ID: <CAMuHMdUy1RYKG0g8OWss3AD-jyYx3DXL0K7ABYkFUdxTxZ9VdQ@mail.gmail.com>
Subject: Re: [PATCH RESEND v2 10/51] zorro: size the proc files like what they serve
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

On Wed, 4 Nov 2026 at 20:18, Christian Brauner <brauner@kernel.org> wrote:
> The files under /proc/bus/zorro hand out a struct ConfigDev and seek
> within that, but their size says sizeof(struct zorro_dev). Say
> sizeof(struct ConfigDev).
>
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
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
