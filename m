From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Fri, 22 Oct 2004 17:35:47 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098480947.7392.14.camel@lade.trondhjem.org>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
	 <20041021161309.GC24417@fieldses.org>
	 <1098413781.21421.37.camel@hole.melbourne.sgi.com>
	 <16760.31766.119716.302669@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Banks <gnb@melbourne.sgi.com>,
	"Dr. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CL74x-0001Gp-Gy
	for nfs@lists.sourceforge.net; Fri, 22 Oct 2004 14:36:07 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CL74w-0001of-0y
	for nfs@lists.sourceforge.net; Fri, 22 Oct 2004 14:36:07 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16760.31766.119716.302669@cse.unsw.edu.au>
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

fr den 22.10.2004 Klokka 13:18 (+1000) skreiv Neil Brown:

> I would suggest that silly-rename should be replaced with silly-link.
> viz.
>     link /b/bob /b/.nfsXXXX
>     rename /a/fred /a/bob
> 
> This would then have correct semantics.  (ofcourse, the filesystem
> might not support "link", in which case you could fall-back to rename
> and that's not a problem, because then /a/fred and /a/bob cannot be
> the same file anyway).

Why? That fixes the _symptom_ of sillyrename, but does nothing to
address the underlying problem.

The _real_ problem here is that the client ends up aliasing inodes
because it has no way to really know that these are the same file. That
leads to incoherent metadata+data caches for that file, resulting in
possible data corruption if file descriptors are open on both inodes at
the same time.
What's more, the cross-directory rename may result in a file descriptor
that is open on the "source" inode ending up with a stale filehandle.

Why should we encourage that sort of server behaviour?

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
