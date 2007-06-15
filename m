From: Shreyansh <shreyansh.jain@gmail.com>
Subject: =?utf-8?q?Understanding_NFS=5FINO=5FINVALID=5FDATA_Flag_and?=
	=?utf-8?q?_others?=
Date: Fri, 15 Jun 2007 09:26:23 +0000 (UTC)
Message-ID: <loom.20070615T105902-753@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hz8pZ-0001aP-7v
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 03:15:01 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hz8pc-00040d-25
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 03:15:04 -0700
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1Hz8kk-00027Z-D2
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 12:10:02 +0200
Received: from 192.8.198.65 ([192.8.198.65])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Jun 2007 12:10:02 +0200
Received: from shreyansh.jain by 192.8.198.65 with local (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Jun 2007 12:10:02 +0200
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

Hi list,

I have been trying to understand NFS's working - focusing mainly on the way I/O
(write back) is performed. But after a lot of tries I am stuck at some very
stupid issues which I am unable to sort out. I would really appreciate if
someone can give a pointer or two. Please correct me wherever my understanding
is not right. I apologize for the length of this mail please.

I am using stock 2.6.16.21 kernel for understanding purpose (and NOT focusing on
NFS v4)

Problem:

1) As per my understanding NFS_INO_INVALID_DATA flag means that if it is set,
flush the data which is in the write back list. 

For writing, nfs_file_write calls nfs_revalidate_mapping function. Which in turn
calls nfs_sync_mapping if it is a regular file in question and if
INO_INVALID_DATA flag is set. nfs_sync_mapping calls nfs_wb_all which would
flush back all the pages to be written back (for any pervious I/O).

Is it that:
a) if invalid data is set means that data should be flushed back - always.
b) invalidating data (with flag) does *not* mean that it should NOT be : written
back and page_cache_release(d). <-- is there any such condition (situation) in
which such a step has to be taken (assuming NON SYNC operations).

2) I created a module which would scan the list of pages associated with an
Inode. I ran this for an I/O done over NFS for checking page flags like:
Uptodate, Dirty, Writeback, Buffered and Private. My observation was:

2.1) Only Buffered and private bits are on for any I/O (unflushed i.e. not
executed using SYNC).
2.2) All the pages had there Uptodate flag set - and no page was NOT(uptodate).
2.3) Same was the case for Dirty flag of the page.

Hence, is it that:
a) Pages used, refered by NFS are *always* Uptodate. Hence, kernel would be able
to read pages without flushing them (without the knowledge of NFS).
If the above is true, THEN:
--> Assuming a read calls comes for a file which had pending write backs. Read
call is for same pages which were to be written back (and are in cache with
Uptodate flag ON).
--> Then, kernel would simply read all the pages which are uptodate and copy
them back to the user space. (do_generic_mapping_read function).HOW does NFS
handle such a request? (it never gets the control of the read request which is
returned from the kernel itself)
OR, 
it is OK to read from pages which are in writeback list of pages?

Also, I could infer that:
nfs_readpage function would NEVER be called for any page which is uptodate (in
cache) even if has to be written back. Still there is a check for pending writes
(nfs_wb_all) in this function which would be redundant.

Regards
Shreyansh




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
