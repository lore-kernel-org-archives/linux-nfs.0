Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:59364 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbZFEQfY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 12:35:24 -0400
Subject: Re: Link performance over NFS degraded in RHEL5. -- was :
 Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, Tom Talpey <tmtalpey@gmail.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <20090605160544.GE10975@fieldses.org>
References: <1243963631.4868.124.camel@heimdal.trondhjem.org>
	 <18982.41770.293636.786518@fisica.ufpr.br>
	 <1244049027.5603.5.camel@heimdal.trondhjem.org>
	 <1244138698.5203.59.camel@heimdal.trondhjem.org>
	 <OF37FCED66.33F08949-ON852575CB.006DE109-852575CB.0071CFBD@us.ibm.com>
	 <4A2902E6.2080006@RedHat.com> <4A29144A.6030405@gmail.com>
	 <4A291DE3.2070105@RedHat.com>
	 <1244209956.5410.33.camel@heimdal.trondhjem.org>
	 <4A29243F.8080008@RedHat.com>  <20090605160544.GE10975@fieldses.org>
Content-Type: text/plain
Date: Fri, 05 Jun 2009 12:35:15 -0400
Message-Id: <1244219715.5410.40.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-06-05 at 12:05 -0400, J. Bruce Fields wrote:
> On Fri, Jun 05, 2009 at 09:57:19AM -0400, Steve Dickson wrote:
> > 
> > 
> > Trond Myklebust wrote:
> > > On Fri, 2009-06-05 at 09:30 -0400, Steve Dickson wrote:
> > >> Tom Talpey wrote:
> > >>> On 6/5/2009 7:35 AM, Steve Dickson wrote:
> > >>>> Brian R Cowan wrote:
> > >>>>> Trond Myklebust<trond.myklebust@fys.uio.no>  wrote on 06/04/2009
> > >>>>> 02:04:58
> > >>>>> PM:
> > >>>>>
> > >>>>>> Did you try turning off write gathering on the server (i.e. add the
> > >>>>>> 'no_wdelay' export option)? As I said earlier, that forces a delay of
> > >>>>>> 10ms per RPC call, which might explain the FILE_SYNC slowness.
> > >>>>> Just tried it, this seems to be a very useful workaround as well. The
> > >>>>> FILE_SYNC write calls come back in about the same amount of time as the
> > >>>>> write+commit pairs... Speeds up building regardless of the network
> > >>>>> filesystem (ClearCase MVFS or straight NFS).
> > >>>> Does anybody had the history as to why 'no_wdelay' is an
> > >>>> export default?
> > >>> Because "wdelay" is a complete crock?
> > >>>
> > >>> Adding 10ms to every write RPC only helps if there's a steady
> > >>> single-file stream arriving at the server. In most other workloads
> > >>> it only slows things down.
> > >>>
> > >>> The better solution is to continue tuning the clients to issue
> > >>> writes in a more sequential and less all-or-nothing fashion.
> > >>> There are plenty of other less crock-ful things to do in the
> > >>> server, too.
> > >> Ok... So do you think removing it as a default would cause
> > >> any regressions?
> > > 
> > > It might for NFSv2 clients, since they don't have the option of using
> > > unstable writes. I'd therefore prefer a kernel solution that makes write
> > > gathering an NFSv2 only feature.
> > Sounds good to me! ;-)
> 
> Patch welcomed.--b.

Something like this ought to suffice...

-----------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
NFSD: Make sure that write gathering only applies to NFSv2

NFSv3 and above can use unstable writes whenever they are sending more
than one write, rather than relying on the flaky write gathering
heuristics. More often than not, write gathering is currently getting it
wrong when the NFSv3 clients are sending a single write with FILE_SYNC
for efficiency reasons.

This patch turns off write gathering for NFSv3/v4, and ensure that
it only applies to the one case that can actually benefit: namely NFSv2.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfsd/vfs.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)


diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b660435..f30cc4e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -975,6 +975,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	__be32			err = 0;
 	int			host_err;
 	int			stable = *stablep;
+	int			use_wgather;
 
 #ifdef MSNFS
 	err = nfserr_perm;
@@ -993,9 +994,10 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	 *  -	the sync export option has been set, or
 	 *  -	the client requested O_SYNC behavior (NFSv3 feature).
 	 *  -   The file system doesn't support fsync().
-	 * When gathered writes have been configured for this volume,
+	 * When NFSv2 gathered writes have been configured for this volume,
 	 * flushing the data to disk is handled separately below.
 	 */
+	use_wgather = (rqstp->rq_vers == 2) && EX_WGATHER(exp);
 
 	if (!file->f_op->fsync) {/* COMMIT3 cannot work */
 	       stable = 2;
@@ -1004,7 +1006,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 
 	if (!EX_ISSYNC(exp))
 		stable = 0;
-	if (stable && !EX_WGATHER(exp)) {
+	if (stable && !use_wgather) {
 		spin_lock(&file->f_lock);
 		file->f_flags |= O_SYNC;
 		spin_unlock(&file->f_lock);
@@ -1040,7 +1042,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 		 * nice and simple solution (IMHO), and it seems to
 		 * work:-)
 		 */
-		if (EX_WGATHER(exp)) {
+		if (use_wgather) {
 			if (atomic_read(&inode->i_writecount) > 1
 			    || (last_ino == inode->i_ino && last_dev == inode->i_sb->s_dev)) {
 				dprintk("nfsd: write defer %d\n", task_pid_nr(current));


