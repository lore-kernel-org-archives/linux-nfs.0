From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: corruption over NFS with 2.6 client, locking,
	truncating and appending...
Date: Tue, 05 Apr 2005 23:40:19 -0400
Message-ID: <1112758819.10518.20.camel@lade.trondhjem.org>
References: <16977.57630.766727.608029@cse.unsw.edu.au>
	 <1112664792.11910.12.camel@lade.trondhjem.org>
	 <16977.60501.153237.389021@cse.unsw.edu.au>
	 <1112667216.11740.4.camel@lade.trondhjem.org>
	 <16978.3509.329730.989580@cse.unsw.edu.au>
	 <1112676829.11900.4.camel@lade.trondhjem.org>
	 <16978.9443.679431.70613@cse.unsw.edu.au>
	 <1112732661.10536.8.camel@lade.trondhjem.org>
	 <16979.19646.790800.298347@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJ1PG-00086d-1c
	for nfs@lists.sourceforge.net; Tue, 05 Apr 2005 20:40:42 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DJ1PE-0004Mh-0Q
	for nfs@lists.sourceforge.net; Tue, 05 Apr 2005 20:40:42 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16979.19646.790800.298347@cse.unsw.edu.au>
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

on den 06.04.2005 Klokka 12:43 (+1000) skreiv Neil Brown:

> I assume it is adequately safe....
> It protects against concurrent writes changing the size, but not
> concurrent setattrs. .... But as the setattr updates i_size *after*
> the NFS request completes, it should be safe, yes?

So, setattrs that change the file size are supposed to take the
inode->i_sem semaphore first, something which should suffice to prevent
anyone from calling __generic_file_aio_write_nolock(), and hence
dirtying new pages while we're doing our thing.
In addition, nfs_setattr() ensures that it writes out any pre-existing
dirty pages and cached writes before it actually launches the setattr
RPC call.

I believe the case of mmap() is also pretty safe, since it calls
deny_write_access(), which again should prevent the calls to
get_write_access() in sys_truncate()/sys_ftruncate() from succeeding.

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
