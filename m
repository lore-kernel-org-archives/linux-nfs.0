Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33080 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754044Ab1INChJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 22:37:09 -0400
Date: Tue, 13 Sep 2011 22:37:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: supertimothy <supertimothy@web.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsv4 and gracetime / leasetime grace_period
Message-ID: <20110914023709.GA28357@fieldses.org>
References: <000801cc71f9$9cc45650$d64d02f0$@web.de>
 <20110913124440.GA22118@fieldses.org>
 <4E6FE4D1.20209@web.de>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4E6FE4D1.20209@web.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 14, 2011 at 01:18:41AM +0200, supertimothy wrote:
> Am 13.09.2011 14:44, schrieb J. Bruce Fields:
> >On Tue, Sep 13, 2011 at 11:43:37AM +0200, Tim wrote:
> >>But how does the notification of clients work with nfsv4?
> >There is no notification.  Clients poll the server regularly, and that's
> >how they find out there's been a reboot.
> >
> Ah polling, that explains a lot.
> >>The problem I can see is the same as described here:
> >>http://www.digipedia.pl/usenet/thread/18978/22974/
> >>
> >>So we have different values:
> >>
> >>/proc/fs/nfsd/nfsv4gracetime
> >>/proc/fs/nfsd/nfsv4leasetime
> >>/proc/sys/fs/nfs/nlm_grace_period
> >>
> >>If I set graceteime and grace_period to a low value, I get a faster
> >>failover. But what do they stand for and do I need nfsv4leasetime to ?
> >>If I set them all to 10 seconds, could that be "dangerous" (assume the
> >>server can handle the additional load)?
> >It's probably OK.  The clients will have to send an rpc to the server at
> >least every 10 seconds, or they lose their state.  So if there's a
> >chance they wouldn't be able to get through for 10 seconds, you could
> >have a problem.
> Thanks for clarifying this! I brought the time down to about 15 secs
> in failover situation, that is really OK for me.
> >>I guess there isnt an easy way to delete all the locks on serverside and
> >>explicitely tell the clients: Hey, the server has rebooted, please get a new
> >>lock for all your files :-)
> >>I just would like to make failover a bit faster.
> >We do need to think about how to make that faster, but that wouldn't be
> >the solution.  The problem is that the new server needs to wait before
> >granting any new locks or opens until it knows all the clients have had
> >the chance to reclaim their old ones.  The only way the server currently
> >hsa to do that is to wait out the grace period (== the previous server's
> >lease time).
> 
> Thanks a lot for your answer Bruce!
> 
> Some more questions here - I try to unterstand this and I am a bit
> struggling with RFC3530. I'd be glad if you/someone could tell me if
> I'm wrong..
> 
> /proc/fs/nfsd/nfsv4leasetime
> The server gives out leases that are valid for this time. The client
> has to renew its lease until nfsv4leasetime times out or the server
> will release the concerning lock.
> 
> /proc/fs/nfsd/nfsv4gracetime
> After a failover (or reboot), the other server starts. As soon as it
> is up and running, the grace period starts during which no client is
> allowed to write or get a new lock. The time should be chosen so
> that all open locks can be renewed which should be possible whithin
> nfsv4leasetime, because the client has to send a RENEW until
> nfsv4leasetime is over. Thats why leasetime should be smaller than
> gracetime.
> Lets say the server needs longer than leasetime to boot. Is the
> leasetime pronlonged until the client gets a signal and then sends a
> RENEW or is it just invalid and the server has to drop the locks
> after gracetime?

The server starts its grace period timer when it starts up, it doesn't
start counting from when it last went down.  As long as it's down,
client should just be retrying rpc calls waiting for the server to
respond again.

> /proc/sys/fs/nfs/nlm_grace_period
> This is the part I don't understand what it is for. I read it has to
> be shrunk too (I set it to 10 - which works). Standard value is 0.

NLM (used with NFSv2/v3) works a little differently: instead of the
clients polling at regular intervals, the server calls back to the
clients to notify them that it has rebooted.  But there's still this
grace period, which is the length of time the NLM server waits for the
clients to act on the notifications by sending lock reclaims.

It affects v4 as well, because the v4 server can't end its grace period
before the NLM server does: if it did, v4 clients could rush in and
start doing new locks before v2/v3 clients had the chance to reclaim all
of theirs.

--b.
