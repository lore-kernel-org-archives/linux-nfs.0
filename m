From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: [NFS] SLES10 SP1 NFS setting ports .....
Date: Wed, 9 Jan 2008 13:27:53 -0500
Message-ID: <OFE438506B.9A02939C-ON852573CB.00640EAA-852573CB.00656E45@us.ibm.com>
References: <1199899950.7433.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:58721 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752335AbYAIS1r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 13:27:47 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCfeT-0002Kw-3v
	for linux-nfs@vger.kernel.org; Thu, 10 Jan 2008 05:27:45 +1100
In-Reply-To: <1199899950.7433.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

My bad here. I had the  .  and  _  incorrectly specified. I see the
kernel-parameters doc. Thanks .......

I made the changes to /etc/zipl.conf, reran zipl and rebooted. I still get
these messages at Linux IPL:

Kernel command line:
root=/dev/disk/by-id/scsi-360050768018180762800000000000328-part1 TERM=dumb
elevator=noop lockd.nlm_tcpport=2051 lockd.nlm_udpport=2051 BOOT_IMAGE=0
Unknown boot option `lockd.nlm_tcpport=2051': ignoring
Unknown boot option `lockd.nlm_udpport=2051': ignoring

Any suggestions here ????

TIA .....................

-----------------------------------------------------------------------------------------------------------------------------------
Trond responded:

The parameter names are

                lockd.nlm_tcpport
                lockd.nlm_udpport

See Documentation/kernel-parameters.txt for more information (and the
full list parameters that are supported).
--------------------------------------------------------------------------------------------------------------------------------------
> I have been able to set specific ports for lockd on SLES8 and SLES9
thanks
> to Neil Brown assistance but I see that with SLES10 it looks like the NFS
> version is newer and it does not like the kernel parms lockd_nlm.tcpport
> and lockd_nlm.udpport used in SLES9.
>
> I receive:  'Unknown boot option 'lockd_nlm.tcpport=xxxx' : ignoring
>             'Unknown boot option 'lockd_nlm.udpport=xxxx' : ignoring
-------------------------------------------------------------------------------------------------------------------------------------------


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

