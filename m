Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:45990 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159Ab0CaLU4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Mar 2010 07:20:56 -0400
In-Reply-To: <1269897740.15895.82.camel@localhost.localdomain>
References: <6278d2221003291136p6481fe8emfb039403343c082@mail.gmail.com>
	 <20100329190307.GJ30031@ZenIV.linux.org.uk>
	 <1269897740.15895.82.camel@localhost.localdomain>
Date: Wed, 31 Mar 2010 12:20:54 +0100
Message-ID: <w2s6278d2221003310420xd36fa9ey92b781fb9f4d1a10@mail.gmail.com>
Subject: Re: [2.6.34-rc2 NFS4 oops] open error path failure...
From: Daniel J Blueman <daniel.blueman@gmail.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 29, 2010 at 10:22 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Mon, 2010-03-29 at 20:03 +0100, Al Viro wrote:
>> On Mon, Mar 29, 2010 at 07:36:45PM +0100, Daniel J Blueman wrote:
>> > Hi Trond,
>> >
>> > When open fails and should return EPERM [1], instead we see an oops
>> > [2]. I see this on 2.6.34-rc1 and -rc2 mainline; NFS4 server is
>> > mainline 2.6.33.1.
>> >
>> > Let me know if you can't reproduce it and I'll provide some analysis
>> > from this end.
>>
>> Joy...  ERR_PTR(-EPERM) in nd.intent.file, and whoever had called
>> lookup_instantiate_filp() hadn't bothered to check the return value.
>>
>> OK, I think I see what's going on.  Replace
>>                                 lookup_instantiate_filp(nd, (struct dentry *)state, NULL);
>>                                 return 1;
>> with
>>                                 lookup_instantiate_filp(nd, (struct dentry *)state, NULL);
>>                                 return state;
>> in fs/nfs/nfs4proc.c:nfs4_open_revalidate() and see if everything works
>> properly (or just lose the lookup_instantiate_filp() in there and simply
>> return state).
>
> So this raises a point. Originally, the d_revalidate() call was required
> to return a boolean 0 or 1. Nowadays it allows the filesystem to return
> an error value instead.
>
> Should we therefore rewrite the NFS implementation to propagate errors
> like ESTALE (when it means the parent directory is gone), EACCES, EPERM
> and EIO instead of the current behaviour of just dropping the dentry and
> hence forcing a lookup?

Passing the error back without forcing a lookup sounds like a good
win, if it can avoid a comparatively expensive roundtrip to the server
(iff the dentry is fresh enough). Is this possible?

Talking of expensive, I see latencytop show >16000ms latency for
writing pages when I have a workload that does large buffered I/O to
an otherwise uncongested server. The gigabit network is saturated, and
reads often stall for 1000-4000ms (!). Client has the default 16 TCP
request slots, and server has 8 nfsds - the server is far from disk or
processor-saturated. I'll see if there is any useful debugging I can
get about this.

Thanks,
  Daniel
-- 
Daniel J Blueman
