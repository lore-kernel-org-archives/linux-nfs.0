Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54873 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802Ab1KPPay (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Nov 2011 10:30:54 -0500
Date: Wed, 16 Nov 2011 10:30:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Pavel <free.lan.c2.718r@gmail.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: clients fail to reclaim locks after server reboot or manual
 sm-notify
Message-ID: <20111116153052.GA20545@fieldses.org>
References: <loom.20111114T180637-632@post.gmane.org>
 <4EC1678D.902@netapp.com>
 <4EC18E5F.4080101@netapp.com>
 <loom.20111115T142111-739@post.gmane.org>
 <4EC2DE49.5070000@netapp.com>
 <20111115221623.GA12453@fieldses.org>
 <4EC3C7BD.6060407@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EC3C7BD.6060407@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 16, 2011 at 09:25:01AM -0500, Bryan Schumaker wrote:
> Here is what I'm doing (On debian with 2.6.32):
> - (On Client) Mount the server: `sudo mount -o vers=3 
> 192.168.122.202:/home/bjschuma /mnt`
> - (On Client) Lock a file using nfs-utils/tools/locktest: `./testlk 
> /mnt/test`
> - (On Server) Call sm-notify with the server's IP address: `sudo 
> sm-notify -f -v 192.168.122.202`
> - dmesg on the client has this message:
>     lockd: spurious grace period reject?!
>     lockd: failed to reclaim lock for pid 2099 (errno -37, status 4)
> - (In wireshark) The client sends a lock request with the "Reclaim" bit 
> set to "yes" but the server replies with "NLM_DENIED_GRACE_PERIOD".

That sounds like correct server behavior to me.

Once the server ends the grace period and starts accepting regular
non-reclaim locks, there's the chance of a situation like:

	client A		client B
	--------		--------

	acquires lock

		---server reboot---
		---grace period ends---

				acquires conflicting lock
				drops conflicting lock

And if the server permits a reclaim of the original lock from client A,
then it gives client A the impression that it has held its lock
continuously over this whole time, when in fact someone else has held a
conflicting lock.

So: no non-reclaim locks are allowed outside the grace period.

If you restart the server, and *then* immediately run sm-notify while
the new nfsd is still in its grace period, I'd expect the reclaim to
succeed.

And that may be where the HA setup isn't right--if you're doing
active/passive failover, then you need to make sure you don't start nfsd
on the backup machine until just before you send the sm-notify.

--b.

> 
> Shouldn't the server be allowing the lock reclaim?  When I tried 
> yesterday using 3.0 it only triggered DNS packets, I tried again a few 
> minutes ago and got the same results that I did using .32.
