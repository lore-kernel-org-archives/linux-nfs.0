From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [patch] flock/fcntl bug
Date: Wed, 15 Dec 2004 14:34:23 -0800
Message-ID: <OF4C58B131.DB061A8C-ON88256F6B.007A58D2-88256F6B.007BFF69@us.ibm.com>
References: <1103147296.1236.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <1103147296.1236.7.camel@lade.trondhjem.org>
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



Trond Myklebust wrote on 12/15/2004 01:48:16 PM:

> on den 15.12.2004 Klokka 10:15 (-0800) skreiv Marc Eshel:
> > To fs/locks.c owner
> >
> > There is a bug in the unlock of posix locks. If there is an flock held
on a
> > file that is being closed an unneeded call is made to the file system
to do
> > an fcntl unlock. In the case of NFS it will be a call to the NFS server
> > which is expensive. This patch just checks that it is a posix lock
before
> > calling the file system.

> Hmm... Not sure this is right.

> What if the filesystem doesn't use inode->i_flock to bookkeep its locks?
> It isn't obliged to do so now...

If the filesystem doesn't use inode->i_flock than there will not be a call
to the filesystem anyhow because locks_remove_posix() return immediately if
i_flock is NULL.

In general I believe that if the filesystem doesn't get the local lock on
top of what it needs to do for it own book keeping things will not work.
For example when you kill lockd it need to free all the locks, and it does
it by going through the local lock list and call the filesystem to release
its locks.

I know that we have changed the code to call either the local lock or the
filesystem but it is required that the filesystem call the local lock. The
only reason that we don't make both call to the filesystem and to get the
local call is that it needs to be done atomically and only the filesystem
can make sure that both it state and the local lock are in sync.

Marc.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
