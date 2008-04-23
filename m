From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] lockd: unlock lockd locks held for a certain
	filesystem
Date: Wed, 23 Apr 2008 16:01:01 -0400
Message-ID: <20080423200101.GC8302@fieldses.org>
References: <480655E7.30800@gmail.com> <20080417215222.GK9912@fieldses.org>
	<4808A9DE.9040304@gmail.com> <20080418181918.GB24552@fieldses.org>
	<20080422231520.GI21770@fieldses.org>
	<20080422231729.GJ21770@fieldses.org>
	<20080422231855.GK21770@fieldses.org>
	<20080423074422.GA23518@lst.de>
	<20080423171240.GG31576@fieldses.org>
	<20080423175226.GA32537@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lon Hohberger <lhh@redhat.com>,
	Wendy Cheng <s.wendy.cheng@gmail.com>,
	nfs@lists.sourceforge.net,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:46305 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbYDWUBf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2008 16:01:35 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jol9n-0000Bf-0g
	for linux-nfs@vger.kernel.org; Thu, 24 Apr 2008 06:01:31 +1000
In-Reply-To: <20080423175226.GA32537@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 23, 2008 at 07:52:26PM +0200, Christoph Hellwig wrote:
> On Wed, Apr 23, 2008 at 01:12:40PM -0400, J. Bruce Fields wrote:
> > +int           nlmsvc_failover_path(struct super_block *sb);
> 
> With a super_block argument the path suffix doesn't make sense anymore.
> Should probably be an _sb instead.

OK.  As long as we're renaming stuff, I always found
nlmsvc_failover_{ip,path}() a little vague, so I've made them
nlmsvc_unlock_all_by_{ip,sb}().

--b.

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

