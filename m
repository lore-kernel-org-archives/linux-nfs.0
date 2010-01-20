Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751931Ab0ATNNW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jan 2010 08:13:22 -0500
Date: Wed, 20 Jan 2010 08:13:10 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        steved@redhat.com
Subject: Re: [PATCH] mount.nfs: prefer IPv4 addresses over IPv6 (try #2)
Message-ID: <20100120081310.552da038@tlielax.poochiereds.net>
In-Reply-To: <1263934304.4920.4.camel@localhost>
References: <1263907662-19107-1-git-send-email-jlayton@redhat.com>
	<1667647A-2BB1-478D-8881-CE8EA2191F97@oracle.com>
	<20100119153826.67dd97a5@tlielax.poochiereds.net>
	<1263934304.4920.4.camel@localhost>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 19 Jan 2010 15:51:44 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Tue, 2010-01-19 at 15:38 -0500, Jeff Layton wrote: 
> > On Tue, 19 Jan 2010 10:43:34 -0500
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > > I think that doesn't describe this workaround adequately.  This is a  
> > > temporary crutch that prevents us from using IPv6 if "proto=" isn't  
> > > specified.  The underlying problem here is that nfs_lookup() returns  
> > > just one address.
> > > 
> > 
> > Yes. The best solution would be to somehow try all addresses in the
> > list until one works. That's a larger project however and we'll
> > probably need some significant kernel changes to handle that anyway.
> 
> Why would that involve kernel changes? I'm assuming that we can just
> retry the mount call if we see that the server isn't listening on a
> particular ip address+port combination.
> 
> Cheers
>   Trond
> 

True, it's not required. We could just return to userspace and have it
try again.

I think that there might be advantages to being able to pass a list of
addresses to the kernel, or overhaul the mount process to have the
kernel upcall for addresses, but it's not strictly required for this.

-- 
Jeff Layton <jlayton@redhat.com>
