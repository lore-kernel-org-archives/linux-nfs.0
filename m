From: "martinnitram@excite.com" <martinnitram@excite.com>
Subject: can't reexport NCP mount point by NFS
Date: Mon,  3 Nov 2003 20:46:47 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031104014647.5A2623E3E@xmxpita.excite.com>
Reply-To: martinnitram@excite.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AGqHZ-0001OI-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Nov 2003 17:46:57 -0800
Received: from nn1.excitenetwork.com ([207.159.120.55] helo=xmxpita.excite.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AGqHZ-000579-DV
	for nfs@lists.sourceforge.net; Mon, 03 Nov 2003 17:46:57 -0800
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>




Dear all,

at past, we had a Redhat 6.0 (kernel 2.2.5-15, knfsd-

1.2.2-4, ncpfs-2.2.0.12) that using ncpmount to mount 

Netware File server and use nfsd to re-export it and let 

other linux machine to mount it, everything work fine.

Currently, we planned to upgrade this machine to RH 

7.3 (clearly installed, with all update, ncpfs-2.2.0.18-

133.i386.rpm, ), Netware mount and local file system 

export ok, but fail when reexport the mounted Netware 

volume, and message log shown:

getfh failed: Operation not permitted



>From the document (How-To, README), it claimed that 

need to reload the mountd/nfsd by --re-export options 

after volume mounted (we had use -V option at 

ncpmount already). But from manpage of mounted/nfsd, 

we can't find this options (exportfs had, tried without 

success).



Any one had idea about this? Any info are welcome.

Thx 





_______________________________________________
Join Excite! - http://www.excite.com
The most personalized portal on the Web!


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
