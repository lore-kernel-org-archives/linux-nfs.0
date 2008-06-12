From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/5] knfsd: Replace lock_kernel with a mutex for nfsd
	thread startup/shutdown locking.
Date: Thu, 12 Jun 2008 13:38:42 +1000
Message-ID: <18512.39490.36187.783761@notabene.brown>
References: <1213101639-26423-1-git-send-email-jlayton@redhat.com>
	<1213101639-26423-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, gnb@melbourne.sgi.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: message from Jeff Layton on Tuesday June 10
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday June 10, jlayton@redhat.com wrote:
> From: Neil Brown <neilb@suse.de>
> 
> This removes the BKL from the RPC service creation codepath. The BKL
> really isn't adequate for this job since some of this info needs
> protection across sleeps.
> 
> Also, add some comments to try and clarify how the locking should work
> and to make it clear that the BKL isn't necessary as long as there is
> adequate locking between tasks when touching the svc_serv fields.
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Thanks for proceeding with this.
As well as the fixes for this that you included in 2/5, you need this
patch as well for correctness.... Well, you need the first hunk.  The
second is unrelated but probably should be fixed.

The rest all looks good.

NeilBrown


---------------------------------

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfssvc.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2008-06-12 13:27:47.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2008-06-12 13:32:14.000000000 +1000
@@ -169,10 +169,12 @@ int nfsd_vers(int vers, enum vers_op cha
 
 int nfsd_nrthreads(void)
 {
-	if (nfsd_serv == NULL)
-		return 0;
-	else
-		return nfsd_serv->sv_nrthreads;
+	int rv = 0;
+	mutex_lock(&nfsd_mutex);
+	if (nfsd_serv)
+		rv = nfsd_serv->sv_nrthreads;
+	mutex_unlock(&nfsd_mutex);
+	return rv;
 }
 
 static int killsig;	/* signal that was used to kill last nfsd */
@@ -275,7 +277,7 @@ static int nfsd_init_socks(int port)
 					SVC_SOCK_DEFAULTS);
 		if (error < 0)
 			lockd_down();
-}
+	}
 	if (error < 0)
 		return error;
 	return 0;
