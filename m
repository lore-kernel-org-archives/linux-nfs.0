From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH NFSv2] Drop inode after rename
Date: Mon, 11 Jul 2005 07:14:20 -0400
Message-ID: <1121080460.8204.18.camel@lade.trondhjem.org>
References: <20050711104611.GK27163@suse.de>
	 <1121079942.8204.15.camel@lade.trondhjem.org>
	 <20050711110733.GN27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net, Michael Schroeder <mls@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrwFE-0004X2-33
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:14:40 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DrwFC-0003KR-Kt
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:14:40 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711110733.GN27163@suse.de>
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

m=C3=A5 den 11.07.2005 Klokka 13:07 (+0200) skreiv Olaf Kirch:
> On Mon, Jul 11, 2005 at 07:05:42AM -0400, Trond Myklebust wrote:
> > > When doing a rename on a NFSv2 mount on top of an existing file, the
> > > inode of the overwritten file would remain, with all caches intact. I=
f
> > > a new file created subsequently ended up with the same inode number, =
it
> > > would pick up the stale cache.
> >=20
> > This should never happen. The inodes are not indexed on the inode
> > number, they are indexed on the _filehandle_.
>=20
> But it does happen. The new file on the NFS server has the exact
> same file handle.

If people care enough about their data to worry about this sort of
problem, then they should care enough to use a server that doesn't
violate the NFS protocol.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
