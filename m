From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: 3 NFS client panics in 2.4.21. Fixed in 2.4.22?
Date: Tue, 26 Aug 2003 07:15:35 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113D06B5B@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "NFS List" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19redM-00007U-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Aug 2003 07:17:20 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19redL-0005Tm-8y
	for nfs@lists.sourceforge.net; Tue, 26 Aug 2003 07:17:19 -0700
To: "Matt C" <wago@phlinux.com>
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

> > I've had 3 very similar panics on 3 seperate machines under=20
> 2.4.21. All
> > appear to be in the NFS client stack. All are SMP/Bigmem=20
> machines, and the
> > kernel was pretty close to vanilla. All machines are=20
> redhat-7.2 using ext3
> > filesystems.
> >
> > Before I hop on the latest kernel out of the hopper for production
> > systems, do you know if these are known/fixed bugs in=20
> 2.4.22 or in BK?
> >
> =20
> I'm afraid there is a critical bug in 2.4.22, please see the thread:
>=20
> [NFS] nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
>=20
>=20
> I havn't tested it with 2.4.22-rc3 and rc4, but I didn't see=20
> anything in the=20
> changelog, that could fix it :-(

the "nfs errors clutter up logs" bug has nothing to do with these
oopses, as far as i can tell.

matt-  can you tell us a little about how you reproduce this problem?
have you ever seen it on UP or non-HIGHMEM systems?


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
