From: Christoph Hellwig <hch@lst.de>
Subject: Re: [NFS] [PATCH] lockd: unlock lockd locks held for a certain
	filesystem
Date: Wed, 23 Apr 2008 09:44:22 +0200
Message-ID: <20080423074422.GA23518@lst.de>
References: <200804161117.24734.hensema@hostingxs.nl>
	<48061807.9030808@gmail.com> <20080416184233.GF22743@fieldses.org>
	<480655E7.30800@gmail.com> <20080417215222.GK9912@fieldses.org>
	<4808A9DE.9040304@gmail.com> <20080418181918.GB24552@fieldses.org>
	<20080422231520.GI21770@fieldses.org>
	<20080422231729.GJ21770@fieldses.org>
	<20080422231855.GK21770@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lon Hohberger <lhh@redhat.com>,
	Wendy Cheng <s.wendy.cheng@gmail.com>,
	nfs@lists.sourceforge.net, Christoph Hellwig <hch@lst.de>,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:33757 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbYDWHo4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2008 03:44:56 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JoZet-0006hv-Cw
	for linux-nfs@vger.kernel.org; Wed, 23 Apr 2008 17:44:51 +1000
In-Reply-To: <20080422231855.GK21770@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please don't pass down the nameidata, but just the super_block.  That's
all we need in the lower layer functions.


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

