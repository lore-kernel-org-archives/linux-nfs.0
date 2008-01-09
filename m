From: Terry Spaulding <spauld@us.ibm.com>
Subject: [NFS] SLES10 SP1 NFS setting ports .....
Date: Wed, 9 Jan 2008 11:23:56 -0500
Message-ID: <OFD7C84CE4.BF64E3AC-ON852573CB.005625AE-852573CB.005A14F9@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:35656 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720AbYAIQXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 11:23:43 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCdiO-0002Bj-Gk
	for linux-nfs@vger.kernel.org; Thu, 10 Jan 2008 03:23:40 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


List,

I have a newly installed SLES10 SP1 system with kernel 2.16.46.-0.12 and
nfs-utils-1.0.7-36.21.

I assume that this version of nfs-utils is NFS v4 ?

This SLES10 SP1 system is a NFS Client. The current NFS server is a SLES9
system.

I have been able to set specific ports for lockd on SLES8 and SLES9 thanks
to Neil Brown assistance but I see that with SLES10 it looks like the NFS
version is newer and it does not like the kernel parms lockd_nlm.tcpport
and lockd_nlm.udpport used in SLES9.

I receive:  'Unknown boot option 'lockd_nlm.tcpport=xxxx' : ignoring
            'Unknown boot option 'lockd_nlm.udpport=xxxx' : ignoring

I have not been successful in finding out what the kernel parameters would
be to implement specific ports for lockd on SLES10 SP1.

Can anyone give me an example of the kernel parm needed to set a specific
lockd port on SLES10 SP1 ?

This is required to get thru the Firewalls.

TIA .........................

Regards,
Terry L. Spaulding
IBM ITS
spauld@us.ibm.com


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

