From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS direct IO needs page lock?
Date: Tue, 15 Feb 2005 17:51:22 -0500
Message-ID: <1108507882.10073.236.camel@lade.trondhjem.org>
References: <20050215203654.GA15634@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1BYo-0007IZ-Cu
	for nfs@lists.sourceforge.net; Tue, 15 Feb 2005 14:52:50 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D1BYl-0006fr-Px
	for nfs@lists.sourceforge.net; Tue, 15 Feb 2005 14:52:50 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050215203654.GA15634@suse.de>
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

ty den 15.02.2005 Klokka 21:36 (+0100) skreiv Olaf Kirch:
> Hi,
> 
> I'm currently looking at a customer problem problem with weird VM oopses
> that is somehow related to a large application doing heavy NFS direct
> IO to/from a POSIX shmem area (hm, what application would *that* be :-).
> 
> I haven't had a bright idea so far, and I'm not even convinced this is
> NFS related at all - but one thing that struck me as odd when meditated
> over the code today was that the directio code doesn't lock the pages
> in nfs_get_user_pages.  Is that an oversight, or does it do that
> intentionally?

It is intentional. Andrew Morton pointed out that you can play zero-copy
tricks by doing direct-io on an mmapped range of pages (as seems to be
the case above).

That could cause deadlocks if the reader and writer were to both try to
lock the same page.

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
