From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] SLES10 SP1 NFS setting ports .....
Date: Wed, 09 Jan 2008 15:22:45 -0500
Message-ID: <1199910165.10701.3.camel@heimdal.trondhjem.org>
References: <OF8E5CF9B2.F07234A5-ON852573CB.006D6181-852573CB.006D89C2@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Terry Spaulding <spauld@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:59040 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755394AbYAIUXR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 15:23:17 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JChSE-0003C3-Oh
	for linux-nfs@vger.kernel.org; Thu, 10 Jan 2008 07:23:14 +1100
In-Reply-To: <OF8E5CF9B2.F07234A5-ON852573CB.006D6181-852573CB.006D89C2@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-01-09 at 14:56 -0500, Terry Spaulding wrote:
> ps.
> 
> I did an lsmod while the NFS filesystem is mounted on the Client and I see
> the lockd module loaded

What does 'modinfo lockd' say?

Cheers
  Trond



-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

