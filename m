From: Rajat <sharma.rajat@hcl.in>
Subject: =?utf-8?q?nfs=5Freadpage?=
Date: Mon, 25 Jun 2007 15:58:20 +0000 (UTC)
Message-ID: <loom.20070625T172031-300@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I2r3s-0005nd-1K
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 09:05:08 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I2r3s-0000OC-TB
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 09:05:11 -0700
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1I2r3m-0005h8-4X
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 18:05:02 +0200
Received: from 192.8.220.9 ([192.8.220.9])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Jun 2007 18:05:02 +0200
Received: from sharma.rajat by 192.8.220.9 with local (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Jun 2007 18:05:02 +0200
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

Hi,

I was vading through NFS read calls, and found a call to nfs_wb_page is made 
to flush any pending writes, in nfs_readpage function. However all pending 
writeback requests in nfs radix tree are set as PG_uptodate.

Ideally readpage would never be called for any page which is PG_uptodate. In 
do_generic_mapping_read, if page is found in cache (using find_or_get_page) 
and is PG_uptodate, the actor method is called to copy it back to userspace 
buffer.

I tried creating programs (random reads, file mapped I/O) but could not 
produce any such scenario where nfs_wb_page is being called against current 
page. 

Could someone please help me when a readpage is called and would there be any 
case where there are pending writeback requests against such pages, which 
needs to be flushed??

Rajat


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
