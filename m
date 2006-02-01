From: "Edwards, Scott (GE Healthcare)" <J.Scott.Edwards@ge.com>
Subject: RE: Another hang problem - Jukebox error (was: NFS hangs for15 seconds after exportfs -r)
Date: Wed, 1 Feb 2006 11:17:08 -0600
Message-ID: <C664ABFF405D6A458806C03AA2E0FF6B06CBC76A@MKEMLVEM01.e2k.ad.ge.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4Lbx-0006ln-5E
	for nfs@lists.sourceforge.net; Wed, 01 Feb 2006 09:17:41 -0800
Received: from ext-nj2ut-7.online-age.net ([64.14.54.237])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F4Lbv-0007nm-3l
	for nfs@lists.sourceforge.net; Wed, 01 Feb 2006 09:17:41 -0800
Received: from int-nj2ut-4.online-age.net (int-nj2ut-4.online-age.net [3.159.237.73])
	by ext-nj2ut-7.online-age.net (8.13.5/8.13.5/20051114-SVVS-TLS-DNSBL) with ESMTP id k11HHAEO005026
	for <nfs@lists.sourceforge.net>; Wed, 1 Feb 2006 12:17:10 -0500
Received: from cinmlef02.e2k.ad.ge.com (localhost.localdomain [127.0.0.1])
	by int-nj2ut-4.online-age.net (8.11.6/8.11.6/20050510-SVVS) with ESMTP id k11HHAS15404
	for <nfs@lists.sourceforge.net>; Wed, 1 Feb 2006 12:17:10 -0500
To: "J. Bruce Fields" <bfields@fieldses.org>
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


I built a custom 2.6.9 kernel without the Jukebox error thing and it
works fine (no hang for 15 seconds).  I have included my patch below.

Thanks to everyone who helped
  -Scott

linux-2.6.9-NFSD-remove-wouldblock-jukebox.patch:

# Remove line that added mapping of EWOULDBLOCK errno to nfserr_jukebox
# which causes a delay the first time an NFS access is attempted.  This
# was added in kernel 2.6.9 and removed again in 2.6.11.
#
# J. Scott Edwards - GE Healthcare
# j.scott.edwards at ge.com
#
*** linux-2.6.9/fs/nfsd/nfsproc.c.orig  2004-10-18 15:53:46.000000000 =
-0600
--- linux-2.6.9/fs/nfsd/nfsproc.c       2006-01-22 16:28:37.454554448 =
-0700
***************
*** 586,592 ****
                { nfserr_dquot, -EDQUOT },
  #endif
                { nfserr_stale, -ESTALE },
-               { nfserr_jukebox, -EWOULDBLOCK },
                { nfserr_jukebox, -ETIMEDOUT },
                { nfserr_dropit, -EAGAIN },
                { nfserr_dropit, -ENOMEM },
--- 586,591 ----


-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org]
Sent: Thursday, January 19, 2006 10:30 AM
To: Edwards, Scott (GE Healthcare)
Cc: Trond Myklebust; nfs@lists.sourceforge.net
Subject: Re: [NFS] Another hang problem - Jukebox error (was: NFS hangs
for15 seconds after exportfs -r)


On Thu, Jan 19, 2006 at 11:23:41AM -0600, Edwards, Scott (GE Healthcare) =
wrote:
> I am guessing the only thing to do is to make a custom version of =
2.6.9
> without that Jukebox stuff.  I assume that there is more to removing =
it
> than just deleting the "{ nfserr_jukebox, -EWOULDBLOCK }," line from
> nfsproc.c.

This should be all you need.--b.

-EAGAIN has a special treatment in the nfsd code since it's used to =
indicate
that an upcall has been initiated and that a request should be dropped =
pending
the upcall result.

But when the break_lease functions return -EWOULDBLOCK (=3D=3D-EAGAIN on =
most
architectures), we actually prefer to return nfserr_jukebox.  So =
translate
-EAGAIN returns to -ETIMEDOUT (which will be translated to =
nfserr_jukebox).

Undo the mapping of -EWOULDBLOCK to nfserr_jukebox, since on most
architectures that has the undesireable effect of mapping -EAGAIN to
nfserr_jukebox.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Linus Torvalds <torvalds@osdl.org>

BKrev: 41db7eb0kXzFxz-8HrN9wQmwijbHJQ

---

 fs/nfsd/nfsproc.c |    1 -
 fs/nfsd/vfs.c     |    4 ++++
 2 files changed, 4 insertions(+), 1 deletions(-)

ca5453fe96bff15a1673900fdb5494b076aee22b
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 52044f2..70b32ea 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -586,7 +586,6 @@ nfserrno (int errno)
 		{ nfserr_dquot, -EDQUOT },
 #endif
 		{ nfserr_stale, -ESTALE },
-		{ nfserr_jukebox, -EWOULDBLOCK },
 		{ nfserr_jukebox, -ETIMEDOUT },
 		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 0949fbd..308feda 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -304,6 +304,8 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 		 * we need to break all leases.
 		 */
 		err =3D break_lease(inode, FMODE_WRITE | O_NONBLOCK);
+		if (err =3D=3D -EWOULDBLOCK)
+			err =3D -ETIMEDOUT;
 		if (err) /* ENOMEM or EWOULDBLOCK */
 			goto out_nfserr;
=20
@@ -668,6 +670,8 @@ nfsd_open(struct svc_rqst *rqstp, struct
 	 * This may block while leases are broken.
 	 */
 	err =3D break_lease(inode, O_NONBLOCK | ((access & MAY_WRITE) ? =
FMODE_WRITE : 0));
+	if (err =3D=3D -EWOULDBLOCK)
+		err =3D -ETIMEDOUT;
 	if (err) /* NOMEM or WOULDBLOCK */
 		goto out_nfserr;
=20
--=20
0.99.8b-g58e3


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
