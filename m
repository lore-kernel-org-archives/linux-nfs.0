From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: Re: [2.6.33-rc3] NFS4 and dentry issues...
Date: Thu, 14 Jan 2010 08:39:52 +0000
Message-ID: <6278d2221001140039m711f2ae4o163d6c7f8d5b98d0@mail.gmail.com>
References: <6278d2221001090632m7fdd77qc73c203840a2a78e@mail.gmail.com>
	 <1263154093.2987.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:51547 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab0ANIjy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 03:39:54 -0500
In-Reply-To: <1263154093.2987.34.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Sun, Jan 10, 2010 at 8:08 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Sat, 2010-01-09 at 14:32 +0000, Daniel J Blueman wrote:
>> When synchronising files (unison, like a two way rsync) over an NFS4
>> mount (server with 2.6.32.2) on a client running 2.6.33-rc3 (also
>> -rc2), I ran into dcache issues [1].
>>
>> I've been unable to consistently reproduce this for bisecting, and
>> filesystem benchmarks via NFS on tmpfs over localhost fails to
>> reproduce it either.
>>
>> What additional information may be useful?
>
> There is a known issue in 2.6.33-rc3 with rename causing corruption of
> the dentry lookup hash lists.
>
> A fix for that problem has already been merged into mainline as
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=56335936de1a41c8978fde62b2158af77ddc7258
>
> Could you see if you can reproduce your problem with that fix applied?

2.6.33-rc4 with the fix does address this issue, though I am now
occasionally seeing 'Stale NFS file handle' during parallel kernel
compilation over NFS4 [1], seemingly when stat(2) is called.

Client mount options are:

x1:/ /net nfs4 rw,relatime,vers=4,rsize=262144,wsize=262144,namlen=255,acregmin=30,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.10.2,addr=192.168.10.250
0 0

I'll see which -rc this was introduced in, from limited time.

Thanks,
  Daniel

--- [1]

$ CONCURRENCY_LEVEL=4 fakeroot make-kpkg --append-to-version -308cd
--initrd kernel-image
...
  CC [M]  drivers/net/wireless/rt2x00/rt2500usb.o
  CC [M]  drivers/net/wireless/rt2x00/rt73usb.o
  CC [M]  drivers/net/wireless/rt2x00/rt2800usb.o
  LD [M]  drivers/net/wireless/rt2x00/rt2x00lib.o
  Building modules, stage 2.
make[2]: stat: arch/x86/crypto/aes-x86_64.o: Stale NFS file handle
make[2]: stat: arch/x86/crypto/aesni-intel.o: Stale NFS file handle
make[2]: stat: arch/x86/crypto/salsa20-x86_64.o: Stale NFS file handle
make[2]: stat: arch/x86/crypto/twofish-x86_64.o: Stale NFS file handle
make[2]: stat: arch/x86/kernel/cpu/cpufreq/p4-clockmod.o: Stale NFS file handle
make[2]: stat: arch/x86/kernel/cpu/cpufreq/speedstep-lib.o: Stale NFS
file handle
....
-- 
Daniel J Blueman
