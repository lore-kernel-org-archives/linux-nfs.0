From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: 2.6.21.3: NFS: Buggy server - nlink == 0!
Date: Fri, 8 Jun 2007 12:31:58 -0700
Message-ID: <20070608193158.GA8520@localdomain>
References: <20070606081303.GB7168@localdomain>
	<Pine.LNX.4.64.0706061221340.18979@maggie.lkpg.cendio.se>
	<1181133197.6171.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Peter =?iso-8859-1?Q?=C5strand?= <astrand@cendio.se>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HwkCC-0008Rg-Bx
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 12:32:28 -0700
Received: from [208.76.80.75] (helo=byss.tchmachines.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HwkCD-0003hb-B8
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 12:32:31 -0700
In-Reply-To: <1181133197.6171.7.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Jun 06, 2007 at 08:33:17AM -0400, Trond Myklebust wrote:
> On Wed, 2007-06-06 at 12:25 +0200, Peter =C5strand wrote:
> > On Wed, 6 Jun 2007, Ravikiran G Thirumalai wrote:
> > =

> > > While running a dbench stress test on  a nfs mounted file system, I n=
otice
> > > the subject error message on the client machine.  The client machine =
is a 48
> > > core box with NUMA characteristics and 1024 dbench processes running
> > > continuously in a loop, while another memory hog application runs in =
parallel.
> > > The client is on 2.6.21.3.  The server is booted up with 2.6.21.3 as =
well.
> > > Attached is the server configuration.  Same test on a 2.6.16 client d=
oes not
> > > spew out these messages.  Is this really the server issue, or is the =
NFS
> > > client to be blamed here?
> > =

> > I've seen this message with the unfs3 server as well, and it contains s=
ome =

> > explicit checks to avoid sending nlink=3D0. So this is another indicati=
on =

> > that this is actually a client problem.
> =

> Feel free to send a tcpdump to prove it. So far all cases I've ever seen
> of this error message have been servers sending crap back for LOOKUP
> calls. The client does not ever modify the struct nfs_fattr after it has
> decoded the server reply.

I think Trond is right.  I tried the same test with the server running
mainline 2.6.18, and I did not see these error messages on the client.  This
seems to be a regression in the 2.6.21 nfs server code.

Thanks,
Kiran

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
