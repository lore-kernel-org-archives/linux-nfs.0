From: Jeff Layton <jlayton@redhat.com>
Subject: Re: oops during nfs4 mount
Date: Sun, 6 Apr 2008 11:11:22 -0400
Message-ID: <20080406111122.1f0c6696@tleilax.poochiereds.net>
References: <20080328111428.GA8665@csclub.uwaterloo.ca>
	<1207427978.8420.18.camel@heimdal.trondhjem.org>
	<20080405211052.0b3f5623@tupile.poochiereds.net>
	<1207452676.19568.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, "Dr. J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1207452676.19568.3.camel@heimdal.trondhjem.org>
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

On Sat, 05 Apr 2008 23:31:15 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Sat, 2008-04-05 at 21:10 -0400, Jeff Layton wrote:
> > > Hmm... Bruce & Jeff,
> > > 
> > > Doesn't the line
> > > 
> > > 	nfs_callback_info.task = NULL;
> > > 
> > > in nfs_callback_svc() need protection by the BKL?
> > > 
> > 
> > Moving it under the BKL probably won't hurt anything, but isn't it
> > already protected by the nfs_callback_mutex?
>
> AFAICS, nfs_callback_svc() doesn't (and in fact, can't) take the mutex. 
> 
> The point of the BKL here would be to protect nfs_callback_down against
> the race where nfs_callback_svc() terminates early, and clears
> nfs_callback_info.task.
> 

It also looks like the new lockd code may have a similar race. How
about something like this patch against Bruce's tree?

Note that this patch is untested. I'll plan to give it some testing in
the next day or two and will post it formally if the basic idea seems
OK.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 513a186..341f9b1 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -194,11 +194,11 @@ lockd(void *vrqstp)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
 
-	unlock_kernel();
-
 	nlmsvc_task = NULL;
 	nlmsvc_serv = NULL;
 
+	unlock_kernel();
+
 	/* Exit the RPC thread */
 	svc_exit_thread(rqstp);
 
@@ -251,6 +251,7 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	struct svc_rqst *rqstp;
 	int		error = 0;
 
+	lock_kernel();
 	mutex_lock(&nlmsvc_mutex);
 	/*
 	 * Check whether we're already up and running.
@@ -315,6 +316,7 @@ out:
 	if (!error)
 		nlmsvc_users++;
 	mutex_unlock(&nlmsvc_mutex);
+	unlock_kernel();
 	return error;
 }
 EXPORT_SYMBOL(lockd_up);
@@ -325,6 +327,7 @@ EXPORT_SYMBOL(lockd_up);
 void
 lockd_down(void)
 {
+	lock_kernel();
 	mutex_lock(&nlmsvc_mutex);
 	if (nlmsvc_users) {
 		if (--nlmsvc_users)
@@ -342,6 +345,7 @@ lockd_down(void)
 	kthread_stop(nlmsvc_task);
 out:
 	mutex_unlock(&nlmsvc_mutex);
+	unlock_kernel();
 }
 EXPORT_SYMBOL(lockd_down);
 
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 2e5de77..894e64b 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -84,8 +84,8 @@ nfs_callback_svc(void *vrqstp)
 		}
 		svc_process(rqstp);
 	}
-	unlock_kernel();
 	nfs_callback_info.task = NULL;
+	unlock_kernel();
 	svc_exit_thread(rqstp);
 	return 0;
 }
