From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Cache flushing
Date: Sat, 17 Nov 2007 19:46:30 -0500
Message-ID: <1195346790.8908.0.camel@localhost.localdomain>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina>
	<1195343531.7084.11.camel@localhost.localdomain>
	<6513EED9-82AA-4613-A207-686CFFB95430@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItYJ4-0006OY-Ew
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 16:46:38 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ItYJ9-0005sX-5I
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 16:46:44 -0800
In-Reply-To: <6513EED9-82AA-4613-A207-686CFFB95430@iki.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Sun, 2007-11-18 at 02:26 +0200, Timo Sirainen wrote:
> Most people are using NetApps, and they also seem to have 1 second  
> resolution (at least the one I just tested had). So this isn't a  
> solution. "Let's hope that there are no writes less than 1 second  
> apart" isn't really a solution either. People like their mailboxes  
> uncorrupted.

No. NetApp filers and WAFL have nanosecond resolution. They should be
fine.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

