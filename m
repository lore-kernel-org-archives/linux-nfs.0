From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] SLES10 SP1 NFS setting ports .....
Date: Wed, 09 Jan 2008 12:32:30 -0500
Message-ID: <1199899950.7433.3.camel@heimdal.trondhjem.org>
References: <OFD7C84CE4.BF64E3AC-ON852573CB.005625AE-852573CB.005A14F9@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Terry Spaulding <spauld@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:35646 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567AbYAIRcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 12:32:52 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCenK-0002GK-AT
	for linux-nfs@vger.kernel.org; Thu, 10 Jan 2008 04:32:50 +1100
In-Reply-To: <OFD7C84CE4.BF64E3AC-ON852573CB.005625AE-852573CB.005A14F9@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-01-09 at 11:23 -0500, Terry Spaulding wrote:
> List,
> 
> I have a newly installed SLES10 SP1 system with kernel 2.16.46.-0.12 and
> nfs-utils-1.0.7-36.21.
> 
> I assume that this version of nfs-utils is NFS v4 ?
> 
> This SLES10 SP1 system is a NFS Client. The current NFS server is a SLES9
> system.
> 
> I have been able to set specific ports for lockd on SLES8 and SLES9 thanks
> to Neil Brown assistance but I see that with SLES10 it looks like the NFS
> version is newer and it does not like the kernel parms lockd_nlm.tcpport
> and lockd_nlm.udpport used in SLES9.
> 
> I receive:  'Unknown boot option 'lockd_nlm.tcpport=xxxx' : ignoring
>             'Unknown boot option 'lockd_nlm.udpport=xxxx' : ignoring

The parameter names are

                lockd.nlm_tcpport
                lockd.nlm_udpport

See Documentation/kernel-parameters.txt for more information (and the
full list parameters that are supported).

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

