From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: NFSv4 pseudo filesystem
Date: Fri, 10 May 2002 14:12:12 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0205101340370.27306-100000@mspacman.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 176EsN-0000Is-00
	for <nfs@lists.sourceforge.net>; Fri, 10 May 2002 11:12:19 -0700
To: nfs@lists.sourceforge.net, <linux-fsdevel@vger.kernel.org>
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


Hi all,

I'm one of the NFSv4 developers at the University of Michigan.  I'm
currently trying to settle on the best way to implement the NFSv4
"pseudo filesystem" in Linux 2.5, and I'm hoping to solicit feedback
from some other developers.

Background: In NFSv2/v3, the server's exports are more or less independent
of each other, and must be mounted seperately by the client.  NFSv4
introduced the requirement that the server must export a 'root filehandle'
(which must be a directory), and that all the exports be obtainable by
browsing the subtree rooted at the root filehandle.  In other words, the
server must present the client with ficticious directories, which live
above the exports and serve to tie them all together into one tree.  (The
term "pseudo filesystem" is used to refer to this collection of ficticious
directories.)

  Proposal 1: Have the server export a pseudofs which "mirrors" the actual
  namespace on the server, or at least enough of it to cover all the
  exports.  In other words, if the server's exports are named
  /home/kmsmith and /usr/local/src, then the server will present the
  client with the following pseudo filesystem:

                             /
       /home                                 /usr
       /home/kmsmith                         /usr/local
          ...                                /usr/local/src
                                                  ...


This is the approach suggested by RFC3010 for Unix servers, but it
seems like a nice feature to relax the requirement that pathnames in
the pseduofs be the same as pathnames in the server's filesystem.
The next 2 proposals allow the possibility of setting up an
arbitarily-named tree of ficticious directories, for the server
to export as the pseudofs.  (This would require changing the
/etc/exports file format, presumably in a backward-compatible way,
such as adding an export option pseudo_pathname=...)

  Proposal 2: Require the pseudofs to be built up somewhere on disk,
  presumably in a well-known location such as /etc/pseudofs.  The
  exportfs utility would create real on-disk subdirectories, then
  mount --bind the exports onto the leaves of the tree, before starting
  nfsd.  (Some mechanism would have to be introduced whereby the
  top-level pathname /etc/pseudofs could be communicated to the kernel.)

  Proposal 3: Build up the pseudofs inside the 2.5 'nfsd' filesystem,
  say in a directory nfsd/pseudofs which is created when the nfsd
  filesystem is mounted.  The exportfs utility would be responsible
  for creating the necesary subdirectories, then hanging the exports
  off the leaves with mount --bind, before starting nfsd.

As I see it, the disadvantage of proposal 3 is that it is a little
tricky to construct persistent filehandles ("persistent" in the sense
that an old filehandle is still recognize after the server is rebooted).
One solution would be to use an MD5 or SHA hash of the pathname as the
filehandle.  The hash could be computed in userspace and passed into
the kernel somehow.

This disadvantage doesn't seem to exist under the other two proposals,
since in both cases each pseudo directory is "backed" by an on-disk
directory, and we can use this directory's filehandle.

Of course, it's possible that no one is interested in having a pseudofs
namespace which is independent of the namespace in the server's
filesystem.  If the consensus is that this is not a useful feature, it's
probably easiest to adopt proposal 1.

Feedback/comments welcome!

Cheers,
 Kendrick



_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
