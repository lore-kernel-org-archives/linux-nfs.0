From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: RE: Linux client on Solaris 7 NFS server
Date: Tue, 30 Dec 2003 09:58:27 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC965@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AbO8X-0007lR-Ny
	for nfs@lists.sourceforge.net; Tue, 30 Dec 2003 09:58:33 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AbO8X-0006LY-Fd
	for nfs@lists.sourceforge.net; Tue, 30 Dec 2003 09:58:33 -0800
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

> Thank you for asking. I was referring to standard RedHat=20
> releases (7.x on up)
> with the default settings. I'd be interested in knowing if=20
> you or anyone
> else has any experience to the contrary.
>=20
> As far as tuning goes, that gets rather extensive, from the=20
> MTU on up to the
> NFS r/w sizes, as well as even the network topology. Since=20
> the options are
> numerous and specific to one's environment, let me ask a=20
> simpler question: Has
> anyone been able to tune a Linux-client and Solaris-server=20
> combination such
> that the speed is comparable to a pure Linux or a pure=20
> Solaris client/server
> combination? This is for heavy r/w access.=20
>=20
> As far the networking topology goes, let us assume a simple isolated
> configuration with just one dumb switch handling the client=20
> and server.
> No NIS, no automounts, etc., etc; just simple NFS mounts.=20
> This is the type
> of environment that I have been looking at the issue with lately.

does "tcp,rsize=3D32768,wsize=3D32768" work?  the Linux defaults are
UDP and r/wsize=3D4096, which work adequately with Linux servers,
but probably are trouble for Solaris.

which Linux kernels, specifically, have you tried on your clients?

what performance do you see, and what do you expect?


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
