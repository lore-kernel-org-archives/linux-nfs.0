From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch] flock/fcntl bug
Date: Wed, 15 Dec 2004 17:52:26 -0500
Message-ID: <1103151146.1236.29.camel@lade.trondhjem.org>
References: <OF4C58B131.DB061A8C-ON88256F6B.007A58D2-88256F6B.007BFF69@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cei1X-0000lI-Jg
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 14:53:35 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cei1W-0002xu-IK
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 14:53:35 -0800
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF4C58B131.DB061A8C-ON88256F6B.007A58D2-88256F6B.007BFF69@us.ibm.com>
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

on den 15.12.2004 Klokka 14:34 (-0800) skreiv Marc Eshel:

> If the filesystem doesn't use inode->i_flock than there will not be a call
> to the filesystem anyhow because locks_remove_posix() return immediately if
> i_flock is NULL.

Right. Which may now be a bug...

> In general I believe that if the filesystem doesn't get the local lock on
> top of what it needs to do for it own book keeping things will not work.
> For example when you kill lockd it need to free all the locks, and it does
> it by going through the local lock list and call the filesystem to release
> its locks.

And? The fact that lockd uses inode->i_flock does not mean that the
filesystem has to.

> I know that we have changed the code to call either the local lock or the
> filesystem but it is required that the filesystem call the local lock.

What is the point of forcing it to do that if it can do its own
bookkeeping? Why should the VFS need to care?

The only case where I can see the VFS might want to care is in the case
of mandatory locks. Most Linux filesystems don't support them anyway.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
