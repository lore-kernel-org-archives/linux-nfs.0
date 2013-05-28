Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48327 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755338Ab3E1B7H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 May 2013 21:59:07 -0400
Date: Tue, 28 May 2013 11:58:54 +1000
From: NeilBrown <neilb@suse.de>
To: NFS list <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Is nfs_flush_incompatible to heavy-handed.
Message-ID: <20130528115854.3bbb5175@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_//VjpGnpMfzPmVz4dyZyljh."; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_//VjpGnpMfzPmVz4dyZyljh.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



The nfs client code has a function "nfs_flush_incompatible" which is called
when a process writes to a page to see if the page is already dirty in a way
that means it should be flushed before the write is permitted.

As I understand it, this is needed so that if two different credentials are
used to write to a file, it is important that the server see the different
writes each with their own credentials.  Similarly if two different process=
es
have different locks, then the writes they send should be kept separate.

However if two processes both have the same credentials and neither are
holding any locks on the file, then there can be no need to flush writes fr=
om
one before writes from the other are allowed.

I have a customer who has hit exactly this problem.  It particularly involv=
es
mmapped files.

Two different processes both mmap a file which happens to be stored on NFS.
They both update the same pages (with some independent synchronisation) and
when this happens each update requires that the change made by the other
process be flushed first.

This was did not happen before 2.6.24, but since the addition of
nfs_vm_page_mkwrite, it has a serious impact on performance.

So my question is: is it safe to make nfs_flush_incompatible" a bit less
heavy handed, and in particular allow different processes with the same
credentials to update the same page without flushing.

The patch I have been experimenting with is below.  It probably don't help =
on
NFSv4 because there probably needs to be some care taken with different
'state' values.  But my customer uses NFSv3 so that is what I focussed on.

Any ideas?

Thanks,
NeilBrown



diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c483cc5..df40c57 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -860,11 +860,16 @@ int nfs_flush_incompatible(struct file *file, struct =
page *page)
 		if (req =3D=3D NULL)
 			return 0;
 		l_ctx =3D req->wb_lock_context;
-		do_flush =3D req->wb_page !=3D page || req->wb_context !=3D ctx;
-		if (l_ctx) {
+
+		do_flush =3D req->wb_page !=3D page;
+		if (req->wb_context !=3D ctx)
+			do_flush |=3D
+				(req->wb_context->dentry !=3D ctx->dentry ||
+				 req->wb_context->cred !=3D ctx->cred );
+		if (l_ctx && (req->wb_context->state || ctx->state))
 			do_flush |=3D l_ctx->lockowner.l_owner !=3D current->files
 				|| l_ctx->lockowner.l_pid !=3D current->tgid;
-		}
+
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;

--Sig_//VjpGnpMfzPmVz4dyZyljh.
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUaQPXjnsnt1WYoG5AQJTCBAApfUNaj2H9Iln8dn4YonwEfsoAeA3+a0b
zAJgQPfJitz2zwbp2YbtVNak0we78GCpCQHcGHjj1yxmV3EZh/AQNfaIiTpMeWTz
+HGJjWyU4y/Mvn97gLZSlK5+c5+legEIdGMk78ZZecNIGYJcJ7k2K5DeemiR+W+C
V4c4zrO3vZSnuB0xh0ky0496vFOXxYK1eV0zuBNOrDKvbfJgh05dKJM4fDkDrJGA
mLUENlu+4+vxCVoT8MB/JmF2y9iZLcETi0LpzFPWqS/jpuNMBCDw5OD6A55bpRB/
hXAMEXgwDU1CoLnZJPrFbZvSDOxKWMKShQ+YZ6DA8o0vlemP7fHVOVTdhtpJOB6g
96Zu7+GKpeGQ8PS1cTgprpVwS0GMy5dMGsr+zp1BbgJ87XQWNK7nWngdfUUk41Xh
CA32bgUOseaI+GK0RpMMlFp4IXKyUzeYf57w+jfv35FxJROc2TX2Dv/UGthtmVYP
XJB9X9J6i9JXbGAc3YeJSLRWYa1aSJAS4CXLu79wnMfKh905qnVgoyKssjbafcDK
XaWpKnC0GZIJTM53uwb6bsWh8pWjYtc4Pan52ddIKnsgVuPmkQ6uAWrr328pinwr
0tYKyJGHdRteqGyCTr7GkhWRW86kgH8TxqxTSIpEziacam9IzBijs2Sck6tyYBR1
HdtASQbF6G0=
=iPBu
-----END PGP SIGNATURE-----

--Sig_//VjpGnpMfzPmVz4dyZyljh.--
