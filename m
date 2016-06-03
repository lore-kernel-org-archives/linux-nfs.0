Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32810 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910AbcFCD0T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2016 23:26:19 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Fri, 03 Jun 2016 13:26:10 +1000
Cc: Olaf Kirch <OKir@suse.com>, NFS List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: flush data when locking a file to ensure cache coherence
 for mmap.
Message-ID: <871t4fosvh.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable



When a byte range lock (or flock) is taken out on an NFS file, the
validity of the cached data is checked and the inode is marked
NFS_INODE_INVALID_DATA.  However the cached data isn't flushed from
the page cache.

This is sufficient for future read() requests or mmap() requests as
they call nfs_revalidate_mapping() which performs the flush if
necessary.

However an existing mapping is not affected.  Accessing data through
that mapping will continue to return old data even though the inode is
marked NFS_INODE_INVALID_DATA.

This can easily be confirmed using the 'nfs' tool in
  git://github.com/okirch/twopence-nfs.git
and running

   nfs coherence FILENAME
on one client, and
   nfs coherence -r FILENAME
on another client.

It appears that prior to Linux 2.6.0 this worked correctly.

However commit:

http://git.kernel.org/cgit/linux/kernel/git/history/history.git/commit/?id=
=3Dca9268fe3ddd075714005adecd4afbd7f9ab87d0

removed the call to inode_invalidate_pages() from nfs_zap_caches().  I
haven't tested this code, but inspection suggests that prior to this
commit, file locking would invalidate all inode pages.

This patch adds a call to nfs_revalidate_mapping_protected() after a
successful SETLK so that invalid data is flushed.  With this patch the
above test passes.

Cc: Olaf Kirch <okir@suse.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/file.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 717a8d6af52d..781cc6c9c60b 100644
=2D-- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -822,6 +822,7 @@ do_setlk(struct file *filp, int cmd, struct file_lock *=
fl, int is_local)
 			__nfs_revalidate_inode(NFS_SERVER(inode), inode);
 		else
 			nfs_zap_caches(inode);
+		nfs_revalidate_mapping_protected(inode, filp->f_mapping);
 	}
 out:
 	return status;
=2D-=20
2.8.3


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXUPjSAAoJEDnsnt1WYoG5H6cQAIIG+xWRFn2vJkhhyc0Wn2u5
09glnsCc6WE+8rKcd/JL5WX0bDWNtUY93VvtoKfpg4HipaZUkX5uB6K3A67qlsFD
9TcPegBUdCCNSzD4rtHceBKnnFPHXpCzSIyTL8oDWjVNTqktY+jA1aYmYEJF9vSP
9C9QIw+5zKiuLxiB5iFZm0RiCQvc8qGxAkWwVO54saIezvbkA1rrA8IOqEOY4b8j
iyjSUeoyM3FL+jKpLdT5vu82r0w9bXUSmU+t2tflbzg5Yt1SbWHQDFb9qI+2KJi+
+sKYmsjvnEH06kVO8l20hghqLkKSWDnNlvQICUzZmIgACT88sTBnaYEh2MWGSjoa
XFxURShCy/LcSflTqXW+s1poacBSPI7NhiN8XO6lU1K9vg8s+z9pMduZa4vp8w22
7MSbQKb4akjyG7NpMfNevCFO7AaESvw6nGTGj+4fkzCwJxlJQn0aq1SomvusZXfG
J6Mue7FgRkedT8uHmbdNkbGXEDHRJ0GHJik5Vh116qGffRIbr2pvRR4la+BtXxgN
93QEia3nF8/hSJUlLxKoDLjLkYiGaQypSrjBnLJb/FwsCY/MSIsTLOYEQetp5M//
/dSA7EW3i7O6+dBtCeHS7HatXh7lfvo3aDSqeqtSpykA2hsy7hSElKLPLkd94LmJ
79M/X0UtTeYMjalHr720
=gVRZ
-----END PGP SIGNATURE-----
--=-=-=--
