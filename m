From: CJ Kucera <pez@apocalyptech.com>
Subject: Re: NFS Causing issues with Gimp XCF files?
Date: Thu, 8 Nov 2007 16:31:33 -0600
Message-ID: <20071108223133.GA9066@apocalyptech.com>
References: <20071108215404.GA8331@apocalyptech.com>
	<20071108220234.GH1813@fieldses.org>
	<20071108220722.GB8331@apocalyptech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqFuQ-0001M2-HX
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 14:31:34 -0800
Received: from mail.apocalyptech.com ([65.99.222.156])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IqFuV-0005Np-2P
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 14:31:40 -0800
In-Reply-To: <20071108220722.GB8331@apocalyptech.com>
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

CJ Kucera wrote:
> J. Bruce Fields wrote:
> > Have you seen this?:
> > 
> > 	http://bugzilla.kernel.org/show_bug.cgi?id=9315
> 
> No, I hadn't - that certainly sounds just like what I was experiencing.

Lo and behold, that was exactly it.  With that patch applied,
everything's working as-expected.

Thanks a lot for the tip!

-CJ

-- 
WOW: Flemmy            |   "Happiness isn't good enough for me!  I
pez@apocalyptech.com   |              demand euphoria!"
24.24.2.3171           |                  - Calvin

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
