Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:59174 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753398Ab3KYE74 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Nov 2013 23:59:56 -0500
Date: Mon, 25 Nov 2013 15:59:42 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: The return of the hanging "ls"...
Message-ID: <20131125155942.0a3e4ca1@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/dy9J4RgxK3S7Ljv_kSDwZ/n"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/dy9J4RgxK3S7Ljv_kSDwZ/n
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi Trond,
 I just noticed commit acdc53b2146c7ee67feb1f02f7bc3020126514b8 from 2010
reverts the effect commit 28c494c5c8d425e15b7b82571e4df6d6bc34594d from Chu=
nk
in 2007.

Specifically it removes mutex lock/unlock in nfs_getattr.
Chuck added them:

-       /* Flush out writes to the server in order to update c/mtime */
-       if (S_ISREG(inode->i_mode))
+       /*
+        * Flush out writes to the server in order to update c/mtime.
+        *
+        * Hold the i_mutex to suspend application writes temporarily;
+        * this prevents long-running writing applications from blocking
+        * nfs_wb_nocommit.
+        */
+       if (S_ISREG(inode->i_mode)) {
+               mutex_lock(&inode->i_mutex);
                nfs_wb_nocommit(inode);
+               mutex_unlock(&inode->i_mutex);
+       }


You removed them.

-       /*
-        * Flush out writes to the server in order to update c/mtime.
-        *
-        * Hold the i_mutex to suspend application writes temporarily;
-        * this prevents long-running writing applications from blocking
-        * nfs_wb_nocommit.
-        */
+       /* Flush out writes to the server in order to update c/mtime.  */
        if (S_ISREG(inode->i_mode)) {
-               mutex_lock(&inode->i_mutex);
-               nfs_wb_nocommit(inode);
-               mutex_unlock(&inode->i_mutex);
+               err =3D filemap_write_and_wait(inode->i_mapping);
+               if (err)
+                       goto out;
        }
=20
        /*


Do you recall why?

I noticed because a customer reported exactly the same symptoms the were
fixed by Chucks patch some years ago.


The comment on your patch says (in part):

    Also replace nfs_wb_nocommit() with a
    call to filemap_write_and_wait(), which doesn't need to hold the
    inode->i_mutex.

It is certainly true that filemap_write_and_wait doesn't need to hold the
mutex, but neither did nfs_wb_nocommit.  The mutex is held to stop "suspend
application writes temporarily" so no more pages get dirtied until all
the current dirty pages have been written out.  i.e. to stop
generic_file_aio_write() from proceeding.

The particular test that shows the problem is a large write like
  dd if=3D/dev/zero of=3D/mnt/nfs/somefile count=3D2000000
then in another window
  ls -l /mnt/nfs

the "ls -l" will hang until the "dd" completes.

Can we put the mutex lock/unlock back please?

Thanks,
NeilBrown

--Sig_/dy9J4RgxK3S7Ljv_kSDwZ/n
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUpLZPjnsnt1WYoG5AQLRnhAAjtXtKouLAvIbwL1bQSfoyIbiJqqa6YpQ
MvKgFVvIjjwdHFdq+Br5/y5wL8q16dh3fQY85wKSrgPhQH2qZDzhSH9Nz7nJVv/j
vFzZbLmj39i609UxoyUtCPgZ13c5jlIlTIzwslhjepbq73MpblDsEQ5aumsD8mYc
Ib2UuVVHX8WTswdYDbBkpquTx1RQDe/f5/D73nT7HHWQQxcMkCEJrRAO36fdx3IH
mK1fXo8PyKGcZWVvmrcS8uiQtNENkG03OEMlf8UM0KyZmN5IZdhilV9YXJKZy7CR
oQbbebC8sUf/oo0t/3NokSvcNKwZVMruGN1hPSNxagwPgCdq/5b18XXFVVSwv7Qq
gwUMbhINgYLK4SLAtr1LiG0I3iaVoIC+xGWDqi9I2drXOopSm1Ph1P5GdpY0lpy2
feMFpZdcHEWuRt8ex/W3NDQ7lQQWDsm7W0DrJehPpd+k9by66lVDQAJy64B2ti/C
iyWhLc/gVyf7DCrda7s/ZVXUWksIjZYhLCe3tgTfQKychanzmxLIz529+d8/C+98
Vw/xDEt2+jyfCOWGvFWUVV0IPf/g1d1RjVARbDUTCqBLhq0ffju6lCVlnEbPXGYf
ctycilNs1p/SDDL8BBt3Cm516Jx3KuRQ09DytAEvd+bnmu9fk7LJhHDMAKFIdGI9
Lf96GD2Tkm8=
=fnDG
-----END PGP SIGNATURE-----

--Sig_/dy9J4RgxK3S7Ljv_kSDwZ/n--
