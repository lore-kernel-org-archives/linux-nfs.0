Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:33776 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934529AbcKKRNC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2016 12:13:02 -0500
MIME-Version: 1.0
In-Reply-To: <20161110164454.293477-1-arnd@arndb.de>
References: <20161110164454.293477-1-arnd@arndb.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 11 Nov 2016 09:13:00 -0800
Message-ID: <CA+55aFx_scFVFKU__TBmoffw_iHvrdAU2dj5u1WKfWJXAkS4QA@mail.gmail.com>
Subject: Re: [PATCH v2 00/11] getting back -Wmaybe-uninitialized
To: Arnd Bergmann <arnd@arndb.de>,
        Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
        sayli karnik <karniksayli1995@gmail.com>,
        Jonathan Cameron <jic23@kernel.org>, Mark Brown <broonie@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Ilya Dryomov <idryomov@gmail.com>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Jiri Kosina <jikos@kernel.org>, Ley Foon Tan <lftan@altera.com>,
        "Luis R . Rodriguez" <mcgrof@kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Michal Marek <mmarek@suse.com>, Russell King <linux@armlinux.org.uk>,
        Sean Young <sean@mess.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "the arch/x86 maintainers" <x86@kernel.org>,
        Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        arcml <linux-snps-arc@lists.infradead.org>,
        nios2-dev@lists.rocketboards.org,
        linux-s390 <linux-s390@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 10, 2016 at 8:44 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>
> Please merge these directly if you are happy with the result.

I will take this.

I do see two warnings, but they both seem to be valid and recent,
though, so I have no issues with the spurious cases.

Warning #1:

  sound/soc/qcom/lpass-platform.c: In function =E2=80=98lpass_platform_pcmo=
ps_open=E2=80=99:
  sound/soc/qcom/lpass-platform.c:83:29: warning: =E2=80=98dma_ch=E2=80=99 =
may be used
uninitialized in this function [-Wmaybe-uninitialized]
    drvdata->substream[dma_ch] =3D substream;
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~

and 'dma_ch' usage there really is crazy and wrong. Broken by
022d00ee0b55 ("ASoC: lpass-platform: Fix broken pcm data usage")

Warning #2 is not a real bug, but it's reasonable that gcc doesn't
know that storage_bytes (chip->read_size) has to be 2/4. Again,
introduced recently by commit 231147ee77f3 ("iio: maxim_thermocouple:
Align 16 bit big endian value of raw reads"), so you didn't see it.

  drivers/iio/temperature/maxim_thermocouple.c: In function
=E2=80=98maxim_thermocouple_read_raw=E2=80=99:
  drivers/iio/temperature/maxim_thermocouple.c:141:5: warning: =E2=80=98ret=
=E2=80=99
may be used uninitialized in this function [-Wmaybe-uninitialized]
    if (ret)
       ^
  drivers/iio/temperature/maxim_thermocouple.c:128:6: note: =E2=80=98ret=E2=
=80=99 was
declared here
    int ret;
        ^~~

and I guess that code can just initialize 'ret' to '-EINVAL' or
something to just make the theoretical "somehow we had a wrong
chip->read_size" case error out cleanly.

                Linus
