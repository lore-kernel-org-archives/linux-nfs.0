From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux' NFS locking b0rken?
Date: Wed, 26 May 2004 12:04:01 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085587441.3763.4.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0405251504220.24001-100000@fattire.ngdc.noaa.gov>
	 <1085523068.12612.58.camel@lade.trondhjem.org>
	 <20040526075058.GA7463@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>, Dan Stromberg <strombrg@dcs.nac.uci.edu>, Jeffrey Layton <jtlayton@poochiereds.net>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT0t5-0007tM-CM
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 09:04:15 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BT0t4-0003be-Np
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 09:04:14 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040526075058.GA7463@suse.de>
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

P=E5 on , 26/05/2004 klokka 03:50, skreiv Olaf Kirch:
> Shouldn't it be possible to map flock locks onto the NLM interface
> if we simply record the PID of the process originally requesting
> the lock, and reuse that pid in all future operations? All the
> flock semantics are provided by fs/locks.c already; all the
> NLM client needs to do is to formulate appropriate NLM calls
> for lock type changes (SH->EX and vice versa), and unlocks.
>=20
> Really the only gotcha is that subsequent calls on an existing
> lock use the same PID as the original call, so that the server
> lockd can match up the request with its existing list of locks.

Sure we could. The question is whether or not there are any applications
out there that set both flock and fcntl locks? They would break with
such a scheme.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
