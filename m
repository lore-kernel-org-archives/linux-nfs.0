From: James Pearson <james-p@moving-picture.com>
Subject: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: Tue, 25 Nov 2003 17:34:20 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FC3929C.EFFE5CDF@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AOh55-0004oO-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Nov 2003 09:34:31 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AOh54-0000ga-Ms
	for nfs@lists.sourceforge.net; Tue, 25 Nov 2003 09:34:30 -0800
Received: from darke.mpc.local ([172.16.11.6] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.24)
	id 1AOh4u-0005c4-EG
	for nfs@lists.sourceforge.net; Tue, 25 Nov 2003 17:34:20 +0000
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

Is it possible to force a different maximum [rw]size on the server
depending on whether the client uses udp or tcp?

Currently, when a client NFS mounts a file system without specifying a
[rw]size, it defaults to whatever NFSSVC_MAXBLKSIZE was defined as (at
compile time) on the server. However, this is the same for udp and tcp
clients.

What I would like is to have a smaller default [rw]size for udp clients,
but allow tcp clients to use 32k.

Is this possible?

Thanks

James Pearson


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
