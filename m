From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: Re: executable but not readable
Date: Mon, 29 Mar 2004 01:59:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040328235952.GA10174@janus>
References: <40631E32.1020707@gsi.de> <1080239856.2584.18.camel@lade.trondhjem.org> <40640A7E.5040601@gsi.de> <1080328671.2480.23.camel@lade.trondhjem.org> <20040327121731.GA27152@janus> <1080517611.5553.115.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7kCm-0007m1-N7
	for nfs@lists.sourceforge.net; Sun, 28 Mar 2004 16:00:40 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7kCm-0003Cx-6c
	for nfs@lists.sourceforge.net; Sun, 28 Mar 2004 16:00:40 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1080517611.5553.115.camel@lade.trondhjem.org>
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

On Sun, Mar 28, 2004 at 06:46:51PM -0500, Trond Myklebust wrote:
> P=E5 lau , 27/03/2004 klokka 07:17, skreiv Frank van Maarseveen:
> > On Fri, Mar 26, 2004 at 02:17:51PM -0500, Trond Myklebust wrote:
> > >=20
> > > In NFSv3, the ACCESS call should then be used to decide whether or not
> > > the client is allowed to open the file for execution (and for reading=
 if
> > > that is required). Unfortunately ACCESS is not implemented in the sto=
ck
> > > Linux 2.4.x kernel.
> >=20
> > So the kernel does its own permission checking on the client side
> > for executables _knowing_ that it is going to execute the file but
> > unfortunately the interpreter has to open the file by itself and that
> > fails.
>=20
> No... The kernel should do permission checking for execute, then opens
> the file for reading (overriding the read permissions since this is the
> kernel).
>=20
> Unfortunately, the server is broken, and failing to follow RFC1813 when
> it comes to allowing reads on executables.

I don't understand this. The server doesn't see the difference between
a read for "read" purposes and a read for "execute" purposes IIRC. How
can the server then be broken?

>=20
> > But from a different perspective:
> >=20
> > Being able to create a (non-setuid) executable which cannot be read
> > for security reasons looks very weak to me unless of course it is not
> > possible to let it dump core, strace (ptrace) it, open /proc/... files
> > etc. But is that all actually the case in 2.6?
>=20
> Sounds like a good test of the 2.6 VFS. Have you tried it?

um, no, that's why I asked it. If security fails here and if it's
insolvable then it is a reason to drop the client side ACCESS check in 2.6
for read versus execute permission because it wouldn't buy you anything.

--=20
Frank


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
