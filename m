From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Fwd: Re: NFS-HOWTO]
Date: 19 Mar 2002 19:47:34 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsn0x4mm2h.fsf@charged.uio.no>
References: <1016561902.2031.23.camel@vaio>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nOeA-0002gh-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 10:47:46 -0800
To: Tavis Barr <tb62@columbia.edu>
In-Reply-To: <1016561902.2031.23.camel@vaio>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Tavis Barr <tb62@columbia.edu> writes:

     > Andrew Ryan had a good question for me below that I don't know
     > the answer to.  When a file gets modified and left the same
     > size twice within one second, its mtime stays the same and all
     > other attributes stay the same, so the NFS server does not see
     > that it has been altered. At least this is my understanding of
     > the bug.  Some things that I don't know because I'm not
     > familiar enough with the NFS internals:

     > *What data structure reflects that the file has been altered?

inode->i_size + inode->i_mtime    ;-)

NFSv4 has support for a new 64-bit opaque value that can be used to
tell if the file has changed (that doesn't have to be i_mtime).
For NFSv2/v3 though, file size and mtime are all we have available to
tell whether or not the file has changed.

     > Is it the inode number, or some field within the inode?  *This
     > was supposedly a 2.5 fix item; the issue is that mtime does not
     > have a granularity finer than one second.  What subsystem does
     > the fix go into?  The VFS layer?  Has there been any work done
     > on it?

Neil was talking about fixing this in 2.5.x (it is after all a server
issue). The problem is that several filesystems (i.e. most notably
ext2/ext3) don't have the space in their on-disk inodes for <1s time
resolution.
There are some ideas floating around on how to get around this, but I
do not believe that concensus has yet been achieved...

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
