From: James Chamberlain <jamesc@exa.com>
Subject: Re: NFS mandelbug
Date: Wed, 2 Jun 2004 14:42:48 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.3.96.1040602143037.19937C-100000@einstein>
References: <1086201048.3955.4.camel@lade.trondhjem.org>
Reply-To: James Chamberlain <jamesc@exa.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVakp-0003EZ-Cc
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 11:46:23 -0700
Received: from fermi.exa.com ([149.65.3.1])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVako-0007lM-Uk
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 11:46:23 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1086201048.3955.4.camel@lade.trondhjem.org>
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

On Wed, 2 Jun 2004, Trond Myklebust wrote:

> P=E5 on , 02/06/2004 klokka 10:28, skreiv James Chamberlain:
> > Hi all,
> >=20
> > Apologies for the braindump, but I've tried everything I can think of a=
nd am
> > hoping someone on the list can think of something I haven't.  I've got =
an NFS
> > server here which seems to randomly stop serving NFS - though the rest =
of the
> > system remains up and running.
> >=20
> > The first thing I noticed in the syslog was that the "kernel is unable =
to
> > handle a NULL pointer dereference at virtual address 00000020".  The cu=
lprit
> > for this message seems to be lockd.  (ksymoops at the end of the messag=
e)
> >=20
> > I've been having some trouble narrowing down exactly what triggers the =
NFS
> > server on this system to stop working, but I've come up with one set of
> > conditions so far:  a relatively short time after the lockd oops, attem=
pts to
> > mount filesystems from the server trigger the problem.  At roughly the =
same
> > time, with additional debugging enabled, I start getting messages in th=
e
> > syslog saying "svc: socket <hex-num> TCP data ready" and "svc: socket
> > <hex-num> busy, not enqueued".  I have observed this problem regardless=
 of
> > whether I was running a SMP or uniprocessor kernel.
>=20
> 2.4.18 never had support for TCP on the server side. That didn't get in
> until 2.4.20...

As I understand it, some patches were backported.  This seems to have been
among them.  I wish I could tell you which others were, but I don't current=
ly
have the source the NAS vendor used to build this kernel.  I haven't been
mounting through TCP normally, but I have confirmed that this kernel has it=
=2E

James Chamberlain



-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
