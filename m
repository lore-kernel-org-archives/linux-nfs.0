From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: RE: Linux client on Solaris 7 NFS server
Date: Mon, 5 Jan 2004 10:21:59 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC981@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AdZMj-0007OI-LS
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 10:22:13 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AdZMj-0007e4-9E
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 10:22:13 -0800
To: <dwight@supercomputer.org>
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

hi dwight-

please capture some network traces of both a fast run and
a slow run (using UDP for both, preferrably).  the traces
don't need to be large (in the neighborhood of 10MB), but
they do need to be raw format, and be sure you capture
at least 256 bytes of each frame (-s256).

the v2/v3 performance delta is usually a red herring; it
is almost always the result of some other problem.

> -----Original Message-----
> From: dwight@supercomputer.org [mailto:dwight@supercomputer.org]=20
> Sent: Monday, January 05, 2004 12:11 PM
> To: Lever, Charles
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] RE: Linux client on Solaris 7 NFS server=20
>=20
>=20
> Chareles Lever wrote:
>=20
> > does "tcp,rsize2768,wsize2768" work?  the Linux defaults are
> > UDP and r/wsize@96, which work adequately with Linux servers,
> > but probably are trouble for Solaris.
> >=20
> > which Linux kernels, specifically, have you tried on your clients?
> >=20
> > what performance do you see, and what do you expect?
>=20
> Well, yes, it works, but there's no noticeable performance=20
> improvement. I'll caveat that with the observation that this was in
> a more complicated production environment. I haven't tried it yet
> with V3 in a semi-isolated environment.
>=20
> One of the more significant speed-ups I've noticed was with
> completely turning off Version 3 NFS support in the kernel, and
> forcing all transactions between Solaris and Linux to be Version 2.
> Just specifying V2 as a mount option improves things a bit; but using
> a 2.4.24-pre1 kernel without V3 support built in dropped the test
> time from about 6 minutes to 3.0 minutes. Just specifying V2 as a=20
> mount option drops the performance from 6 minutes to 4 min,=20
> 45 seconds.
>=20
> In comparision, the pure Linux server and client test ran about 30
> seconds (UDP and TCP); and the pure Solaris environment ran about
> the same. Mind you, the Solaris 8 systems are much slower CPU's in=20
> my test bed the same.  Mind you, the Solaris 8 systems are much=20
> slower CPU's in my test bed
>=20
> Another rather interesting thing is that a Solaris client using a=20
> Linux server runs the test at the same speed as the pure Solaris or=20
> pure Linux environment. So this behaviour is specific to the=20
> Linux-client/Solaris-server situation.
>=20
> As for what kind of results I was expecting, I was hoping for=20
> something comparable to the other 3 pairs of combinations. Perhaps=20
> even just double would be of use; but not a factor of 6.
>=20
> As far as the kernels used, the same consistent results have been=20
> seen across the range of 2.4 kernels. Mostly the RH variations of=20
> 2.4.18, but earlier ones as well, and right now I'm looking at the=20
> 2.4.24 pre-releases. However, I will note that the one's prior to=20
> 2.4.18 were done in the production environment, and not with some=20
> attempt at isolation.
>=20
> Also, the problem seems unaffected by using the latest version of=20
> nfsutils.
>=20
> The overall throughput seems to be pegged at about 11 Mbps IIRC.=20
> Googling shows that other people have also reported this issue over=20
> the years, and there is no clear solution. =20
>=20
> So, in summary, this seems to be a constant issue with Linux/Solaris
> interaction. There also seem to be be issues with V3 in this
> environment.
>=20
> Any suggestions and/or ideas would be welcome.
>=20
> Best Regards,
>=20
>         -dwight-
>=20
>=20
>=20


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
