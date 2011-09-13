Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35178 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753321Ab1IMMol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 08:44:41 -0400
Date: Tue, 13 Sep 2011 08:44:41 -0400
To: Tim <supertimothy@web.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsv4 and gracetime / leasetime grace_period
Message-ID: <20110913124440.GA22118@fieldses.org>
References: <000801cc71f9$9cc45650$d64d02f0$@web.de>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <000801cc71f9$9cc45650$d64d02f0$@web.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 13, 2011 at 11:43:37AM +0200, Tim wrote:
> Hi all!
> 
> First, just a question to make clear, with nfsv4 rpc.statd and nfslock are
> not needed ? The Clients are not notified with sm-notify in case of a reboot
> - is this correct?
> But how does the notification of clients work with nfsv4?

There is no notification.  Clients poll the server regularly, and that's
how they find out there's been a reboot.

> The problem I can see is the same as described here:
> http://www.digipedia.pl/usenet/thread/18978/22974/
> 
> So we have different values:
> 
> /proc/fs/nfsd/nfsv4gracetime
> /proc/fs/nfsd/nfsv4leasetime
> /proc/sys/fs/nfs/nlm_grace_period
> 
> If I set graceteime and grace_period to a low value, I get a faster
> failover. But what do they stand for and do I need nfsv4leasetime to ?
> If I set them all to 10 seconds, could that be "dangerous" (assume the
> server can handle the additional load)?

It's probably OK.  The clients will have to send an rpc to the server at
least every 10 seconds, or they lose their state.  So if there's a
chance they wouldn't be able to get through for 10 seconds, you could
have a problem.

> I guess there isnt an easy way to delete all the locks on serverside and
> explicitely tell the clients: Hey, the server has rebooted, please get a new
> lock for all your files :-)
> I just would like to make failover a bit faster. 

We do need to think about how to make that faster, but that wouldn't be
the solution.  The problem is that the new server needs to wait before
granting any new locks or opens until it knows all the clients have had
the chance to reclaim their old ones.  The only way the server currently
hsa to do that is to wait out the grace period (== the previous server's
lease time).

--b.
