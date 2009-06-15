From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Link performance over NFS degraded in RHEL5. -- was :
	Read/Write NFS I/O performance degraded by FLUSH_STABLE page
	flushing
Date: Mon, 15 Jun 2009 19:08:01 -0400
Message-ID: <20090615230801.GA18504@fieldses.org>
References: <1244049027.5603.5.camel@heimdal.trondhjem.org> <1244138698.5203.59.camel@heimdal.trondhjem.org> <OF37FCED66.33F08949-ON852575CB.006DE109-852575CB.0071CFBD@us.ibm.com> <4A2902E6.2080006@RedHat.com> <4A29144A.6030405@gmail.com> <4A291DE3.2070105@RedHat.com> <1244209956.5410.33.camel@heimdal.trondhjem.org> <4A29243F.8080008@RedHat.com> <20090605160544.GE10975@fieldses.org> <1244219715.5410.40.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, Tom Talpey <tmtalpey@gmail.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51704 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbZFOXIF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 19:08:05 -0400
In-Reply-To: <1244219715.5410.40.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 05, 2009 at 12:35:15PM -0400, Trond Myklebust wrote:
> On Fri, 2009-06-05 at 12:05 -0400, J. Bruce Fields wrote:
> > On Fri, Jun 05, 2009 at 09:57:19AM -0400, Steve Dickson wrote:
> > > 
> > > 
> > > Trond Myklebust wrote:
> > > > On Fri, 2009-06-05 at 09:30 -0400, Steve Dickson wrote:
> > > >> Tom Talpey wrote:
> > > >>> On 6/5/2009 7:35 AM, Steve Dickson wrote:
> > > >>>> Brian R Cowan wrote:
> > > >>>>> Trond Myklebust<trond.myklebust@fys.uio.no>  wrote on 06/04/2009
> > > >>>>> 02:04:58
> > > >>>>> PM:
> > > >>>>>
> > > >>>>>> Did you try turning off write gathering on the server (i.e. add the
> > > >>>>>> 'no_wdelay' export option)? As I said earlier, that forces a delay of
> > > >>>>>> 10ms per RPC call, which might explain the FILE_SYNC slowness.
> > > >>>>> Just tried it, this seems to be a very useful workaround as well. The
> > > >>>>> FILE_SYNC write calls come back in about the same amount of time as the
> > > >>>>> write+commit pairs... Speeds up building regardless of the network
> > > >>>>> filesystem (ClearCase MVFS or straight NFS).
> > > >>>> Does anybody had the history as to why 'no_wdelay' is an
> > > >>>> export default?
> > > >>> Because "wdelay" is a complete crock?
> > > >>>
> > > >>> Adding 10ms to every write RPC only helps if there's a steady
> > > >>> single-file stream arriving at the server. In most other workloads
> > > >>> it only slows things down.
> > > >>>
> > > >>> The better solution is to continue tuning the clients to issue
> > > >>> writes in a more sequential and less all-or-nothing fashion.
> > > >>> There are plenty of other less crock-ful things to do in the
> > > >>> server, too.
> > > >> Ok... So do you think removing it as a default would cause
> > > >> any regressions?
> > > > 
> > > > It might for NFSv2 clients, since they don't have the option of using
> > > > unstable writes. I'd therefore prefer a kernel solution that makes write
> > > > gathering an NFSv2 only feature.
> > > Sounds good to me! ;-)
> > 
> > Patch welcomed.--b.
> 
> Something like this ought to suffice...

Thanks, applied.

I'd also like to apply cleanup something like the following--there's
probably some cleaner way, but it just bothers me to have this
write-gathering special case take up the bulk of nfsd_vfs_write....

--b.

commit bfe7680d68afaf3f0b1195c8976db1fd1f03229d
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Jun 15 16:03:53 2009 -0700

    nfsd: Pull write-gathering code out of nfsd_vfs_write
    
    This is a relatively self-contained piece of code that handles a special
    case--move it to its own function.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a8aac7f..de68557 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -963,6 +963,44 @@ static void kill_suid(struct dentry *dentry)
 	mutex_unlock(&dentry->d_inode->i_mutex);
 }
 
+/*
+ * Gathered writes: If another process is currently writing to the file,
+ * there's a high chance this is another nfsd (triggered by a bulk write
+ * from a client's biod). Rather than syncing the file with each write
+ * request, we sleep for 10 msec.
+ *
+ * I don't know if this roughly approximates C. Juszak's idea of
+ * gathered writes, but it's a nice and simple solution (IMHO), and it
+ * seems to work:-)
+ *
+ * Note: we do this only in the NFSv2 case, since v3 and higher have a
+ * better tool (separate unstable writes and commits) for solving this
+ * problem.
+ */
+static void wait_for_concurrent_writes(struct file *file, int use_wgather, int *host_err)
+{
+	struct inode *inode = file->f_path.dentry->d_inode;
+	static ino_t last_ino;
+	static dev_t last_dev;
+
+	if (!use_wgather)
+		goto out;
+	if (atomic_read(&inode->i_writecount) > 1
+	    || (last_ino == inode->i_ino && last_dev == inode->i_sb->s_dev)) {
+		dprintk("nfsd: write defer %d\n", task_pid_nr(current));
+		msleep(10);
+		dprintk("nfsd: write resume %d\n", task_pid_nr(current));
+	}
+
+	if (inode->i_state & I_DIRTY) {
+		dprintk("nfsd: write sync %d\n", task_pid_nr(current));
+		*host_err = nfsd_sync(file);
+	}
+out:
+	last_ino = inode->i_ino;
+	last_dev = inode->i_sb->s_dev;
+}
+
 static __be32
 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 				loff_t offset, struct kvec *vec, int vlen,
@@ -1025,41 +1063,8 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	if (host_err >= 0 && (inode->i_mode & (S_ISUID | S_ISGID)))
 		kill_suid(dentry);
 
-	if (host_err >= 0 && stable) {
-		static ino_t	last_ino;
-		static dev_t	last_dev;
-
-		/*
-		 * Gathered writes: If another process is currently
-		 * writing to the file, there's a high chance
-		 * this is another nfsd (triggered by a bulk write
-		 * from a client's biod). Rather than syncing the
-		 * file with each write request, we sleep for 10 msec.
-		 *
-		 * I don't know if this roughly approximates
-		 * C. Juszak's idea of gathered writes, but it's a
-		 * nice and simple solution (IMHO), and it seems to
-		 * work:-)
-		 */
-		if (use_wgather) {
-			if (atomic_read(&inode->i_writecount) > 1
-			    || (last_ino == inode->i_ino && last_dev == inode->i_sb->s_dev)) {
-				dprintk("nfsd: write defer %d\n", task_pid_nr(current));
-				msleep(10);
-				dprintk("nfsd: write resume %d\n", task_pid_nr(current));
-			}
-
-			if (inode->i_state & I_DIRTY) {
-				dprintk("nfsd: write sync %d\n", task_pid_nr(current));
-				host_err=nfsd_sync(file);
-			}
-#if 0
-			wake_up(&inode->i_wait);
-#endif
-		}
-		last_ino = inode->i_ino;
-		last_dev = inode->i_sb->s_dev;
-	}
+	if (host_err >= 0 && stable)
+		wait_for_concurrent_writes(file, use_wgather, &host_err);
 
 	dprintk("nfsd: write complete host_err=%d\n", host_err);
 	if (host_err >= 0) {
