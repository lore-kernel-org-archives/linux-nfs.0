From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [2.6.34-rc2 NFS4 oops] open error path failure...
Date: Mon, 29 Mar 2010 17:22:20 -0400
Message-ID: <1269897740.15895.82.camel@localhost.localdomain>
References: <6278d2221003291136p6481fe8emfb039403343c082@mail.gmail.com>
	 <20100329190307.GJ30031@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Daniel J Blueman <daniel.blueman@gmail.com>,
	linux-nfs@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:53143 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772Ab0C2VW0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Mar 2010 17:22:26 -0400
In-Reply-To: <20100329190307.GJ30031@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-03-29 at 20:03 +0100, Al Viro wrote: 
> On Mon, Mar 29, 2010 at 07:36:45PM +0100, Daniel J Blueman wrote:
> > Hi Trond,
> > 
> > When open fails and should return EPERM [1], instead we see an oops
> > [2]. I see this on 2.6.34-rc1 and -rc2 mainline; NFS4 server is
> > mainline 2.6.33.1.
> > 
> > Let me know if you can't reproduce it and I'll provide some analysis
> > from this end.
> 
> Joy...  ERR_PTR(-EPERM) in nd.intent.file, and whoever had called
> lookup_instantiate_filp() hadn't bothered to check the return value.
> 
> OK, I think I see what's going on.  Replace
>                                 lookup_instantiate_filp(nd, (struct dentry *)state, NULL);
>                                 return 1;
> with
>                                 lookup_instantiate_filp(nd, (struct dentry *)state, NULL);
>                                 return state;
> in fs/nfs/nfs4proc.c:nfs4_open_revalidate() and see if everything works
> properly (or just lose the lookup_instantiate_filp() in there and simply
> return state).
> 

So this raises a point. Originally, the d_revalidate() call was required
to return a boolean 0 or 1. Nowadays it allows the filesystem to return
an error value instead.

Should we therefore rewrite the NFS implementation to propagate errors
like ESTALE (when it means the parent directory is gone), EACCES, EPERM
and EIO instead of the current behaviour of just dropping the dentry and
hence forcing a lookup?

Trond

