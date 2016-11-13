Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:35094 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932923AbcKMKbg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Nov 2016 05:31:36 -0500
Date: Sun, 13 Nov 2016 11:31:46 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Jonathan Cameron <jic23@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
        sayli karnik <karniksayli1995@gmail.com>,
        Mark Brown <broonie@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
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
        the arch/x86 maintainers <x86@kernel.org>,
        Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        arcml <linux-snps-arc@lists.infradead.org>,
        nios2-dev@lists.rocketboards.org,
        linux-s390 <linux-s390@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 00/11] getting back -Wmaybe-uninitialized
Message-ID: <20161113103146.GA8319@kroah.com>
References: <20161110164454.293477-1-arnd@arndb.de>
 <CA+55aFx_scFVFKU__TBmoffw_iHvrdAU2dj5u1WKfWJXAkS4QA@mail.gmail.com>
 <2695221.kyRJMsRMjs@wuerfel>
 <f6dccd27-09d2-1842-220b-24aa84043674@kernel.org>
 <20161113084741.GA5225@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20161113084741.GA5225@kroah.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 13, 2016 at 09:47:41AM +0100, Greg KH wrote:
> On Sat, Nov 12, 2016 at 01:27:12PM +0000, Jonathan Cameron wrote:
> > On 11/11/16 19:49, Arnd Bergmann wrote:
> > > On Friday, November 11, 2016 9:13:00 AM CET Linus Torvalds wrote:
> > >> On Thu, Nov 10, 2016 at 8:44 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > >>>
> > >>> Please merge these directly if you are happy with the result.
> > >>
> > >> I will take this.
> > > 
> > > Thanks a lot!
> > >  
> > >> I do see two warnings, but they both seem to be valid and recent,
> > >> though, so I have no issues with the spurious cases.
> > > 
> > > Ok, both of them should have my fixes coming your way already.
> > > 
> > >> Warning #1:
> > >>
> > >>   sound/soc/qcom/lpass-platform.c: In function ‘lpass_platform_pcmops_open’:
> > >>   sound/soc/qcom/lpass-platform.c:83:29: warning: ‘dma_ch’ may be used
> > >> uninitialized in this function [-Wmaybe-uninitialized]
> > >>     drvdata->substream[dma_ch] = substream;
> > >>     ~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~
> > >>
> > >> and 'dma_ch' usage there really is crazy and wrong. Broken by
> > >> 022d00ee0b55 ("ASoC: lpass-platform: Fix broken pcm data usage")
> > > 
> > > Right, the patches crossed here, the bugfix patch that introduced
> > > this came into linux-next over the kernel summit, and the fix I
> > > sent on Tuesday made it into Mark Brown's tree on Wednesday but not
> > > before you pulled alsa tree. It should be fixed the next time you
> > > pull from the alsa tree, the commit is
> > > 
> > > 3b89e4b77ef9 ("ASoC: lpass-platform: initialize dma channel number")
> > >  
> > >> Warning #2 is not a real bug, but it's reasonable that gcc doesn't
> > >> know that storage_bytes (chip->read_size) has to be 2/4. Again,
> > >> introduced recently by commit 231147ee77f3 ("iio: maxim_thermocouple:
> > >> Align 16 bit big endian value of raw reads"), so you didn't see it.
> > > 
> > > This is the one I mentioned in the commit message as one that
> > > is fixed in linux-next and that should make it in soon.
> > > 
> > >>   drivers/iio/temperature/maxim_thermocouple.c: In function
> > >> ‘maxim_thermocouple_read_raw’:
> > >>   drivers/iio/temperature/maxim_thermocouple.c:141:5: warning: ‘ret’
> > >> may be used uninitialized in this function [-Wmaybe-uninitialized]
> > >>     if (ret)
> > >>        ^
> > >>   drivers/iio/temperature/maxim_thermocouple.c:128:6: note: ‘ret’ was
> > >> declared here
> > >>     int ret;
> > >>         ^~~
> > >>
> > >> and I guess that code can just initialize 'ret' to '-EINVAL' or
> > >> something to just make the theoretical "somehow we had a wrong
> > >> chip->read_size" case error out cleanly.
> > > 
> > > Right, that was my conclusion too. I sent the bugfix on Oct 25
> > > for linux-next but it didn't make it in until this Monday, after
> > > you pulled the patch that introduced it on Oct 29.
> > > 
> > > The commit in staging-testing is
> > > 32cb7d27e65d ("iio: maxim_thermocouple: detect invalid storage size in read()")
> > > 
> > > Greg and Jonathan, I see now that this is part of the 'iio-for-4.10b'
> > > branch, so I suspect you were not planning to send this before the
> > > merge window. Could you make sure this ends up in v4.9 so we get
> > > a clean build when -Wmaybe-uninitialized gets enabled again?
> > I'll queue this up and send a pull to Greg tomorrow.
> > 
> > Was highly doubtful that a false warning suppression (be it an
> > understandable one) was worth sending mid cycle, hence it was
> > taking the slow route.
> 
> I can just cherry-pick this, no need to send a separate pull request.

Now done and sent to Linus, so all should be good here.

thanks,

greg k-h
