From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: corruption over NFS with 2.6 client, locking, truncating and
 appending...
Date: Mon, 04 Apr 2005 21:33:12 -0400
Message-ID: <1112664792.11910.12.camel@lade.trondhjem.org>
References: <16977.57630.766727.608029@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIcwf-0003e7-QG
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 18:33:33 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DIcwe-0005H2-8O
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 18:33:33 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16977.57630.766727.608029@cse.unsw.edu.au>
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

ty den 05.04.2005 Klokka 10:51 (+1000) skreiv Neil Brown:

> 		switch(*action) {
> 		case 'a': /* append */
> 			off = lseek(fd, 0, SEEK_END);
> 			sprintf(buf, "%09lu\n", off);
> 			write(fd, buf, 10);
> 			fsync(fd);
> 			break;

Argh... OK, I see the problem here.

When you call lseek(SEEK_END), the kernel really needs to be calling
nfs_revalidate_inode() in order to update the cached attribute info.
Currently that is not the case, since we just default to the VFS
generic_file_llseek().

I'll code something up in the morning.

BTW: This will indeed affect both 2.4.x and 2.6.x kernels.

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
