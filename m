Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41692 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbbEUBQv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2015 21:16:51 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: NFS client broken in 4.1.0-rc2
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150520232228.GC2067@n2100.arm.linux.org.uk>
Date: Wed, 20 May 2015 21:16:18 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        LKML Kernel <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-arm-kernel@lists.infradead.org
Message-Id: <4DD061F4-B1A8-4CBE-A817-ACC921661A89@oracle.com>
References: <20150515142403.GL2067@n2100.arm.linux.org.uk> <F423EE93-1A93-42F8-8593-9D2E4F85CB3B@oracle.com> <20150515145013.GM2067@n2100.arm.linux.org.uk> <20150520232228.GC2067@n2100.arm.linux.org.uk>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 20, 2015, at 7:22 PM, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> On Fri, May 15, 2015 at 03:50:14PM +0100, Russell King - ARM Linux wrote:
>> On Fri, May 15, 2015 at 10:26:48AM -0400, Chuck Lever wrote:
>>> On May 15, 2015, at 10:24 AM, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
>>>> While trying to update a kernel and modules on one of my test systems,
>>>> I was greeted by these errors:
>>>> 
>>>> tar: lib/modules/4.1.0-rc2+/kernel/drivers/media/platform/coda/coda.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/drivers/media/dvb-frontends/drx39xyj/drx39xyj.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/drivers/media/usb/em28xx/em28xx.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/drivers/usb/serial/option.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/drivers/usb/serial/ftdi_sio.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/drivers/net/wireless/brcm80211/brcmfmac/brcmfmac.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/drivers/input/mouse/psmouse.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/fs/udf/udf.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/fs/fuse/fuse.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/fs/nfsd/nfsd.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/sound/soc/codecs/snd-soc-wm8962.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/kernel/net/bluetooth/bluetooth.ko: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/modules.alias.bin: Cannot utime
>>>> tar: lib/modules/4.1.0-rc2+/modules.alias: Cannot utime
>>>> tar: Exiting with failure status due to previous errors
>>>> 
>>>> Searching google wasn't helpful, as all the "Cannot utime" errors that
>>>> google could find are followed by an errno string.
>>>> 
>>>> stracing at first sight didn't seem to be helpful, as no syscalls (apart
>>>> from openat() with a pre-existing file) were failing.
>>>> 
>>>> Having recently updated to fc21 tar generating the archive, I thought
>>>> maybe it was a tar format bug between fc21 tar and the target's tar.
>>>> That was until I tried to "apt-get source tar" on the target, and was
>>>> greeted by the same error.
>>>> 
>>>> So I then tried untaring the tar source archive onto a ramfs, which
>>>> worked without complaint.  The difference being that it's a root NFS
>>>> box, and so I was untaring onto NFS.
>>>> 
>>>> Here's the entry from /proc/mounts:
>>>> 
>>>> x.y.z.221:/var/boot/ci on / type nfs (rw,nolock,vers=4,addr=x.y.z.221,clientaddr=a.b.c.55)
>>>> 
>>>> Looking closer at the strace reveals this:
>>>> 
>>>> openat(AT_FDCWD, "lib/modules/4.1.0-rc2+/kernel/drivers/media/platform/coda/coda.ko", O_WRONLY|O_CREAT|O_EXCL|O_NOCTTY|O_NONBLOCK|O_LARGEFILE|O_CLOEXEC, 0600) = -1 EEXIST (File exists)
>>>> unlinkat(AT_FDCWD, "lib/modules/4.1.0-rc2+/kernel/drivers/media/platform/coda/coda.ko", 0) = 0
>>>> openat(AT_FDCWD, "lib/modules/4.1.0-rc2+/kernel/drivers/media/platform/coda/coda.ko", O_WRONLY|O_CREAT|O_EXCL|O_NOCTTY|O_NONBLOCK|O_LARGEFILE|O_CLOEXEC, 0600) = 4
>>>> write(4, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\1\0(\0\1\0\0\0\0\0\0\0\0\0\0\0"..., 4096) = 4096
>>>> ...
>>>> write(4, "\300H\0\0\34\345\1\0\314H\0\0\34\345\1\0\330H\0\0\34\345\1\0<I\0\0\34\370\1\0"..., 7312) = 7312
>>>> dup2(4, 4)                              = 4
>>>> fstat64(4, {st_mode=0757221, st_size=13181880119170311768, ...}) = 21
>>>> write(2, "tar: ", 5)                    = 5
>>>> write(2, "lib/modules/4.1.0-rc2+/kernel/dr"..., 79) = 79
>>>> write(2, "\n", 1)                       = 1
>>>> fchown32(4, 0, 0)                       = 0
>>>> fchmod(4, 0664)                         = 0
>>>> close(4)                                = 0
>>>> 
>>>> Look closely at that fstat64, and you'll notice that it's returning crap.
>>> 
>>> This is likely fixed by:
>>> 
>>>  http://marc.info/?l=linux-nfs&m=143095122604344&w=2
>> 
>> Yes, it appears to be fixed by that change.  I'll add it to my tree so
>> my test systems work.
> 
> I notice NFS patches were merged by Linus recently, but this patch was not
> in the set.  Is this patch scheduled to go in for 4.1?

Trond sent Linus a pull request yesterday for 2 patches, including
the one you are asking about. See:

http://marc.info/?l=linux-nfs&m=143205093309624&w=2

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



