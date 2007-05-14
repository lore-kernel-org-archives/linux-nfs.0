From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: exportfs -f question
Date: Mon, 14 May 2007 20:28:09 +0200
Message-ID: <20070514182809.GA7127@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnfHF-0004Sq-Gl
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 11:28:09 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HnfHH-0007Al-22
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 11:28:12 -0700
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

I have a server which exports 20-30 local filesystems, each with a
different fsid=<decimal-ip-address> option. eth0 on the server has one
additional ip address for every export. Apart from NLM issues mentioned
earlier on this list, what is the best way to drop caches to be able to
umount one exported mount-point on the server?

Right now I do a

	ip addr del... (remove ip address to block traffic for this export)
	exportfs -f
	umount /exported-mountpoint

but since exportfs -f does a

	time(NULL)                              = 1179165584
	open("/proc/net/rpc/auth.unix.ip/flush", O_RDWR) = 3
	write(3, "1179165584\n", 11)            = 11
	close(3)                                = 0
	open("/proc/net/rpc/nfsd.export/flush", O_RDWR) = 3
	write(3, "1179165584\n", 11)            = 11
	close(3)                                = 0
	open("/proc/net/rpc/nfsd.fh/flush", O_RDWR) = 3
	write(3, "1179165584\n", 11)            = 11
	close(3)                                = 0

I wonder if:

-	can above umount fail due to a race with in-kernel operations?
-	is there a more efficient way to flush cached filehandles
	for a specific export or fsid?
	(I have no clue about performance penalty for the other exports)


-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
