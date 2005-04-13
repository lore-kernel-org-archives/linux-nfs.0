From: Beschorner Daniel <Daniel.Beschorner@facton.com>
Subject: Re: Can't callback server
Date: Wed, 13 Apr 2005 11:50:10 +0200
Message-ID: <BB1F4EFD574E9F409035BDA71C961250023B4A@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DLeVW-0008AB-7n
	for nfs@lists.sourceforge.net; Wed, 13 Apr 2005 02:50:02 -0700
Received: from loewe.unit-netz.de ([212.202.148.42])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DLeVT-000268-KJ
	for nfs@lists.sourceforge.net; Wed, 13 Apr 2005 02:50:02 -0700
To: "'Trond Myklebust'" <trond.myklebust@fys.uio.no>
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

With 2.6.12-rc2 the bug is indeed still not shown.

Thank you!
Daniel

----------
Von: Trond Myklebust [mailto:trond.myklebust@fys.uio.no] 
Gesendet: Freitag, 8. April 2005 21:07
An: Beschorner Daniel
Betreff: Re: [NFS] Can't callback server

fr den 08.04.2005 Klokka 20:22 (+0200) skreiv Beschorner Daniel:
> Is the client really involved?
> It's in the server log and IP is 127.0.0.1.
> So I believed the problem is between server statd and server lockd?!?

Duh... Sorry, I'm sleeping today.

So, all kernels prior to 2.6.12-rc1 had a bug in them which prevented
statd and lockd from interoperating correctly unless you had an entry
for "localhost" in your /etc/exports file.
Can you therefore try reproducing the problem with 2.6.12-rc1 or
2.6.12-rc2?

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
