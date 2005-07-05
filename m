From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux client with MS SFU server
Date: Tue, 05 Jul 2005 14:43:31 -0400
Message-ID: <1120589011.8093.49.camel@lade.trondhjem.org>
References: <Pine.LNX.4.61.0507051838180.28175@maggie.lkpg.cendio.se>
	 <42CACE6A.6090005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpsOW-0004am-Gn
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 11:43:44 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DpsOV-0006gQ-0c
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 11:43:44 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <42CACE6A.6090005@redhat.com>
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

ty den 05.07.2005 Klokka 14:16 (-0400) skreiv Peter Staubach:

> Does this server need to be configured with the uid and maybe gid of the 
> user to
> be accessing files on the file system?  I have seen some situations, 
> typically
> with Microsoft servers, that need to be accessed using a specific uid/gid
> combination.  Since these systems don't have the concept of uid and gid 
> anyway,
> perhaps this is required here.
> 
> At Connectathon, it seems like some of the servers need to be accessed using
> magic uids and gids...

It seems strange, though, that a GETATTR should succeed but that a
READDIR with the same credential should fail with an RPC error of
AUTH_REJECTEDCRED.

It looks as if they rather want to be returning NFSERR_ACCES here.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
