From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [NFS] async vs. sync. corrupted fs
Date: Tue, 20 May 2008 09:36:05 -0400
Message-ID: <RTPCLUEXC1-PRD4g3Sv00000129@RTPMVEXC1-PRD.hq.netapp.com>
References: <215ff4410805160355x25b8d055x9a0a246aa5875482@mail.gmail.com>
	<20080519145411.GC7622@fieldses.org>
	<215ff4410805200100o20fb83bcm9921127efef27ef9@mail.gmail.com> <215ff4410805200100o20fb83bcm9921127efef27ef9@mail.gmail.co
 m>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: "Chris Fanning" <christopher.fanning@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:47234 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754204AbYETNpZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 09:45:25 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JyS9a-0000kB-W0
	for linux-nfs@vger.kernel.org; Tue, 20 May 2008 23:45:23 +1000
In-Reply-To: <215ff4410805200100o20fb83bcm9921127efef27ef9-JsoAwUIsXouhRSP0FMvGiw@public.gmane.org
 m>
References: <215ff4410805160355x25b8d055x9a0a246aa5875482-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	<20080519145411.GC7622@fieldses.org>
	<215ff4410805200100o20fb83bcm9921127efef27ef9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 04:00 AM 5/20/2008, Chris Fanning wrote:
>However it does show up in /proc/mounts
>nfs_home_server:/home /home nfs
>rw,vers=3,rsize=32768,wsize=23768,hard,nointr,proto=tcp,timeo=600,retr
>ans=2,sec=sys,addr=192.168.2.2
>0 0

Is that a transcription typo - "23768"?

As Trond mentioned though - NFS can't cause server corruption.
If server "async" changes this, there's a deeper root cause.

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft 
Defy all challenges. Microsoft(R) Visual Studio 2008. 
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

