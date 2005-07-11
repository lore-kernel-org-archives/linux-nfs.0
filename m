From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH NFSv2] Drop inode after rename
Date: Mon, 11 Jul 2005 07:05:42 -0400
Message-ID: <1121079942.8204.15.camel@lade.trondhjem.org>
References: <20050711104611.GK27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net, Michael Schroeder <mls@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drw6s-0004Cd-8A
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:06:02 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Drw6q-0001BD-Q8
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:06:02 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711104611.GK27163@suse.de>
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

m=C3=A5 den 11.07.2005 Klokka 12:46 (+0200) skreiv Olaf Kirch:
> With recent kernels, we were seeing frequent corruption of files on NFSv2
> immediately after creation, often containing pieces of of frequently
> written files such as .viminfo and the like.
>=20
> The problem turns out to be caused by rename. The applications
> encountering this problem were all rewriting files by first creating a
> temporary copy, and finally renaming it, replacing the original file.
>=20
> When doing a rename on a NFSv2 mount on top of an existing file, the
> inode of the overwritten file would remain, with all caches intact. If
> a new file created subsequently ended up with the same inode number, it
> would pick up the stale cache.

This should never happen. The inodes are not indexed on the inode
number, they are indexed on the _filehandle_.

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
