From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS - Fix for Infinite loop during syncing
Date: Mon, 13 Dec 2004 15:45:04 -0500
Message-ID: <1102970704.15627.8.camel@lade.trondhjem.org>
References: <41BDFA46.7070403@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cdx4J-00063d-LH
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 12:45:19 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cdx4H-00016N-B4
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 12:45:19 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41BDFA46.7070403@RedHat.com>
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

m=E5 den 13.12.2004 Klokka 15:23 (-0500) skreiv Steve Dickson:
> It was brought to my attention that following series of events
> would cause an infinite loop in the 2.4 nfs kernels.
>=20
> 1) Mount the fileystem with acregmin=3D1,acregmax=3D1 from two clients.
> 2) On client 1, create a process that continuously writes to a file.
> 3) On client 2, remove that file that is being written
> 4) On client 1, interrupted out of the writing process (which is failing
>      with ESTALEs) and type sync
>=20
> The sync process loops in wait_on_locked(), when called from
> sync_inodes_sb(), since the "broken" inode can not be cleared
> from the locked inode list.

Isn't this pretty much a generic problem of mmapped files? AFAICS, sync
can loop here no matter what filesystem one is using.

If you use ordinary writes, then all is well, since the
nfs_revalidate_inode() in nfs_file_write() should set the NFS_INO_STALE
flag for you.

Cheers
  Trond

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
