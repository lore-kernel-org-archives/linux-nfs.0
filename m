From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: [NFS] SLES10 SP1 NFS setting ports .....
Date: Thu, 10 Jan 2008 08:29:23 -0500
Message-ID: <OFFA3F71BE.9EFD6CBE-ON852573CC.0049CD1E-852573CC.004A1A2A@us.ibm.com>
References: <18309.18942.424543.639785@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:55459 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754266AbYAJNaO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jan 2008 08:30:14 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCxU1-0004gP-Iv
	for linux-nfs@vger.kernel.org; Fri, 11 Jan 2008 00:30:09 +1100
In-Reply-To: <18309.18942.424543.639785-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil,

That did the trick. The lockd.nlm_tcpport and lockd.nlm_udpport are not
required on the zipl.conf parameters
for SLES10. I created the file as shown and now the nlockmgr shows the
specified ports for tcp and udp.

Thanks again for your assistance ............

----------------------------------------------------------------------------------------------
Neil Brown responded:
Create a file
   /etc/modprobe.d/lockd

in it put the line

   options lockd nlm.tcpport=2051 nlm_udpport=2051

then when modprobe loads the lockd module, it will set these options.
------------------------------------------------

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

