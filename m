From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Move (mv) hangs with NFSv4
Date: Fri, 03 Dec 2004 13:18:51 -0500
Message-ID: <1102097931.10878.21.camel@lade.trondhjem.org>
References: <41B0A79A.2010203@drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CaI1J-0000t9-3j
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 10:19:05 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CaI1I-0006Fx-2K
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 10:19:04 -0800
To: Pierre Ossman <drzeus-list@drzeus.cx>, "Dr. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <41B0A79A.2010203@drzeus.cx>
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

fr den 03.12.2004 Klokka 18:51 (+0100) skreiv Pierre Ossman:

> There is no error message on the server. On the client I get "RPC: 
> rpciod waiting on sync task!" now and then. Most of the time it doesn't 
> say a thing though so I'm not sure it's related.

The "rpciod waiting on sync task" is a known problem that should
normally only occur if you ^C out. I'm still working on a complete fix
for that.

As for the other hang: I'm not reproducing it against non-linux servers.
Bruce, any ideas?

Cheers,
  Trond

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
