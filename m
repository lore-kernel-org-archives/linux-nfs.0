Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932356Ab0GTPnQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 11:43:16 -0400
Date: Tue, 20 Jul 2010 11:43:13 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] nfsd: fix error handling in write_ports interfaces
 (resend)
Message-ID: <20100720114313.78509cbb@tlielax.poochiereds.net>
In-Reply-To: <20100720145540.GA28972@fieldses.org>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
	<20100720145540.GA28972@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 20 Jul 2010 10:55:40 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

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

Yep.

> Your patches help when it's step 2 that fails.  Probably that's the most
> common case, so good.
> 
> But what if we step 3 fails?  Or rpc.nfsd encounters some other error
> between steps 2 and 4?  Does it have any way to clean up?  (Is starting
> a single thread and then stopping it the only way to destroy the server
> at that point?)  And what if rpc.nfsd is interrupted before it gets to
> step 4?
> 

Then the server will remain "created", lockd will be up, etc and the
refcount will stay at 0. I think starting a single thread and stopping
it is the only way to clean it up.

> The whole interface seems strange and fragile.
> 
> The correct thing may be to apply your patches anyway, as long as they
> solve a problem and don't make things any worse.
> 
> But I fear we'll be spending more time on corner cases in the future.
> 
> As a first exercise, maybe we should figure out how the interface would
> look if we had the opportunity to start over from scratch.
> 

I wholeheartedly agree. This set is essentially a bandaid and I think
it helps the basic problems but there are plenty of others.

I'm all for redesigning the innards for better fault tolerance, but I
think we ought to shoot for not changing the userspace interface unless
there's just no other way, or it provides a substantial "win".

I think we could fix this in a much better way by not creating the
nfsd_serv until threads need to be started. 

Basically just have write_ports add socket info to a global list rather
than to the nfsd_serv itself. When nfsd_serv is created, we'd walk that
list and add those sockets to the nfsd_serv.

Any time that the portlist file is written to, we'd check to see if
nfsd is up. If it is then sync up the nfsd sockets with the contents of
the list.

-- 
Jeff Layton <jlayton@redhat.com>
