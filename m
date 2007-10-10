From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Nfs Failover
Date: Wed, 10 Oct 2007 09:40:54 -0400
Message-ID: <20071010134054.GA31732@fieldses.org>
References: <2a46ebd60710091240k37369e15rbc99b57d26579e8a@mail.gmail.com>
	<20071009195128.GQ22750@fieldses.org> <470BDFB9.30409@cesca.es>
	<2a46ebd60710100638k5665f025vbadb8d7194262f1a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Saurabh Sehgal <saurabh.r.s@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ifbo3-0001yv-HG
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 06:40:59 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ifbo6-00066x-II
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 06:41:04 -0700
In-Reply-To: <2a46ebd60710100638k5665f025vbadb8d7194262f1a@mail.gmail.com>
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

On Wed, Oct 10, 2007 at 09:38:18AM -0400, Saurabh Sehgal wrote:
> I will be sure to try that and see if I get the same problem ...
> 
> I am exporting an ext3 filesystem ...

So you're using a shared block device?

> Does that change anything ?

It's just important to make sure you're exporting the *identical* ext3
filesystem from the two servers--copies made above the filesystem level
(using cp or rsync or whatever) aren't sufficient to ensure that
filehandles stay the same.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
