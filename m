Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:55911 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758524AbcCaUxh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2016 16:53:37 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'NeilBrown'" <neilb@suse.com>, "'Jeff Layton'" <jlayton@poochierds.net>,
        "'Christian Robottom Reis'" <kiko@acm.org>
Cc: "'NFS List'" <linux-nfs@vger.kernel.org>
References: <20160321143914.GA6397@anthem.async.com.br> <20160321131906.05ec478b@tlielax.poochiereds.net> <20160321175500.GA5118@async.com.br> <20160321205637.GB5118@async.com.br> <20160321172735.7936f1f0@tlielax.poochiereds.net> <87h9fns03o.fsf@notabene.neil.brown.name>
In-Reply-To: <87h9fns03o.fsf@notabene.neil.brown.name>
Subject: RE: Finding and breaking client locks
Date: Thu, 31 Mar 2016 13:52:56 -0700
Message-ID: <024101d18b8f$4e104b90$ea30e2b0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Tue, Mar 22 2016, Jeff Layton wrote:
> 
> > On Mon, 21 Mar 2016 17:56:38 -0300
> > Christian Robottom Reis <kiko-HInyCGIudOg@public.gmane.org> wrote:
> >
> >> On Mon, Mar 21, 2016 at 02:55:00PM -0300, Christian Robottom Reis
> wrote:
> >> > > Alternately, there is the /proc/fs/nfsd/unlock_ip interface.
> >> > > Supposedly you can echo an address into there and it'll forcibly
> >> > > drop all of the locks that that that client holds. I've not used
that so
> YMMV there.
> >> >
> >> > Oh! That's a very interesting, and I now see it documented here:
> >> >
> >> >     http://people.redhat.com/rpeterso/Patches/NFS/NLM/004.txt
> >>
> >> On second look, I don't think that interface is meant to take a
> >> client IP, but rather a server IP:
> >>
> >>   "They are intended to allow admin or user mode script to release NLM
> >>    locks based on either a path name or a server in-bound ip
address[...]"
> >>
> >> That's why echoing the client IP makes no difference.
> >>
> >> I'm surprised -- so far I've found no facility for lock management
> >> server-side other than restarting the server.
> >
> > Ahh that's exactly right -- my bad. I had forgotten that the idea
> > there was to use that for clustering.
> >
> > And you're also correct that there is currently no facility for
> > administratively revoking locks. That's something that would be a nice
> > to have, if someone wanted to propose a sane interface and mechanism
> > for it.
> 
> I was all set to give you an answer until I saw that word "sane"... nearly
> scared me off, but I chose to persist.
> 
> You know this, but let me remind you and inform Christian.
> 
> When an NFS client ("bob") asks the NFS server ("jane") to lock a file
(the
> first time), the kernel says to statd "Hey, Bob wants a lock.
> Can you keep and eye on him and let me know when he reboots - when he
> does I want to discard his locks".
> 
> So statd on Jane talks to statd on Bob saying "Hey Bob, tell me if you
ever
> reboot - OK"?  Bob takes note of this request by writing "Jane" in
> /var/lib/nfs/sm.

Actually, Jane's statd and Bob's statd don't talk until one of them comes
back up after reboot...

The actual process is:

1. application on Bob makes a lock request on a mount from jane
2. Bob's lockd asks Bob's statd to record jane as a party of interest after
reboot
3. Bob's lockd requests lock from Jane's lockd
4. Jane's lockd asks Jane's statd to record Bob as a party of interest after
reboot 
5. Jane's lockd completes lock request and responds to Bob's lockd
6. Bob crashes
7. Jane is oblivious to this crash for now...
8. Bob restarts and Bob's statd NOW sends a message to Jane's statd that it
rebooted
9 Jane's statd notes that Jane's lockd took and interest in Bob, and passes
on the fact that Bob rebooted
10. Jane's lockd cleans up the lock

> When Bob reboots, sm-notify sees "Jane" in /var/lib/nfs/sm and sends a
> message to statd on Jane "Hey Jane, Bob just rebooted.  You're welcome".
> 
> statd on Jane then tells the kernel "Bob rebooted" and the kernel drops
all
> those locks.
> 
> And there, in that last step, we see the key.  It is already possible to
tell the
> kernel "drop all the locks held by Bob", you just have to say "Hey, I'm
statd -
> Bob rebooted".  Or maybe we could stay to statd "Hi Jane, this is Bob, I
just
> rebooted" - even though we aren't really Bob.

Yes, either of those would work. I'm pretty sure there are tools out there
that do this.

What is sometimes more interesting to sysadmins is being able to free up a
specific lock rather than ALL locks held by that client.

> (Or we could just reboot Bob and let it do the talking).
> 
> I'd have to hunt through the statd code to figure out what is possible and
> what is best.  It can't be too hard though.
> 
> Christian:  If the problem client actually comes back up (instead of
staying
> down) do the locks get drops as they should?
> 
> NeilBrown


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

