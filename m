From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS FAQ updates
Date: Sun, 13 Mar 2005 13:41:36 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130853986D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAaqF-0005oM-8t
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 13:41:43 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DAaqE-0008Mj-VG
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 13:41:43 -0800
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

> On Sun, Mar 13, 2005 at 11:37:26AM -0800, Lever, Charles wrote:
> > Why should I disable subtree checking on my NFS server exports?
> >   http://nfs.sourceforge.net/index.cel.php#faq_c7

thanks for the review!

> Kerberos doesn't solve exactly the problem that subtree=20
> checking attempts to solve.  My attempt at a concise way of=20
> putting this (maybe you can think of a better way):
>=20
> 	Use Kerberos and/or NFSv4 when they become available: it may
> 		still be possible for a user of NFS over Kerberos to
> 		access files outside of the exported subtree.  However,
> 		it should not be possible for them to fake=20
> their identity,
> 		so they should not be able to read files that they do
> 		not have permissions to.

hmmm.  so what's the difference between not having access to a file, and
having access but not being able to read the file?  is it just the
ability to know the file is there?  wouldn't that be prevented by not
having access to its parent?  or, since the file handle is still good,
lack of permission to look the file up in the new parent would be
inconsequential?

to my mind, this is a very fine hair to split.  why, in your opinion, is
it worth mentioning?  ie do you have a particular case in mind where
this kind of thing could be important?


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
