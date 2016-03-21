Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:33434 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbcCUV1k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 17:27:40 -0400
Received: by mail-yw0-f169.google.com with SMTP id h65so88136529ywe.0
        for <linux-nfs@vger.kernel.org>; Mon, 21 Mar 2016 14:27:39 -0700 (PDT)
Date: Mon, 21 Mar 2016 17:27:35 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Christian Robottom Reis <kiko@acm.org>
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Finding and breaking client locks
Message-ID: <20160321172735.7936f1f0@tlielax.poochiereds.net>
In-Reply-To: <20160321205637.GB5118@async.com.br>
References: <20160321143914.GA6397@anthem.async.com.br>
	<20160321131906.05ec478b@tlielax.poochiereds.net>
	<20160321175500.GA5118@async.com.br>
	<20160321205637.GB5118@async.com.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 21 Mar 2016 17:56:38 -0300
Christian Robottom Reis <kiko@acm.org> wrote:

> On Mon, Mar 21, 2016 at 02:55:00PM -0300, Christian Robottom Reis wrote:
> > > Alternately, there is the /proc/fs/nfsd/unlock_ip interface. Supposedly
> > > you can echo an address into there and it'll forcibly drop all of the
> > > locks that that that client holds. I've not used that so YMMV there.  
> > 
> > Oh! That's a very interesting, and I now see it documented here:
> > 
> >     http://people.redhat.com/rpeterso/Patches/NFS/NLM/004.txt  
> 
> On second look, I don't think that interface is meant to take a client
> IP, but rather a server IP:
> 
>   "They are intended to allow admin or user mode script to release NLM
>    locks based on either a path name or a server in-bound ip address[...]"
> 
> That's why echoing the client IP makes no difference.
> 
> I'm surprised -- so far I've found no facility for lock management
> server-side other than restarting the server.

Ahh that's exactly right -- my bad. I had forgotten that the idea there
was to use that for clustering.

And you're also correct that there is currently no facility for
administratively revoking locks. That's something that would be a nice
to have, if someone wanted to propose a sane interface and mechanism
for it. Solaris had such a thing, IIRC, but I don't know how it was
implemented.

There is one other option too -- you can send a SIGKILL to the lockd
kernel thread and it will drop _all_ of its locks. That sort of sucks
for all of the other clients, but it can unwedge things without
restarting NFS.

That said, your earlier email said:

> In the situation which happened today my guess (because it's a mbox
> file) is that a client ran something like mutt and the machine died
> somewhere during shutdown. It's my guess because AIUI the lock doesn't
> get stuck if the process is simply KILLed or crashes.

What should happen there is that the client notify the server when it
comes back up, so it can release its locks. That can fail to occur for
all sorts of reasons, and that leads exactly to the problem you have
now. It's also possible for the client to just drop off the net
indefinitely while holding locks in which case you're just out of luck.

It really is better to use NFSv4 if you can at all get away with it.
Lease-based locking puts the onus on the client to stay in contact with
the server if it wants to maintain its state.

-- 
Jeff Layton <jlayton@poochiereds.net>
