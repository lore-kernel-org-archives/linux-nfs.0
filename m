From: "Chris Pascoe" <c.pascoe@itee.uq.edu.au>
Subject: NFS server reports stale handles intermittently
Date: Fri, 5 Apr 2002 15:24:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <009101c1dc62$2510ac80$47426682@csee.uq.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
To: <nfs@Lists.sourceforge.net>
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

Hi,

I'm trying to track down problems with NFS exports of a large XFS
partition that's only become apparent when the server went into production
(of course it didn't show up in 6 months of stability testing!).

Unfortunately, I don't know if the problem occurs on other filesystems as
I don't have any ext2/3 that I can put the same random load onto available
at this moment in time.  We were running 2.2.18 + NFS patches over ext2
until we migrated to this server last Friday - so a lot has changed.  It
looks like it may be similar to what is reported in the
http://marc.theaimsgroup.com/?t=101567659700002&r=1&w=2 thread.

The server is a Dual Xeon 1GHz/1GB (highmem enabled), running 2.4.18 w/XFS
(the 2.4.18-xfs-pr2 kernel).  It has a large (500GB) partition on LVM (on
hardware raid 5, it's only on LVM to try to get snapshots down the track)
exported to a number of Solaris clients.  I have tried kernels from the
SGI 2.4.9-31 one, through CVS various versions up to the 2.4.18 PR2, and
all display the same behaviour.

Basically, it seems that the server returns 'stale file handles' for files
that most definitely exist and aren't being touched in any way.  A few
seconds later, the stale handles are gone.  The server is fairly heavily
loaded during the day, and the problem occurs less overnight when there is
low load.  It does not make a difference if I run a UP or SMP kernel.

At http://www.itee.uq.edu.au/~chrisp/NFS/, I have put the snoop output for
a few transactions that demonstrate the problem.

'bad_nfs.txt' is 'snoop -V' output which shows a few NFS transactions that
have gone to the NFS server, showing that a handle gets reported as stale
but is found immediately after by another 'find' run.  (tcpdump on the
server itself doesn't report fsid/inode information..)

You can see FH=9543 (as Solaris snoop displays it) being returned by the
server as a result of a LOOKUP of the '.microsoft' directory, and then
used for ACCESS checks.  The FH is supposed to be able to be used to map
back to an inode on the disk on a subsequent request.

Some time later (I usually wait between 600 and 1200 seconds between
runs), I run a find again, and it does a GETATTR3 on that handle to check
the current file attributes.  At this time one sees the server report an
Illegal (stale) NFS handle back to the client, and the client forgets
about the handle.

A few seconds after this occurs, if I run another find, the client does
yet another LOOKUP3 to find it again (as it's forgotten about the handle
as a result of the stale handle), and it's successfully found, so the
client succeeds again.

In my find test, all the stale handles are returned for directories that I
have no access to the contents of; however we have seen stale handles
returned for binaries that are most definitely accessible to users (like
window managers, etc), and mail folders, etc.

Another file 'bad_nfs2.txt' that is a more verbose log of
another one that plays up.  In this case, you can see a LOOKUP3 goes out;
the server responds with a file handle, and later when the Solaris client
tries to GETATTR3 the file again, it fails.  Yet the file hasn't gone
anywhere, and another LOOKUP3 on it after a while works fine and returns
the same handle.

It all looks like the file info has fallen out of some kind of cache, and
the subsequent lookup helps it be found again.  I'm not familiar enough
with the knfsd code (yet) to try to track this down myself; is there any
obvious debugging that I could/should turn on/add to see what's happening?

Thanks,
Chris


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
