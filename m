From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Fri, 7 May 2004 15:34:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040507223414.GQ30964@polop.usc.edu>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org> <20040506230055.GC26968@polop.usc.edu> <20040507182543.GA27341@fieldses.org> <20040507213811.GL30964@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Y9o+fgG4MNl0mnzl"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMDwV-00076R-Df
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 15:35:43 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BMDwV-0008Dw-90
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 15:35:43 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i47MYFlv031483
	for <nfs@lists.sourceforge.net>; Fri, 7 May 2004 15:34:15 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i47MYFXC031481
	for nfs@lists.sourceforge.net; Fri, 7 May 2004 15:34:15 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040507213811.GL30964@polop.usc.edu>
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


--Y9o+fgG4MNl0mnzl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 07, 2004 at 02:38:12PM -0700, Garrick Staples alleged:
> But now I've just noticed something else that is odd.  Something that I'm
> surprised I haven't come across before...  I have to unexport filesystems
> twice before I can unmount them.

I'm looking at exportfs.c to see if I can add in a call to flush the caching
when unmounting, does the following seem reasonable?

Force a cache flush if unexporting, and don't reread rmtab if we're using t=
he
new cache.

--- exportfs.c_orig     2004-05-07 15:32:22.423905760 -0700
+++ exportfs.c  2004-05-07 15:33:33.669998637 -0700
@@ -127,10 +127,13 @@
                 */
                if (!f_reexport)
                        xtab_export_read();
-               if (!f_export)
+               if (!f_export) {
+                       force_flush=3D1;
                        for (i =3D optind ; i < argc ; i++)
                                unexportfs(argv[i], f_verbose);
-               rmtab_read();
+               }
+               if (!new_cache)
+                       rmtab_read();
        }
        if (!new_cache) {
                xtab_mount_read();


--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--Y9o+fgG4MNl0mnzl
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAnA7m0SBUxJbm9HMRAlgIAKCNVODidMWweTUTnQtIgXczjU7o3ACePONw
wssWGiqA17tH3RRSDlaljiM=
=EK3B
-----END PGP SIGNATURE-----

--Y9o+fgG4MNl0mnzl--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
