From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv3+Krb5 and mountd
Date: Thu, 2 Sep 2004 11:39:08 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040902153908.GB32379@fieldses.org>
References: <20040824184138.GB3251@nasse> <Pine.LNX.4.61.0408300238530.2441@fogarty.jakma.org> <20040830020132.GA28919@fieldses.org> <20040830154541.GA3671@nasse> <1093884302.8729.21.camel@lade.trondhjem.org> <20040830171734.GC1555@fieldses.org> <1093887933.8729.35.camel@lade.trondhjem.org> <20040830180402.GE1555@fieldses.org> <1093904714.8729.106.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Per Olofsson <pelle@dsv.su.se>, Paul Jakma <paul@clubi.ie>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2tgM-00048N-Sa
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 08:39:26 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C2tgL-0003xw-5Y
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 08:39:26 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1093904714.8729.106.camel@lade.trondhjem.org>
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

On Mon, Aug 30, 2004 at 06:25:14PM -0400, Trond Myklebust wrote:
> På må , 30/08/2004 klokka 14:04, skreiv J. Bruce Fields:
> > Well, I suppose unauthenticated locks are a DOS at worse.  But the
> > lookup of the initial filehandle seems more security-critical to me.
> 
> What can an attacker do with that filehandle?

One attack that rpcsec_gss is designed to prevent is spoofing of
server's replies to the client.  The client needs to be able to trust
the root filehandle returned by the server; an attacker could probably
do some interesting things by feeding the client faked replies with
incorrect filehandles.

> Actually re-reading the RFC, it does not actually restrict MOUNT to
> AUTH_SYS-only, but again - interoperability with Solaris automounters
> means that it is pretty much expected...

Yeah, OK, but it's unfortunate.  It would be better just to require the
automounter to have credentials of some sort.

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
