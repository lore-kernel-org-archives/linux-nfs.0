From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS mandelbug
Date: Wed, 02 Jun 2004 11:30:48 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1086201048.3955.4.camel@lade.trondhjem.org>
References: <Pine.GSO.3.96.1040602104637.19937A-100000@einstein>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVaWa-0008RW-L2
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 11:31:40 -0700
Received: from adsl-207-214-87-84.dsl.snfc21.pacbell.net ([207.214.87.84] helo=lade.trondhjem.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BVaWa-0004i2-55
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 11:31:40 -0700
To: James Chamberlain <jamesc@exa.com>
In-Reply-To: <Pine.GSO.3.96.1040602104637.19937A-100000@einstein>
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

P=E5 on , 02/06/2004 klokka 10:28, skreiv James Chamberlain:
> Hi all,
>=20
> Apologies for the braindump, but I've tried everything I can think of and=
 am
> hoping someone on the list can think of something I haven't.  I've got an=
 NFS
> server here which seems to randomly stop serving NFS - though the rest of=
 the
> system remains up and running.
>=20
> The first thing I noticed in the syslog was that the "kernel is unable to
> handle a NULL pointer dereference at virtual address 00000020".  The culp=
rit
> for this message seems to be lockd.  (ksymoops at the end of the message)
>=20
> I've been having some trouble narrowing down exactly what triggers the NF=
S
> server on this system to stop working, but I've come up with one set of
> conditions so far:  a relatively short time after the lockd oops, attempt=
s to
> mount filesystems from the server trigger the problem.  At roughly the sa=
me
> time, with additional debugging enabled, I start getting messages in the
> syslog saying "svc: socket <hex-num> TCP data ready" and "svc: socket
> <hex-num> busy, not enqueued".  I have observed this problem regardless o=
f
> whether I was running a SMP or uniprocessor kernel.

2.4.18 never had support for TCP on the server side. That didn't get in
until 2.4.20...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
