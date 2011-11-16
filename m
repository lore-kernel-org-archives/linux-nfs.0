Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:46013 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383Ab1KPTJI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2011 14:09:08 -0500
Received: by ywt32 with SMTP id 32so38694ywt.19
        for <linux-nfs@vger.kernel.org>; Wed, 16 Nov 2011 11:09:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EC3F4E3.7050803@netapp.com>
References: <loom.20111114T180637-632@post.gmane.org>
	<4EC1678D.902@netapp.com>
	<4EC18E5F.4080101@netapp.com>
	<loom.20111115T142111-739@post.gmane.org>
	<4EC2DE49.5070000@netapp.com>
	<20111115221623.GA12453@fieldses.org>
	<4EC3C7BD.6060407@netapp.com>
	<20111116153052.GA20545@fieldses.org>
	<4EC3F4E3.7050803@netapp.com>
Date: Wed, 16 Nov 2011 21:09:07 +0200
Message-ID: <CAA-yEOLYRSxxOWPEe+e_C4T=qkQcKenzw=PNjq4cACYYXA8ncA@mail.gmail.com>
Subject: Re: clients fail to reclaim locks after server reboot or manual sm-notify
From: Pavel A <free.lan.c2.718r@gmail.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@...> writes:

>
> On Wed, Nov 16, 2011 at 07:15:42PM +0200, Pasha Z wrote:
> > 2011/11/16 J. Bruce Fields <bfields@...>:
> > > On Wed, Nov 16, 2011 at 09:25:01AM -0500, Bryan Schumaker wrote:
> > >> Here is what I'm doing (On debian with 2.6.32):
> > >> - (On Client) Mount the server: `sudo mount -o vers=3
> > >> 192.168.122.202:/home/bjschuma /mnt`
> > >> - (On Client) Lock a file using nfs-utils/tools/locktest: `./testlk
> > >> /mnt/test`
> > >> - (On Server) Call sm-notify with the server's IP address: `sudo
> > >> sm-notify -f -v 192.168.122.202`
> > >> - dmesg on the client has this message:
> > >>     lockd: spurious grace period reject?!
> > >>     lockd: failed to reclaim lock for pid 2099 (errno -37, status 4)
> > >> - (In wireshark) The client sends a lock request with the "Reclaim" bit
> > >> set to "yes" but the server replies with "NLM_DENIED_GRACE_PERIOD".
> > >
> > > That sounds like correct server behavior to me.
> > >
> > > Once the server ends the grace period and starts accepting regular
> > > non-reclaim locks, there's the chance of a situation like:
> > >
> > >        client A                client B
> > >        --------                --------
> > >
> > >        acquires lock
> > >
> > >                ---server reboot---
> > >                ---grace period ends---
> > >
> > >                                acquires conflicting lock
> > >                                drops conflicting lock
> > >
> > > And if the server permits a reclaim of the original lock from client A,
> > > then it gives client A the impression that it has held its lock
> > > continuously over this whole time, when in fact someone else has held a
> > > conflicting lock.
> >
> > Hm...This is how NFS behaves on real server reboot:
> >
> > client A                client B
> >    --------                --------
> >        ---server started, serving regular locks---
> > acquires lock
> >
> >        ---server rebooted--- (at this point sm-notify is called automatically)
> > client A reacquires lock
> >       ---grace period ends---
> >
> >                            cannot acquire lock,
> >                            client A is holding it.
>
> Yes.
>
> >
> > Shouldn't manual 'sm-notify -f' behave as the same way
> > as real server reboot?
>
> No, sm-notify does *not* restart knfsd (so does not cause knfsd to drop
> existing locks or to enter a new grace period).  It *only* sends NSM
> notifications.

Thank you for the explanation.

>
> > I can't see how your example can take place.
> > If client B acquires lock, then client A has to have
> > released it some time before.
>
> No, in my example above, there is a real server reboot; client A's lock
> is lost in the reboot, it does not reclaim the lock in time, and so
> client B is able to grab the lock.
>

I've read about this issue here:
http://www.time-travellers.org/shane/papers/NFS_considered_harmful.html

/*-----
In the event of server failure (e.g. server reboot or lock daemon
restart), all client locks are lost. However, the clients are not
informed of this, and because the other operations (read, write, and
so on) are not visibly interrupted, they have no reliable way to
prevent other clients from obtaining a lock on a file they think they
have locked.
-----*/

Can't get this. If there is a grace period after reboot and clients
can successfully reclaim locks, then how other clients can obtain
locks?
Can you please explain when does this happen, if you've answered 'Yes'
to my example and your example is a real server reboot.

> > > So: no non-reclaim locks are allowed outside the grace period.
> >
> > I'm sorry, is that what you meant?
>
> To restate it ing different words: locks with the reclaim bit will fail
> outside of the grace period.

I've got it now, thanks.

>
> > As of HA setup. It is as follows, so you can understand, what I plan to use
> > sm-notify for:
> >
> > Some background:
> >
> > I'm building an Active/Active NFS cluster and nfs-kernel-server is
> > always running
> > on all nodes. Note: each node in cluster exports shares, different from
> > other nodes (they do not overlap), so clients never access same files through
> > more than one server node and a usual file system (not cluster one) is
> > used for storage.
> > What I'm doing is moving NFS share (with resources underneath: virtual
> > IP, drbd storage)
> > between the nodes with exportfs OCF resource agent.
> >
> > This is how this setup is described here: http://ben.timby.com/?p=109
> >
> > /*-----
> > I have need for an active-active NFS cluster. For review, and active-active
> > cluster is two boxes that export two resources (one each). Each box acts as a
> > backup for the other box’s resource. This way, both boxes actively
> > serve clients
> >  (albeit for different NFS exports).
> >
> > *** To be clear, this means that half my users use Volume A and half
> > of them use
> >  Volume B. Server A exports Volume A and Server B exports Volume B. If server A
> > fails, Server B will export both volumes. I use DRBD to synchronize the primary
> > server to the secondary server, for each volume. You can think of this like
> > cross-replication, where Server A replicates changes to Volume A to Server B. I
> > hope this makes it clear how this setup works. ***
> > -----*/
> >
> > The goal:
> >
> > The solution by the link above allows to move NFS shares between the nodes, but
> > doesn't support locking. Therefore I'll need to inform clients when share
> > migrates to the other node (due to a node failure or manually), so
> > that they can
> >  reclaim locks (given that files from /var/lib/nfs/sm are transferred to the
> > other node).
> >
> > The problem:
> >
> > When I run sm-notify manually ('sm-notify -f -v <virtual IP of
> > share>'), clients
> >  fail to reclaim locks. The log on the client looks like this:
> >
> > lockd: request from 127.0.0.1, port=637
> > lockd: SM_NOTIFY     called
> > lockd: host B (192.168.0.110) rebooted, cnt 2
> > lockd: get host B
> > lockd: get host B
> > lockd: release host B
> > lockd: reclaiming locks for host B
> > lockd: rebind host B
> > lockd: call procedure 2 on B
> > lockd: nlm_bind_host B (192.168.0.110)
> > lockd: server in grace period
> > lockd: spurious grace period reject?!
> > lockd: failed to reclaim lock for pid 2508 (errno -37, status 4)
> > NLM: done reclaiming locks for host B
> > lockd: release host B
>
> You need to restart nfsd on the node that is taking over.  That means
> that clients usings both filesystems (A and B) will have to do lock
> recovery, when in theory only those using volume B should have to, and
> that is suboptimal.  But it is also correct.
>

Seems to work. As of a more optimal solution: what do you think of the
contents of /proc/locks? May it be possible to use this info to then
perform locking locally on the other node (after failover)?

Thanks!

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@...
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
