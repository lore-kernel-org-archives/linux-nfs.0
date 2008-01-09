From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] SLES10 SP1 NFS setting ports .....
Date: Thu, 10 Jan 2008 09:26:06 +1100
Message-ID: <18309.18942.424543.639785@notabene.brown>
References: <1199899950.7433.3.camel@heimdal.trondhjem.org>
	<OFE438506B.9A02939C-ON852573CB.00640EAA-852573CB.00656E45@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Terry Spaulding <spauld@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44123 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751555AbYAIW0c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 17:26:32 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCjNV-0003Mz-OL
	for linux-nfs@vger.kernel.org; Thu, 10 Jan 2008 09:26:29 +1100
In-Reply-To: message from Terry Spaulding on Wednesday January 9
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday January 9, spauld@us.ibm.com wrote:
> Trond,
> 
> My bad here. I had the  .  and  _  incorrectly specified. I see the
> kernel-parameters doc. Thanks .......
> 
> I made the changes to /etc/zipl.conf, reran zipl and rebooted. I still get
> these messages at Linux IPL:
> 
> Kernel command line:
> root=/dev/disk/by-id/scsi-360050768018180762800000000000328-part1 TERM=dumb
> elevator=noop lockd.nlm_tcpport=2051 lockd.nlm_udpport=2051 BOOT_IMAGE=0
> Unknown boot option `lockd.nlm_tcpport=2051': ignoring
> Unknown boot option `lockd.nlm_udpport=2051': ignoring
> 
> Any suggestions here ????

Create a file
   /etc/modprobe.d/lockd

in it put the line

   options lockd nlm.tcpport=2051 nlm_udpport=2051

then when modprobe loads the lockd module, it will set these options.

NeilBrown

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

