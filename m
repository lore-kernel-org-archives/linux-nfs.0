From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Fwd: Re: NFS-HOWTO]
Date: 19 Mar 2002 20:20:32 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsit7smkjj.fsf@charged.uio.no>
References: <1016561902.2031.23.camel@vaio> <shsn0x4mm2h.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nPB2-0002wM-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 11:21:44 -0800
To: Tavis Barr <tb62@columbia.edu>,  nfs@lists.sourceforge.net
In-Reply-To: <shsn0x4mm2h.fsf@charged.uio.no>
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

>>>>> " " == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

    >> Is it the inode number, or some field within the inode?  *This
    >> was supposedly a 2.5 fix item; the issue is that mtime does not
    >> have a granularity finer than one second.  What subsystem does
    >> the fix go into?  The VFS layer?  Has there been any work done
    >> on it?

     > Neil was talking about fixing this in 2.5.x (it is after all a
     > server issue). The problem is that several filesystems
     > (i.e. most notably ext2/ext3) don't have the space in their
     > on-disk inodes for <1s time resolution.  There are some ideas
     > floating around on how to get around this, but I do not believe
     > that concensus has yet been achieved...

Perhaps I should expand a little on this. The changes are twofold:

   - Change the VFS structures to support 64-bit (a|c|m)time values.
     This is not really a big deal, and nothing is stopping us from
     doing it today...

   - Changes to the individual filesystems so that they can save and
     retrieve the extra 96 bits (== 32 bits * (mtime + atime + ctime))
     as part of the on-disk metadata.
     This is non-trivial, since a lot of these filesystems have not
     got much padding left in their inodes (particularly once acls
     etc. have grabbed their share of real-estate). Even finding 32
     free bits is a real problem for ext[23]...

One solution might be to only keep the full 64-bit data in the VFS
inode cache, and to zero the low 32-bits whenever we have to reload
the metadata from the disk.
That means that each time the file falls out of cache, then the mtime
would appear to change on the client (which might then proceed to
invalidate its data cache). Not entirely satisfactory, but probably
better than nothing...

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
