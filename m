From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 09:16:57 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DF51@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH3MV-00073e-Cu
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 09:17:11 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH3MV-0005oW-48
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 09:17:11 -0700
To: "Steve Dickson" <SteveD@redhat.com>
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

> >This again means that people who think they have open files=20
> on the "old"
> >inode may suddenly find their program Oopsing or corrupting the new
> >file.=20
> >
> Again, this new fh is only gotten on getattrs any other ops will still
> fail with ESTALE...

so you need to invalidate all the cached pages for this inode
explicitly.  nfs_refresh_inode will not detect any change in
mtime or i_size so it will not do this for you.

but this exposes us to the "unable to invalidate locked pages"
bug again.

and i think this is only a valid thing to do iff the mtime
and i_size are the same as our cached values but the fh has
changed.  otherwise, you can fool yourself into thinking that
an entirely new file is the same as the old one.



-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
