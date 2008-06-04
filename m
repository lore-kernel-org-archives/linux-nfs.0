From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] I/O Errors with hard mounts
Date: Wed, 4 Jun 2008 14:19:10 -0400
Message-ID: <A9046394-948D-4EDF-B1B2-3E3BD2C484C1@oracle.com>
References: <4f0f0cb0806040633x74fd0afbm94866cf85810f242@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "David Konerding" <dakoner@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57834 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922AbYFDSVH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2008 14:21:07 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K3xbc-0001g7-CR
	for linux-nfs@vger.kernel.org; Thu, 05 Jun 2008 04:21:04 +1000
In-Reply-To: <4f0f0cb0806040633x74fd0afbm94866cf85810f242-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 4, 2008, at 9:33 AM, David Konerding wrote:
> Hi,
>
> We have a bunch of Linux clients (SLES 10 SP1) which mount a NetApp  
> filer.
>
> When the NetApp gets very, very busy, for example, one user is
> deleting 1Tbyte of data
> while another user is doing a 30 client throughput test, it will stop
> responding to some requests.
>
> Although we are using hard mounts, some users report that during the
> hammering period, some of their
> file operations produce "I/O Error" messages on their terminal.
>
> We checked, and the hosts are indeed using hard mounting.  From our
> reading, I/O Errors
> should only ever make it back to the user if are using soft mounting.
>
> We're pretty sure the filer is not sending back an NFS_ERR response  
> (and we're
> pretty sure that wouldn't get reported to the user as an I/O Error...)
>
> At this point, we suspect there must be a path in the NFS
> implementation that returns I/O Error to user
> space even with a hard mount.
>
> Any ideas?

One place where this can occur is if XDR encoding or decoding fails.   
This is not too likely though.  I would look at the RPC client's  
decoding logic first: call_decode() and friends.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

