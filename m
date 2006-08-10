From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] fix recursive nlm_file_mutex deadlock
Date: Thu, 10 Aug 2006 12:05:01 -0400
Message-ID: <1155225902.10547.53.camel@localhost>
References: <44DA25D3.3010003@redhat.com>
	<1155159937.15624.22.camel@localhost>  <44DA5CBF.3040309@redhat.com>
	<1155167828.15624.70.camel@localhost>
	<1155223450.3666.48.camel@localhost.localdomain>
	<1155224407.10547.45.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-LhwXvhBkDi23wtmcBMYD"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GBD2I-00046L-Pf
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 09:05:31 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GBD2G-0002xw-Nd
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 09:05:31 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <1155224407.10547.45.camel@localhost>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--=-LhwXvhBkDi23wtmcBMYD
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2006-08-10 at 11:40 -0400, Trond Myklebust wrote:
> On Thu, 2006-08-10 at 11:24 -0400, Wendy Cheng wrote:
> 
> > We simply can't call nlm_release_file() as long as it requires
> > nlm_file_mutex (no matter where you move the locking line) within
> > nlm_traverse_files() code path. I'm ok with atomic variable though.
> 
> As long as we can guarantee that file->f_count doesn't drop to zero (and
> we can make that guarantee in nlm_traverse_file()), then the code is
> correct.

Doh! There is no reason whatsoever to be holding nlm_file_mutex across
the call to nlm_inspect_file. As you said, the only thing it does is
protect the list, and we don't care about that.

The simplest fix is just to do something like the following.

Cheers,
  Trond

--=-LhwXvhBkDi23wtmcBMYD
Content-Disposition: inline;
	filename=linux-2.6.18-009-fix_nlm_traverse_files_deadlock.dif
Content-Type: message/rfc822;
	name=linux-2.6.18-009-fix_nlm_traverse_files_deadlock.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
LOCKD: Fix a deadlock in nlm_traverse_files()
Date: Thu, 10 Aug 2006 12:01:51 -0400
Subject: No Subject
Message-Id: <1155225711.10547.49.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

nlm_traverse_files() is not allowed to hold the nlm_file_mutex while calling
nlm_inspect file, since it may end up calling nlm_release_file() when
releaseing the blocks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/svcsubs.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 2a4df9b..01b4db9 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -237,19 +237,22 @@ static int
 nlm_traverse_files(struct nlm_host *host, int action)
 {
 	struct nlm_file	*file, **fp;
-	int		i;
+	int i, ret = 0;
 
 	mutex_lock(&nlm_file_mutex);
 	for (i = 0; i < FILE_NRHASH; i++) {
 		fp = nlm_files + i;
 		while ((file = *fp) != NULL) {
+			file->f_count++;
+			mutex_unlock(&nlm_file_mutex);
+
 			/* Traverse locks, blocks and shares of this file
 			 * and update file->f_locks count */
-			if (nlm_inspect_file(host, file, action)) {
-				mutex_unlock(&nlm_file_mutex);
-				return 1;
-			}
+			if (nlm_inspect_file(host, file, action))
+				ret = 1;
 
+			mutex_lock(&nlm_file_mutex);
+			file->f_count--;
 			/* No more references to this file. Let go of it. */
 			if (!file->f_blocks && !file->f_locks
 			 && !file->f_shares && !file->f_count) {
@@ -262,7 +265,7 @@ nlm_traverse_files(struct nlm_host *host
 		}
 	}
 	mutex_unlock(&nlm_file_mutex);
-	return 0;
+	return ret;
 }
 
 /*

--=-LhwXvhBkDi23wtmcBMYD
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--=-LhwXvhBkDi23wtmcBMYD
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-LhwXvhBkDi23wtmcBMYD--
