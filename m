From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: corruption over NFS with 2.6 client, locking,
	truncating and appending...
Date: Tue, 05 Apr 2005 00:53:49 -0400
Message-ID: <1112676829.11900.4.camel@lade.trondhjem.org>
References: <16977.57630.766727.608029@cse.unsw.edu.au>
	 <1112664792.11910.12.camel@lade.trondhjem.org>
	 <16977.60501.153237.389021@cse.unsw.edu.au>
	 <1112667216.11740.4.camel@lade.trondhjem.org>
	 <16978.3509.329730.989580@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIg4m-0006rw-DN
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 21:54:08 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DIg4j-0003PJ-Kh
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 21:54:08 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16978.3509.329730.989580@cse.unsw.edu.au>
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

ty den 05.04.2005 Klokka 14:01 (+1000) skreiv Neil Brown:
> I don't think ftruncates on stale offsets can cause this problem.
> As the client which calls ftruncate is the only client which ever
> causes the file to shrink (the other client only causes it to grow),
> stale offsets that it sees may be too short, but will never be too
> long.
> So it might truncate more than it expects to (and this test doesn't
> check for that possibility) but it won't truncate beyond the end of
> the file and so create a hole.

OK.


> (I  had to change
> > +		int retval = nfs_revalidate_inode(file->f_dentry->d_inode);
> to
> > +		int retval = nfs_revalidate_inode(NFS_SERVER(file->f_dentry->d_inode), file->f_dentry->d_inode);
> 
> but that might be because I'm actually using -mm for testing).

Sorry. I didn't have time for a compile test...

> I poked around in the related code and found that nfs_update_inode,
> which is called by nfs_revalidate_inode, won't accept a decrease in
> file size if it thinks the file is 'unstable'.  So I put in a printk
> to tell me when this happened:
> 
> 		if (S_ISREG(inode->i_mode) && data_unstable) {
> 			if (new_isize > cur_isize) {
> 				inode->i_size = new_isize;
> 				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
> 			}
> 			else printk("may have missed trunc %ld->%ld\n",
> 				    (long)cur_isize, (long)new_isize); /* neilb */
> 		} else {
> 			inode->i_size = new_isize;
> 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
> 		}
> 
> and got some output:
> 
> Apr  5 13:40:41 cage kernel: may have missed trunc 2050->2030
> Apr  5 13:40:41 cage kernel: may have missed trunc 2060->2020
> Apr  5 13:40:41 cage kernel: may have missed trunc 2090->2070
> Apr  5 13:40:41 cage kernel: may have missed trunc 2130->2110

That is indeed a problem. The current code basically assumes
close-to-open semantics, and that of course breaks down in the case of
locking.
OK. I'm going to have to give that some thought...

BTW: The 2.4 code should be very different in this respect: it has no
equivalent to the "unstable" test. Are you seeing the same problem
there?

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
