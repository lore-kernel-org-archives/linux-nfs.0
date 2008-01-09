From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] SLES10 SP1 NFS setting ports .....
Date: Wed, 09 Jan 2008 13:39:35 -0500
Message-ID: <1199903975.7433.22.camel@heimdal.trondhjem.org>
References: <OFE438506B.9A02939C-ON852573CB.00640EAA-852573CB.00656E45@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Terry Spaulding <spauld@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44280 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753919AbYAISj7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 13:39:59 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCfqG-0002OI-AA
	for linux-nfs@vger.kernel.org; Thu, 10 Jan 2008 05:39:56 +1100
In-Reply-To: <OFE438506B.9A02939C-ON852573CB.00640EAA-852573CB.00656E45@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-01-09 at 13:27 -0500, Terry Spaulding wrote:
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

Hmm. I don't have a copy of SLES10 with which to test, but I assume that
lockd is compiled as a module, named 'lockd' right? I'm wondering if the
above message just means that the kernel doesn't parse the options
because the module isn't loaded yet.

What happens when you do load the lockd module, and then start nfsd or
mount an nfs partition? Does 'rpcinfo -p' show lockd listening on any
other ports.

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

