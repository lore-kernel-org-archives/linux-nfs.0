From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: NFS over TCP: random drop
Date: Tue, 16 Mar 2004 12:05:30 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1079456730.3045.47.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DD6E@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3I1D-0002z8-AS
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 09:06:19 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B3I0t-00011u-1f
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 09:05:59 -0800
To: Charles Lever <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DD6E@lavender-fe.eng.netapp.com>
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

P=E5 ty , 16/03/2004 klokka 11:21, skreiv Lever, Charles:
> hi olaf-
>=20
> IMO it would be better to fix this in the client.  overloaded
> servers of all kinds behave this way, and the client should
> deal with it.  server cluster failover also behaves this way.

It *should* currently be dealing with it...

ECONNRESET in xprt_sendmsg will be tranformed into ENOTCONN. That again
should cause call_status() to call the reconnection code.

However if the server disconnects us *while we are reconnecting*, then
the soft request will fail with an EIO. This seems like sensible
behaviour to me: a server which is accepting a connection then
immediately breaking it is fundamentally broken...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
