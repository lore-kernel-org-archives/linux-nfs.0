From: Paul Jakma <paul@clubi.ie>
Subject: Re: NFSv4 daemons...
Date: Sat, 24 Jan 2004 03:41:49 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0401240337210.2140@fogarty.jakma.org>
References: <1073608448.1380.22.camel@nidelv.trondhjem.org>
 <1073619719.12271.7.camel@binkley> <1073621173.1398.55.camel@nidelv.trondhjem.org>
 <Pine.LNX.4.58.0401231453070.2140@fogarty.jakma.org> <20040123162018.GC26511@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        seth vidal <skvidal@phy.duke.edu>, hjl@users.sourceforge.net,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AkEgX-0007PR-DI
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 19:42:13 -0800
Received: from hibernia.jakma.org ([213.79.33.168])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1AkEgU-0000QI-KU
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 19:42:11 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040123162018.GC26511@fieldses.org>
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

On Fri, 23 Jan 2004, J. Bruce Fields wrote:

> There are three levels levels of protection provided by rpcsec_gss, from
> weakest to strongest:
> 
> 	authentication only: the header of each rpc request is signed, so you
> 		who sent the request.
> 	integrity: the body of each packet is also signed, so you know
> 		the request itself hasn't been tampered with.
> 	privacy: the body of each packet is encrypted, to prevent
> 		eavesdropping.

Ah, good.

> In the krb5 case, these are selected using mount options (sec=krb5,
> sec=krb5i, or sec=krb5p).  Mainline 2.6 currently supports the
> first of these.  Patches in -mm support integrity.  

So we'll have strong authorisation and integrity checks for NFS^WRPC
soon in 2.6. Excellent news!

> But privacy hasn't been implemented yet (it's been done before,
> there's bits and pieces of code still lying around, it just needs
> some time and effort).

Ok. But its on the horizon at least? Would be really nice to have
this, esp if it can use some of the stronger algorithms supported by
Krb5 (eg DES3 and/or AES).

Anyway, future looks bright! Thanks!
 
> --Bruce Fields

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
	warning: do not ever send email to spam@dishone.st
Fortune:
Political history is far too criminal a subject to be a fit thing to
teach children.
		-- W.H. Auden


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
