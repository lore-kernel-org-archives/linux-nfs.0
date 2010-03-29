From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: Re: [2.6.34-rc2 NFS4 oops] open error path failure...
Date: Mon, 29 Mar 2010 20:21:57 +0100
Message-ID: <6278d2221003291221j78d93780uff516b07f134ef0f@mail.gmail.com>
References: <6278d2221003291136p6481fe8emfb039403343c082@mail.gmail.com>
	 <20100329190307.GJ30031@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:62637 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796Ab0C2TV7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Mar 2010 15:21:59 -0400
In-Reply-To: <20100329190307.GJ30031@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Al,

On Mon, Mar 29, 2010 at 8:03 PM, Al Viro <viro@zeniv.linux.org.uk> wrot=
e:
> On Mon, Mar 29, 2010 at 07:36:45PM +0100, Daniel J Blueman wrote:
>> Hi Trond,
>>
>> When open fails and should return EPERM [1], instead we see an oops
>> [2]. I see this on 2.6.34-rc1 and -rc2 mainline; NFS4 server is
>> mainline 2.6.33.1.
>>
>> Let me know if you can't reproduce it and I'll provide some analysis
>> from this end.
>
> Joy... =A0ERR_PTR(-EPERM) in nd.intent.file, and whoever had called
> lookup_instantiate_filp() hadn't bothered to check the return value.
>
> OK, I think I see what's going on. =A0Replace
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lookup=
_instantiate_filp(nd, (struct dentry *)state, NULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 1;
> with
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lookup=
_instantiate_filp(nd, (struct dentry *)state, NULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 state;
> in fs/nfs/nfs4proc.c:nfs4_open_revalidate() and see if everything wor=
ks
> properly (or just lose the lookup_instantiate_filp() in there and sim=
ply
> return state).

That did the trick!

Looks like I should have reported this when I first encountered it,
but I guess it goes to show there needs to be some NFS validation
(LTP?). I'm still trying to chase down a rare NFSv4 dentry "Stale NFS
file handle" issue I've seen.

Thanks,
  Daniel
--=20
Daniel J Blueman
