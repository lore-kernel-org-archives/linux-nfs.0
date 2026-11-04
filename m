Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793813666;
	b=IozT5TRCfpRzhoHsRQ+16jiXlPZBhjhyHBW/Z7saSflXtFC+n89GTaSwHWLci+YjQzyk
	 PqmQQL6mIiXbcsABAipjBWvhLm2JFrtT9LmDh40euoHVEfbYjsTvkaCUtHmi61ZBdRdEB
	 LSvhUMqFBkWfbxn5uIv4hS+/gQaAkyZm3oq9wMoizhS5Hh/Y3JxtDKpkeMzrRrSfHsXtJ
	 LJEleQIEALh9gcznVyGiJFo5it+sSyooF/BiIViKag/xQBXpZZPq3PV2CUz5v9mPyF5ke
	 igiGKlfwgCxkbxrD28QJQBmVz7RSMZim0996NZTKoccCnmL2AcND/jmNKhlwG0sUB0w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793813666;
	h=Received:DKIM-Signature:Received:X-Forwarded-Encrypted:
	 X-Gm-Message-State:X-Received:MIME-Version:References:In-Reply-To:
	 From:Date:X-Gmail-Original-Message-ID:X-Gm-Features:Message-ID:
	 Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=AMOD33XmGyHm36xJWMnYgDFAfU9OylqTMFKngAIWEtA=;
	b=KVTQkLW7KAX2vgbdmjO/BHRnNX5AagKaS/AdGkdQCNs9+/F4Thb+s32Vdv2RRNT2aGN/
	 p3VorHz4+/0hHZMCGm9g8EHFej3MxPggB8tiRRyvh6nTBhorGVYFsT7SjSwKWHFyiD5P5
	 QrKpD0iOMCFcAhICEBNq3IAk9oJ92gDsh5grqhc/dmBkgkwrnmRcCzm1+bC/+C0U/GA/7
	 sEZIC15BQUeA8SlLAXpbqdo3SRo2DFlk94XAgP7JhTI/whwE9B5Uy7J+ZUFmShiHgfskJ
	 KNIFyVA/jF6tzl9x50aY1RLQ5MAtlE/7pSkgy07Xh3kuuvttMfWcwmVN6J2AVXXW3gg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=c8+xsGNw;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3314606A32D
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 17:34:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=c8+xsGNw
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C081E1F00A16
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 17:34:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793813665;
	bh=AMOD33XmGyHm36xJWMnYgDFAfU9OylqTMFKngAIWEtA=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc;
	b=c8+xsGNwRBct5ZUGKjk3eZtmN9gohM+NybLZwzj8cc388Jf+FuWQqNAaPFbwzicgF
	 zS2zfMb3GNkt3+o3qOH/KRvjG68CgqG8o23gRTXfw7pSsq7xlk0nEVbJSnWMEA6Vd6
	 WsQavQA+/klM4cHbpHQw7qBZ8l3tKs6OuHSy/oDVGO3ncD8J/WZPtQSd+ulSyM/Yvj
	 SBUb7y9RAQdeVkxB69uBukVLsWQpV7AE3b0Clr/+8u5fh7eWDuhsegmcTIoDomrBRZ
	 vc/4pFXDJIjiffydLU28BUqCA6oxGMiSW1cfuvO5UpTUsxXW3Go1YpNw0HVmUQhb63
	 NRPDlVWP872Tg==
Received: by mail-vk1-f178.google.com with SMTP id 71dfb90a1353d-5eaabf28c06so687883e0c.2
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2026 09:34:25 -0800 (PST)
X-Forwarded-Encrypted: i=1; AKwUvBwNynpfQzyEeG3rs7+heY9Vt6+43z2VDpFLOEd3usH9uhIYJkiauz5x1QE8lcd1nqZzjTCsPr7Ma7w=@vger.kernel.org
X-Gm-Message-State: APuU4Z/kNP2CJwux9MMO6eGfAcs10J4fKtInnkv5nDWDxLRPLn8r2Af0
	kWq2E6VrvPnmep9VoLAM1d/oFWjA3wWIfX1+bEA+4oHeDvrKtt+IuNyWPfaqWH59EXW2+RLfaxD
	ljfcJGv79odAhyViY1fOzfL1Qb7rHps0=
X-Received: by 2002:a05:6122:180a:b0:5ec:5f1b:f725 with SMTP id
 71dfb90a1353d-5ec689c4d7fmr8231097e0c.23.1793813664918; Wed, 04 Nov 2026
 09:34:24 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org> <20261104-work-procfs-bugfixes-v2-4-bbf7d5546809@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-4-bbf7d5546809@kernel.org>
From: "Rafael J. Wysocki (Intel)" <rafael@kernel.org>
Date: Wed, 4 Nov 2026 18:34:10 +0100
X-Gmail-Original-Message-ID: <CAJZ5v0gnefKDcBnLzxxXPLJkYRHN9pbYH9WVFAoUGuCSOPcW1A@mail.gmail.com>
X-Gm-Features: AclHuK8WGpfSf3TpV-YfKcvDlenGAnmL4yQTyeV9z6QpHJtyVq4G8L84EjJ5Q2g
Message-ID: <CAJZ5v0gnefKDcBnLzxxXPLJkYRHN9pbYH9WVFAoUGuCSOPcW1A@mail.gmail.com>
Subject: Re: [PATCH v2 04/51] PNP: isapnp: don't go on when isapnp_cfg_begin() fails
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
	linux-debuggers@vger.kernel.org, Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 4, 2026 at 6:30=E2=80=AFPM Christian Brauner <brauner@kernel.or=
g> wrote:
>
> isapnp_cfg_begin() refuses a logical device number above 10 and a bad
> card number with -EINVAL before it takes isapnp_cfg_mutex. The callers
> that read and write the device's configuration, the proc file included,
> don't look at that: they go on talking to whatever device the card
> currently has selected and then unlock a mutex they never took in
> isapnp_cfg_end(). isapnp_create_device() hands out logical device
> numbers without a bound, so a card with twelve or more logical devices
> gets there. Return the error instead.
>
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Acked-by: Rafael J. Wysocki (Intel) <rafael@kernel.org>

> ---
>  drivers/pnp/isapnp/core.c | 16 ++++++++++++----
>  drivers/pnp/isapnp/proc.c |  5 ++++-
>  sound/isa/es18xx.c        |  6 +++++-
>  3 files changed, 21 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/pnp/isapnp/core.c b/drivers/pnp/isapnp/core.c
> index 219f96f2aaaf..3591a2791c1a 100644
> --- a/drivers/pnp/isapnp/core.c
> +++ b/drivers/pnp/isapnp/core.c
> @@ -853,7 +853,9 @@ static int isapnp_get_resources(struct pnp_dev *dev)
>
>         pnp_dbg(&dev->dev, "get resources\n");
>         pnp_init_resources(dev);
> -       isapnp_cfg_begin(dev->card->number, dev->number);
> +       ret =3D isapnp_cfg_begin(dev->card->number, dev->number);
> +       if (ret)
> +               return ret;
>         dev->active =3D isapnp_read_byte(ISAPNP_CFG_ACTIVATE);
>         if (!dev->active)
>                 goto __end;
> @@ -887,10 +889,12 @@ __end:
>  static int isapnp_set_resources(struct pnp_dev *dev)
>  {
>         struct resource *res;
> -       int tmp;
> +       int tmp, ret;
>
>         pnp_dbg(&dev->dev, "set resources\n");
> -       isapnp_cfg_begin(dev->card->number, dev->number);
> +       ret =3D isapnp_cfg_begin(dev->card->number, dev->number);
> +       if (ret)
> +               return ret;
>         dev->active =3D 1;
>         for (tmp =3D 0; tmp < ISAPNP_MAX_PORT; tmp++) {
>                 res =3D pnp_get_resource(dev, IORESOURCE_IO, tmp);
> @@ -936,9 +940,13 @@ static int isapnp_set_resources(struct pnp_dev *dev)
>
>  static int isapnp_disable_resources(struct pnp_dev *dev)
>  {
> +       int ret;
> +
>         if (!dev->active)
>                 return -EINVAL;
> -       isapnp_cfg_begin(dev->card->number, dev->number);
> +       ret =3D isapnp_cfg_begin(dev->card->number, dev->number);
> +       if (ret)
> +               return ret;
>         isapnp_deactivate(dev->number);
>         dev->active =3D 0;
>         isapnp_cfg_end();
> diff --git a/drivers/pnp/isapnp/proc.c b/drivers/pnp/isapnp/proc.c
> index c1f6e6bd0eb2..b3abab24050b 100644
> --- a/drivers/pnp/isapnp/proc.c
> +++ b/drivers/pnp/isapnp/proc.c
> @@ -25,6 +25,7 @@ static ssize_t isapnp_proc_bus_read(struct file *file, =
char __user * buf,
>         struct pnp_dev *dev =3D pde_data(file_inode(file));
>         int pos =3D *ppos;
>         int cnt, size =3D 256;
> +       int ret;
>
>         if (pos >=3D size)
>                 return 0;
> @@ -37,7 +38,9 @@ static ssize_t isapnp_proc_bus_read(struct file *file, =
char __user * buf,
>         if (!access_ok(buf, cnt))
>                 return -EINVAL;
>
> -       isapnp_cfg_begin(dev->card->number, dev->number);
> +       ret =3D isapnp_cfg_begin(dev->card->number, dev->number);
> +       if (ret)
> +               return ret;
>         for (; pos < 256 && cnt > 0; pos++, buf++, cnt--) {
>                 unsigned char val;
>                 val =3D isapnp_read_byte(pos);
> diff --git a/sound/isa/es18xx.c b/sound/isa/es18xx.c
> index 3cadbf7cf238..de1eda5a0656 100644
> --- a/sound/isa/es18xx.c
> +++ b/sound/isa/es18xx.c
> @@ -1950,7 +1950,11 @@ static int snd_audiodrive_pnp_init_main(int dev, s=
truct pnp_dev *pdev)
>         /* ok. hack using Vendor-Defined Card-Level registers */
>         /* skip csn and logdev initialization - already done in isapnp_co=
nfigure */
>         if (pnp_device_is_isapnp(pdev)) {
> -               isapnp_cfg_begin(isapnp_card_number(pdev), isapnp_csn_num=
ber(pdev));
> +               int ret =3D isapnp_cfg_begin(isapnp_card_number(pdev),
> +                                          isapnp_csn_number(pdev));
> +
> +               if (ret)
> +                       return ret;
>                 isapnp_write_byte(0x27, pnp_irq(pdev, 0));      /* Hardwa=
re Volume IRQ Number */
>                 if (mpu_port[dev] !=3D SNDRV_AUTO_PORT)
>                         isapnp_write_byte(0x28, pnp_irq(pdev, 0)); /* MPU=
-401 IRQ Number */
>
> --
> 2.53.0
>
>
