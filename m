From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Debian Bug#235886: nfs-kernel-server inducing load of 8-9 with no good reason for Linux 2.6 clients
Date: Fri, 19 Mar 2004 12:53:30 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200403191253.37489.bernd-schubert@web.de>
References: <20040318210943.GK3605@perlsupport.com> <20040319084935.GB25649@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4IZO-0004gy-27
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 03:53:46 -0800
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4IZK-0000M2-3S
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 03:53:42 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040319084935.GB25649@suse.de>
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

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Friday 19 March 2004 09:49, Olaf Kirch wrote:
> One more thing:
> > Something is clearly wrong here; stopping nfs-kernel-server makes the
> > load drop to zero almost immediately, and substituting nfs-user-server
> > for nfs-kernel-server also fixes the problem.
>
> This probably means the problem is in the NFSv3 client code. The major
> difference between knfsd and unfsd is that the latter is v2 only.
>

Now there's also unfs3 (http://unfs3.sourceforge.net/), which supports as t=
he=20
name suggests v3.

Cheers,
	Bernd
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAWt8/C8BUnAF+ydYRAhCVAJ48HQ8l8o/ZKZBhaXFBQxv4VvMoNQCeIsv0
+cn/FO2oRl/XFf9v6Ktf+kE=3D
=3DjWh4
=2D----END PGP SIGNATURE-----


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
