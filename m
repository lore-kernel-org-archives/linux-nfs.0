From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] Forcefully resetting a lock
Date: Wed, 16 Apr 2008 14:42:33 -0400
Message-ID: <20080416184233.GF22743@fieldses.org>
References: <200804161117.24734.hensema@hostingxs.nl>
	<48061807.9030808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:56831 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbYDPSmu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2008 14:42:50 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JmCam-0006Uu-A9
	for linux-nfs@vger.kernel.org; Thu, 17 Apr 2008 04:42:48 +1000
In-Reply-To: <48061807.9030808@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 16, 2008 at 10:15:19AM -0500, Wendy Cheng wrote:
> Erik Hensema / HostingXS Internet Services wrote:
>> Hi all,
>>
>> Sometimes a file lock gets stuck. Is there any way on either server or  
>> client to obtain a list of locks? Or a list of processes/clients  
>> locking a particular file?
>> And the million dollar question: is it possible to forcefully remove a  
>> lock?
>>
>> I'm using NFSv4 on Linux 2.6.18 (server and client).
>>
>>   
>
> *Cough* !
>
> Bruce, so what happens to my lock dropping patch that was said "will get  
> pulled into 2.6.26 kernel" ?

Gulp.

I started an alternative implementation, and got it to the point where
it was basically working (but I didn't completely trust it).  And I did
a small fix or two on your patches, but I seem to recall there were one
or more todo's there too.

Then I dropped both for a couple weeks.

I'll take a harder look this afternoon....

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

