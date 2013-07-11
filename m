Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:41589 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755025Ab3GKOMZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jul 2013 10:12:25 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 11 Jul 2013 08:12:22 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id CA5AE6E8047
	for <linux-nfs@vger.kernel.org>; Thu, 11 Jul 2013 10:12:15 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6BECJkE211644
	for <linux-nfs@vger.kernel.org>; Thu, 11 Jul 2013 10:12:19 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6BECAu8005061
	for <linux-nfs@vger.kernel.org>; Thu, 11 Jul 2013 08:12:15 -0600
Date: Thu, 11 Jul 2013 09:12:06 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: corruption due to loss of lock
Message-ID: <20130711141206.GA14374@us.ibm.com>
References: <20130613184737.GA25713@us.ibm.com>
 <20130711071346.03b946bd@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130711071346.03b946bd@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton [jlayton@redhat.com] wrote:
> On Thu, 13 Jun 2013 13:47:37 -0500
> Malahal Naineni <malahal@us.ibm.com> wrote:
> 
> > Hi Trond,
> > 
> > I saw Bryan's patches here https://patchwork.kernel.org/patch/987402/
> > that fix issues after loss of a lock.  What is the status on this patch
> > set? Do they need more work? We have an application that uses range
> > locks on a file. Two threads from two different clients end up writing
> > to the same a file due to this bug after a lease expiry from a client.
> > 
> > Regards, Malahal.
> 
> (cc'ing Bryan since he did the original set)
> 
> Yeah, this set would be a nice thing to have. A couple of comments:
> 
> - I still think it would be best to make SIGLOST its own signal, but as
>   Bryan points out, it would need to be larger than SIGRTMAX. I'm
>   not sure that's possible on all arches with the way the RT signals
>   were done. It's probably worth investigating that though before
>   settling on SIGIO since it would be hard to change that retroactively.

Our application doesn't handle SIGIO, so it was terminating due to
SIGIO. We tested without SIGIO/SIGLOST part of the patch, it stopped
sending writes to NFS server as expected but the application didn't
receive EIO because the original patch set some task fields and didn't
call rpc_exit(). I just had to modify nfs_write_prepare() to call
rpc_exit(task) rather than modifying task status and action fields
directly.

I will post my patch after some more testing.

> 
> - This is not really a v4.1 specific thing. It should also be done for
>   v4.0 and v2/3, though the latter two really need to be done within
>   lockd.

Correct.

Regards, Malahal.

