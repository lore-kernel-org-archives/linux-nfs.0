From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [CHECKER] inconsistent NFS stat cache (NFS on ext3, 2.6.11)
Date: Sun, 13 Mar 2005 10:18:30 -0500
Message-ID: <1110727110.10684.21.camel@lade.trondhjem.org>
References: <Pine.GSO.4.44.0503122300030.6817-100000@elaine24.Stanford.EDU>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, mc@cs.Stanford.EDU
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAUri-0007jh-9B
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 07:18:50 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAUrg-0001Nx-Hd
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 07:18:50 -0800
To: Junfeng Yang <yjf@stanford.edu>
In-Reply-To: <Pine.GSO.4.44.0503122300030.6817-100000@elaine24.Stanford.EDU>
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

lau den 12.03.2005 Klokka 23:04 (-0800) skreiv Junfeng Yang:
> > This is a known problem. Turn off the (default - grrr) subtree checking
> > export option on the server, and it will all work properly. The subtree
> > checking option violates the NFS standards for filehandle generation in
> > so many ways, that it isn't even funny.
> 
> Hi Trond,
> 
> Turn off this option in /etc/exports does fix the inconsistency.  However
> I looked throught the export man page and seems that subtree checking will
> cause problems only in the following case: "accessing files that are
> renamed while a client has them open".  My test case is *not* doing this.
> It does renames but it never does so with a file opened.  Can you please
> clarify?

The subtree checking option causes knfsd to store the inode number of
the parent directory in the filehandle. Your case involves two hard
links that resides in different directories, and so the filehandles are
different.
In theory, the client could use the fileid in order to decide that these
2 filehandles point to the same file, but doing so will still fail to
deal with the problem of renamed open files. It also adds a lot of
complexity, since fileids have a lot of nasty properties (not least
being the fact that they may be reused after the original file was
deleted).

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
