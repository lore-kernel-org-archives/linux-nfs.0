From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: [NFS] SLES10 SP1 NFS setting ports .....
Date: Wed, 9 Jan 2008 14:56:26 -0500
Message-ID: <OF8E5CF9B2.F07234A5-ON852573CB.006D6181-852573CB.006D89C2@us.ibm.com>
References: <1199903975.7433.22.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:33958 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026AbYAITz7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 14:55:59 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCh1p-0002xo-8v
	for linux-nfs@vger.kernel.org; Thu, 10 Jan 2008 06:55:57 +1100
In-Reply-To: <1199903975.7433.22.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ps.

I did an lsmod while the NFS filesystem is mounted on the Client and I see
the lockd module loaded

-----------------------------------------------------------------------------------------------------------------------------------------------------
Yes, If I mount and NFS filesystem on the client and issue rpcinfo -p I see
random ports for udp and tcp assigned to the nlockmngr.

I am using the supplied kernel.

How can I tell the module was compiled as lockd ? I assume it is setup
similar to how SLES9 and SLES8 was where the lockd is compiled in the
kernel
and requires the kernel parms in /etc/zipl.conf if you want to force it to
use specific ports for firewall purposes.

Thanks .................
------------------------------------------------------------------------------------------------------------------------------------------
Trond responds:

Hmm. I don't have a copy of SLES10 with which to test, but I assume that
lockd is compiled as a module, named 'lockd' right? I'm wondering if the
above message just means that the kernel doesn't parse the options
because the module isn't loaded yet.

What happens when you do load the lockd module, and then start nfsd or
mount an nfs partition? Does 'rpcinfo -p' show lockd listening on any
other ports.
------------------------------------------------------------------------------------------------------------------------------------------

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

