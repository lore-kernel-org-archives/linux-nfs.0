From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv3+Krb5 and mountd
Date: Mon, 30 Aug 2004 12:45:02 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093884302.8729.21.camel@lade.trondhjem.org>
References: <20040824184138.GB3251@nasse>
	 <Pine.LNX.4.61.0408300238530.2441@fogarty.jakma.org>
	 <20040830020132.GA28919@fieldses.org>  <20040830154541.GA3671@nasse>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Paul Jakma <paul@clubi.ie>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1pHm-0005uw-0T
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 09:45:38 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C1pHj-0001Ml-5O
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 09:45:37 -0700
To: Per Olofsson <pelle@dsv.su.se>
In-Reply-To: <20040830154541.GA3671@nasse>
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

P=E5 m=E5 , 30/08/2004 klokka 11:45, skreiv Per Olofsson:

> OK, I understand. I don't really need authenticated mount requests
> though, I only need authenticated file system accesses. In other
> words, I don't care who mounts the file system as long as they can't
> impersonate a user without a valid ticket. Is this easier to
> implement? Does it have any other security implications?

This is already implemented...

The RPCSEC_GSS implementation that is in linux-2.6.x already follows the
guidelines in RFC2623 when you mount an NFSv2 or v3 partition. (The same
RFC also includes a brief discussion of the security implications of
this model.)

You'll need a patched version of "mount" though. The one distributed as
part of Fedora Core 2 should work...

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
