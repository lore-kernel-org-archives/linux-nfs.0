From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 17:26:31 -0500
Message-ID: <1101162391.11196.94.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com>
	 <20041122153655.GH1291@suse.de>  <41A2280B.1010005@int-evry.fr>
	 <1101146906.11196.35.camel@lade.trondhjem.org>
	 <41A236A6.4050104@int-evry.fr>
	 <1101154485.11196.64.camel@lade.trondhjem.org>
	 <02f401c4d0d6$ce19e9c0$2801a8c0@PAULLAPTOP1>
	 <1101158068.11196.71.camel@lade.trondhjem.org>
	 <030901c4d0df$b9664bf0$2801a8c0@PAULLAPTOP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWMdw-000199-1M
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:26:44 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWMdv-0004VV-4v
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:26:43 -0800
To: Paul Cunningham <paulcunningham@sprintmail.com>
In-Reply-To: <030901c4d0df$b9664bf0$2801a8c0@PAULLAPTOP1>
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

m=E5 den 22.11.2004 Klokka 17:07 (-0500) skreiv Paul Cunningham:

> So how does a client mount NFS v3 with Linux?
>=20

The default is to do just as you described: writes are asynchronous
using the caching model described in RFC1813 (NFSv3 unstable writes are
the default, and a COMMIT is sent on close and/or if memory pressure
forces the client to release the cached writes early).

There is also a "sync" mount option available that forces the client to
use NFSv3 stable writes.

The problem is the server side "async" option which basically causes
knfsd to ignore COMMIT requests, as well as causing it to fail to
fsync() the directory after file CREATE/LINK/UNLINK/RENAME/...
i.e. it turns of all consistency guarantess on the server.

Cheers,
  Trond

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
