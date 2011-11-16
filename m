Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:61665 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757648Ab1KPRPn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2011 12:15:43 -0500
Received: by ggnb2 with SMTP id b2so9052259ggn.19
        for <linux-nfs@vger.kernel.org>; Wed, 16 Nov 2011 09:15:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111116153052.GA20545@fieldses.org>
References: <loom.20111114T180637-632@post.gmane.org>
	<4EC1678D.902@netapp.com>
	<4EC18E5F.4080101@netapp.com>
	<loom.20111115T142111-739@post.gmane.org>
	<4EC2DE49.5070000@netapp.com>
	<20111115221623.GA12453@fieldses.org>
	<4EC3C7BD.6060407@netapp.com>
	<20111116153052.GA20545@fieldses.org>
Date: Wed, 16 Nov 2011 19:15:42 +0200
Message-ID: <CAA-yEOLE=j2uArOQimnVdwF1jjx-RWU712==2PQGf49AB30RuA@mail.gmail.com>
Subject: Re: clients fail to reclaim locks after server reboot or manual sm-notify
From: Pasha Z <free.lan.c2.718r@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2011/11/16 J. Bruce Fields <bfields@fieldses.org>:
> On Wed, Nov 16, 2011 at 09:25:01AM -0500, Bryan Schumaker wrote:
>> Here is what I'm doing (On debian with 2.6.32):
>> - (On Client) Mount the server: `sudo mount -o vers=3
>> 192.168.122.202:/home/bjschuma /mnt`
>> - (On Client) Lock a file using nfs-utils/tools/locktest: `./testlk
>> /mnt/test`
>> - (On Server) Call sm-notify with the server's IP address: `sudo
>> sm-notify -f -v 192.168.122.202`
>> - dmesg on the client has this message:
>>     lockd: spurious grace period reject?!
>>     lockd: failed to reclaim lock for pid 2099 (errno -37, status 4)
>> - (In wireshark) The client sends a lock request with the "Reclaim" bit
>> set to "yes" but the server replies with "NLM_DENIED_GRACE_PERIOD".
>
> That sounds like correct server behavior to me.
>
> Once the server ends the grace period and starts accepting regular
> non-reclaim locks, there's the chance of a situation like:
>
>        client A                client B
>        --------                --------
>
>        acquires lock
>
>                ---server reboot---
>                ---grace period ends---
>
>                                acquires conflicting lock
>                                drops conflicting lock
>
> And if the server permits a reclaim of the original lock from client A,
> then it gives client A the impression that it has held its lock
> continuously over this whole time, when in fact someone else has held a
> conflicting lock.

Hm...This is how NFS behaves on real server reboot:

client A                client B
   --------                --------
       ---server started, serving regular locks---
acquires lock

       ---server rebooted--- (at this point sm-notify is called automatically)
client A reacquires lock
      ---grace period ends---

                           cannot acquire lock,
                           client A is holding it.

Shouldn't manual 'sm-notify -f' behave as the same way
as real server reboot?
I can't see how your example can take place.
If client B acquires lock, then client A has to have
released it some time before.

>
> So: no non-reclaim locks are allowed outside the grace period.

I'm sorry, is that what you meant?
>
> If you restart the server, and *then* immediately run sm-notify while
> the new nfsd is still in its grace period, I'd expect the reclaim to
> succeed.
>
> And that may be where the HA setup isn't right--if you're doing
> active/passive failover, then you need to make sure you don't start nfsd
> on the backup machine until just before you send the sm-notify.
>
As of HA setup. It is as follows, so you can understand, what I plan to use
sm-notify for:

Some background:

I'm building an Active/Active NFS cluster and nfs-kernel-server is
always running
on all nodes. Note: each node in cluster exports shares, different from
other nodes (they do not overlap), so clients never access same files through
more than one server node and a usual file system (not cluster one) is
used for storage.
What I'm doing is moving NFS share (with resources underneath: virtual
IP, drbd storage)
between the nodes with exportfs OCF resource agent.

This is how this setup is described here: http://ben.timby.com/?p=109

/*-----
I have need for an active-active NFS cluster. For review, and active-active
cluster is two boxes that export two resources (one each). Each box acts as a
backup for the other box’s resource. This way, both boxes actively
serve clients
 (albeit for different NFS exports).

*** To be clear, this means that half my users use Volume A and half
of them use
 Volume B. Server A exports Volume A and Server B exports Volume B. If server A
fails, Server B will export both volumes. I use DRBD to synchronize the primary
server to the secondary server, for each volume. You can think of this like
cross-replication, where Server A replicates changes to Volume A to Server B. I
hope this makes it clear how this setup works. ***
-----*/

The goal:

The solution by the link above allows to move NFS shares between the nodes, but
doesn't support locking. Therefore I'll need to inform clients when share
migrates to the other node (due to a node failure or manually), so
that they can
 reclaim locks (given that files from /var/lib/nfs/sm are transferred to the
other node).

The problem:

When I run sm-notify manually ('sm-notify -f -v <virtual IP of
share>'), clients
 fail to reclaim locks. The log on the client looks like this:

lockd: request from 127.0.0.1, port=637
lockd: SM_NOTIFY     called
lockd: host B (192.168.0.110) rebooted, cnt 2
lockd: get host B
lockd: get host B
lockd: release host B
lockd: reclaiming locks for host B
lockd: rebind host B
lockd: call procedure 2 on B
lockd: nlm_bind_host B (192.168.0.110)
lockd: server in grace period
lockd: spurious grace period reject?!
lockd: failed to reclaim lock for pid 2508 (errno -37, status 4)
NLM: done reclaiming locks for host B
lockd: release host B

!However, this happens even in case of a standard single-machine
NFS server!

The Active/Passive setup you have described is known to work.

> --b.
>
>>
>> Shouldn't the server be allowing the lock reclaim?  When I tried
>> yesterday using 3.0 it only triggered DNS packets, I tried again a few
>> minutes ago and got the same results that I did using .32.
>
