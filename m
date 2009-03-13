From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull NFS client bug and regression fixes
Date: Fri, 13 Mar 2009 14:16:28 -0400
Message-ID: <1236968188.7265.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59684 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076AbZCMSRQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Mar 2009 14:17:16 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/lockd/clntlock.c         |   51 +++++++++++++++++++++++++++++-
 fs/nfs/client.c             |   73 ++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/dir.c                |    8 ++++-
 fs/nfs/nfs3acl.c            |   27 ++++++++++++---
 fs/nfs/nfs3xdr.c            |   34 ++++++++------------
 fs/nfs/nfs4namespace.c      |   15 +++++----
 include/linux/lockd/lockd.h |    8 +++++
 include/linux/nfs_xdr.h     |    2 +
 include/linux/nfsacl.h      |    3 ++
 net/sunrpc/sched.c          |   33 ++++++++++++--------
 net/sunrpc/xprt.c           |    2 +-
 net/sunrpc/xprtsock.c       |   23 ++++++++++---
 12 files changed, 223 insertions(+), 56 deletions(-)

commit 9f4c899c0d90e1b51b6864834f3877b47c161a0e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Mar 12 14:51:32 2009 -0400

    NFS: Fix the fix to Bugzilla #11061, when IPv6 isn't defined...
    
    Stephen Rothwell reports:
    
    Today's linux-next build (powerpc ppc64_defconfig) failed like this:
    
    fs/built-in.o: In function `.nfs_get_client':
    client.c:(.text+0x115010): undefined reference to `.__ipv6_addr_type'
    
    Fix by moving the IPV6 specific parts of commit
    d7371c41b0cda782256b1df759df4e8d4724584c ("Bug 11061, NFS mounts dropped")
    into the '#ifdef IPV6..." section.
    
    Also fix up a couple of formatting issues.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 01d37c428ae080563c0a3bb8bdfa88c65a6891d3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:09:39 2009 -0400

    SUNRPC: xprt_connect() don't abort the task if the transport isn't bound
    
    If the transport isn't bound, then we should just return ENOTCONN, letting
    call_connect_status() and/or call_status() deal with retrying. Currently,
    we appear to abort all pending tasks with an EIO error.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fba91afbec2c004e2c8733ae9e0ca6998e962c64
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:06:41 2009 -0400

    SUNRPC: Fix an Oops due to socket not set up yet...
    
    We can Oops in both xs_udp_send_request() and xs_tcp_send_request() if the
    call to xs_sendpages() returns an error due to the socket not yet being
    set up.
    Deal with that situation by returning a new error: ENOTSOCK, so that we
    know to avoid dereferencing transport->sock.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d7371c41b0cda782256b1df759df4e8d4724584c
Author: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Date:   Tue Mar 10 20:33:22 2009 -0400

    Bug 11061, NFS mounts dropped
    
    Addresses: http://bugzilla.kernel.org/show_bug.cgi?id=11061
    
    sockaddr structures can't be reliably compared using memcmp() because
    there are padding bytes in the structure which can't be guaranteed to
    be the same even when the sockaddr structures refer to the same
    socket. Instead compare all the relevant fields. In the case of IPv6
    sin6_flowinfo is not compared because it only affects QoS and
    sin6_scope_id is only compared if the address is "link local" because
    "link local" addresses need only be unique to a specific link.
    
    Signed-off-by: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a71ee337b31271e701f689d544b6153b75609bc5
Author: Suresh Jayaraman <sjayaraman@suse.de>
Date:   Tue Mar 10 20:33:21 2009 -0400

    NFS: Handle -ESTALE error in access()
    
    Hi Trond,
    
    I have been looking at a bugreport where trying to open applications on KDE
    on a NFS mounted home fails temporarily. There have been multiple reports on
    different kernel versions pointing to this common issue:
    http://bugzilla.kernel.org/show_bug.cgi?id=12557
    https://bugs.launchpad.net/ubuntu/+source/linux/+bug/269954
    http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=508866.html
    
    This issue can be reproducible consistently by doing this on a NFS mounted
    home (KDE):
    1. Open 2 xterm sessions
    2. From one of the xterm session, do "ssh -X <remote host>"
    3. "stat ~/.Xauthority" on the remote SSH session
    4. Close the two xterm sessions
    5. On the server do a "stat ~/.Xauthority"
    6. Now on the client, try to open xterm
    This will fail.
    
    Even if the filehandle had become stale, the NFS client should invalidate
    the cache/inode and should repeat LOOKUP. Looking at the packet capture when
    the failure occurs shows that there were two subsequent ACCESS() calls with
    the same filehandle and both fails with -ESTALE error.
    
    I have tested the fix below. Now the client issue a LOOKUP after the
    ACCESS() call fails with -ESTALE. If all this makes sense to you, can you
    consider this for inclusion?
    
    Thanks,
    
    
    If the server returns an -ESTALE error due to stale filehandle in response to
    an ACCESS() call, we need to invalidate the cache and inode so that LOOKUP()
    can be retried. Without this change, the nfs client retries ACCESS() with the
    same filehandle, fails again and could lead to temporary failure of
    applications running on nfs mounted home.
    
    Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 57df675c60c5cf0748ddba9c7f85afde1530d74d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Mar 10 20:33:20 2009 -0400

    NLM: Fix GRANT callback address comparison when IPv6 is enabled
    
    The NFS mount command may pass an AF_INET server address to lockd.  If
    lockd happens to be using a PF_INET6 listener, the nlm_cmp_addr() in
    nlmclnt_grant() will fail to match requests from that host because they
    will all have a mapped IPv4 AF_INET6 address.
    
    Adopt the same solution used in nfs_sockaddr_match_ipaddr() for NFSv4
    callbacks: if either address is AF_INET, map it to an AF_INET6 address
    before doing the comparison.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 78851e1aa4c3b796d5f0bb11b445016726302b44
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Mar 10 20:33:19 2009 -0400

    NLM: Shrink the IPv4-only version of nlm_cmp_addr()
    
    Clean up/micro-optimatization:  Make the AF_INET-only version of
    nlm_cmp_addr() smaller.  This matches the style of
    nlm_privileged_requester(), and makes the AF_INET-only version of
    nlm_cmp_addr() nearly the same size as it was before IPv6 support.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ae46141ff08f1965b17c531b571953c39ce8b9e2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 10 20:33:18 2009 -0400

    NFSv3: Fix posix ACL code
    
    Fix a memory leak due to allocation in the XDR layer. In cases where the
    RPC call needs to be retransmitted, we end up allocating new pages without
    clearing the old ones. Fix this by moving the allocation into
    nfs3_proc_setacls().
    
    Also fix an issue discovered by Kevin Rudd, whereby the amount of memory
    reserved for the acls in the xdr_buf->head was miscalculated, and causing
    corruption.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ef95d31e6de6be9602ce950b85fb7ab8af46ae42
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 10 20:33:17 2009 -0400

    NFS: Fix misparsing of nfsv4 fs_locations attribute (take 2)
    
    The changeset ea31a4437c59219bf3ea946d58984b01a45a289c (nfs: Fix
    misparsing of nfsv4 fs_locations attribute) causes the mountpath that is
    calculated at the beginning of try_location() to be clobbered when we
    later strncpy a non-nul terminated hostname using an incorrect buffer
    length.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eb9b55ab4d73280597fd183b367d50452f4d7846
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 10 20:33:16 2009 -0400

    SUNRPC: Tighten up the task locking rules in __rpc_execute()
    
    We should probably not be testing any flags after we've cleared the
    RPC_TASK_RUNNING flag, since rpc_make_runnable() is then free to assign the
    rpc_task to another workqueue, which may then destroy it.
    
    We can fix any races with rpc_make_runnable() by ensuring that we only
    clear the RPC_TASK_RUNNING flag while holding the rpc_wait_queue->lock that
    the task is supposed to be sleeping on (and then checking whether or not
    the task really is sleeping).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 1f3b0fc..aedc47a 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -139,6 +139,55 @@ int nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long timeout)
 	return 0;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static const struct in6_addr *nlmclnt_map_v4addr(const struct sockaddr *sap,
+						 struct in6_addr *addr_mapped)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+
+	switch (sap->sa_family) {
+	case AF_INET6:
+		return &((const struct sockaddr_in6 *)sap)->sin6_addr;
+	case AF_INET:
+		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, addr_mapped);
+		return addr_mapped;
+	}
+
+	return NULL;
+}
+
+/*
+ * If lockd is using a PF_INET6 listener, all incoming requests appear
+ * to come from AF_INET6 remotes.  The address of AF_INET remotes are
+ * mapped to AF_INET6 automatically by the network layer.  In case the
+ * user passed an AF_INET server address at mount time, ensure both
+ * addresses are AF_INET6 before comparing them.
+ */
+static int nlmclnt_cmp_addr(const struct nlm_host *host,
+			    const struct sockaddr *sap)
+{
+	const struct in6_addr *addr1;
+	const struct in6_addr *addr2;
+	struct in6_addr addr1_mapped;
+	struct in6_addr addr2_mapped;
+
+	addr1 = nlmclnt_map_v4addr(nlm_addr(host), &addr1_mapped);
+	if (likely(addr1 != NULL)) {
+		addr2 = nlmclnt_map_v4addr(sap, &addr2_mapped);
+		if (likely(addr2 != NULL))
+			return ipv6_addr_equal(addr1, addr2);
+	}
+
+	return 0;
+}
+#else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
+static int nlmclnt_cmp_addr(const struct nlm_host *host,
+			    const struct sockaddr *sap)
+{
+	return nlm_cmp_addr(nlm_addr(host), sap);
+}
+#endif	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
+
 /*
  * The server lockd has called us back to tell us the lock was granted
  */
@@ -166,7 +215,7 @@ __be32 nlmclnt_grant(const struct sockaddr *addr, const struct nlm_lock *lock)
 		 */
 		if (fl_blocked->fl_u.nfs_fl.owner->pid != lock->svid)
 			continue;
-		if (!nlm_cmp_addr(nlm_addr(block->b_host), addr))
+		if (!nlmclnt_cmp_addr(block->b_host, addr))
 			continue;
 		if (nfs_compare_fh(NFS_FH(fl_blocked->fl_file->f_path.dentry->d_inode) ,fh) != 0)
 			continue;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9b728f3..574158a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -255,6 +255,32 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 	}
 	return 0;
 }
+
+/*
+ * Test if two ip6 socket addresses refer to the same socket by
+ * comparing relevant fields. The padding bytes specifically, are not
+ * compared. sin6_flowinfo is not compared because it only affects QoS
+ * and sin6_scope_id is only compared if the address is "link local"
+ * because "link local" addresses need only be unique to a specific
+ * link. Conversely, ordinary unicast addresses might have different
+ * sin6_scope_id.
+ *
+ * The caller should ensure both socket addresses are AF_INET6.
+ */
+static int nfs_sockaddr_cmp_ip6(const struct sockaddr *sa1,
+				const struct sockaddr *sa2)
+{
+	const struct sockaddr_in6 *saddr1 = (const struct sockaddr_in6 *)sa1;
+	const struct sockaddr_in6 *saddr2 = (const struct sockaddr_in6 *)sa2;
+
+	if (!ipv6_addr_equal(&saddr1->sin6_addr,
+			     &saddr1->sin6_addr))
+		return 0;
+	if (ipv6_addr_scope(&saddr1->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL &&
+	    saddr1->sin6_scope_id != saddr2->sin6_scope_id)
+		return 0;
+	return saddr1->sin6_port == saddr2->sin6_port;
+}
 #else
 static int nfs_sockaddr_match_ipaddr4(const struct sockaddr_in *sa1,
 				 const struct sockaddr_in *sa2)
@@ -270,9 +296,52 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 	return nfs_sockaddr_match_ipaddr4((const struct sockaddr_in *)sa1,
 			(const struct sockaddr_in *)sa2);
 }
+
+static int nfs_sockaddr_cmp_ip6(const struct sockaddr * sa1,
+				const struct sockaddr * sa2)
+{
+	return 0;
+}
 #endif
 
 /*
+ * Test if two ip4 socket addresses refer to the same socket, by
+ * comparing relevant fields. The padding bytes specifically, are
+ * not compared.
+ *
+ * The caller should ensure both socket addresses are AF_INET.
+ */
+static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
+				const struct sockaddr *sa2)
+{
+	const struct sockaddr_in *saddr1 = (const struct sockaddr_in *)sa1;
+	const struct sockaddr_in *saddr2 = (const struct sockaddr_in *)sa2;
+
+	if (saddr1->sin_addr.s_addr != saddr2->sin_addr.s_addr)
+		return 0;
+	return saddr1->sin_port == saddr2->sin_port;
+}
+
+/*
+ * Test if two socket addresses represent the same actual socket,
+ * by comparing (only) relevant fields.
+ */
+static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
+			    const struct sockaddr *sa2)
+{
+	if (sa1->sa_family != sa2->sa_family)
+		return 0;
+
+	switch (sa1->sa_family) {
+	case AF_INET:
+		return nfs_sockaddr_cmp_ip4(sa1, sa2);
+	case AF_INET6:
+		return nfs_sockaddr_cmp_ip6(sa1, sa2);
+	}
+	return 0;
+}
+
+/*
  * Find a client by IP address and protocol version
  * - returns NULL if no such client
  */
@@ -344,8 +413,10 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
 static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *data)
 {
 	struct nfs_client *clp;
+	const struct sockaddr *sap = data->addr;
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
+	        const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -358,7 +429,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 			continue;
 
 		/* Match the full socket address */
-		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
+		if (!nfs_sockaddr_cmp(sap, clap))
 			continue;
 
 		atomic_inc(&clp->cl_count);
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e35c819..672368f 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1892,8 +1892,14 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 	cache.cred = cred;
 	cache.jiffies = jiffies;
 	status = NFS_PROTO(inode)->access(inode, &cache);
-	if (status != 0)
+	if (status != 0) {
+		if (status == -ESTALE) {
+			nfs_zap_caches(inode);
+			if (!S_ISDIR(inode->i_mode))
+				set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
+		}
 		return status;
+	}
 	nfs_access_add_cache(inode, &cache);
 out:
 	if ((mask & ~cache.mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index cef6255..6bbf0e6 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -292,7 +292,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_fattr fattr;
-	struct page *pages[NFSACL_MAXPAGES] = { };
+	struct page *pages[NFSACL_MAXPAGES];
 	struct nfs3_setaclargs args = {
 		.inode = inode,
 		.mask = NFS_ACL,
@@ -303,7 +303,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 		.rpc_argp	= &args,
 		.rpc_resp	= &fattr,
 	};
-	int status, count;
+	int status;
 
 	status = -EOPNOTSUPP;
 	if (!nfs_server_capable(inode, NFS_CAP_ACLS))
@@ -319,6 +319,20 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	if (S_ISDIR(inode->i_mode)) {
 		args.mask |= NFS_DFACL;
 		args.acl_default = dfacl;
+		args.len = nfsacl_size(acl, dfacl);
+	} else
+		args.len = nfsacl_size(acl, NULL);
+
+	if (args.len > NFS_ACL_INLINE_BUFSIZE) {
+		unsigned int npages = 1 + ((args.len - 1) >> PAGE_SHIFT);
+
+		status = -ENOMEM;
+		do {
+			args.pages[args.npages] = alloc_page(GFP_KERNEL);
+			if (args.pages[args.npages] == NULL)
+				goto out_freepages;
+			args.npages++;
+		} while (args.npages < npages);
 	}
 
 	dprintk("NFS call setacl\n");
@@ -329,10 +343,6 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	nfs_zap_acl_cache(inode);
 	dprintk("NFS reply setacl: %d\n", status);
 
-	/* pages may have been allocated at the xdr layer. */
-	for (count = 0; count < NFSACL_MAXPAGES && args.pages[count]; count++)
-		__free_page(args.pages[count]);
-
 	switch (status) {
 		case 0:
 			status = nfs_refresh_inode(inode, &fattr);
@@ -346,6 +356,11 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 		case -ENOTSUPP:
 			status = -EOPNOTSUPP;
 	}
+out_freepages:
+	while (args.npages != 0) {
+		args.npages--;
+		__free_page(args.pages[args.npages]);
+	}
 out:
 	return status;
 }
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 11cddde..6cdeacf 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -82,8 +82,10 @@
 #define NFS3_commitres_sz	(1+NFS3_wcc_data_sz+2)
 
 #define ACL3_getaclargs_sz	(NFS3_fh_sz+1)
-#define ACL3_setaclargs_sz	(NFS3_fh_sz+1+2*(2+5*3))
-#define ACL3_getaclres_sz	(1+NFS3_post_op_attr_sz+1+2*(2+5*3))
+#define ACL3_setaclargs_sz	(NFS3_fh_sz+1+ \
+				XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
+#define ACL3_getaclres_sz	(1+NFS3_post_op_attr_sz+1+ \
+				XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
 #define ACL3_setaclres_sz	(1+NFS3_post_op_attr_sz)
 
 /*
@@ -703,28 +705,18 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req, __be32 *p,
                    struct nfs3_setaclargs *args)
 {
 	struct xdr_buf *buf = &req->rq_snd_buf;
-	unsigned int base, len_in_head, len = nfsacl_size(
-		(args->mask & NFS_ACL)   ? args->acl_access  : NULL,
-		(args->mask & NFS_DFACL) ? args->acl_default : NULL);
-	int count, err;
+	unsigned int base;
+	int err;
 
 	p = xdr_encode_fhandle(p, NFS_FH(args->inode));
 	*p++ = htonl(args->mask);
-	base = (char *)p - (char *)buf->head->iov_base;
-	/* put as much of the acls into head as possible. */
-	len_in_head = min_t(unsigned int, buf->head->iov_len - base, len);
-	len -= len_in_head;
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p + (len_in_head >> 2));
-
-	for (count = 0; (count << PAGE_SHIFT) < len; count++) {
-		args->pages[count] = alloc_page(GFP_KERNEL);
-		if (!args->pages[count]) {
-			while (count)
-				__free_page(args->pages[--count]);
-			return -ENOMEM;
-		}
-	}
-	xdr_encode_pages(buf, args->pages, 0, len);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	base = req->rq_slen;
+
+	if (args->npages != 0)
+		xdr_encode_pages(buf, args->pages, 0, args->len);
+	else
+		req->rq_slen += args->len;
 
 	err = nfsacl_encode(buf, base, args->inode,
 			    (args->mask & NFS_ACL) ?
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 30befc3..2a2a0a7 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -21,7 +21,9 @@
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
 /*
- * Check if fs_root is valid
+ * Convert the NFSv4 pathname components into a standard posix path.
+ *
+ * Note that the resulting string will be placed at the end of the buffer
  */
 static inline char *nfs4_pathname_string(const struct nfs4_pathname *pathname,
 					 char *buffer, ssize_t buflen)
@@ -99,21 +101,20 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 {
 	struct vfsmount *mnt = ERR_PTR(-ENOENT);
 	char *mnt_path;
-	int page2len;
+	unsigned int maxbuflen;
 	unsigned int s;
 
 	mnt_path = nfs4_pathname_string(&location->rootpath, page2, PAGE_SIZE);
 	if (IS_ERR(mnt_path))
 		return mnt;
 	mountdata->mnt_path = mnt_path;
-	page2 += strlen(mnt_path) + 1;
-	page2len = PAGE_SIZE - strlen(mnt_path) - 1;
+	maxbuflen = mnt_path - 1 - page2;
 
 	for (s = 0; s < location->nservers; s++) {
 		const struct nfs4_string *buf = &location->servers[s];
 		struct sockaddr_storage addr;
 
-		if (buf->len <= 0 || buf->len >= PAGE_SIZE)
+		if (buf->len <= 0 || buf->len >= maxbuflen)
 			continue;
 
 		mountdata->addr = (struct sockaddr *)&addr;
@@ -126,8 +127,8 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 			continue;
 		nfs_set_port(mountdata->addr, NFS_PORT);
 
-		strncpy(page2, buf->data, page2len);
-		page2[page2len] = '\0';
+		memcpy(page2, buf->data, buf->len);
+		page2[buf->len] = '\0';
 		mountdata->hostname = page2;
 
 		snprintf(page, PAGE_SIZE, "%s:%s",
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index aa6fe70..51855df 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -346,6 +346,7 @@ static inline int __nlm_cmp_addr4(const struct sockaddr *sap1,
 	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline int __nlm_cmp_addr6(const struct sockaddr *sap1,
 				  const struct sockaddr *sap2)
 {
@@ -353,6 +354,13 @@ static inline int __nlm_cmp_addr6(const struct sockaddr *sap1,
 	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
 	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
 }
+#else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
+static inline int __nlm_cmp_addr6(const struct sockaddr *sap1,
+				  const struct sockaddr *sap2)
+{
+	return 0;
+}
+#endif	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
 
 /*
  * Compare two host addresses
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a550b52..2e5f000 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -406,6 +406,8 @@ struct nfs3_setaclargs {
 	int			mask;
 	struct posix_acl *	acl_access;
 	struct posix_acl *	acl_default;
+	size_t			len;
+	unsigned int		npages;
 	struct page **		pages;
 };
 
diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index 54487a9..43011b6 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -37,6 +37,9 @@
 #define NFSACL_MAXPAGES		((2*(8+12*NFS_ACL_MAX_ENTRIES) + PAGE_SIZE-1) \
 				 >> PAGE_SHIFT)
 
+#define NFS_ACL_MAX_ENTRIES_INLINE	(5)
+#define NFS_ACL_INLINE_BUFSIZE	((2*(2+3*NFS_ACL_MAX_ENTRIES_INLINE)) << 2)
+
 static inline unsigned int
 nfsacl_size(struct posix_acl *acl_access, struct posix_acl *acl_default)
 {
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 385f427..ff50a05 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -293,11 +293,6 @@ static void rpc_make_runnable(struct rpc_task *task)
 	rpc_clear_queued(task);
 	if (rpc_test_and_set_running(task))
 		return;
-	/* We might have raced */
-	if (RPC_IS_QUEUED(task)) {
-		rpc_clear_running(task);
-		return;
-	}
 	if (RPC_IS_ASYNC(task)) {
 		int status;
 
@@ -607,7 +602,9 @@ void rpc_release_calldata(const struct rpc_call_ops *ops, void *calldata)
  */
 static void __rpc_execute(struct rpc_task *task)
 {
-	int		status = 0;
+	struct rpc_wait_queue *queue;
+	int task_is_async = RPC_IS_ASYNC(task);
+	int status = 0;
 
 	dprintk("RPC: %5u __rpc_execute flags=0x%x\n",
 			task->tk_pid, task->tk_flags);
@@ -647,15 +644,25 @@ static void __rpc_execute(struct rpc_task *task)
 		 */
 		if (!RPC_IS_QUEUED(task))
 			continue;
-		rpc_clear_running(task);
-		if (RPC_IS_ASYNC(task)) {
-			/* Careful! we may have raced... */
-			if (RPC_IS_QUEUED(task))
-				return;
-			if (rpc_test_and_set_running(task))
-				return;
+		/*
+		 * The queue->lock protects against races with
+		 * rpc_make_runnable().
+		 *
+		 * Note that once we clear RPC_TASK_RUNNING on an asynchronous
+		 * rpc_task, rpc_make_runnable() can assign it to a
+		 * different workqueue. We therefore cannot assume that the
+		 * rpc_task pointer may still be dereferenced.
+		 */
+		queue = task->tk_waitqueue;
+		spin_lock_bh(&queue->lock);
+		if (!RPC_IS_QUEUED(task)) {
+			spin_unlock_bh(&queue->lock);
 			continue;
 		}
+		rpc_clear_running(task);
+		spin_unlock_bh(&queue->lock);
+		if (task_is_async)
+			return;
 
 		/* sync task: sleep here */
 		dprintk("RPC: %5u sync task going to sleep\n", task->tk_pid);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 29e401b..62098d1 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -663,7 +663,7 @@ void xprt_connect(struct rpc_task *task)
 			xprt, (xprt_connected(xprt) ? "is" : "is not"));
 
 	if (!xprt_bound(xprt)) {
-		task->tk_status = -EIO;
+		task->tk_status = -EAGAIN;
 		return;
 	}
 	if (!xprt_lock_write(xprt, task))
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5cbb404..29c71e6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -467,7 +467,7 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	int err, sent = 0;
 
 	if (unlikely(!sock))
-		return -ENOTCONN;
+		return -ENOTSOCK;
 
 	clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 	if (base != 0) {
@@ -577,6 +577,8 @@ static int xs_udp_send_request(struct rpc_task *task)
 				req->rq_svec->iov_base,
 				req->rq_svec->iov_len);
 
+	if (!xprt_bound(xprt))
+		return -ENOTCONN;
 	status = xs_sendpages(transport->sock,
 			      xs_addr(xprt),
 			      xprt->addrlen, xdr,
@@ -594,6 +596,10 @@ static int xs_udp_send_request(struct rpc_task *task)
 	}
 
 	switch (status) {
+	case -ENOTSOCK:
+		status = -ENOTCONN;
+		/* Should we call xs_close() here? */
+		break;
 	case -EAGAIN:
 		xs_nospace(task);
 		break;
@@ -693,6 +699,10 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	}
 
 	switch (status) {
+	case -ENOTSOCK:
+		status = -ENOTCONN;
+		/* Should we call xs_close() here? */
+		break;
 	case -EAGAIN:
 		xs_nospace(task);
 		break;
@@ -1523,7 +1533,7 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int err, status = -EIO;
 
-	if (xprt->shutdown || !xprt_bound(xprt))
+	if (xprt->shutdown)
 		goto out;
 
 	/* Start by resetting any existing state */
@@ -1564,7 +1574,7 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int err, status = -EIO;
 
-	if (xprt->shutdown || !xprt_bound(xprt))
+	if (xprt->shutdown)
 		goto out;
 
 	/* Start by resetting any existing state */
@@ -1648,6 +1658,9 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 
+	if (!xprt_bound(xprt))
+		return -ENOTCONN;
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
@@ -1668,7 +1681,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int err, status = -EIO;
 
-	if (xprt->shutdown || !xprt_bound(xprt))
+	if (xprt->shutdown)
 		goto out;
 
 	if (!sock) {
@@ -1728,7 +1741,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int err, status = -EIO;
 
-	if (xprt->shutdown || !xprt_bound(xprt))
+	if (xprt->shutdown)
 		goto out;
 
 	if (!sock) {

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
