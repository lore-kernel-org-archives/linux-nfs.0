From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [patch] flock/fcntl bug
Date: Wed, 15 Dec 2004 15:51:48 -0800
Message-ID: <OF89CDCE7F.4F36F059-ON88256F6B.00820187-88256F6B.008315EF@us.ibm.com>
References: <1103151146.1236.29.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CeizS-0005b7-P3
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 15:55:30 -0800
Received: from e5.ny.us.ibm.com ([32.97.182.145])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CeizQ-0001Yp-6x
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 15:55:29 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBFNtESn004081
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 18:55:14 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBFNtEft202504
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 18:55:14 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBFNt3UX021038
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 18:55:03 -0500
In-Reply-To: <1103151146.1236.29.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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



Trond Myklebust <trond.myklebust@fys.uio.no> wrote on 12/15/2004 02:52:26
PM:

> on den 15.12.2004 Klokka 14:34 (-0800) skreiv Marc Eshel:

> > If the filesystem doesn't use inode->i_flock than there will not be a
call
> > to the filesystem anyhow because locks_remove_posix() return
immediately if
> > i_flock is NULL.

> Right. Which may now be a bug...

So how would you fix it? Call the filesystem to unlock what? If you have no
information on what is locked how can you unlock it, and having an extra
call to the filesystem (that can be remote for NFS) when there is no lock
held is very wasteful.

> > In general I believe that if the filesystem doesn't get the local lock
on
> > top of what it needs to do for it own book keeping things will not
work.
> > For example when you kill lockd it need to free all the locks, and it
does
> > it by going through the local lock list and call the filesystem to
release
> > its locks.

> And? The fact that lockd uses inode->i_flock does not mean that the
> filesystem has to.

That is the only why that lockd knows what to clean up when it is
terminated

> > I know that we have changed the code to call either the local lock or
the
> > filesystem but it is required that the filesystem call the local lock.

> What is the point of forcing it to do that if it can do its own
> bookkeeping? Why should the VFS need to care?

It would be nice if it didn't have to care but the fact is that right now
there is dependency on the lock state to be in the VFS too for correct
operation.

Marc.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
