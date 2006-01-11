From: walt <wa1ter@myrealbox.com>
Subject: NFS breakage from recent commit
Date: Wed, 11 Jan 2006 06:42:57 -0800
Message-ID: <dq35hi$372$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EwhKf-00051B-HE
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 06:52:13 -0800
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EwhKe-0006hC-BP
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 06:52:13 -0800
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1EwhK6-0006Uf-JR
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 15:51:39 +0100
Received: from adsl-69-234-210-171.dsl.irvnca.pacbell.net ([69.234.210.171])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Wed, 11 Jan 2006 15:51:38 +0100
Received: from wa1ter by adsl-69-234-210-171.dsl.irvnca.pacbell.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Wed, 11 Jan 2006 15:51:38 +0100
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi all,

This recent commit has broken NFS for me:

commit a334de28665b14f0a33df82699fa9a78cfeedf31
tree 21749c30159b1e0bf4cae7e174ec1bdcf3859ef4
parent 93fbf1a5de8afde08988dda3735669099dee84d0
author David Shaw <dshaw@jabberwocky.com> Fri, 06 Jan 2006 00:19:58 -0800
committer Linus Torvalds <torvalds@g5.osdl.org> Fri, 06 Jan 2006
08:33:59 -0800

    [PATCH] knfsd: check error status from vfs_getattr and i_op->fsync

#mount -t nfs k2:/ /mnt/nfs/
mount: Cannot allocate memory

Reverting that one commit makes nfs work normally again.  Anyone
else seeing this?



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
