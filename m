From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS client fixes for 2.6.25-rc2
Date: Thu, 21 Feb 2008 20:01:16 -0500
Message-ID: <1203642076.11926.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47776 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754518AbYBVBBU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 20:01:20 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "hotfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git hotfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/lockd/svc.c        |    2 +-
 fs/nfs/callback.c     |    3 ++-
 fs/nfs/callback_xdr.c |    6 +++---
 fs/nfs/delegation.c   |    2 +-
 fs/nfs/idmap.c        |    2 +-
 fs/nfs/nfs4state.c    |    2 +-
 fs/nfsd/nfsfh.c       |    2 +-
 net/sunrpc/svcsock.c  |    6 +++---
 8 files changed, 13 insertions(+), 12 deletions(-)

commit 5216a8e70e25b01cbd2915cd0442fb96deb2c262
Author: Pavel Emelyanov <xemul@openvz.org>
Date:   Thu Feb 21 10:57:45 2008 +0300

    Wrap buffers used for rpc debug printks into RPC_IFDEBUG
    
    Sorry for the noise, but here's the v3 of this compilation fix :)
    
    There are some places, which declare the char buf[...] on the stack
    to push it later into dprintk(). Since the dprintk sometimes (if the
    CONFIG_SYSCTL=n) becomes an empty do { } while (0) stub, these buffers
    cause gcc to produce appropriate warnings.
    
    Wrap these buffers with RPC_IFDEBUG macro, as Trond proposed, to
    compile them out when not needed.
    
    Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
    Acked-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 90dc7d2796edf94a9eaa838321a9734c8513e717
Author: Harvey Harrison <harvey.harrison@gmail.com>
Date:   Wed Feb 20 13:03:05 2008 -0800

    nfs: fix sparse warnings
    
    fs/nfs/nfs4state.c:788:34: warning: Using plain integer as NULL pointer
    fs/nfs/delegation.c:52:34: warning: Using plain integer as NULL pointer
    fs/nfs/idmap.c:312:12: warning: Using plain integer as NULL pointer
    fs/nfs/callback_xdr.c:257:6: warning: Using plain integer as NULL pointer
    fs/nfs/callback_xdr.c:270:6: warning: Using plain integer as NULL pointer
    fs/nfs/callback_xdr.c:281:6: warning: Using plain integer as NULL pointer
    
    Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1227a74e2e0217a4ca155d1677bdbf5f69e32bed
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Feb 19 12:51:35 2008 -0500

    NFS: flush signals before taking down callback thread
    
    Now that the reference counting on the callback thread is working as
    expected, it uncovers another problem.  Peter Staubach noticed while
    testing that patch on an older kernel that he would occasionally see
    this printk in rpc_register fire:
    
        "RPC: failed to contact portmap (errno -512).
    
    The NFSv4 callback thread is signaled by nfs_callback_down(), but never
    flushes that signal. All of the shutdown processing is done with that
    signal pending. This makes it fail the call to unregister the port with
    the portmapper.
    
    In actuality, this rpc_register call isn't necessary at all since the
    port isn't actually registered with the portmapper anymore. Regardless,
    there doesn't seem to be any reason to leave the signal pending while
    the thread is being shut down and flushing it should generally silence
    that printk.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 0822646..1ed8bd4 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -153,7 +153,7 @@ lockd(struct svc_rqst *rqstp)
 	 */
 	while ((nlmsvc_users || !signalled()) && nlmsvc_pid == current->pid) {
 		long timeout = MAX_SCHEDULE_TIMEOUT;
-		char buf[RPC_MAX_ADDRBUFLEN];
+		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 		if (signalled()) {
 			flush_signals(current);
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index ecc06c6..66648dd 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -93,6 +93,7 @@ static void nfs_callback_svc(struct svc_rqst *rqstp)
 		svc_process(rqstp);
 	}
 
+	flush_signals(current);
 	svc_exit_thread(rqstp);
 	nfs_callback_info.pid = 0;
 	complete(&nfs_callback_info.stopped);
@@ -171,7 +172,7 @@ void nfs_callback_down(void)
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
 	struct nfs_client *clp;
-	char buf[RPC_MAX_ADDRBUFLEN];
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	/* Don't talk to strangers */
 	clp = nfs_find_client(svc_addr(rqstp), 4);
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index c63eb72..13619d2 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -254,7 +254,7 @@ static __be32 encode_attr_change(struct xdr_stream *xdr, const uint32_t *bitmap,
 	if (!(bitmap[0] & FATTR4_WORD0_CHANGE))
 		return 0;
 	p = xdr_reserve_space(xdr, 8);
-	if (unlikely(p == 0))
+	if (unlikely(!p))
 		return htonl(NFS4ERR_RESOURCE);
 	p = xdr_encode_hyper(p, change);
 	return 0;
@@ -267,7 +267,7 @@ static __be32 encode_attr_size(struct xdr_stream *xdr, const uint32_t *bitmap, u
 	if (!(bitmap[0] & FATTR4_WORD0_SIZE))
 		return 0;
 	p = xdr_reserve_space(xdr, 8);
-	if (unlikely(p == 0))
+	if (unlikely(!p))
 		return htonl(NFS4ERR_RESOURCE);
 	p = xdr_encode_hyper(p, size);
 	return 0;
@@ -278,7 +278,7 @@ static __be32 encode_attr_time(struct xdr_stream *xdr, const struct timespec *ti
 	__be32 *p;
 
 	p = xdr_reserve_space(xdr, 12);
-	if (unlikely(p == 0))
+	if (unlikely(!p))
 		return htonl(NFS4ERR_RESOURCE);
 	p = xdr_encode_hyper(p, time->tv_sec);
 	*p = htonl(time->tv_nsec);
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index b9eadd1..00a5e44 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -49,7 +49,7 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 	struct file_lock *fl;
 	int status;
 
-	for (fl = inode->i_flock; fl != 0; fl = fl->fl_next) {
+	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
 		if (!(fl->fl_flags & (FL_POSIX|FL_FLOCK)))
 			continue;
 		if (nfs_file_open_context(fl->fl_file) != ctx)
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 8ae5dba..86147b0 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -309,7 +309,7 @@ nfs_idmap_name(struct idmap *idmap, struct idmap_hashtable *h,
 	mutex_lock(&idmap->idmap_im_lock);
 
 	he = idmap_lookup_id(h, id);
-	if (he != 0) {
+	if (he) {
 		memcpy(name, he->ih_name, he->ih_namelen);
 		ret = he->ih_namelen;
 		goto out;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6233eb5..b962397 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -785,7 +785,7 @@ static int nfs4_reclaim_locks(struct nfs4_state_recovery_ops *ops, struct nfs4_s
 	struct file_lock *fl;
 	int status = 0;
 
-	for (fl = inode->i_flock; fl != 0; fl = fl->fl_next) {
+	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
 		if (!(fl->fl_flags & (FL_POSIX|FL_FLOCK)))
 			continue;
 		if (nfs_file_open_context(fl->fl_file)->state != state)
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 0130b34..1eb771d 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -101,7 +101,7 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 {
 	/* Check if the request originated from a secure port. */
 	if (!rqstp->rq_secure && EX_SECURE(exp)) {
-		char buf[RPC_MAX_ADDRBUFLEN];
+		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 		dprintk(KERN_WARNING
 		       "nfsd: request from insecure port %s!\n",
 		       svc_print_addr(rqstp, buf, sizeof(buf)));
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1d3e5fc..c475977 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -175,7 +175,7 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 	size_t		base = xdr->page_base;
 	unsigned int	pglen = xdr->page_len;
 	unsigned int	flags = MSG_MORE;
-	char		buf[RPC_MAX_ADDRBUFLEN];
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	slen = xdr->len;
 
@@ -716,7 +716,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
 	int		err, slen;
-	char		buf[RPC_MAX_ADDRBUFLEN];
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
@@ -1206,10 +1206,10 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	struct socket	*sock;
 	int		error;
 	int		type;
-	char		buf[RPC_MAX_ADDRBUFLEN];
 	struct sockaddr_storage addr;
 	struct sockaddr *newsin = (struct sockaddr *)&addr;
 	int		newlen;
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	dprintk("svc: svc_create_socket(%s, %d, %s)\n",
 			serv->sv_program->pg_name, protocol,

