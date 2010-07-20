Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52689 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932491Ab0GTPn5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 11:43:57 -0400
Date: Tue, 20 Jul 2010 11:43:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] nfsd: fix error handling in write_ports interfaces
 (resend)
Message-ID: <20100720154316.GC28972@fieldses.org>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
 <20100720145540.GA28972@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100720145540.GA28972@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jul 20, 2010 at 10:55:40AM -0400, J. Bruce Fields wrote:
> On Mon, Jul 19, 2010 at 04:50:03PM -0400, Jeff Layton wrote:
> > This patchset is a resend of the set I sent a month or so ago, with
> > a couple of other patches to fix related problems that came to light
> > as we were discussing them.
> 
> So, rpc.nfsd starts the nfs server by more or less:
> 
> 	1. write nfs versions to /proc/fs/nfsd/versions
> 	2. write tcp socket fd to /proc/fs/nfsd/portlist
> 	3. write udp socket fd to /proc/fs/nfsd/portlist
> 	4. write number of threads to /proc/fs/nfsd/threads
> 
> A failure anywhere between step 2 and 4 leaves the server in an odd
> state: it's created, but not really running yet.
> 
> Your patches help when it's step 2 that fails.  Probably that's the most
> common case, so good.
> 
> But what if we step 3 fails?  Or rpc.nfsd encounters some other error
> between steps 2 and 4?  Does it have any way to clean up?  (Is starting
> a single thread and then stopping it the only way to destroy the server
> at that point?)  And what if rpc.nfsd is interrupted before it gets to
> step 4?
> 
> The whole interface seems strange and fragile.

Also, looking at this from userland's point of view:

	- Why am I no longer allowed to set nfs versions after writing
	  to "portlist"?
	- Why does changing threads from non-zero to zero destroy
	  portlist configuration, but not any other configuration?

It's a strange interface to use.

Maybe it would be simpler (and solve your problem) if we made the rule
that any configuration can be done as long as nrthreads is 0.  And that
lockd startup also only happens on transition between zero and nonzero
nrthreads.  ?

(On the other hand, I don't really like overloading the meaning of "echo
0 >/proc/fs/nfsd/threads".  There might be times when it's convenient to
stall the server temporarily while still keeping nfsv4 state, sockets,
etc., all up.)

--b.
