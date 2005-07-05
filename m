From: Peter Staubach <staubach@redhat.com>
Subject: Re: Linux client with MS SFU server
Date: Tue, 05 Jul 2005 14:42:56 -0400
Message-ID: <42CAD4B0.3080307@redhat.com>
References: <Pine.LNX.4.61.0507051838180.28175@maggie.lkpg.cendio.se>	 <42CACE6A.6090005@redhat.com> <1120589011.8093.49.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpsSa-0004or-K2
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 11:47:56 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DpsSa-0007bH-4L
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 11:47:56 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1120589011.8093.49.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>
>It seems strange, though, that a GETATTR should succeed but that a
>READDIR with the same credential should fail with an RPC error of
>AUTH_REJECTEDCRED.
>
>It looks as if they rather want to be returning NFSERR_ACCES here.
>

I'd rather given up on trying to guess why some of the Windows based 
solutions
worked the way that they did.  I keep hoping that it make some sense, given
some information that I don't have...  :-)

       ps


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
