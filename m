Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:4475 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757517Ab3EaXYF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 May 2013 19:24:05 -0400
Date: Fri, 31 May 2013 19:24:03 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Bram Vandoren <brambi@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Message-ID: <785211889.113142.1370042643416.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <CACQjR_CsRY4O+S1Zx-QabXYBUtRMKHa8o7ymCmLqSHa9UdgNFQ@mail.gmail.com>
Subject: Re: NFS client hangs after server reboot
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bram Vandoren wrote:
> > Did both the client and server have the same IP addresses before the
> > reboot?
> 
> Yes.
> 
> > If not, the Linux client's nfs_client_id4.id SetClientID argument
> > will be different (it has the client/side IP# in it).
> > nfs_client_id4.id
> > isn't supposed to change for a given client when it is rebooted.
> > That will make the FreeBSD NFSv4 server see "new client" (which is
> > not in the
> > stablerestart file used to avoid certain reboot edge conditions) and
> > will not give it a grace period.
> > This is the only explanation I can think of for the NFS4ERR_NO_GRACE
> > reply shortly after the reboot.
> 
> I checked some other clients and they all receive the
> NFS4ERR_NO_GRACE response from the server. It's not unique for the
> clients that hang. I was unable to reproduce this is a minimal test
> configuration. Perhaps the nfs-stablerestart file is corrupt on the
> server?
> 
> I checked
> strings nfs-stablerestart
> and I see a lot of duplicate entries. In total there are ~10000 lines
> but we only have ~50 clients.
> Most clients have 3 types of entries:
> Linux NFSv4.0 a.b.c.d/e.f.g.h tcp
> Linux NFSv4.0 a.b.c.d/e.f.g.h tcp*
> Linux NFSv4.0 a.b.c.d/e.f.g.h tcp+
> 
I'll take a look. I wrote that code about 10 years ago, so I don't remember
all the details w.r.t. the records in the stable restart file. If you truncate
the file, there won't be any recovery on the next reboot, so you need to
unmount all the NFSv4 mounts on it before rebooting for that case.

What you packet trace didn't indicate was when the server was rebooted vs
when the client sent it a SYN that started a new connection. During the
approx. 4400 sec the server was down there should have been repeated attempts
to connect to it (basically a TCP packet with SYN in it) at least once every
30sec. Basically, after the server reboots, the client must establish a TCP
connection and attempt recovery within 2 minutes or it just isn't going to
work.

Btw, server reboot recovery doesn't get a lot of testing. Some of that is
logistics (no one pays for FreeBSD NFS development, etc) and the rest is that
most assume a server will remain up for months/years at a time. If the FreeBSD
server is crashing, you need to try and resolve that. If the approx. 4400 sec
downtime was a scheduled maintenance type of thing, you should consider unmounting
the volumes before the server is shut down and doing fresh mounts after it
is rebooted.

rick

> Again, thanks a lot for looking into this.
> 
> Bram.
