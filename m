Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40790 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbcCVAaY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 20:30:24 -0400
Date: Mon, 21 Mar 2016 20:30:24 -0400
To: Christian Robottom Reis <kiko@acm.org>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Finding and breaking client locks
Message-ID: <20160322003024.GB2353@fieldses.org>
References: <20160321143914.GA6397@anthem.async.com.br>
 <20160321131906.05ec478b@tlielax.poochiereds.net>
 <20160321175500.GA5118@async.com.br>
 <20160321205637.GB5118@async.com.br>
 <20160321172735.7936f1f0@tlielax.poochiereds.net>
 <20160322000911.GA27183@chorus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160322000911.GA27183@chorus>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 21, 2016 at 09:09:11PM -0300, Christian Robottom Reis wrote:
> On Mon, Mar 21, 2016 at 05:27:35PM -0400, Jeff Layton wrote:
> > And you're also correct that there is currently no facility for
> > administratively revoking locks. That's something that would be a nice
> > to have, if someone wanted to propose a sane interface and mechanism
> > for it. Solaris had such a thing, IIRC, but I don't know how it was
> > implemented.
> 
> I might look into that -- I think the right thing to do is (as you had
> originally alluded to) dropping all locks pertaining to a specific
> client, as the only failure scenario that can't be worked around that
> I'm thinking about is the client disappearing.
> 
> I would also like to understand whether the data structure behind
> /proc/locks could be extended to provide additional metadata which
> the nfs kernel client could annotate to indicate client information.
> That would allow one to figure out who the actual culprit machine was.
> 
> > There is one other option too -- you can send a SIGKILL to the lockd
> > kernel thread and it will drop _all_ of its locks. That sort of sucks
> > for all of the other clients, but it can unwedge things without
> > restarting NFS.
> 
> That's quite useful to know, thanks -- I knew that messing with the
> initscripts responsible for the nfs kernel services "fixed" the problem,
> but killing lockd is much more convenient.
> 
> I wonder, is it normal application behaviour that any locks dropped
> would be detected and reestablished on the client side?

No, you generally don't want that--you don't want an application to
believe it's held a lock continuously when it reality it's been dropped
(and conflicting locks possibly granted and dropped) and then acquired
again.

Client behavior varies.  I believe recent linux clients should return
-EIO on subsequent attempts to use associated file descriptors after a
lock is lost.  Other OS's apparently signal the process.

--b.
