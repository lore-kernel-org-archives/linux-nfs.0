Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:35145 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934822Ab3DKDzL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 23:55:11 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 10 Apr 2013 23:55:10 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 3811DC9001E
	for <linux-nfs@vger.kernel.org>; Wed, 10 Apr 2013 23:55:09 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B3t9i2161700
	for <linux-nfs@vger.kernel.org>; Wed, 10 Apr 2013 23:55:09 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B3t8EF029782
	for <linux-nfs@vger.kernel.org>; Thu, 11 Apr 2013 00:55:09 -0300
Date: Wed, 10 Apr 2013 22:55:06 -0500
From: malahal naineni <malahal@us.ibm.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv3/v2: Fix data corruption with NFS short reads.
Message-ID: <20130411035506.GA32459@us.ibm.com>
References: <1364587026-7504-1-git-send-email-malahal@us.ibm.com>
 <20130411112121.74d996c5@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130411112121.74d996c5@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown [neilb@suse.de] wrote:
> On Fri, 29 Mar 2013 19:57:06 -0000 malahal naineni <malahal@us.ibm.com> wrote:
> 
> > This bug seems to be present in v2.6.37 or lower versions. The code was
> > re-organized in v2.6.38 that eliminated the bug. Current upstream code
> > doesn't have this bug. This may be applicable to some longterm releases!
> > 
> > Here are the bug details:
> > 
> > 1. nfs_read_rpcsetup(), args.count and res.count are both set to the
> >    actual number of bytes to be read. Let us assume that the request is
> >    for 16K, so arg.count = res.count = 16K
> > 2. nfs3_xdr_readres() conditionally sets res.count to to the actual
> >    number of bytes read. This condition is true for the first response
> >    as res.count was set to args.count before the first request. Let us
> >    say the server returned only 4K bytes. res.count=4K
> > 3. Another read request is sent for the remaining data. Note that
> >    res.count is NOT updated. It is still set to the actual amount of
> >    bytes we got in the first response.  The client will send a READ
> >    request for the remaining 12K.
> 
> This is looks like a real bug, but I think the "NOT" above is the best thing
> to fix.

No doubt, a real bug! Easily reproduced with an instrumented nfsd.

> i.e. when another read request is set, res.count *SHOULD*BE* updated.  That
> makes it consistent with the original send, and consistency is good!

I thought about it, but the resp->count is NOT really used as far as I
know. And the current upstream code unconditionally sets the resp->count
in xdr function. So I chose the upstream method! I agree, your patch is
more consistent with the existing code.

> Index: linux-2.6.32-SLE11-SP1-LTSS/fs/nfs/read.c
> ===================================================================
> --- linux-2.6.32-SLE11-SP1-LTSS.orig/fs/nfs/read.c	2013-03-20 16:24:31.426605189 +1100
> +++ linux-2.6.32-SLE11-SP1-LTSS/fs/nfs/read.c	2013-04-11 11:19:57.670724540 +1000
> @@ -368,6 +368,7 @@ static void nfs_readpage_retry(struct rp
>  	argp->offset += resp->count;
>  	argp->pgbase += resp->count;
>  	argp->count -= resp->count;
> +	resp->count = argp->count;
>  	nfs4_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client);
>  	return;
>  out:

This patch should fix the bug as well.

> This would old affect clients with servers which would sometimes
> return partial reads, and I don't think the Linux NFS server does.
> What server have you seen this against?

We came across under Ganesha development, and I was told the same thing
that Linux NFS server doesn't do this. I didn't bother to post then, but
now we saw the same thing with linux NFS server, so I decided to post it
now. Although linux NFS server doesn't in itself create short reads but
it just calls the underlying back-end file system and sends without a
short read "check" to NFS clients. In other words, the short read
behaviour actually depends on the back-end file system rather than linux
NFS server. We saw this bug with our GPFS file system in combination
with HSM -- request for reading data on tape would fail until it is
brought back to disk.

Regards, Malahal.

