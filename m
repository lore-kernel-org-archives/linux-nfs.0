Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dragon.async.com.br ([208.70.149.241]:38866 "EHLO
	dragon.async.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbcCVAJV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 20:09:21 -0400
Date: Mon, 21 Mar 2016 21:09:11 -0300
From: Christian Robottom Reis <kiko@acm.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Finding and breaking client locks
Message-ID: <20160322000911.GA27183@chorus>
References: <20160321143914.GA6397@anthem.async.com.br>
 <20160321131906.05ec478b@tlielax.poochiereds.net>
 <20160321175500.GA5118@async.com.br>
 <20160321205637.GB5118@async.com.br>
 <20160321172735.7936f1f0@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160321172735.7936f1f0@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 21, 2016 at 05:27:35PM -0400, Jeff Layton wrote:
> And you're also correct that there is currently no facility for
> administratively revoking locks. That's something that would be a nice
> to have, if someone wanted to propose a sane interface and mechanism
> for it. Solaris had such a thing, IIRC, but I don't know how it was
> implemented.

I might look into that -- I think the right thing to do is (as you had
originally alluded to) dropping all locks pertaining to a specific
client, as the only failure scenario that can't be worked around that
I'm thinking about is the client disappearing.

I would also like to understand whether the data structure behind
/proc/locks could be extended to provide additional metadata which
the nfs kernel client could annotate to indicate client information.
That would allow one to figure out who the actual culprit machine was.

> There is one other option too -- you can send a SIGKILL to the lockd
> kernel thread and it will drop _all_ of its locks. That sort of sucks
> for all of the other clients, but it can unwedge things without
> restarting NFS.

That's quite useful to know, thanks -- I knew that messing with the
initscripts responsible for the nfs kernel services "fixed" the problem,
but killing lockd is much more convenient.

I wonder, is it normal application behaviour that any locks dropped
would be detected and reestablished on the client side?

> > In the situation which happened today my guess (because it's a mbox
> > file) is that a client ran something like mutt and the machine died
> > somewhere during shutdown. It's my guess because AIUI the lock doesn't
> > get stuck if the process is simply KILLed or crashes.
> 
> What should happen there is that the client notify the server when it
> comes back up, so it can release its locks. That can fail to occur for
> all sorts of reasons, and that leads exactly to the problem you have
> now. It's also possible for the client to just drop off the net
> indefinitely while holding locks in which case you're just out of luck.

That's quite interesting. I had initially thought that a misbehaved
application could die while holding a lock, but it seems as though the
client kernel tracks any remote locks held and releases them regardless
of how the process dies. It seems like the actual problem scenarios are:

    - Client disappears off the net while holding a lock
    - Client kernel fails to clear NFS locks (likely a bug)
    - Rogue or misbehaved client holds a lock indefinitely

In any of these cases, the useful thing to know is which client actually
holds the lock.

> It really is better to use NFSv4 if you can at all get away with it.
> Lease-based locking puts the onus on the client to stay in contact with
> the server if it wants to maintain its state.

I considered moving a few times, but the setup here is a bit fragile and
AIUI NFSv4 isn't a straight drop-in for v3. Beyond modifying nfsvers,
IIRC at least idmapd needed to be set up and perhaps there was more.
-- 
Christian Robottom Reis | [+55 16] 3376 0125   | http://async.com.br/~kiko
                        | [+55 16] 991 126 430 | http://launchpad.net/~kiko
