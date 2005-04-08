From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NAT & lockd
Date: Fri, 08 Apr 2005 11:12:48 -0400
Message-ID: <1112973168.9974.18.camel@lade.trondhjem.org>
References: <111aefd050408062546161db8@mail.gmail.com>
	 <1112967554.15565.58.camel@lade.trondhjem.org>
	 <111aefd050408070844511651@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJvAL-0004Lu-9D
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 08:13:01 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DJvAJ-0003pf-Jp
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 08:13:01 -0700
To: penney@msu.edu
In-Reply-To: <111aefd050408070844511651@mail.gmail.com>
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

fr den 08.04.2005 Klokka 10:08 (-0400) skreiv Chris Penney:

> In this situation (behind NAT), what happens with the client?  Will a
> lock request fail or simply appear to always work?
> 

The server will refuse to grant the lock if it fails to set up
monitoring with the client, so you should be "safe".

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
