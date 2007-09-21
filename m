From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd not responding
Date: Fri, 21 Sep 2007 16:52:12 -0400
Message-ID: <1190407932.6721.42.camel@heimdal.trondhjem.org>
References: <fc84aa$o11$1@sea.gmane.org>
	<20070912202721.d8f70ac1.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Q2jNs3GLxLVwy4WJfCEt"
Cc: kenneth johansson <ken@kenjo.org>, nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYpU8-0005MX-QR
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 13:52:24 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IYpUD-0005Fh-0t
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 13:52:29 -0700
In-Reply-To: <20070912202721.d8f70ac1.jlayton@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--=-Q2jNs3GLxLVwy4WJfCEt
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2007-09-12 at 20:27 -0400, Jeff Layton wrote:
> On Wed, 12 Sep 2007 07:26:02 +0000 (UTC)
> kenneth johansson <ken@kenjo.org> wrote:
> 
> > Got a warning from the lock validating check again and
> > later a unresponsive lockd with a backtrace this time
> > actually at the same place the lock warning was on.
> 
> FWIW, I think I ran into the exact same problem recently. I opened a
> BZ case for it so I wouldn't forget about it, but haven't had time to
> track it down:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=280311
> 
> I'm not certain that lockd was stuck at the time, since I had some
> other things going on with the box, but it may have been...

Does the attached patch help?

Cheers
  Trond

--=-Q2jNs3GLxLVwy4WJfCEt
Content-Disposition: inline;
	filename=linux-2.6.23-001-fix_lockd_circular_dependency.dif
Content-Type: message/rfc822;
	name=linux-2.6.23-001-fix_lockd_circular_dependency.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Wed, 19 Sep 2007 11:54:54 -0400
NLM: Fix a circular lock dependency in lockd
Subject: No Subject
Message-Id: <1190407932.6721.43.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

The problem is that the garbage collector for the 'host' structures
nlm_gc_hosts(), holds nlm_host_mutex while calling down to
nlmsvc_mark_resources, which, eventually takes the file->f_mutex.

We cannot therefore call nlmsvc_lookup_host() from within
nlmsvc_create_block, since the caller will already hold file->f_mutex, so
the attempt to grab nlm_host_mutex may deadlock.

Fix the problem by calling nlmsvc_lookup_host() outside the file->f_mutex.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/svclock.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index a21e4bc..d098c7a 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -171,19 +171,14 @@ found:
  * GRANTED_RES message by cookie, without having to rely on the client's IP
  * address. --okir
  */
-static inline struct nlm_block *
-nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_file *file,
-		struct nlm_lock *lock, struct nlm_cookie *cookie)
+static struct nlm_block *
+nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
+		    struct nlm_file *file, struct nlm_lock *lock,
+		    struct nlm_cookie *cookie)
 {
 	struct nlm_block	*block;
-	struct nlm_host		*host;
 	struct nlm_rqst		*call = NULL;
 
-	/* Create host handle for callback */
-	host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
-	if (host == NULL)
-		return NULL;
-
 	call = nlm_alloc_call(host);
 	if (call == NULL)
 		return NULL;
@@ -366,6 +361,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 			struct nlm_lock *lock, int wait, struct nlm_cookie *cookie)
 {
 	struct nlm_block	*block = NULL;
+	struct nlm_host		*host;
 	int			error;
 	__be32			ret;
 
@@ -377,6 +373,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 				(long long)lock->fl.fl_end,
 				wait);
 
+	/* Create host handle for callback */
+	host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
+	if (host == NULL)
+		return nlm_lck_denied_nolocks;
 
 	/* Lock file against concurrent access */
 	mutex_lock(&file->f_mutex);
@@ -385,7 +385,8 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 	 */
 	block = nlmsvc_lookup_block(file, lock);
 	if (block == NULL) {
-		block = nlmsvc_create_block(rqstp, file, lock, cookie);
+		block = nlmsvc_create_block(rqstp, nlm_get_host(host), file,
+				lock, cookie);
 		ret = nlm_lck_denied_nolocks;
 		if (block == NULL)
 			goto out;
@@ -449,6 +450,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 out:
 	mutex_unlock(&file->f_mutex);
 	nlmsvc_release_block(block);
+	nlm_release_host(host);
 	dprintk("lockd: nlmsvc_lock returned %u\n", ret);
 	return ret;
 }
@@ -477,10 +479,15 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 
 	if (block == NULL) {
 		struct file_lock *conf = kzalloc(sizeof(*conf), GFP_KERNEL);
+		struct nlm_host	*host;
 
 		if (conf == NULL)
 			return nlm_granted;
-		block = nlmsvc_create_block(rqstp, file, lock, cookie);
+		/* Create host handle for callback */
+		host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
+		if (host == NULL)
+			return nlm_lck_denied_nolocks;
+		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
 		if (block == NULL) {
 			kfree(conf);
 			return nlm_granted;

--=-Q2jNs3GLxLVwy4WJfCEt
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--=-Q2jNs3GLxLVwy4WJfCEt
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-Q2jNs3GLxLVwy4WJfCEt--
