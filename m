From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv4 daemons...
Date: Fri, 23 Jan 2004 11:20:18 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040123162018.GC26511@fieldses.org>
References: <1073608448.1380.22.camel@nidelv.trondhjem.org> <1073619719.12271.7.camel@binkley> <1073621173.1398.55.camel@nidelv.trondhjem.org> <Pine.LNX.4.58.0401231453070.2140@fogarty.jakma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	seth vidal <skvidal@phy.duke.edu>, hjl@users.sourceforge.net,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ak42q-0000qR-HZ
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 08:20:32 -0800
To: Paul Jakma <paul@clubi.ie>
In-Reply-To: <Pine.LNX.4.58.0401231453070.2140@fogarty.jakma.org>
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

On Fri, Jan 23, 2004 at 02:54:36PM +0000, Paul Jakma wrote:
> On Thu, 8 Jan 2004, Trond Myklebust wrote:
> > rpc.gssd is necessary if you want to use strong authentication (for
> > NFSv2/v3 as well as for NFSv4).
> 
> Does this implement data stream encryption? (rpcsec as opposed to rpc
> auth? (possibly getting my jargon wrong here))

There are three levels levels of protection provided by rpcsec_gss, from
weakest to strongest:

	authentication only: the header of each rpc request is signed, so you
		who sent the request.
	integrity: the body of each packet is also signed, so you know
		the request itself hasn't been tampered with.
	privacy: the body of each packet is encrypted, to prevent
		eavesdropping.

In the krb5 case, these are selected using mount options (sec=krb5,
sec=krb5i, or sec=krb5p).  Mainline 2.6 currently supports the first of
these.  Patches in -mm support integrity.  But privacy hasn't been
implemented yet (it's been done before, there's bits and pieces of code
still lying around, it just needs some time and effort).

--Bruce Fields


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
