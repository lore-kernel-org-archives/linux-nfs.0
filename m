From: Rajat <sharma.rajat@hcl.in>
Subject: Re: Unlocked pages flushed
Date: Tue, 3 Jul 2007 05:39:27 +0000 (UTC)
Message-ID: <loom.20070703T073118-585@post.gmane.org>
References: <loom.20070702T122224-68@post.gmane.org>
	<1183379648.6479.7.camel@heimdal.trondhjem.org>
	<loom.20070702T150607-90@post.gmane.org>
	<1183424035.6479.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5b71-00025U-LK
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 22:39:43 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5b73-0006q4-UD
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 22:39:47 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1I5b6t-0003Cc-JX
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 07:39:35 +0200
Received: from 192.8.220.5 ([192.8.220.5])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Jul 2007 07:39:35 +0200
Received: from sharma.rajat by 192.8.220.5 with local (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Jul 2007 07:39:35 +0200
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

> The only VM requirement is that the pages be locked when you set the
> PG_writeback flag. This is already the case in recent kernels.

Oh! I didnt know that.   

> Otherwise, NFS manages its own locking scheme on the nfs_page.

Now that makes sense. Thanks a lot Trond.

Rajat


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
