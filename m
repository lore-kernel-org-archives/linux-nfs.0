From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: OSX server to Linux client: readdir() returns empty
	directory
Date: Mon, 20 Jun 2005 12:37:26 -0700
Message-ID: <1119296246.22853.62.camel@seki.nac.uci.edu>
References: <8E7453D7-FAED-473B-A5F0-08B16994836A@mudbuginfo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-itAara/OQ8uLu6xJoft3"
Cc: nfs@lists.sourceforge.net, strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DkS5T-0000yi-0H
	for nfs@lists.sourceforge.net; Mon, 20 Jun 2005 12:37:39 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DkS5O-00083E-6h
	for nfs@lists.sourceforge.net; Mon, 20 Jun 2005 12:37:38 -0700
To: Gabe Martin-Dempesy <gabe@mudbuginfo.com>
In-Reply-To: <8E7453D7-FAED-473B-A5F0-08B16994836A@mudbuginfo.com>
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


--=-itAara/OQ8uLu6xJoft3
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


=46rom what I've heard OS X's NFS implementation is a bit lacking - both
in terms of performance and reliability.

You might want to try using CIFS instead, I suppose.  Or sshfs or
something less borgish.

On Mon, 2005-06-20 at 14:34 -0500, Gabe Martin-Dempesy wrote:
> Situation:
>=20
> Apple Xserve (10.3.9) was exporting its primary file share (/Volumes/=20
> Sack) via read-only NFS to a Debian-woody (with 2.4.30 w/ grsecurity =20
> patch, to /files) with Apache 2 serving up this share as a =20
> DocumentRoot.  This was done to allow us to have any PHP/etc we were =20
> developing run in the same environment as our production server, =20
> while allowing all the file sharing to occur on the Xserve.  This =20
> setup worked without any hitches.
>=20
> We upgraded the Xserve to tiger after waiting for the 10.4.1 patch to =20
> come out (to hopefully have any critical issues ironed out) and NFS =20
> started acting strange.  Please note that none of these issues =20
> involving hanging, or a looping getdents (which is the closest linux/=20
> osx NFS issue involving readdir() which I've run into)
>=20
>=20
> Issues:
> * First thing we noticed was that Apache2's file listings, created by =20
> mod_autoindex -- the default module that creates directory listings, =20
> started pulling up all directories as if they were empty.  Typing in =20
> absolute paths to files still worked
> * Bash's tab-completion stopped working on the /files mount on the =20
> Debian machine.
> * Suspecting an issue with readdir(), I wrote this sample PHP applet =20
> to verify my hunch with readdir().  Code follows:
> <?php
> $dir =3D '/files';
>=20
> if ($handle =3D opendir($dir)) {
>     echo "dir opened fine\n";
>     while (false !=3D=3D ($file =3D readdir($handle))) {
>        echo "$file\n";
>     }
>     closedir($handle);
> } else {
>     echo "could not open dir\n";
> }
> ?>
> Output:
> dir opened fine
> .
> ..
> * A sample C program doing the same thing also didn't work.  Code:
> /*
> * readdir.c: example usage for opendir()/readdir()/closedir()
> *
> * Matt Dailey, Feb 2004
> *
> * Compile with "gcc readdir.c" to get executable a.out.
> *
> * This example program prints out the files in the current
> * directory
> *
> * Be sure to refer to "man 3 readdir" etc.
> *
> */
>=20
> #include <stdio.h>
> #include <sys/types.h>
> #include <dirent.h>
> #include <errno.h>
> #include <string.h>
> #include <stdlib.h>
>=20
> int main( int argc, char *argv[] ) {
>      DIR *pDIR;
>      struct dirent *pDirEnt;
>=20
>      /* Open the current directory */
>=20
>      pDIR =3D opendir("/files");
>=20
>      if ( pDIR =3D=3D NULL ) {
>          fprintf( stderr, "%s %d: opendir() failed (%s)\n",
>                   __FILE__, __LINE__, strerror( errno ));
>          exit( -1 );
>      }
>=20
>      /* Get each directory entry from pDIR and print its name */
>=20
>      pDirEnt =3D readdir( pDIR );
>      while ( pDirEnt !=3D NULL ) {
>          printf( "%s\n", pDirEnt->d_name );
>          pDirEnt =3D readdir( pDIR );
>      }
>=20
>      /* Release the open directory */
>=20
>      closedir( pDIR );
>=20
>      return 0;
> }
> Output:
> .
> ..
>=20
> Things that still worked:
> * (GNU's) `ls` worked fine.  I downloaded the GNU fileutils 4.1 =20
> source to examine the source to `ls`, and its only readdir() call =20
> looks very similar to the above C snippet.  From ls.c:1778
> --snip--
>    while ((next =3D readdir (reading)) !=3D NULL)
>      if (file_interesting (next))
>        {
>          enum filetype type =3D unknown;
>=20
> #if HAVE_STRUCT_DIRENT_D_TYPE
>          if (next->d_type =3D=3D DT_DIR || next->d_type =3D=3D DT_CHR
>              || next->d_type =3D=3D DT_BLK || next->d_type =3D=3D DT_SOCK
>              || next->d_type =3D=3D DT_FIFO)
>            type =3D next->d_type;
> #endif
>          total_blocks +=3D gobble_file (next->d_name, type, 0, name);
>        }
>=20
>    if (CLOSEDIR (reading))
>      {
>        error (0, errno, "%s", quotearg_colon (name));
>        exit_status =3D 1;
>        /* Don't return; print whatever we got. */
>      }
> --snip--
> * A Perl program basically equilvilent to the above PHP program =20
> worked fine.
> #!/usr/bin/perl
>=20
> use strict;
>=20
> my $path =3D '/files/';
> opendir(DIR, $path) || die "can not opendir $path";
> my @files =3D readdir(DIR);
> closedir DIR;
>=20
> my $file;
> foreach $file (sort @files) {
>          print $file, "\n";
> }
> Output:
> .
> ..
> .DS_Store
> .FBCIndexCopy
> .FBCLockFolder
> .TemporaryItems
> .Trashes
> .VolumeIcon.icns
> Abernathie
> About Joints
> BBK
> (etc..)
> * After restarting `portmap` and remounting the file share (to =20
> hopefully eliminate any cacheing), watching a `tcpdump` while any of =20
> the above non-working programs execute clearly displays all the =20
> directories being transmitted in the raw traffic.  Note that I was =20
> just running with `tcpdump -x -s 0 src host xserve`, so if there is a =20
> better way to execute that as to get more meaningful NFS debugging =20
> with that, I'd like to give it a shot.
> * EVERYTHING works fine using a separate OSX machine as a client.
>=20
>=20
> Other systems reproduced on:
> Suspecting that this was an issue with Debian-woody being outdated as =20
> all hell, I installed a new server with a fresh copy of Gentoo =20
> 2005.0, with a 2.6 kernel and all recent versions of userland =20
> programs (like portmap).  This resulted in identical behavior to all =20
> of the successes and failures listed above, except for bash =20
> completion, which worked on the gentoo machine.
>=20
>=20
> I'm really not sure where this is to blame, so I'm probably going to =20
> end up  cross posting this to a lot of places.  Maybe OSX Server is =20
> actually complying to the protocol, and the latest upgrade triggered =20
> something broken in the kernel.  Maybe this is some weird compile-=20
> time option dealing with glibc. for these apps that is controlling =20
> the 'do I break or not' behavior; I suspect glibc could be involved =20
> due to the getdents behavior listed in the following straces:
>=20
>=20
> Appendix:
> `straces` and `ldd`s for all the programs above which succeeded and =20
> failed
>=20
> * "strace php -f readdir-test.php" -- This program did not work; note =20
> the llseek
> open("/files", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) =3D 3
> fstat64(3, {st_mode=3DS_IFDIR|0775, st_size=3D2278, ...}) =3D 0
> fcntl64(3, F_SETFD, FD_CLOEXEC)         =3D 0
> fstat64(1, {st_mode=3DS_IFCHR|0620, st_rdev=3Dmakedev(136, 0), ...}) =3D =
0
> mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, =20
> -1, 0) =3D 0x52b26000
> write(1, "dir opened fine\n", 16dir opened fine
> )       =3D 16
> getdents64(3, /* 64 entries */, 32768)  =3D 2168
> _llseek(3, 2, [2], SEEK_SET)            =3D 0
> write(1, ".\n", 2.
> )                      =3D 2
> write(1, "..\n", 3..
> )                     =3D 3
> getdents64(3, /* 62 entries */, 32768)  =3D 2120
> close(3)                                =3D 0
> -- and the ldd --
>          libsablot.so.0 =3D> /usr/lib/libsablot.so.0 (0x24380000)
>          libstdc++.so.5 =3D> /usr/lib/gcc-lib/i386-pc-linux-gnu/=20
> 3.3.5-20050130/libstdc++.so.5 (0x24477000)
>          libexpat.so.0 =3D> /usr/lib/libexpat.so.0 (0x2458e000)
>          libhistory.so.5 =3D> /lib/libhistory.so.5 (0x245b7000)
>          libreadline.so.5 =3D> /lib/libreadline.so.5 (0x245c1000)
>          libncurses.so.5 =3D> /lib/libncurses.so.5 (0x245f7000)
>          libpanel.so.5 =3D> /usr/lib/libpanel.so.5 (0x24640000)
>          libmysqlclient.so.14 =3D> /usr/lib/libmysqlclient.so.14 =20
> (0x24645000)
>          libmhash.so.2 =3D> /usr/lib/libmhash.so.2 (0x24770000)
>          libmcrypt.so.4 =3D> /usr/lib/libmcrypt.so.4 (0x247a9000)
>          libltdl.so.3 =3D> /usr/lib/libltdl.so.3 (0x247e5000)
>          libexslt.so.0 =3D> /usr/lib/libexslt.so.0 (0x247ee000)
>          libgcrypt.so.11 =3D> /usr/lib/libgcrypt.so.11 (0x24803000)
>          libgpg-error.so.0 =3D> /usr/lib/libgpg-error.so.0 (0x2485c000)
>          libz.so.1 =3D> /lib/libz.so.1 (0x24861000)
>          libm.so.6 =3D> /lib/libm.so.6 (0x24875000)
>          libxslt.so.1 =3D> /usr/lib/libxslt.so.1 (0x24897000)
>          libdb-4.2.so =3D> /usr/lib/libdb-4.2.so (0x248d1000)
>          libdb.so.2 =3D> /usr/lib/libdb.so.2 (0x249ca000)
>          libbz2.so.1.0 =3D> /usr/lib/libbz2.so.1.0 (0x249dc000)
>          libresolv.so.2 =3D> /lib/libresolv.so.2 (0x249ed000)
>          libxmlparse.so.0 =3D> /usr/lib/libxmlparse.so.0 (0x24a01000)
>          libxmltok.so.0 =3D> /usr/lib/libxmltok.so.0 (0x24a0d000)
>          libcrypt.so.1 =3D> /lib/libcrypt.so.1 (0x24a25000)
>          libnsl.so.1 =3D> /lib/libnsl.so.1 (0x24a53000)
>          libssl.so.0.9.7 =3D> /usr/lib/libssl.so.0.9.7 (0x24a69000)
>          libcrypto.so.0.9.7 =3D> /usr/lib/libcrypto.so.0.9.7 (0x24aa0000)
>          libxml2.so.2 =3D> /usr/lib/libxml2.so.2 (0x24bd4000)
>          libdl.so.2 =3D> /lib/libdl.so.2 (0x24d12000)
>          libpthread.so.0 =3D> /lib/libpthread.so.0 (0x24d16000)
>          libc.so.6 =3D> /lib/libc.so.6 (0x24d68000)
>          libgcc_s.so.1 =3D> /usr/lib/gcc-lib/i386-pc-linux-gnu/=20
> 3.3.5-20050130/libgcc_s.so.1 (0x24e7b000)
>          /lib/ld-linux.so.2 (0x2436a000)
>=20
> * "strace ./rd" (c implementation) -- This program did not work; note =20
> the llseek
> open("/files", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) =3D 3
> fstat64(3, {st_mode=3DS_IFDIR|0775, st_size=3D2278, ...}) =3D 0
> fcntl64(3, F_SETFD, FD_CLOEXEC)         =3D 0
> brk(0)                                  =3D 0x12672ee0
> brk(0x12693ee0)                         =3D 0x12693ee0
> brk(0x12694000)                         =3D 0x12694000
> getdents64(3, /* 64 entries */, 32768)  =3D 2168
> _llseek(3, 2, [2], SEEK_SET)            =3D 0
> fstat64(1, {st_mode=3DS_IFCHR|0620, st_rdev=3Dmakedev(136, 0), ...}) =3D =
0
> mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, =20
> -1, 0) =3D 0x5713e000
> write(1, ".\n", 2.
> )                      =3D 2
> write(1, "..\n", 3..
> )                     =3D 3
> getdents64(3, /* 62 entries */, 32768)  =3D 2120
> brk(0x12693000)                         =3D 0x12693000
> close(3)                                =3D 0
> -- and the ldd --
>          libc.so.6 =3D> /lib/libc.so.6 (0x21b88000)
>          /lib/ld-linux.so.2 (0x21b72000)
>=20
> *  "strace perl readdir-test.pl" -- This program worked; note the two =20
> successive getdents
> open("/files/", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) =3D 3
> fstat64(3, {st_mode=3DS_IFDIR|0775, st_size=3D2278, ...}) =3D 0
> fcntl64(3, F_SETFD, FD_CLOEXEC)         =3D 0
> getdents64(3, /* 64 entries */, 32768)  =3D 2168
> getdents64(3, /* 0 entries */, 32768)   =3D 0
> close(3)
> -- and the ldd --
>          libpthread.so.0 =3D> /lib/libpthread.so.0 (0x25d85000)
>          libnsl.so.1 =3D> /lib/libnsl.so.1 (0x25dd7000)
>          libdl.so.2 =3D> /lib/libdl.so.2 (0x25ded000)
>          libm.so.6 =3D> /lib/libm.so.6 (0x25df1000)
>          libcrypt.so.1 =3D> /lib/libcrypt.so.1 (0x25e13000)
>          libutil.so.1 =3D> /lib/libutil.so.1 (0x25e41000)
>          libc.so.6 =3D> /lib/libc.so.6 (0x25e45000)
>          /lib/ld-linux.so.2 (0x25d6f000)
>=20
> * "strace ls /files" -- This program worked; note the two successive =20
> getdents
> open("/files", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) =3D 3
> fstat64(3, {st_mode=3DS_IFDIR|0775, st_size=3D2278, ...}) =3D 0
> fcntl64(3, F_SETFD, FD_CLOEXEC)         =3D 0
> getdents64(3, /* 64 entries */, 32768)  =3D 2168
> getdents64(3, /* 0 entries */, 32768)   =3D 0
> close(3)                                =3D 0
> -- and the ldd --
>          librt.so.1 =3D> /lib/librt.so.1 (0x225ca000)
>          libncurses.so.5 =3D> /lib/libncurses.so.5 (0x225dd000)
>          libc.so.6 =3D> /lib/libc.so.6 (0x22626000)
>          libpthread.so.0 =3D> /lib/libpthread.so.0 (0x22739000)
>          /lib/ld-linux.so.2 (0x225b4000)
>=20
>=20
> I've switched the server over to SMBFS until I can figure out what's =20
> causing the problem, but I feel like this is probably a small gotcha =20
> that is seldom encountered.
>=20
> -- Gabe
>=20
>=20
> -------------------------------------------------------
> SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
> from IBM. Find simple to follow Roadmaps, straightforward articles,
> informative Webcasts and more! Get everything you need to get up to
> speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-itAara/OQ8uLu6xJoft3
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBCtxr2o0feVm00f/8RAnfzAKClrG69b2iJoHBogQ/S+6Po9X6o3gCdHT37
fo8ukSiRQ0L8X2WP0H730S8=
=w6sR
-----END PGP SIGNATURE-----

--=-itAara/OQ8uLu6xJoft3--



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
