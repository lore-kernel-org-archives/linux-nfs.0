From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: invalidate cache / NFS performance on a diskless system
Date: Fri, 10 Dec 2004 00:34:58 -0500
Message-ID: <1102656898.11052.4.camel@lade.trondhjem.org>
References: <200412091718.48973.jrinas@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcdR4-0005EP-DJ
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 21:35:22 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CcdR0-0005q4-4H
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 21:35:21 -0800
To: "J.Rinas" <jrinas@gmx.de>
In-Reply-To: <200412091718.48973.jrinas@gmx.de>
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

to den 09.12.2004 Klokka 17:18 (+0100) skreiv J.Rinas:

> So I'd like to know if there is a switch to invalidate the whole NFS / VFS? 
> cache at once!
> (e.g. an    echo something > /proc/somewhere  )?

No.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
