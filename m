From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS FAQ updates
Date: Mon, 14 Mar 2005 10:19:11 -0800
Message-ID: <482A3FA0050D21419C269D13989C611308539876@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	<nfs@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAu9v-0000j6-77
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 10:19:19 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DAu9t-0007A7-U2
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 10:19:19 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
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

> I found it a little difficult to understand what you meant by "files
> sensitive to access by root" on my first reading:
>=20
> 	"If you are still concerned about the minor security
> 	implications described above, export only whole file systems if
> 	the file system contains files sensitive to access by root (such
> 	as setuid binaries)."
>=20
> And I wouldn't downplay the security concern quite so much.  How about
> just this?:
>=20
> 	"If you need to be certain that clients cannot access files
> 	outside the exported part of a filesystem, set up the partitions
> 	on your server so that you need only export whole filesystems."

ok.

> A related complaint: the world "filesystem" has a lot of different
> meanings.  I'm not sure if I'd be able to tell from this=20
> answer exactly
> which boundaries I could count on being respected by nfsd with subtree
> checking turned off.  I think "partition" would convey something more
> concrete to most administrators.  Would it be inaccurate to replace
> "filesystem" by "partition" everywhere in this answer?

problem is, i got a lot of this text straight from the man page.  :^(

i will see what can be done.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
