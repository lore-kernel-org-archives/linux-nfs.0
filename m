From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 19] knfsd: lockd: introduce nsm_handle
Date: Fri, 1 Sep 2006 14:38:25 +1000
Message-ID: <1060901043825.27464@suse.de>
References: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0nc-0005lA-0t
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:38:36 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0nb-0004IH-IC
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:38:36 -0700
To: Andrew Morton <akpm@osdl.org>
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


From: Olaf Kirch <okir@suse.de>

  This patch introduces the nsm_handle, which is shared by
  all nlm_host objects referring to the same client.

  With this patch applied, all nlm_hosts from the same address
  will share the same nsm_handle. A future patch will add sharing
  by name.

  Note: this patch changes h_name so that it is no longer guaranteed
  to be an IP address of the host.  When the host represents an NFS server,
  h_name will be the name passed in the mount call.  When the host
  represents a client, h_name will be the name presented in the lock
  request received from the client.  A h_name is only used for printing
  informational messages, this change should not be significant.

Signed-off-by: Olaf Kirch <okir@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/clntlock.c         |    3 -
 ./fs/lockd/host.c             |  121 ++++++++++++++++++++++++++++++++++++++----
 ./fs/lockd/mon.c              |   14 +++-
 ./include/linux/lockd/lockd.h |   17 ++++-
 4 files changed, 136 insertions(+), 19 deletions(-)

diff .prev/fs/lockd/clntlock.c ./fs/lockd/clntlock.c
--- .prev/fs/lockd/clntlock.c	2006-08-31 16:44:23.000000000 +1000
+++ ./fs/lockd/clntlock.c	2006-08-31 17:00:03.000000000 +1000
@@ -150,7 +150,8 @@ u32 nlmclnt_grant(const struct sockaddr_
 static void nlmclnt_prepare_reclaim(struct nlm_host *host)
 {
 	down_write(&host->h_rwsem);
-	host->h_monitored = 0;
+	if (host->h_nsmhandle)
+		host->h_nsmhandle->sm_monitored = 0;
 	host->h_state++;
 	host->h_nextrebind = 0;
 	nlm_rebind_host(host);

diff .prev/fs/lockd/host.c ./fs/lockd/host.c
--- .prev/fs/lockd/host.c	2006-08-31 16:23:12.000000000 +1000
+++ ./fs/lockd/host.c	2006-08-31 17:00:03.000000000 +1000
@@ -34,6 +34,8 @@ static DEFINE_MUTEX(nlm_host_mutex);
 
 
 static void			nlm_gc_hosts(void);
+static struct nsm_handle *	__nsm_find(const struct sockaddr_in *,
+					const char *, int, int);
 
 /*
  * Find an NLM server handle in the cache. If there is none, create it.
@@ -68,7 +70,7 @@ nlm_lookup_host(int server, const struct
 					int hostname_len)
 {
 	struct nlm_host	*host, **hp;
-	u32		addr;
+	struct nsm_handle *nsm = NULL;
 	int		hash;
 
 	dprintk("lockd: nlm_lookup_host(%u.%u.%u.%u, p=%d, v=%d, my role=%s, name=%.*s)\n",
@@ -86,7 +88,21 @@ nlm_lookup_host(int server, const struct
 	if (time_after_eq(jiffies, next_gc))
 		nlm_gc_hosts();
 
+	/* We may keep several nlm_host objects for a peer, because each
+	 * nlm_host is identified by
+	 * (address, protocol, version, server/client)
+	 * We could probably simplify this a little by putting all those
+	 * different NLM rpc_clients into one single nlm_host object.
+	 * This would allow us to have one nlm_host per address.
+	 */
 	for (hp = &nlm_hosts[hash]; (host = *hp) != 0; hp = &host->h_next) {
+		if (!nlm_cmp_addr(&host->h_addr, sin))
+			continue;
+
+		/* See if we have an NSM handle for this client */
+		if (!nsm && (nsm = host->h_nsmhandle) != 0)
+			atomic_inc(&nsm->sm_count);
+
 		if (host->h_proto != proto)
 			continue;
 		if (host->h_version != version)
@@ -94,7 +110,7 @@ nlm_lookup_host(int server, const struct
 		if (host->h_server != server)
 			continue;
 
-		if (nlm_cmp_addr(&host->h_addr, sin)) {
+		{
 			if (hp != nlm_hosts + hash) {
 				*hp = host->h_next;
 				host->h_next = nlm_hosts[hash];
@@ -106,16 +122,18 @@ nlm_lookup_host(int server, const struct
 		}
 	}
 
-	/* Ooops, no host found, create it */
-	dprintk("lockd: creating host entry\n");
+	/* Sadly, the host isn't in our hash table yet. See if
+	 * we have an NSM handle for it. If not, create one.
+	 */
+	if (!nsm && !(nsm = nsm_find(sin, hostname, hostname_len)))
+		goto out;
 
 	host = kzalloc(sizeof(*host), GFP_KERNEL);
-	if (!host)
-		goto nohost;
-
-	addr = sin->sin_addr.s_addr;
-	sprintf(host->h_name, "%u.%u.%u.%u", NIPQUAD(addr));
-
+	if (!host) {
+		nsm_release(nsm);
+		goto out;
+	}
+	host->h_name	   = nsm->sm_name;
 	host->h_addr       = *sin;
 	host->h_addr.sin_port = 0;	/* ouch! */
 	host->h_version    = version;
@@ -129,6 +147,7 @@ nlm_lookup_host(int server, const struct
 	init_rwsem(&host->h_rwsem);
 	host->h_state      = 0;			/* pseudo NSM state */
 	host->h_nsmstate   = 0;			/* real NSM state */
+	host->h_nsmhandle  = nsm;
 	host->h_server	   = server;
 	host->h_next       = nlm_hosts[hash];
 	nlm_hosts[hash]    = host;
@@ -140,7 +159,7 @@ nlm_lookup_host(int server, const struct
 	if (++nrhosts > NLM_HOST_MAX)
 		next_gc = 0;
 
-nohost:
+out:
 	mutex_unlock(&nlm_host_mutex);
 	return host;
 }
@@ -393,3 +412,83 @@ nlm_gc_hosts(void)
 	next_gc = jiffies + NLM_HOST_COLLECT;
 }
 
+
+/*
+ * Manage NSM handles
+ */
+static LIST_HEAD(nsm_handles);
+static DECLARE_MUTEX(nsm_sema);
+
+static struct nsm_handle *
+__nsm_find(const struct sockaddr_in *sin,
+		const char *hostname, int hostname_len,
+		int create)
+{
+	struct nsm_handle *nsm = NULL;
+	struct list_head *pos;
+
+	if (!sin)
+		return NULL;
+
+	if (hostname && memchr(hostname, '/', hostname_len) != NULL) {
+		if (printk_ratelimit()) {
+			printk(KERN_WARNING "Invalid hostname \"%.*s\" "
+					    "in NFS lock request\n",
+				hostname_len, hostname);
+		}
+		return NULL;
+	}
+
+	down(&nsm_sema);
+	list_for_each(pos, &nsm_handles) {
+		nsm = list_entry(pos, struct nsm_handle, sm_link);
+
+		if (!nlm_cmp_addr(&nsm->sm_addr, sin))
+			continue;
+		atomic_inc(&nsm->sm_count);
+		goto out;
+	}
+
+	if (!create) {
+		nsm = NULL;
+		goto out;
+	}
+
+	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
+	if (nsm != NULL) {
+		nsm->sm_addr = *sin;
+		nsm->sm_name = (char *) (nsm + 1);
+		memcpy(nsm->sm_name, hostname, hostname_len);
+		nsm->sm_name[hostname_len] = '\0';
+		atomic_set(&nsm->sm_count, 1);
+
+		list_add(&nsm->sm_link, &nsm_handles);
+	}
+
+out:	up(&nsm_sema);
+	return nsm;
+}
+
+struct nsm_handle *
+nsm_find(const struct sockaddr_in *sin, const char *hostname, int hostname_len)
+{
+	return __nsm_find(sin, hostname, hostname_len, 1);
+}
+
+/*
+ * Release an NSM handle
+ */
+void
+nsm_release(struct nsm_handle *nsm)
+{
+	if (!nsm)
+		return;
+	if (atomic_read(&nsm->sm_count) == 1) {
+		down(&nsm_sema);
+		if (atomic_dec_and_test(&nsm->sm_count)) {
+			list_del(&nsm->sm_link);
+			kfree(nsm);
+		}
+		up(&nsm_sema);
+	}
+}

diff .prev/fs/lockd/mon.c ./fs/lockd/mon.c
--- .prev/fs/lockd/mon.c	2006-08-31 16:12:30.000000000 +1000
+++ ./fs/lockd/mon.c	2006-08-31 17:00:03.000000000 +1000
@@ -70,11 +70,14 @@ nsm_mon_unmon(struct nlm_host *host, u32
 int
 nsm_monitor(struct nlm_host *host)
 {
+	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
 	int		status;
 
 	dprintk("lockd: nsm_monitor(%s)\n", host->h_name);
-	if (host->h_monitored)
+	BUG_ON(nsm == NULL);
+
+	if (nsm->sm_monitored)
 		return 0;
 
 	status = nsm_mon_unmon(host, SM_MON, &res);
@@ -82,7 +85,7 @@ nsm_monitor(struct nlm_host *host)
 	if (status < 0 || res.status != 0)
 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", host->h_name);
 	else
-		host->h_monitored = 1;
+		nsm->sm_monitored = 1;
 	return status;
 }
 
@@ -92,19 +95,22 @@ nsm_monitor(struct nlm_host *host)
 int
 nsm_unmonitor(struct nlm_host *host)
 {
+	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
 	int		status = 0;
 
 	dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
-	if (!host->h_monitored)
+	if (nsm == NULL)
 		return 0;
-	host->h_monitored = 0;
+	host->h_nsmhandle = NULL;
 
 	if (!host->h_killed) {
 		status = nsm_mon_unmon(host, SM_UNMON, &res);
 		if (status < 0)
 			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n", host->h_name);
+		nsm->sm_monitored = 0;
 	}
+	nsm_release(nsm);
 	return status;
 }
 

diff .prev/include/linux/lockd/lockd.h ./include/linux/lockd/lockd.h
--- .prev/include/linux/lockd/lockd.h	2006-08-31 16:23:12.000000000 +1000
+++ ./include/linux/lockd/lockd.h	2006-08-31 17:00:03.000000000 +1000
@@ -40,14 +40,13 @@ struct nlm_host {
 	struct nlm_host *	h_next;		/* linked list (hash table) */
 	struct sockaddr_in	h_addr;		/* peer address */
 	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
-	char			h_name[20];	/* remote hostname */
+	char *			h_name;		/* remote hostname */
 	u32			h_version;	/* interface version */
 	unsigned short		h_proto;	/* transport proto */
 	unsigned short		h_reclaiming : 1,
 				h_server     : 1, /* server side, not client side */
 				h_inuse      : 1,
-				h_killed     : 1,
-				h_monitored  : 1;
+				h_killed     : 1;
 	wait_queue_head_t	h_gracewait;	/* wait while reclaiming */
 	struct rw_semaphore	h_rwsem;	/* Reboot recovery lock */
 	u32			h_state;	/* pseudo-state counter */
@@ -61,6 +60,16 @@ struct nlm_host {
 	spinlock_t		h_lock;
 	struct list_head	h_granted;	/* Locks in GRANTED state */
 	struct list_head	h_reclaim;	/* Locks in RECLAIM state */
+	struct nsm_handle *	h_nsmhandle;	/* NSM status handle */
+};
+
+struct nsm_handle {
+	struct list_head	sm_link;
+	atomic_t		sm_count;
+	char *			sm_name;
+	struct sockaddr_in	sm_addr;
+	unsigned int		sm_monitored : 1,
+				sm_sticky : 1;	/* don't unmonitor */
 };
 
 /*
@@ -171,6 +180,8 @@ void		  nlm_release_host(struct nlm_host
 void		  nlm_shutdown_hosts(void);
 extern struct nlm_host *nlm_find_client(void);
 extern void	  nlm_host_rebooted(const struct sockaddr_in *, const struct nlm_reboot *);
+struct nsm_handle *nsm_find(const struct sockaddr_in *, const char *, int);
+void		  nsm_release(struct nsm_handle *);
 
 
 /*

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
