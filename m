From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3 of 6] svcrpc: move export table checks to a
 per-program pg_add_client method
Date: Wed, 29 Sep 2004 00:37:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1096411028.11135.201.camel@lade.trondhjem.org>
References: <1095375544.839c1c96.3@fieldses.org>
	 <1095383919.10216.142.camel@lade.trondhjem.org>
	 <20040917022015.GA15212@fieldses.org>
	 <16721.8596.980204.899779@cse.unsw.edu.au>
	 <20040923214644.GA19291@fieldses.org>
	 <16723.40128.804230.618580@cse.unsw.edu.au>
	 <20040928220055.GI5554@fieldses.org>
	 <1096409478.11135.182.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CCQb9-0001Wa-9L
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 15:37:27 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CCQb7-0005gj-68
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 15:37:26 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <1096409478.11135.182.camel@lade.trondhjem.org>
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

P=E5 on , 29/09/2004 klokka 00:11, skreiv Trond Myklebust:
> >=20
> > I can't find anything definitive on this in any rfc, but I don't believ=
e
> > that clients are required to be able to deal with callbacks from a
> > different IP address (or that a server should allow such a thing to
> > happen).  Can anyone find evidence to the contrary?
>=20
> Agreed. If the client talks to the server on one IP-address, but the
> server replies on another, then there is no reason for the client to
> trust the reply.

To put the argument slightly differently:

Although you might argue that when I type "mount bar:/foo", I'm
accepting replies from the DNS entry "bar" rather than an IP address,
however if I type "mount 192.168.0.1:/foo" then I might not want to rely
on DNS to tell me that 192.168.0.2 is an alias for "bar" which is an
alias for 192.168.0.1.

The server doesn't know what I've typed on my command line, so it must
take the conservative view that if I'm talking to 192.168.0.1, then I'm
only accepting replies from that address.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
