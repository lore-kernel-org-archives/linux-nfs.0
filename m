From: Christoph Hellwig <hch@lst.de>
Subject: Re: [NFS] [PATCH] lockd: unlock lockd locks held for a certain
	filesystem
Date: Wed, 23 Apr 2008 19:52:26 +0200
Message-ID: <20080423175226.GA32537@lst.de>
References: <20080416184233.GF22743@fieldses.org> <480655E7.30800@gmail.com>
	<20080417215222.GK9912@fieldses.org> <4808A9DE.9040304@gmail.com>
	<20080418181918.GB24552@fieldses.org>
	<20080422231520.GI21770@fieldses.org>
	<20080422231729.GJ21770@fieldses.org>
	<20080422231855.GK21770@fieldses.org>
	<20080423074422.GA23518@lst.de>
	<20080423171240.GG31576@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lon Hohberger <lhh@redhat.com>,
	Wendy Cheng <s.wendy.cheng@gmail.com>,
	nfs@lists.sourceforge.net, Christoph Hellwig <hch@lst.de>,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:47118 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbYDWS2U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2008 14:28:20 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jojha-0008PM-Ij
	for linux-nfs@vger.kernel.org; Thu, 24 Apr 2008 04:28:18 +1000
In-Reply-To: <20080423171240.GG31576@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 23, 2008 at 01:12:40PM -0400, J. Bruce Fields wrote:
> +int           nlmsvc_failover_path(struct super_block *sb);

With a super_block argument the path suffix doesn't make sense anymore.
Should probably be an _sb instead.


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

