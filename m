From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: corruption over NFS with 2.6 client, locking, truncating and
 appending...
Date: Tue, 5 Apr 2005 14:01:57 +1000
Message-ID: <16978.3509.329730.989580@cse.unsw.edu.au>
References: <16977.57630.766727.608029@cse.unsw.edu.au>
	<1112664792.11910.12.camel@lade.trondhjem.org>
	<16977.60501.153237.389021@cse.unsw.edu.au>
	<1112667216.11740.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIfGP-0004oy-9j
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 21:02:05 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DIfGO-0008O0-H4
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 21:02:05 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Monday April 4
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

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Monday April 4, trond.myklebust@fys.uio.no wrote:
> ty den 05.04.2005 Klokka 11:39 (+1000) skreiv Neil Brown:
> 
> > Your explanation would explain that value of 'off' being wrong as I
> > found with the lockf locking in 2.4. 
> > However as the file was open for O_APPEND, there would be an implicit
> > seek to the end on every write.  Is this implicit seek expected to do
> > the right thing or would it need fixing too?
> 
> The writes should indeed end up being correctly positioned w.r.t. the
> end of the file (but may write the wrong offset - which is what you
> claimed to see). The problem will be the case of the ftruncate()s which
> will end up using stale offsets obtained from the call to lseek(). You
> may therefore end up extending the file instead of truncating it.

I don't think ftruncates on stale offsets can cause this problem.
As the client which calls ftruncate is the only client which ever
causes the file to shrink (the other client only causes it to grow),
stale offsets that it sees may be too short, but will never be too
long.
So it might truncate more than it expects to (and this test doesn't
check for that possibility) but it won't truncate beyond the end of
the file and so create a hole.

> 
> Could you please test out the following patch? It should apply to 2.4.x
> too if you substitute generic_file_llseek() for the references to
> remote_llseek().

I tried the patch, and it didn't help noticeably.

(I  had to change
> +		int retval = nfs_revalidate_inode(file->f_dentry->d_inode);
to
> +		int retval = nfs_revalidate_inode(NFS_SERVER(file->f_dentry->d_inode), file->f_dentry->d_inode);

but that might be because I'm actually using -mm for testing).


I poked around in the related code and found that nfs_update_inode,
which is called by nfs_revalidate_inode, won't accept a decrease in
file size if it thinks the file is 'unstable'.  So I put in a printk
to tell me when this happened:

		if (S_ISREG(inode->i_mode) && data_unstable) {
			if (new_isize > cur_isize) {
				inode->i_size = new_isize;
				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
			}
			else printk("may have missed trunc %ld->%ld\n",
				    (long)cur_isize, (long)new_isize); /* neilb */
		} else {
			inode->i_size = new_isize;
			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
		}

and got some output:

Apr  5 13:40:41 cage kernel: may have missed trunc 2050->2030
Apr  5 13:40:41 cage kernel: may have missed trunc 2060->2020
Apr  5 13:40:41 cage kernel: may have missed trunc 2090->2070
Apr  5 13:40:41 cage kernel: may have missed trunc 2130->2110

and more.
This first message would have resulted in a 20 byte hole at 2030.
The next a 40 byte hole at 2020 (subsuming the previous hole).
The next a 20 byte hole at 2070

The are indeed the first 2 'holes' of nuls that I find when looking
in the resulting file.
(This is using fcntl locking).

I feel were getting closer to atleast one bug...

NeilBrown
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)
Comment: Processed by Mailcrypt 3.5.8 <http://mailcrypt.sourceforge.net/>

iD8DBQFCUg21G5fc6gV+Wb0RAps8AKDAV2Wzj+hajLzCBkN1jmx50H3duQCdFrr8
OuGnL8KM1fi/MHB22U3jCX0=
=5jLw
-----END PGP SIGNATURE-----


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
