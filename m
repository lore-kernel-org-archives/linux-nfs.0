Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753714Ab2DJNNw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 09:13:52 -0400
Date: Tue, 10 Apr 2012 09:13:21 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org, jiri.horky@cesnet.cz
Subject: Re: NFSv4 high availability setups
Message-ID: <20120410091321.1be1a87e@tlielax.poochiereds.net>
In-Reply-To: <20120410125552.GC5074@ics.muni.cz>
References: <20120405103124.GV4752@ics.muni.cz>
	<20120405073901.63d1c749@tlielax.poochiereds.net>
	<20120410125552.GC5074@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 10 Apr 2012 14:55:52 +0200
Lukas Hejtmanek <xhejtman@ics.muni.cz> wrote:

> Hi Jeff, 
> 
> On Thu, Apr 05, 2012 at 07:39:01AM -0400, Jeff Layton wrote:
> > > As I understand, NFS4 uses state dir somewhere in /var/lib/nfs/rpc_pipefs.
> > > 
> > 
> > You're probably thinking of /var/lib/nfs/v4recovery.
> 
> yes, sorry for confusion.
> 
> > > Can we put this state dir on a shared volume so that this state dir is common
> > > for all the front-ends serving the same content? Is is supposed to work and
> > > NFSv4 can merge its state with existing state on a shared disk?
> > > 
> > 
> > Not properly, no. nfsd expects to have complete control over that
> > directory. There's no locking or merging of the data there. A node will
> > also clean that directory out in some cases, and that will throw your
> > state tracking off.
> 
> Thank you for information.
> 
> Is there any (preferably simple) way to demonstrate that this does not work
> properly? E.g., if I share the same export through two or more NFSv4
> front-ends that share the v4recovery directory, do I trigger problems with
> this tool http://nfsv4.bullopensource.org/tools/tests/locktest.php?
> 

Nope. It'll all work just great...until it doesn't. I don't have any
specific failure scenarios, but most of the problems will be issues
with state recovery when a server node is restarted.

That may manifest in different ways -- problems reclaiming locks for
instance, or even silent data corruption depending on the application.

For instance, a node might hand out a lock and the client release it,
after a server node reboots but before a client that really "owns" it
reclaims it. Depending on the application, that may cause serious
problems.

-- 
Jeff Layton <jlayton@redhat.com>
