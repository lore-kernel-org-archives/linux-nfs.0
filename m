From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: executable but not readable
Date: Sun, 28 Mar 2004 20:00:09 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080522009.5553.119.camel@lade.trondhjem.org>
References: <40631E32.1020707@gsi.de>
	 <1080239856.2584.18.camel@lade.trondhjem.org> <40640A7E.5040601@gsi.de>
	 <1080328671.2480.23.camel@lade.trondhjem.org>
	 <20040327121731.GA27152@janus>
	 <1080517611.5553.115.camel@lade.trondhjem.org>
	 <20040328235952.GA10174@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7l8C-000652-3S
	for nfs@lists.sourceforge.net; Sun, 28 Mar 2004 17:00:00 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B7l8C-0000hq-1d
	for nfs@lists.sourceforge.net; Sun, 28 Mar 2004 17:00:00 -0800
To: Frank van Maarseveen <frankvm@xs4all.nl>
In-Reply-To: <20040328235952.GA10174@janus>
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

P=E5 su , 28/03/2004 klokka 18:59, skreiv Frank van Maarseveen:
> >=20
> > Unfortunately, the server is broken, and failing to follow RFC1813 when
> > it comes to allowing reads on executables.
>=20
> I don't understand this. The server doesn't see the difference between
> a read for "read" purposes and a read for "execute" purposes IIRC. How
> can the server then be broken?

Read the paragraph I quoted earlier in this thread from RFC1813. The
server is supposed to allow READ if the executable bit is set.

The ACCESS call should, however, act exactly like the local
sys_access(), and so should return an error if the user asks for READ
permission.

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
