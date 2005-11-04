From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Bug: nfsd ignores return value from vfs_getattr()
Date: Fri, 04 Nov 2005 11:05:42 +0100
Message-ID: <E1EXyS6-0003cx-00@dorka.pomaz.szeredi.hu>
Cc: nfs@lists.sourceforge.net, David Shaw <dshaw@jabberwocky.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EXySm-0005Js-QE
	for nfs@lists.sourceforge.net; Fri, 04 Nov 2005 02:06:24 -0800
Received: from 238-193.adsl.pool.ew.hu ([193.226.238.193] helo=dorka.pomaz.szeredi.hu)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EXySl-0001Xz-Dj
	for nfs@lists.sourceforge.net; Fri, 04 Nov 2005 02:06:24 -0800
To: neilb@suse.de
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

In fs/nfsd/nfs3xdr.c encode_fattr3() the return value from
vfs_getattr() is ignored.

This causes the server to send bogus (random stack contents) values as
attributes.  This affects exported FUSE filesystems, and possibly
others which may return an error from ->getattr() (e.g. reexported
NFS).

Miklos




-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
