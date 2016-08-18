Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59766 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404AbcHRN5z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Aug 2016 09:57:55 -0400
Date: Thu, 18 Aug 2016 09:57:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/8] mountd: remove 'dev_missing' checks
Message-ID: <20160818135754.GA21470@fieldses.org>
References: <20160714021310.5874.22953.stgit@noble>
 <20160714022643.5874.84409.stgit@noble>
 <20160718200121.GC12304@fieldses.org>
 <878twx9ra3.fsf@notabene.neil.brown.name>
 <20160721172452.GC27148@fieldses.org>
 <87wpjokofy.fsf@notabene.neil.brown.name>
 <20160816152148.GC30124@fieldses.org>
 <87bn0qj1yz.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87bn0qj1yz.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not really arguing--I'll trust your judgement--just some random ideas:

On Thu, Aug 18, 2016 at 11:32:52AM +1000, NeilBrown wrote:
> On Wed, Aug 17 2016, J. Bruce Fields wrote:
> > In which case what it really wants to say is "before nfs mounts" (or
> > even "before nfs mounts of localhost"; and vice versa on shutdown).  I
> > can't tell if there's an easy way to get say that.
> 
> I'd be happy with a difficult/complex way, if it was reliable.
> Could we write a systemd generator which parses /etc/fstab, determines
> all mount points which a loop-back NFS mounts (or even just any NFS
> mounts) and creates a drop-in for nfs-server which adds
>   Before=mount-point.mount
> for each /mount/point.
> 
> Could that be reliable?  I might try.

Digging around... we've also got this callout from mount to start-statd,
can we use something like that to make loopback nfs mounts wait on nfs
server startup?

> > Is that the only risk, though?  Maybe so--presumably you've killed any
> > users, so any write data associated with opens should be flushed.  And
> > if you do a sync after that you take care of write delegations too.
> 
> In the easily reproducible case, all user processes are gone.
> It would be worth checking what happens if processes are accessing a
> filesystem from an unreachable server at shutdown.
> "kill -9" should get rid of them all now, so it might be OK.
> "sync" would hang though.  I'd be happy for that to cause a delay of a
> minute or so, but hopefully systemd would (or could be told to) kill -9
> a sync if it took too long.

We shouldn't have to resort to that in the loopback nfs case, where we
control ordering.  So in that case, I'm just pointing out that:

	kill -9 all users of the filesystem
	shutdown nfs server
	umount nfs filesystems

isn't the right ordering, because in the presence of write delegations
there could still be writeback data.

(OK, actually, knfsd doesn't currently implement write delegations--but
we shouldn't depend on that assumption.)

Adding a sync between the first two steps might help, though the write
delegations themselves could still linger, and I don't know how the
client will behave when it finds it can't return them.

So it'd be nice if we could just order the umount before the server
shutdown.

The case of a remote server shut down too early is different of course.

> > Looking at rpcbind(8)....  Shouldn't "-w" prevent this by loading some
> > registrations before it starts responding to requests?
> 
> "-w" (which isn't listed in the SYNOPSIS!) only applies to a warm-start
> where the daemons which previously registered are still running.
> The problem case is that the daemons haven't registered yet (so we don't
> necessarily know what port number they will get).

We probably know the port in the specific case of nfsd, and could fake
up rpcbind's state file if necessary.  Eh, your idea's not as bad:

> To address the issue in rpcbind, we would need a flag to say "don't
> respond to lookup requests, just accept registrations", then when all
> registrations are complete, send some message to rpcbind to say "OK,
> respond to lookups now".  That could even be done by killing and
> restarting with "-w", though that it a bit ugly.
> 
> I'm leaning towards having mount retry after RPC_PROGNOTREGISTERED for
> fg like it does with bg.

Anyway, sounds OK to me.

--b.
