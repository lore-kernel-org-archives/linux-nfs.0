From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv3+Krb5 and mountd
Date: Mon, 30 Aug 2004 18:25:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093904714.8729.106.camel@lade.trondhjem.org>
References: <20040824184138.GB3251@nasse>
	 <Pine.LNX.4.61.0408300238530.2441@fogarty.jakma.org>
	 <20040830020132.GA28919@fieldses.org> <20040830154541.GA3671@nasse>
	 <1093884302.8729.21.camel@lade.trondhjem.org>
	 <20040830171734.GC1555@fieldses.org>
	 <1093887933.8729.35.camel@lade.trondhjem.org>
	 <20040830180402.GE1555@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Per Olofsson <pelle@dsv.su.se>, Paul Jakma <paul@clubi.ie>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1uag-0006mk-0x
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 15:25:30 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C1uae-0000Dl-Ck
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 15:25:29 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040830180402.GE1555@fieldses.org>
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

P=E5 m=E5 , 30/08/2004 klokka 14:04, skreiv J. Bruce Fields:

> Since we specify the rpcsec_gss security flavor as the client in
> /etc/exports, in the place of the ip address/network/whatever, this
> means in practice we'd need to allow MOUNT from any ip address for a
> filesystem that's exported to rpcsec_gss.  Which I suppose is OK, though
> I don't understand why clients really want to do that.

See the RFC. It was basically Sun's decision in order to avoid having to
assign machine credentials to their automounters. If you want your
server to work with SunOS clients, then that's all pretty mandatory.

> > mountd should always support AUTH_SYS, so no changes required there
> > (apart from the need to add the supported RPCSEC_GSS pseudoflavours to
> > the "auth_flavors" list).
> > As far as I know, nobody (not even Sun) has set up NLM to work with
> > RPCSEC_GSS either.
>=20
> Well, I suppose unauthenticated locks are a DOS at worse.  But the
> lookup of the initial filehandle seems more security-critical to me.

What can an attacker do with that filehandle?

Actually re-reading the RFC, it does not actually restrict MOUNT to
AUTH_SYS-only, but again - interoperability with Solaris automounters
means that it is pretty much expected...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
