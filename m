Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from saturn.retrosnub.co.uk ([178.18.118.26]:34949 "EHLO
        saturn.retrosnub.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938767AbcKLN1U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2016 08:27:20 -0500
Subject: Re: [PATCH v2 00/11] getting back -Wmaybe-uninitialized
To: Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>
References: <20161110164454.293477-1-arnd@arndb.de>
 <CA+55aFx_scFVFKU__TBmoffw_iHvrdAU2dj5u1WKfWJXAkS4QA@mail.gmail.com>
 <2695221.kyRJMsRMjs@wuerfel>
Cc: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
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
        arcml <"linux-snps -arc"@lists.infradead.org>,
        nios2-dev@lists.rocketboards.org,
        linux-s390 <linux-s390@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        gregkh@linuxfoundation.org
From: Jonathan Cameron <jic23@kernel.org>
Message-ID: <f6dccd27-09d2-1842-220b-24aa84043674@kernel.org>
Date: Sat, 12 Nov 2016 13:27:12 +0000
MIME-Version: 1.0
In-Reply-To: <2695221.kyRJMsRMjs@wuerfel>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/11/16 19:49, Arnd Bergmann wrote:
> On Friday, November 11, 2016 9:13:00 AM CET Linus Torvalds wrote:
>> On Thu, Nov 10, 2016 at 8:44 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>>>
>>> Please merge these directly if you are happy with the result.
>>
>> I will take this.
> 
> Thanks a lot!
>  
>> I do see two warnings, but they both seem to be valid and recent,
>> though, so I have no issues with the spurious cases.
> 
> Ok, both of them should have my fixes coming your way already.
> 
>> Warning #1:
>>
>>   sound/soc/qcom/lpass-platform.c: In function ‘lpass_platform_pcmops_open’:
>>   sound/soc/qcom/lpass-platform.c:83:29: warning: ‘dma_ch’ may be used
>> uninitialized in this function [-Wmaybe-uninitialized]
>>     drvdata->substream[dma_ch] = substream;
>>     ~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~
>>
>> and 'dma_ch' usage there really is crazy and wrong. Broken by
>> 022d00ee0b55 ("ASoC: lpass-platform: Fix broken pcm data usage")
> 
> Right, the patches crossed here, the bugfix patch that introduced
> this came into linux-next over the kernel summit, and the fix I
> sent on Tuesday made it into Mark Brown's tree on Wednesday but not
> before you pulled alsa tree. It should be fixed the next time you
> pull from the alsa tree, the commit is
> 
> 3b89e4b77ef9 ("ASoC: lpass-platform: initialize dma channel number")
>  
>> Warning #2 is not a real bug, but it's reasonable that gcc doesn't
>> know that storage_bytes (chip->read_size) has to be 2/4. Again,
>> introduced recently by commit 231147ee77f3 ("iio: maxim_thermocouple:
>> Align 16 bit big endian value of raw reads"), so you didn't see it.
> 
> This is the one I mentioned in the commit message as one that
> is fixed in linux-next and that should make it in soon.
> 
>>   drivers/iio/temperature/maxim_thermocouple.c: In function
>> ‘maxim_thermocouple_read_raw’:
>>   drivers/iio/temperature/maxim_thermocouple.c:141:5: warning: ‘ret’
>> may be used uninitialized in this function [-Wmaybe-uninitialized]
>>     if (ret)
>>        ^
>>   drivers/iio/temperature/maxim_thermocouple.c:128:6: note: ‘ret’ was
>> declared here
>>     int ret;
>>         ^~~
>>
>> and I guess that code can just initialize 'ret' to '-EINVAL' or
>> something to just make the theoretical "somehow we had a wrong
>> chip->read_size" case error out cleanly.
> 
> Right, that was my conclusion too. I sent the bugfix on Oct 25
> for linux-next but it didn't make it in until this Monday, after
> you pulled the patch that introduced it on Oct 29.
> 
> The commit in staging-testing is
> 32cb7d27e65d ("iio: maxim_thermocouple: detect invalid storage size in read()")
> 
> Greg and Jonathan, I see now that this is part of the 'iio-for-4.10b'
> branch, so I suspect you were not planning to send this before the
> merge window. Could you make sure this ends up in v4.9 so we get
> a clean build when -Wmaybe-uninitialized gets enabled again?
I'll queue this up and send a pull to Greg tomorrow.

Was highly doubtful that a false warning suppression (be it an
understandable one) was worth sending mid cycle, hence it was
taking the slow route.

Jonathan
> 
> 	Arnd
> 

