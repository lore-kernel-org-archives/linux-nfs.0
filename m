From: David Wuertele <dave-gmane@bfnet.com>
Subject: What's up with those fractional-second mtimes?
Date: Tue, 15 May 2007 03:04:33 +0000 (UTC)
Message-ID: <loom.20070515T045905-915@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnnQQ-0006WQ-DV
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 20:10:10 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnnQR-0001iR-P7
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 20:10:13 -0700
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1HnnQI-00015u-1B
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 05:10:02 +0200
Received: from wwwgate5.motorola.com ([129.188.69.145])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 15 May 2007 05:10:02 +0200
Received: from dave-gmane by wwwgate5.motorola.com with local (Gmexim 0.1
	(Debian)) id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 15 May 2007 05:10:02 +0200
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

I'm trying to deploy a make-based build system to some x86_64 RHEL-4 ES boxes
that mount their build directories NFS.  I'm having problems because timestamps
seem to be recorded in fractions of a second, but the timestamps aren't always
copied that way with cp -a or gzip.  Here is an example with gzip:

$ dd if=/dev/zero of=test bs=1024 count=1024
1024+0 records in
1024+0 records out
$ stat test
  File: `test'
  Size: 1048576   	Blocks: 2056       IO Block: 32768  regular file
Device: 26h/38d	Inode: 15119606    Links: 1
Access: (0644/-rw-r--r--)  Uid: (10059/  qwv684)   Gid: (10001/ma29cu01)
Access: 2007-05-14 22:48:01.058211000 -0400
Modify: 2007-05-14 22:57:28.468235000 -0400
Change: 2007-05-14 22:57:28.468235000 -0400
$ gzip test
$ stat test.gz
  File: `test.gz'
  Size: 1056      	Blocks: 8          IO Block: 32768  regular file
Device: 26h/38d	Inode: 6176375     Links: 1
Access: (0644/-rw-r--r--)  Uid: (10059/  qwv684)   Gid: (10001/ma29cu01)
Access: 2007-05-14 22:48:01.000000000 -0400
Modify: 2007-05-14 22:57:28.000000000 -0400
Change: 2007-05-14 22:57:49.431252000 -0400

See how the mtime didn't get propogated perfectly?  The fraction after the
decimal was truncated to zero!  This seems to happen only on the x86_64 boxes.

What is up with that?  Can I disable fractional timestamps?  Can I enable proper
processing of them?

Thanks,
Dave



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
