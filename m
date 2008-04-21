From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] NFS limits?
Date: Mon, 21 Apr 2008 09:43:55 -0400
Message-ID: <480C9A1B.20604@redhat.com>
References: <480C8DAB.40504@cesca.es>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jordi Prats <jprats-KO9VOOLprG0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:56525 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762065AbYDUNoY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Apr 2008 09:44:24 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JnwJi-0005Lp-LK
	for linux-nfs@vger.kernel.org; Mon, 21 Apr 2008 23:44:22 +1000
In-Reply-To: <480C8DAB.40504-KO9VOOLprG0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jordi Prats wrote:
> Hi all,
> I've a 4246 GB (above 4TB) using NFSv2 to export it. Some application 
> are generating estrange errors, so it's possible I'm facing a NFS limit? 
> How large can a be to be exported without problems?
>
> I'm using a 32bits architecture.
>
> Thanks!
> Jordi
>
>   
NFSv2 is a 32 bit file access protocol, so don't be surprised
if you see EFBIG sorts of errors on operations such as FSSTAT.

In particular, that file system size is too large to represent,
I am sort of surprised that it would even be mountable.

Why not use NFSv3 or NFSv4?

       ps

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

