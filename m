From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: support of IPv6 by NFSv4
Date: Tue, 23 Mar 2004 10:58:09 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080057489.3109.8.camel@lade.trondhjem.org>
References: <40605D2E.EB4668C0@Bull.Net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net,
	PATRICE ROMAND <Patrice.Romand@Bull.Net>,
	Gerrit Huizenga <gerrit@us.ibm.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5oID-0004TJ-Iv
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 07:58:17 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B5oID-0003Mg-6Y
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 07:58:17 -0800
To: Gilles Quillard <Gilles.Quillard@Bull.Net>
In-Reply-To: <40605D2E.EB4668C0@Bull.Net>
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

P=E5 ty , 23/03/2004 klokka 10:52, skreiv Gilles Quillard:
> Hi,
>=20
> I'm new in this mailing list. We are interesting by having NFSv4 working =
over IPv6.
> One year ago, Bruce Allan from IBM submitted a patch to add the support o=
f IPv6 in the SUNRPC and in the NFS client/server
> kernel part. This patch has not been adopted. Trond, did you remember why=
 this patch has not been taken into account ?

There was (and still is) no userland support for RPC on IPv6, so
NFSv2/v3 cannot as of yet make use of it... At the time, NFSv4 was not
merged.

> Since this date, there has been no new message on the mailing list about =
the support of IPv6. Is there some people working on
> this subject or interested by it ?

Yes: Chuck Lever (cel@citi.umich.edu) has recently taken it up. He is
also trying to extend Bruce's work in order to allow for non-TCP/IP
based transport mechanisms (for an internal project).

> I have begun to look how the support of IPv6 could be integrated in NFS a=
nd SUNRPC. The most efficient way seems to be using the
> IPv4-mapped IPv6 address format (as described in the sections 3.7 and 6 o=
f RFC2133). With this method, IPv4 addresses are
> converted into IPv6 addresses the first time they are used by the user pa=
rt applications, and then all the address processing is
> done using INET6 addresses (simple change of in_addr/sockaddr_in by in6_a=
ddr/sockaddr_in6). This method avoids the multiple
> tests of the INET family and the corresponding castings. A set of macros/=
functions (IN6_IS_ADDR_V4MAPPED(), inet_pton(),
> inet_ntop(), gethostbyname2(), ...) is available to identify the format o=
f the addresses, to convert and display the addresses
> according to their format and to use the name server.

Please make sure you coordinate any work with Chuck...

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
