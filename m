From: CJ Kucera <pez@apocalyptech.com>
Subject: Re: NFS Causing issues with Gimp XCF files?
Date: Thu, 8 Nov 2007 16:07:22 -0600
Message-ID: <20071108220722.GB8331@apocalyptech.com>
References: <20071108215404.GA8331@apocalyptech.com>
	<20071108220234.GH1813@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqFWv-0007Pe-TF
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 14:07:17 -0800
Received: from mail.apocalyptech.com ([65.99.222.156])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IqFX1-0005y2-Cj
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 14:07:23 -0800
In-Reply-To: <20071108220234.GH1813@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

J. Bruce Fields wrote:
> Have you seen this?:
> 
> 	http://bugzilla.kernel.org/show_bug.cgi?id=9315

No, I hadn't - that certainly sounds just like what I was experiencing.
I'll go see if I can reproduce their cpio/rsync case, and try and track
down the patch they mention as well.

Thanks for the info!  Hopefully this is exactly what I'm encountering.

-CJ

-- 
WOW: Flemmy            |   "The ships hung in the sky in much the same
pez@apocalyptech.com   |    way that bricks don't." - Douglas Adams,
24.24.2.3171           |     _The Hitchhiker's Guide To The Galaxy_

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
