From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] Forcefully resetting a lock
Date: Fri, 18 Apr 2008 14:19:18 -0400
Message-ID: <20080418181918.GB24552@fieldses.org>
References: <200804161117.24734.hensema@hostingxs.nl>
	<48061807.9030808@gmail.com> <20080416184233.GF22743@fieldses.org>
	<480655E7.30800@gmail.com> <20080417215222.GK9912@fieldses.org>
	<4808A9DE.9040304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:46006 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758867AbYDRSUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2008 14:20:04 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JmvBn-0007Ia-3n
	for linux-nfs@vger.kernel.org; Sat, 19 Apr 2008 04:19:59 +1000
In-Reply-To: <4808A9DE.9040304@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 09:02:06AM -0500, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>> My current version of your patch follows.
>>
>> I've rebased it a couple times (the only change I recall being required
>> was a trivial fix to take into account reorganization of struct
>> nameidata.).  I also made two other changes; any objections to either?:
>>   
>
> Thanks for doing this... The changes look good - though I don't have  
> chances to test it out yet. When is 2.6.26 code cut-off date (or we have  
> missed it again) ?

Really it should be now, though there's another week or so when we can
submit stuff if it's in good shape.

But I'm feeling bad about letting this go recently, so I'll look at the
last couple issues and do some testing over the next few days...

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

