From: "David Konerding" <dakoner@gmail.com>
Subject: Re: [NFS] I/O Errors with hard mounts
Date: Wed, 4 Jun 2008 15:56:10 -0700
Message-ID: <4f0f0cb0806041556y28fa0d2dxecbec0bc3f43ad81@mail.gmail.com>
References: <927260.87785.qm@web31407.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:41335 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757958AbYFDW4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2008 18:56:23 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K41tz-0002cI-Mm
	for linux-nfs@vger.kernel.org; Thu, 05 Jun 2008 08:56:19 +1000
In-Reply-To: <927260.87785.qm-KtJlQ5K7SlOvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 4, 2008 at 3:45 PM, Ricardo Labiaga <labiaga@yahoo.com> wrote:
> Does /var/log/messages show any errors around the same time?  In addition to the network trace and rpcdebug on the client, take a look at "nfsstat -d" on the filer. Is the filer dropping the connection?  Look for "dropped with EAGAIN" or "dropped from vol offline" in the output.  This will help narrow down the problem.

So, sometimes when somebody deletes a lot of data (like the problem we
just observed),
the deleting host, and often other hosts, do report  'filer not
responding' in the logs.
However, operations that aren't happening in the delete dir, tend to
work just fine (for example, iozone could be running and doing pretty
well)).  Further, the most recent time this happened, the host didn't
report filer not responding.


This is the only EAGAN reference I see:

assist queue (queued, split mbufs, drop for EAGAIN) = (0, 64478612, 94340)


Dave

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

