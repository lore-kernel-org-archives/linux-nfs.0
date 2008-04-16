From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [NFS] Forcefully resetting a lock
Date: Wed, 16 Apr 2008 10:15:19 -0500
Message-ID: <48061807.9030808@gmail.com>
References: <200804161117.24734.hensema@hostingxs.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52817 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754384AbYDPPT2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2008 11:19:28 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jm9Pw-0005sW-Cl
	for linux-nfs@vger.kernel.org; Thu, 17 Apr 2008 01:19:24 +1000
In-Reply-To: <200804161117.24734.hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Erik Hensema / HostingXS Internet Services wrote:
> Hi all,
>
> Sometimes a file lock gets stuck. Is there any way on either server or 
> client to obtain a list of locks? Or a list of processes/clients 
> locking a particular file?
> And the million dollar question: is it possible to forcefully remove a 
> lock?
>
> I'm using NFSv4 on Linux 2.6.18 (server and client).
>
>   

*Cough* !

Bruce, so what happens to my lock dropping patch that was said "will get 
pulled into 2.6.26 kernel" ?

-- Wendy


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

