Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:57215 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbaBCOVT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 09:21:19 -0500
Received: by mail-ie0-f172.google.com with SMTP id e14so6344196iej.17
        for <linux-nfs@vger.kernel.org>; Mon, 03 Feb 2014 06:21:18 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: NFS client broken in Linus' tip
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <s5hioswy1iy.wl%tiwai@suse.de>
Date: Mon, 3 Feb 2014 09:21:16 -0500
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Viro Alexander <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org
Message-Id: <5ACE0C45-BEFA-47A8-9195-F3AB36C27752@primarydata.com>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk> <20140130141405.GA23985@infradead.org> <20140130142752.GX15937@n2100.arm.linux.org.uk> <20140130143208.GB9573@infradead.org> <20140130153812.GA15937@n2100.arm.linux.org.uk> <1391201970.6978.1.camel@leira.trondhjem.org> <20140201010328.GI15937@n2100.arm.linux.org.uk> <20140202122757.GC26684@n2100.arm.linux.org.uk> <1391378678.8123.5.camel@leira.trondhjem.org> <s5hioswy1iy.wl%tiwai@suse.de>
To: Takashi Iwai <tiwai@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 3, 2014, at 4:43, Takashi Iwai <tiwai@suse.de> wrote:

> At Sun, 02 Feb 2014 17:04:38 -0500,
> Trond Myklebust wrote:
>> 
>> On Sun, 2014-02-02 at 12:27 +0000, Russell King - ARM Linux wrote:
>>> On Sat, Feb 01, 2014 at 01:03:28AM +0000, Russell King - ARM Linux wrote:
>>>> On Fri, Jan 31, 2014 at 03:59:30PM -0500, Trond Myklebust wrote:
>>>>> On Thu, 2014-01-30 at 15:38 +0000, Russell King - ARM Linux wrote:
>>>>>> On Thu, Jan 30, 2014 at 06:32:08AM -0800, Christoph Hellwig wrote:
>>>>>>> On Thu, Jan 30, 2014 at 02:27:52PM +0000, Russell King - ARM Linux wrote:
>>>>>>>> Yes and no.  I still end up with an empty /etc/mtab, but the file now
>>>>>>>> exists.  However, I can create and echo data into /etc/mtab, but it seems
>>>>>>>> that can't happen at boot time.
>>>>>>> 
>>>>>>> Odd.  Can you disable CONFIG_NFSD_V3_ACL for now to isolate the issue?
>>>>>> 
>>>>>> Unfortunately, that results in some problem at boot time, which
>>>>>> ultimately ends up with the other three CPUs being stopped, and
>>>>>> hence the original reason scrolls off the screen before it can be
>>>>>> read... even at 1920p.
>>>>>> 
>>>>> Hi Russell,
>>>>> 
>>>>> The following patch fixes the issue for me.
>>>> 
>>>> It doesn't entirely fix the issue for me, instead we've got even weirder
>>>> behaviour:
>>>> 
>>>> root@cubox-i4:~# ls -al test
>>>> ls: cannot access test: No such file or directory
>>>> root@cubox-i4:~# touch test
>>>> root@cubox-i4:~# ls -al test
>>>> -rw-r--r-- 1 root root 0 Feb  1 01:01 test
>>>> root@cubox-i4:~# echo foo > test
>>>> root@cubox-i4:~# ls -al test
>>>> -rw-r--r-- 1 root root 4 Feb  1 01:01 test
>>>> root@cubox-i4:~# cat test
>>>> foo
>>>> root@cubox-i4:~# rm test
>>>> root@cubox-i4:~# echo foo > test
>>>> -bash: test: Operation not supported
>>>> root@cubox-i4:~# ls -al test
>>>> -rw-r--r-- 1 root root 0 Feb  1 01:01 test
>>> 
>>> FYI, I just tested Linus' tip, and NFS is still broken.
>>> 
>> Hi Russell,
>> 
>> The following patch should fix the above problem. It needs to be applied
>> on top of the one I sent you previously.
> 
> I've hit the same problem, and your two patches seem fixing it.
> I tested them on top of 3.14-rc1.  Feel free to take my tested-by tag
> 
>  Tested-by: Takashi Iwai <tiwai@suse.de>
> 
> 
>> In addition, you will want to
>> apply Noah Massey's patch from
>> http://lkml.kernel.org/r/1391135472-9639-1-git-send-email-Noah.Massey@gmail.com 
> 
> Do I still need to test this one, too?
> 

Hi Takashi,

Noah’s patch is not a replacement for the above 2 patches; it fixes a different problem. All three patches are therefore required for a complete solution.

Cheers
  Trond

--
Trond Myklebust
Linux NFS client maintainer

