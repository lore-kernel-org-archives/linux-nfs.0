From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: executable but not readable
Date: Sun, 28 Mar 2004 18:46:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080517611.5553.115.camel@lade.trondhjem.org>
References: <40631E32.1020707@gsi.de>
	 <1080239856.2584.18.camel@lade.trondhjem.org> <40640A7E.5040601@gsi.de>
	 <1080328671.2480.23.camel@lade.trondhjem.org>
	 <20040327121731.GA27152@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7jzL-0002GT-Un
	for nfs@lists.sourceforge.net; Sun, 28 Mar 2004 15:46:47 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B7jzL-0001xL-RD
	for nfs@lists.sourceforge.net; Sun, 28 Mar 2004 15:46:47 -0800
To: Frank van Maarseveen <frankvm@xs4all.nl>
In-Reply-To: <20040327121731.GA27152@janus>
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

P=E5 lau , 27/03/2004 klokka 07:17, skreiv Frank van Maarseveen:
> On Fri, Mar 26, 2004 at 02:17:51PM -0500, Trond Myklebust wrote:
> >=20
> > In NFSv3, the ACCESS call should then be used to decide whether or not
> > the client is allowed to open the file for execution (and for reading i=
f
> > that is required). Unfortunately ACCESS is not implemented in the stock
> > Linux 2.4.x kernel.
>=20
> So the kernel does its own permission checking on the client side
> for executables _knowing_ that it is going to execute the file but
> unfortunately the interpreter has to open the file by itself and that
> fails.

No... The kernel should do permission checking for execute, then opens
the file for reading (overriding the read permissions since this is the
kernel).

Unfortunately, the server is broken, and failing to follow RFC1813 when
it comes to allowing reads on executables.

> But from a different perspective:
>=20
> Being able to create a (non-setuid) executable which cannot be read
> for security reasons looks very weak to me unless of course it is not
> possible to let it dump core, strace (ptrace) it, open /proc/... files
> etc. But is that all actually the case in 2.6?

Sounds like a good test of the 2.6 VFS. Have you tried it?

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
