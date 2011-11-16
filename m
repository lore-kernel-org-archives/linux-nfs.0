Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34673 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868Ab1KPUIl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Nov 2011 15:08:41 -0500
Date: Wed, 16 Nov 2011 15:08:37 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Pavel A <free.lan.c2.718r@gmail.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: clients fail to reclaim locks after server reboot or manual
 sm-notify
Message-ID: <20111116200837.GD2955@pad.fieldses.org>
References: <loom.20111114T180637-632@post.gmane.org>
 <4EC1678D.902@netapp.com>
 <4EC18E5F.4080101@netapp.com>
 <loom.20111115T142111-739@post.gmane.org>
 <4EC2DE49.5070000@netapp.com>
 <20111115221623.GA12453@fieldses.org>
 <4EC3C7BD.6060407@netapp.com>
 <20111116153052.GA20545@fieldses.org>
 <4EC3F4E3.7050803@netapp.com>
 <CAA-yEOLYRSxxOWPEe+e_C4T=qkQcKenzw=PNjq4cACYYXA8ncA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAA-yEOLYRSxxOWPEe+e_C4T=qkQcKenzw=PNjq4cACYYXA8ncA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 16, 2011 at 09:09:07PM +0200, Pavel A wrote:
> I've read about this issue here:
> http://www.time-travellers.org/shane/papers/NFS_considered_harmful.html
> 
> /*-----
> In the event of server failure (e.g. server reboot or lock daemon
> restart), all client locks are lost. However, the clients are not
> informed of this, and because the other operations (read, write, and
> so on) are not visibly interrupted, they have no reliable way to
> prevent other clients from obtaining a lock on a file they think they
> have locked.
> -----*/

That's incorrect.  Perhaps the article is out of date, I don't know.

> Can't get this. If there is a grace period after reboot and clients
> can successfully reclaim locks, then how other clients can obtain
> locks?

That's right, in the absence of bugs, if a client succesfully reclaims a
lock, then it knows that no other client can have acquired that lock in
the interim: since the reclaim succeeded, that means the server is still
in the grace period, which means the only other locks that it has
allowed are also reclaims.  If some reclaim conflicts with this lock,
then the other client must have reclaimed a lock that it didn't actually
hold before (hence must be buggy).

> > You need to restart nfsd on the node that is taking over.  That means
> > that clients usings both filesystems (A and B) will have to do lock
> > recovery, when in theory only those using volume B should have to, and
> > that is suboptimal.  But it is also correct.
> >
> 
> Seems to work. As of a more optimal solution: what do you think of the
> contents of /proc/locks? May it be possible to use this info to then
> perform locking locally on the other node (after failover)?

No, I don't think so.  And I'd be careful about using /proc/locks for
anything but debugging.

--b.
