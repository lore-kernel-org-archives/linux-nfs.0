From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: completely unimportant bug in fs/nfs/inode.c
Date: 03 May 2002 19:04:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsd6wdb1t1.fsf@charged.uio.no>
References: <Pine.SOL.4.44.0205031144230.1863-100000@mspacman.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,  nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 173gU0-0002eA-00
	for <nfs@lists.sourceforge.net>; Fri, 03 May 2002 10:04:36 -0700
To: "Kendrick M. Smith" <kmsmith@umich.edu>
In-Reply-To: <Pine.SOL.4.44.0205031144230.1863-100000@mspacman.gpcc.itd.umich.edu>
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

>>>>> " " == Kendrick M Smith <kmsmith@umich.edu> writes:

     > Hi Trond et al,

     > Here is a completely unimportant bug in the latest (2.5.12)
     > fs/nfs/inode.c.  In nfs_get_sb(), a couple of error paths have
     > memory leaks.  I believe the block
     >    if (root->size > sizeof(root->data)) {
     >       printk("nfs_get_sb: invalid root filehandle\n"); return
     >       ERR_PTR(-EINVAL);
     >    }
     > should also contain
     >       kfree(server);
     > The same comment also applies to the check on the return value
     > of nfs_fill_super() near the bottom of the routine.

Thanks Kendrick. I appear to have missed those when I OKed Al's
patch. I'll try to get round to fixing it up soon...

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
