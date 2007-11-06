From: Ilya Ovchinnikov <ilya@prao.ru>
Subject: BUG: TIFF files created by libtiff on NFS4 filesystem are
	corrupted
Date: Tue, 06 Nov 2007 16:00:54 +0300
Message-ID: <47306586.6050802@prao.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ilya Ovchinnikov <ilya@prao.ru>,
	Alexandr Zaitsev <sasha-z@psn.ru>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpO3B-0005W1-Ci
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 05:01:01 -0800
Received: from server.psn.ru ([194.149.67.134])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IpO3F-0004uC-Qv
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 05:01:07 -0800
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

Hello!

I have found the following problem with NFS v4 filesystem:
TIFF files written by libtiff are corrupted.

% mount
/home1/ilya/nfs on /home1/nfs4/ilya type none (rw,bind)
localhost:/ilya on /home/ilya/nfs type nfs4 (rw,addr=127.0.0.1)

% cd /home1/nfs4/ilya
% tifftopnm 1.tif | pnmtotiff > 1a.tif
% cd /home/ilya/nfs
% tifftopnm 1.tif | pnmtotiff > 1n.tif
% cmp 1.tif 1a.tif
% cmp 1.tif 1n.tif
15315  10 ^H     0 ^@
15317  10 ^H     0 ^@
15319  10 ^H     0 ^@


NFS v3 does not have this problem.

Software versions:

Linux  2.6.23.1 #1 SMP Sun Nov 4 01:18:12 MSK 2007 i686 GNU/Linux
or
Linux  2.6.23 #1 SMP Fri Oct 12 16:36:16 MSD 2007 x86_64 GNU/Linux

libc6 2.3.6 or 2.6.1 (Debian etch or sid)
libtiff 3.8.2-7 (Debian etch)
netpbm 2:10.0-11 (Debiam etch)

With best regards,
Ilya Ovchinnikov

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
