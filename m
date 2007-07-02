From: Rajat <sharma.rajat@hcl.in>
Subject: Unlocked pages flushed
Date: Mon, 2 Jul 2007 10:51:07 +0000 (UTC)
Message-ID: <loom.20070702T122224-68@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5JV1-0007LR-AV
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 03:51:19 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5JV4-0006Qd-Jr
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 03:51:22 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1I5JUw-0007qo-Kh
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 12:51:14 +0200
Received: from 192.8.220.5 ([192.8.220.5])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Jul 2007 12:51:14 +0200
Received: from sharma.rajat by 192.8.220.5 with local (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Jul 2007 12:51:14 +0200
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

Hi List,

While flushing the data through nfs_file_flush, I observed that pages are 
being flushed in unlocked state. nfs_file_flush call graph reaches to 
nfs_flush_one where the comment above this definition states "The page must 
have been locked by the caller." However I have checked with PageLocked() call 
that the pages which enter into nfs_flush_one are not locked. 

What I could make out of it is: this is done porbably to avoid deadlock with 
other functions like prepare_write, commit_write, writepage, readpage where 
page is grabbed first then lock_kernel (HEAVILY used in NFS) is called. 
Whereas nfs_file_flush calls lock_kernel, then enters into nfs_wb_all. So, to 
avoid deadlock, logical place for lock_page loop would have been in 
nfs_file_flush before lock_kernel (still not sure about this, will it help?). 

Here we are flushing pages without honouring page_lock OR am I going wrong 
somewhere???

Rajat


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
