From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS lockups/hangs on RHEL64 U4 ?
Date: Wed, 16 Feb 2005 13:13:08 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130853976C@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1WU0-0003QU-8I
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 13:13:16 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D1WTy-00046A-Pg
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 13:13:16 -0800
To: <greg@bakers.org>
Sender: nfs-admin@lists.sourceforge.net
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

greg-

your mail just got through the nfs exploder.

this is a known issue on RHEL 3.0, RH bugzilla 138182.

> -----Original Message-----
> From: gb [mailto:bakerg3@yahoo.com]=20
> Sent: Monday, January 24, 2005 5:35 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] NFS lockups/hangs on RHEL64 U4 ?
>=20
>=20
>=20
> All,
>=20
> Apologies in advance if this forward is viewed as
> uncouth; I wanted to ask the folks here if they have
> had any experience, or have seen the NFS problem
> described below (well, linked to below may be a better
> explanation...)
>=20
> The showTasks output lists multiple deadlocked tasks
> with a Call Trace in the following condition:
>=20
> (from the sif029.strings included on the Bugzilla
> page)
>=20
> Call Trace:
> [<ffffffffa00c6024>]{:nfs:nfs_complete_unlink+308}=20
>=20
> Call Trace: [<ffffffffa00d39c0>]{:nfs:nfs_sops+0}
> [<ffffffffa00d3d00>]{:nfs:nfs_fs_type+0}=20
>=20
> Ideas?  Suggestions?  I've also opened a ticket with
> internal Redhat support to see if they have any
> hypothesis.
>=20
> Thanks,
>=20
> --Greg=20
>=20
> >
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D145550
> >=20
> >            Summary: NFS lockups/hangs on RHEL3
> > x86_64 U4
> >            Product: Red Hat Enterprise Linux
> >            Version: 3
> >           Platform: x86_64
> >         OS/Version: Linux
> >=20
> >=20
> > Description of problem:
> >=20
> > We have a group of 10 systems to distribute builds
> > (gcc).  When these
> > systems are under heavy load, the builds (make
> > process) hang in a
> > blocked, deadlocked state.
> >=20
> > The NFS servers do not show excessive load or any
> > problems.
> >=20
> > NFS gcc source: NetApp Release 6.4.5P2
> > NFS build source: NetApp Release 6.5.2R1P9:
> >=20
> > The 10 build clients are exactly the same hardware
> > and configuration.
> >  I'll be attaching the following from a system that
> > is exhibiting this
> > behavior:
> >=20
> > # lspci -vv
> > # lsmod
> > # cat /proc/meminfo
> > # cat /proc/cpuinfo
> > # uname -a
> >=20
> > And as much as I can capture from the console as
> > possible.
> >=20
> > Unfortunately, we cannot recreate the hang
> > on-demand.
> >=20
> > Please let me know if there is any other information
> > I can provide
> > that would be helpful.=20
> >=20
> > Version-Release number of selected component (if
> > applicable):
> >=20
> > Redhat Enterprise Linux 3 Update 4 x86_64
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from=20
> real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=3D6595&alloc_id=3D14396&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
