From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: network storage solutions
Date: Thu, 15 May 2003 14:01:06 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127DD1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "Beowulf" <beowulf@beowulf.org>, <nfs@lists.sourceforge.net>,
   <jeffrey.b.layton@lmco.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GPrN-0008Oe-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 14:01:53 -0700
To: "Joe Landman" <landman@scalableinformatics.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> >    Since we use our cluster for production work (please, I'm
> > not trying to offend anyone), we HAVE to have non-corrupted
> > data. This is why we use hard mounts with 'sync' as well as
> > a few other options. The URL above to Chuck's paper has
> > several examples of "good" mount options.
>=20
> Hmmm.  I am reasonably sure that when the IO system returns=20
> an error, it
> does in fact get propagated to the appropriate user-land calling
> program.

yes, that's true.

> The program then makes the determination as to=20
> whether or not
> to continue.  There are quite a few programs that rarely=20
> inspect return
> code from file operations.

not all programs are well-written.  most, in fact, do not
assume that ESTALE can happen, nor were they designed to
work with NFS locking (they may use dot-file locking, for
example, which doesn't work on NFS).  most programs assume
that they run on a local disk-based file system, and were
never tested over NFS.

NFS systems are becoming more and more reliable all the
time, and that means that some corner-case behaviors are
not well tested, or not tested at all, because they
rarely occur any more.

> > > The way I and other who use soft mounts view it, data=20
> lossage occurs
> > > when the server crashes, as you cannot guarantee (except=20
> with sync),
> > > that the data was committed to disk.
> > >
> >=20
> > However, if I read Chuck's paper correctly, with soft mount
> > you can get a soft time-out that can interrupt an operation
> > but the client will continue then with corrupted data. Am I
> > understanding this correctly? Therefore, the clients may be
> > up, but now the data is corrupt and the appliation doesn't
> > know it.
>=20
> I would like to know that as well.  I would like to believe=20
> it will not
> continue with corrupt data, but return an error code/condition which
> should be handled.

to quote:

  If a soft time-out interrupts a write operation, there is no
  guarantee that the file on the server is correct, nor is there
  any guarantee that the client's cached version of the file matches
  what is on the server.

in the face of a soft timeout, there is no way to synchronize
write requests remaining on the client with what exists on the
server.

if a soft timeout occurs during a read operation, the client
should purge its data cache, but i'm not sure it does that
today.  if there are pending write requests on the client
when a read timeout occurs, there is still the problem of
what to do with the waiting writes.

if you absolutely must use soft mounts, you can reduce the
probability of data corruption by making sure that:

  +  you have specified a large number of retransmissions on
     your mount command line:  retrans=3D10 for example

  +  you specify a conservative retransmission timeout:
     timeo=3D7 or more for UDP, and timeo=3D600 for TCP

  +  you use NFS over TCP if possible

  +  on Linux clients, you specify rsize and wsize larger
     than the client's page size to ensure the client
     generates NFS operations asynchronously.  synchronous
     operations (especially a lot of synchronous small
     writes or directory operations) will slow the server
     down and be more likely to trigger a timeout.

> > I'm not sure... If the server crashes, I think this is true.
> > But what if you get an interrupt. Soft mounts will allow
> > the application to continue with corrupted data while hard
> > mounts will produce an error, but not corrupt data (I think).
>=20
> I hope not.  The programs that I send an INTR to on an NFS=20
> system (with
> the intr flag allowed) seem to accept the signal and die.  I guess the
> question is here, what should be the state of the filesystem upon
> acceptance of that signal?  Can you assume it is in a known state?

usually interrupting an application waiting on a file system
mounted with "intr" is harmless, but there is also a probability
of corruption when using "intr," although it is smaller than
when using "soft."

for databases, i recommend "hard,nointr."  that is the safest
combination.


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
