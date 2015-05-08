Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60070 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995AbbEHDKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 23:10:49 -0400
Date: Fri, 8 May 2015 13:10:40 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: report more appropriate block size for directories.
Message-ID: <20150508131040.140bf570@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_//Pcnv_YYXP8E3noH37hDxpA"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_//Pcnv_YYXP8E3noH37hDxpA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


In glibc 2.21 (and several previous), a call to opendir() will
result in a 32K (BUFSIZ*4) buffer being allocated and passed to
getdents.

However a call to fdopendir() results in an 'fstat' request to
determine block size and a matching buffer allocated for subsequent
use with getdents.  This will typically be 1M.

The first getdents call on an NFS directory will always use
READDIR_PLUS (or NFSv4 equivalent) if available.  Subsequent getdents
calls only use this more expensive version if some 'stat' requests are
made between the getdents calls.

For this reason it is good to keep at least that first getdents call
relatively short.  When fdopendir() and readdir() is used on a large
directory, it takes approximately 32 times as long to complete as
using "opendir".  Current versions of 'find' use fdopendir() and
demonstrate this slowness.

'stat' on a directory currently returns the 'wsize'.  This number has
no meaning on directories.
Actual READDIR requests are limited to ->dtsize, which itself is
capped at 4 pages, coincidently the same as BUFSIZ*4.
So this is a meaningful number to use as the blocksize on directories,
and has the effect of making 'find' on large directories go a lot
faster.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 96f2d55781fb..f8aebf59383f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -678,6 +678,8 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *de=
ntry, struct kstat *stat)
 	if (!err) {
 		generic_fillattr(inode, stat);
 		stat->ino =3D nfs_compat_user_ino64(NFS_FILEID(inode));
+		if (S_ISDIR(inode->i_mode))
+			stat->blksize =3D NFS_SERVER(inode)->dtsize;
 	}
 out:
 	trace_nfs_getattr_exit(inode, err);

--Sig_//Pcnv_YYXP8E3noH37hDxpA
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVUwpMDnsnt1WYoG5AQKflg/7BCIIbLrKpZD4ddhPkklyGtA88DnaZ+Sh
rgU7n/Drca2L9DrvpanKRadPxxoCSS9nFeA0NWFBZNdypztrEEgt98g0WiW07mqI
xHSTjAzcqupxcVNWgO3x6umCd2ZALwS59Da6KXmV9a400HbIaEMyOle3D+xrvoRE
QX/oUN9dSFGzq7LC1Xq9I2irZX5tb+BroW98+WBKib4eqFWdmLc/sxkGCjX7f6xQ
90MqVMQ2YQQdE/OxBJSbfTcUr4Gt4/9ivNw+Bpe2XBnuNnGoYL+Zv62J6BHzHl7T
rheapMtBhSigG2vv5GVSdDkgYMAeTcaU6KjxiSCA5Dmg5/wYj4S8uyIGi3Mr0HLZ
XUzGRNCh4DmhYPntstnUehPq7oWrzrxx0oZc/lLIJNrHq8oH++QPs3P9N5OW0828
Fpxm1fmVFy7F+Vsnvlig6fLt58m/OsckyBXd04fJs/a1Im/FD+HyomNzh03nQ0Sw
1vFF3lsbvSqtfAKaiWmuNTperL3+m2lXBgEdK2EYcZZVUD1JufAB0eqLyBOhYyTk
c0RqCF4w7Gs1sNDZ9MR0fjYd/H3Fk+2rMMtwdPT6WJW6CZL7CTWVBaoPp8PwJySh
9lWBTYwmLXIjR7bqGhy7J6jNUmwLZZlVvXfIpGbNTTZxbvimTJqGJr5AU8D4dzJU
DZjdWDjdDPs=
=2Tob
-----END PGP SIGNATURE-----

--Sig_//Pcnv_YYXP8E3noH37hDxpA--
