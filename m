From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux' NFS locking b0rken?
Date: Thu, 27 May 2004 12:31:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085675509.4074.26.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0405251504220.24001-100000@fattire.ngdc.noaa.gov>
	 <1085523068.12612.58.camel@lade.trondhjem.org>
	 <20040526075058.GA7463@suse.de>
	 <1085587441.3763.4.camel@lade.trondhjem.org>
	 <20040527161412.GA19288@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>, Dan Stromberg <strombrg@dcs.nac.uci.edu>, Jeffrey Layton <jtlayton@poochiereds.net>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTNnT-0002HA-C2
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 09:31:59 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BTNnT-0000Jw-1k
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 09:31:59 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040527161412.GA19288@suse.de>
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

P=E5 to , 27/05/2004 klokka 12:14, skreiv Olaf Kirch:
> On Wed, May 26, 2004 at 12:04:01PM -0400, Trond Myklebust wrote:
> > Sure we could. The question is whether or not there are any application=
s
> > out there that set both flock and fcntl locks? They would break with
> > such a scheme.
>=20
> Don't they deserve to break?

Yep, but since the main users of flock tend to be mail-related
applications, we'd better check first. People tend to get grumpy when
their favourite MTA locks up and dies.

That said, I believe that RHEL-3 at least is returning an error these
days whenever you try to flock over NFS: I dunno if you are doing this
at SuSE yet?
Hopefully that will suffice to wipe the slate clean w.r.t. borken apps
(I know it caused my old uni to be aware of the problem and fix up a
couple of "movemail"s that were using flock).

> I'd rather make flock work over NFS (and have one FAQ less to deal with),
> than supporting patently broken apps.
>=20
> We could create a mount option or even better a lockd module option to
> make the old behavior selectable for those that need it.

lockd sysctl...

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
