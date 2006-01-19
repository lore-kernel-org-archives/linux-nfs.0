From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Another hang problem - Jukebox error (was: NFS hangs for15 seconds after exportfs -r)
Date: Thu, 19 Jan 2006 12:30:08 -0500
Message-ID: <20060119173008.GG7175@fieldses.org>
References: <C664ABFF405D6A458806C03AA2E0FF6B0749F0A9@MKEMLVEM01.e2k.ad.ge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzdcD-00013u-UZ
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 09:30:29 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EzdcB-0003lY-Ex
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 09:30:30 -0800
To: "Edwards, Scott (GE Healthcare)" <J.Scott.Edwards@ge.com>
In-Reply-To: <C664ABFF405D6A458806C03AA2E0FF6B0749F0A9@MKEMLVEM01.e2k.ad.ge.com>
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

On Thu, Jan 19, 2006 at 11:23:41AM -0600, Edwards, Scott (GE Healthcare) wrote:
> I am guessing the only thing to do is to make a custom version of 2.6.9
> without that Jukebox stuff.  I assume that there is more to removing it
> than just deleting the "{ nfserr_jukebox, -EWOULDBLOCK }," line from
> nfsproc.c.

This should be all you need.--b.

-EAGAIN has a special treatment in the nfsd code since it's used to indicate
that an upcall has been initiated and that a request should be dropped pending
the upcall result.

But when the break_lease functions return -EWOULDBLOCK (==-EAGAIN on most
architectures), we actually prefer to return nfserr_jukebox.  So translate
-EAGAIN returns to -ETIMEDOUT (which will be translated to nfserr_jukebox).

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
 		err = break_lease(inode, FMODE_WRITE | O_NONBLOCK);
+		if (err == -EWOULDBLOCK)
+			err = -ETIMEDOUT;
 		if (err) /* ENOMEM or EWOULDBLOCK */
 			goto out_nfserr;
 
@@ -668,6 +670,8 @@ nfsd_open(struct svc_rqst *rqstp, struct
 	 * This may block while leases are broken.
 	 */
 	err = break_lease(inode, O_NONBLOCK | ((access & MAY_WRITE) ? FMODE_WRITE : 0));
+	if (err == -EWOULDBLOCK)
+		err = -ETIMEDOUT;
 	if (err) /* NOMEM or WOULDBLOCK */
 		goto out_nfserr;
 
-- 
0.99.8b-g58e3


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
