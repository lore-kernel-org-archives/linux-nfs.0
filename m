From: Adrian Phillips <a.phillips-VB/+SrIvmXw@public.gmane.org>
Subject: Re: [NFS] Data corruption using 2.6.18 NFSv3 client -- sparse files?
Date: Wed, 30 Apr 2008 11:56:39 +0200
Message-ID: <8763tzis2w.fsf@freeze.oslo.dnmi.no>
References: <loom.20080430T061925-652@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43349 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757580AbYD3OVy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 10:21:54 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JrDBw-00067Y-DR
	for linux-nfs@vger.kernel.org; Thu, 01 May 2008 00:21:52 +1000
In-Reply-To: <loom.20080430T061925-652-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org> (Clay McClure's message
	of "Wed, 30 Apr 2008 06:41:48 +0000 (UTC)")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "Clay" == Clay McClure <clay-zo/yENU/GurR7s880joybQ@public.gmane.org> writes:

    Clay> Hello, When multiple 2.6.18 NFSv3 clients write to the same
    Clay> file, after one of the clients has recently read from the
    Clay> file, we see data corruption in the form of null bytes
    Clay> inserted into the file.

If its the same bug we've seen it appeared in 2.6.17 and we "fixed" by
downgrading the involved hosts to 2.6.16. It was related to this post
by Trond Myklebust (in Jan/Feb) :-

    That is very likely to be the same problem as fixed in

    http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=5d47a35600270e7115061cb1320ee60ae9bcb6b8

    AFAICR, all kernels after 2.6.17 were affected. Can you therefore see if
    the same patch applies to 2.6.19, and if it fixes your problem?

    Cheers
      Trond

Sincerely,

Adrian Phillips

-- 
Who really wrote the works of William Shakespeare ?
http://www.pbs.org/wgbh/pages/frontline/shakespeare/

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

