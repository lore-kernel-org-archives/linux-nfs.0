From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: completely unimportant bug in fs/nfs/inode.c
Date: Fri, 3 May 2002 11:56:37 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0205031144230.1863-100000@mspacman.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 173fQH-0003kE-00
	for <nfs@lists.sourceforge.net>; Fri, 03 May 2002 08:56:41 -0700
To: nfs@lists.sourceforge.net
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


Hi Trond et al,

Here is a completely unimportant bug in the latest (2.5.12)
fs/nfs/inode.c.  In nfs_get_sb(), a couple of error paths have
memory leaks.  I believe the block
   if (root->size > sizeof(root->data)) {
      printk("nfs_get_sb: invalid root filehandle\n");
      return ERR_PTR(-EINVAL);
   }
should also contain
      kfree(server);
The same comment also applies to the check on the return value
of nfs_fill_super() near the bottom of the routine.

Cheers,
 Kendrick



_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
