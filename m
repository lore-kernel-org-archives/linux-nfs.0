From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH RFC 1/1] NLM GRANTED callback race
Date: Wed, 17 Oct 2007 11:41:24 -0400
Message-ID: <EXNANE01prR0E6faZWZ0000073d@exnane01.hq.netapp.com>
References: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiB1V-0006pr-8N
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 08:41:29 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IiB1Y-0004Jh-3L
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 08:41:34 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l9HFfQln026299
	for <nfs@lists.sourceforge.net>; Wed, 17 Oct 2007 08:41:26 -0700 (PDT)
In-Reply-To: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
References: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
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

Sorry, that patch wasn't supposed to be an attachment. Here it is inline.

Tom.

At 09:36 AM 10/17/2007, Talpey, Thomas wrote:
>I've discovered a serious and somewhat interesting issue in the NLM
>client that's been present for quite a while. Basically, if an NLM server
>GRANTED callback arrives for a lock the client already holds, the client
>*rejects* the lock. This leads to incorrect behavior (since the server
>may give the lock to another process), but it also may lead to deadlock
>in the affected client when the next process is on the same machine;
>it means two processes are contending in the local locking code. We
>have seen this in the field recently.
>
>I have a proposed fix (patch below), which adds further checking to
>the NLM callback to scan for held locks, if the callback does not find
>a blocked lock in the client's nlm_blocked list. If found, the client will
>*accept* the lock instead of rejecting it. We're testing the patch at
>high scale currently, an earlier version of the patch (for kernel 2.6.15)
>works well at extreme levels.
>
>To see this, you need to have NLM lock contention, and enough
>network traffic to cause UDP NLM_GRANTED callbacks to be lost in
>the network. Typically, the client will retry the NLM_LOCK rpc after
>30 seconds when this occurs. These retries often succeed, but there
>are still the old GRANTED callbacks floating around, either at the server
>or in the network itself. We can duplicate this in minutes at high load,
>even with server callback retry.
>
>Comments?
>
>Tom.
>
>=====
>

Author: Tom Talpey  <talpey@netapp.com>
NLM: close race condition in GRANTED callback

Don't reply with nlm_lck_denied to a late GRANTED callback for
a lock which we already hold. These callbacks can be delayed in
the network, and also may cross the client's NLMCLNT_POLL_TIMEOUT
retry.

Signed-off-by: Tom Talpey <talpey@netapp.com>

---

 fs/lockd/clntlock.c         |    3 ++
 fs/lockd/host.c             |   52 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/lockd/lockd.h |    2 +
 3 files changed, 57 insertions(+)

Index: linux-2.6.22.10/fs/lockd/clntlock.c
===================================================================
--- linux-2.6.22.10.orig/fs/lockd/clntlock.c
+++ linux-2.6.22.10/fs/lockd/clntlock.c
@@ -135,6 +135,9 @@ __be32 nlmclnt_grant(const struct sockad
 		wake_up(&block->b_wait);
 		res = nlm_granted;
 	}
+	/* Do NOT deny a lock which we already hold */
+	if (res != nlm_granted && nlmclnt_check_lock(addr, lock))
+		res = nlm_granted;
 	return res;
 }
 
Index: linux-2.6.22.10/include/linux/lockd/lockd.h
===================================================================
--- linux-2.6.22.10.orig/include/linux/lockd/lockd.h
+++ linux-2.6.22.10/include/linux/lockd/lockd.h
@@ -174,6 +174,8 @@ void		  nlmclnt_next_cookie(struct nlm_c
  */
 struct nlm_host * nlmclnt_lookup_host(const struct sockaddr_in *, int, int, const char *, int);
 struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *, const char *, int);
+int		  nlmclnt_check_lock(const struct sockaddr_in *,
+				     const struct nlm_lock *);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
Index: linux-2.6.22.10/fs/lockd/host.c
===================================================================
--- linux-2.6.22.10.orig/fs/lockd/host.c
+++ linux-2.6.22.10/fs/lockd/host.c
@@ -11,6 +11,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/in.h>
+#include <linux/nfs_fs.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
@@ -197,6 +198,57 @@ nlmsvc_lookup_host(struct svc_rqst *rqst
 }
 
 /*
+ * Find an existing client NLM lock, used for validating old GRANTED callbacks.
+ */
+
+static inline int
+nlm_lock_match(const struct nlm_lock *lock, const struct file_lock *fl)
+{
+	return	lock->fl.fl_start == fl->fl_start &&
+		lock->fl.fl_end == fl->fl_end &&
+		lock->svid == fl->fl_u.nfs_fl.owner->pid &&
+		0 == nfs_compare_fh(&lock->fh,
+				NFS_FH(fl->fl_file->f_path.dentry->d_inode));
+}
+
+int
+nlmclnt_check_lock(const struct sockaddr_in *sin, const struct nlm_lock *lock)
+{
+	struct hlist_head *chain;
+	struct hlist_node *pos;
+	struct nlm_host	*host;
+	struct file_lock  *fl;
+	int		hash;
+
+	dprintk("lockd: nlmclnt_check_lock(%u.%u.%u.%u)\n",
+			NIPQUAD(sin->sin_addr.s_addr));
+
+	hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
+
+	/* Lock hash table */
+	mutex_lock(&nlm_host_mutex);
+
+	/* We must check all nlm_host objects for a peer, because the
+	 * callback does not provide protocol, version or other context.
+	 * When each peer is found, we scan for any matching granted lock.
+	 * Also check for a granted lock in the process of being reclaimed. */
+	chain = &nlm_hosts[hash];
+	hlist_for_each_entry(host, pos, chain, h_hash) {
+		if (!nlm_cmp_addr(&host->h_addr, sin))
+			continue;
+		list_for_each_entry(fl, &host->h_granted, fl_u.nfs_fl.list)
+			if (nlm_lock_match(lock, fl))
+				goto found;
+		list_for_each_entry(fl, &host->h_reclaim, fl_u.nfs_fl.list)
+			if (nlm_lock_match(lock, fl))
+				goto found;
+	}
+	fl = NULL;
+found:
+	mutex_unlock(&nlm_host_mutex);
+	return fl != NULL;
+}
+/*
  * Create the NLM RPC client for an NLM peer
  */
 struct rpc_clnt *

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
