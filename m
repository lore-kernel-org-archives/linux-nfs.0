From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS FAQ updates
Date: Mon, 14 Mar 2005 09:48:05 -0800
Message-ID: <482A3FA0050D21419C269D13989C611308539875@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAtfs-0007va-HW
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 09:48:16 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DAtfr-0003no-1F
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 09:48:16 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
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

thanks for your comments, guys.  i've simplified C7 a bit, see if it
helps:

  http://nfs.sourceforge.net/index.cel.php#faq_c7


> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]=20
> Sent: Sunday, March 13, 2005 5:45 PM
> To: Trond Myklebust
> Cc: Lever, Charles; nfs@lists.sourceforge.net
> Subject: Re: [NFS] NFS FAQ updates
>=20
>=20
> On Sun, Mar 13, 2005 at 05:10:11PM -0500, Trond Myklebust wrote:
> > The subtree_check option attempts to decide whether or not=20
> a file lies
> > within an exported subtree. If you turn it off, then people can
> > theoretically try to guess filehandles and gain access to the files
> > (assuming the access permissions on the file itself allow that).
>=20
> I wouldn't put too much emphasis on that "theoretically".  The root
> directory on all my ext2/3 filesystems has inode number 2,=20
> and as far as
> I can tell guessing the rest of the rest of the filehandle just comes
> down to guessing the root device, which on my machines is always
> /dev/hdaN for some very small N.  Add a few more for people with scsi
> and so on, and I bet you could cover most linux NFS servers=20
> with a dozen
> guesses.  Now just lookup and readdir down to wherever you want.  Am I
> missing anything here?
>=20
> If the administrator tightened down directory permissions a=20
> bit, you'll
> be forced to guess filehandles for objects deeper in the filesystem,
> which may be a little harder.  I wouldn't count on it.
>=20
> --b.
>=20


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
