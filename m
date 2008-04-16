From: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Subject: Re: [NFS] How to set-up a Linux NFS server to handle	massive	number
 of requests
Date: Wed, 16 Apr 2008 16:35:42 +0200
Message-ID: <48060EBE.4060604@aei.mpg.de>
References: <47FE044A.7020008@aei.mpg.de> <20080411230754.GI24830@fieldses.org>
	<1208234913.17169.50.camel@trinity.ogc.int>
	<20080415151227.GB32218@fieldses.org>
	<1208313790.3521.32.camel@trinity.ogc.int>
	<20080416025848.GA27274@fieldses.org>
	<1208316166.3521.42.camel@trinity.ogc.int>
	<E9FA280C-E881-4DCB-9C4C-5DBD4B16A984@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48591 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950AbYDPOhr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2008 10:37:47 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jm8le-0005m3-1b
	for linux-nfs@vger.kernel.org; Thu, 17 Apr 2008 00:37:46 +1000
In-Reply-To: <E9FA280C-E881-4DCB-9C4C-5DBD4B16A984@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
>
> Force UDP for the mountd protocol by specifying the "mountproto=udp" 
> option.

I'll give that also a try. I'm currently busy running other benchmarks. 
I'll try to get some results by the weekend, if nothing comes from my 
side by then, I'm probably buried alive in work, but please send me a 
(friendly) reminder then.

Thanks already for all the input!

Cheers

Carsten

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

