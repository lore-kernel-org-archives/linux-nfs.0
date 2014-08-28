Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:52625 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbaH1HmX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Aug 2014 03:42:23 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so399714qcx.27
        for <linux-nfs@vger.kernel.org>; Thu, 28 Aug 2014 00:42:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140827132607.GA12766@fieldses.org>
References: <CALtMJECmW-yYgD3W5FUxQZJVZkb5NSJpQ5V9Q3ZE=1NKeCDtOA@mail.gmail.com>
	<20140710175136.GA26561@fieldses.org>
	<CALtMJECLdEOsmuW4AOnNsAyY+OMr3MtFN9W71DRw3tpidKrU8A@mail.gmail.com>
	<CAHQdGtQAgKyFgwp+6w64vXkcKkBQ=YVfiH0jgaonAMumHoTutg@mail.gmail.com>
	<CALtMJEDT=jCWMR0Akjo72fL3SW63dEmDTQbdg5Pv_DV5Oggz_g@mail.gmail.com>
	<CAHQdGtS_O3i6fBhW7vTurL=Y7cKmoeGjTXiEMU5mbb3tR3-LjA@mail.gmail.com>
	<CALtMJEALbP3DKpaL9Bz6tNjj3GHYUo7wb=VRbOcjB1+hOr6GCg@mail.gmail.com>
	<CAHQdGtS34K6S_59Huvx8EK+mh1QwSrjtUXaNogGYSm5aQZCA=w@mail.gmail.com>
	<20140826195033.GB25117@fieldses.org>
	<CALtMJECxo57CXw1=yKDGLm0o+jPLLpj+7rDMAMMJ95uYEC15Xw@mail.gmail.com>
	<20140827132607.GA12766@fieldses.org>
Date: Thu, 28 Aug 2014 09:42:22 +0200
Message-ID: <CALtMJEDvU2M=gMd1gfivd2c3p--QQHmMx-8ed2YJspFjfV4x3A@mail.gmail.com>
Subject: Re: `ls` shows no files in mounted nfs folder, but ls 'file' works
From: Andreas Fenkart <afenkart@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Daniel Mack <zonque@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

http://snapshot.debian.org/package/linux/3.14.4-1/#linux-image-3.14-1-amd64_3.14.4-1
  <- version when reporting bug
http://snapshot.debian.org/package/linux/3.14.15-2/#linux-image-3.14-2-amd64_3.14.15-2
<- current version

even when downgrading to the previous version, I can't reproduce the
bug anymore...
just realized that I didn't mention the tip of my embedded system
kernel, bad me, but it was some 3.16 rc,

/Andreas


2014-08-27 15:26 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Wed, Aug 27, 2014 at 10:30:34AM +0200, Andreas Fenkart wrote:
>> Hi
>>
>> 2014-08-26 21:50 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
>> >>
>> >> Still not seeing the readdir, but the getattrs are there and all looks OK.
>> >> Question: the server is knfsd from a Linux 3.14.4 kernel, is that
>> >> correct? So it does have commit 83b19121522 (nfsd: revert v2 half of
>> >> "nfsd: don't return high mode bits")?
>> >
>> > Yeah, you can even see the high bits set (correctly) in the stat
>> > returns, so he has that patch.
>> >
>> > Andreas, are you still seeing this problem?
>>
>> No it's gone, but I upgraded my (server-)system meanwhile (debian unstable)
>> I also tried downgrading my kernel to the version I had back then, but
>> the problem doesn't show up anymore.
>
> Well, maybe there was a server bug in the old server that this change
> just happened to expose.
>
> What was the server upgrade, out of curiosity?  (From what kernel
> version, to what kernel version?)
>
> --b.
