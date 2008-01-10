From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: [NFS] SLES10 SP1 NFS setting ports .....
Date: Thu, 10 Jan 2008 08:14:12 -0500
Message-ID: <OF0E7BA2A6.74525B0C-ON852573CC.0048882B-852573CC.0048B652@us.ibm.com>
References: <1199910165.10701.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37903 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753461AbYAJNOT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jan 2008 08:14:19 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCxEf-0004fB-9i
	for linux-nfs@vger.kernel.org; Fri, 11 Jan 2008 00:14:17 +1100
In-Reply-To: <1199910165.10701.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

modinfo lockd

filename:
/lib/modules/2.6.16.46-0.12-default/kernel/fs/lockd/lockd.ko
license:        GPL
description:    NFS file locking service version 0.5.
author:         Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
srcversion:     08AEA65F1243B999D0019C9
depends:        sunrpc
supported:      yes
vermagic:       2.6.16.46-0.12-default SMP gcc-4.1
parm:           nsm_use_kstatd:int

-------------------------------------------------------------
Trond responded:
What does 'modinfo lockd' say?
-------------------------------------------------------------

Thanks ...............

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

