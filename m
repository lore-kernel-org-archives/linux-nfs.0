From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: corruption over NFS with 2.6 client, locking,
	truncating and appending...
Date: Tue, 5 Apr 2005 15:40:51 +1000
Message-ID: <16978.9443.679431.70613@cse.unsw.edu.au>
References: <16977.57630.766727.608029@cse.unsw.edu.au>
	<1112664792.11910.12.camel@lade.trondhjem.org>
	<16977.60501.153237.389021@cse.unsw.edu.au>
	<1112667216.11740.4.camel@lade.trondhjem.org>
	<16978.3509.329730.989580@cse.unsw.edu.au>
	<1112676829.11900.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIgo7-0000Jf-Uw
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 22:40:59 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DIgo7-00074A-81
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 22:40:59 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Tuesday April 5
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

On Tuesday April 5, trond.myklebust@fys.uio.no wrote:
> > I poked around in the related code and found that nfs_update_inode,
> > which is called by nfs_revalidate_inode, won't accept a decrease in
> > file size if it thinks the file is 'unstable'.  So I put in a printk
> > to tell me when this happened:
> > 
> > 		if (S_ISREG(inode->i_mode) && data_unstable) {
> > 			if (new_isize > cur_isize) {
> > 				inode->i_size = new_isize;
> > 				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
> > 			}
> > 			else printk("may have missed trunc %ld->%ld\n",
> > 				    (long)cur_isize, (long)new_isize); /* neilb */
> > 		} else {
> > 			inode->i_size = new_isize;
> > 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
> > 		}
> > 
> > and got some output:
> > 
> > Apr  5 13:40:41 cage kernel: may have missed trunc 2050->2030
> > Apr  5 13:40:41 cage kernel: may have missed trunc 2060->2020
> > Apr  5 13:40:41 cage kernel: may have missed trunc 2090->2070
> > Apr  5 13:40:41 cage kernel: may have missed trunc 2130->2110
> 
> That is indeed a problem. The current code basically assumes
> close-to-open semantics, and that of course breaks down in the case of
> locking.
> OK. I'm going to have to give that some thought...

The thing is that it seems to break down even without locking, though
I don't fully understand why yet.
When I use .lock file locking I get the same problem.
However I have found that if I open the file for read, and then close
it, immediately before opening for write+append, then the problem goes
away.  This is for the .lock file locking, and the .lock file is held
over both opens.

However, let's fix one thing at a time.  I look forward to the result
of your thoughts.

> 
> BTW: The 2.4 code should be very different in this respect: it has no
> equivalent to the "unstable" test. Are you seeing the same problem
> there?

When using lockf locking, the only problem I see can be explained by the
llseek problem you sent a patch for (I haven't tested it in 2.4 yet).
With .lock file locking I see a similar problem in 2.4, but that could
be because 2.4 doesn't support full cto semantics - I'm not sure.

I have a question though.
If I understand cto properly, then if I do
  open(O_READ)
  read
  close
  open(O_READ)
  read
  close

then the client should atleast refresh the attributes somewhere
between the first close and the second read.  tcpdump shows that it 
does do this, however I cannot find in the code where either the close
or the open invalidates the cached attributes.
Could you give me a pointer?

Thanks
NeilBrown
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)
Comment: Processed by Mailcrypt 3.5.8 <http://mailcrypt.sourceforge.net/>

iD8DBQFCUiTjG5fc6gV+Wb0RAkoXAKC+lTD+VmFDQCpHM7hbKy3cOb3FwQCgtNYO
wWNl7iobnxLV9xXXmqY/Osc=
=YmF9
-----END PGP SIGNATURE-----


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
