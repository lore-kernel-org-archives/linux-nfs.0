Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207Ab1BDVeo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:44 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 25/40] pnfs-submit: wave3 refactor dataserver client setup
Date: Fri,  4 Feb 2011 16:33:47 -0500
Message-Id: <1296855242-2592-26-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-25-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
 <1296855242-2592-25-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Follow nfs4_set_client convention.

Once a new nfs_client is on the nfs_client_list, the nfs_client cl_cons_state
serializes access to creating an nfs_client struct with matching properties.

Use the new nfs_get_client() that initializes new clients.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            |   48 +++++++++++++++++++++++++---
 fs/nfs/internal.h          |   13 ++------
 fs/nfs/nfs4filelayoutdev.c |   76 +++++++++++++-------------------------------
 3 files changed, 68 insertions(+), 69 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5cfcd40..9e07586 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -413,7 +413,7 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
  * Test if two socket addresses represent the same actual socket,
  * by comparing (only) relevant fields, including the port number.
  */
-int nfs_sockaddr_cmp(const struct sockaddr *sa1,
+static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 			    const struct sockaddr *sa2)
 {
 	if (sa1->sa_family != sa2->sa_family)
@@ -427,7 +427,6 @@ int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 	}
 	return 0;
 }
-EXPORT_SYMBOL(nfs_sockaddr_cmp);
 
 /* Common match routine for v4.0 and v4.1 callback services */
 bool
@@ -592,7 +591,6 @@ int nfs4_check_client_ready(struct nfs_client *clp)
 		return -EPROTONOSUPPORT;
 	return 0;
 }
-EXPORT_SYMBOL(nfs4_check_client_ready);
 
 /*
  * Initialise the timeout values for a connection
@@ -1379,7 +1377,7 @@ error:
 /*
  * Set up an NFS4 client
  */
-int nfs4_set_client(struct nfs_server *server,
+static int nfs4_set_client(struct nfs_server *server,
 		const char *hostname,
 		const struct sockaddr *addr,
 		const size_t addrlen,
@@ -1416,8 +1414,48 @@ error:
 	dprintk("<-- nfs4_set_client() = xerror %d\n", error);
 	return error;
 }
-EXPORT_SYMBOL(nfs4_set_client);
 
+/*
+ * Set up a pNFS Data Server client.
+ *
+ * Return any existing nfs_client that matches server address,port,version
+ * and minorversion.
+ *
+ * For a new nfs_client, use a soft mount (default), a low retrans and a
+ * low timeout interval so that if a connection is lost, we retry through
+ * the MDS.
+ */
+struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
+		const struct sockaddr *ds_addr,
+		int ds_addrlen, int ds_proto)
+{
+	struct nfs_client_initdata cl_init = {
+		.addr = ds_addr,
+		.addrlen = ds_addrlen,
+		.rpc_ops = &nfs_v4_clientops,
+		.proto = ds_proto,
+		.minorversion = mds_clp->cl_minorversion,
+	};
+	struct rpc_timeout ds_timeout = {
+		.to_initval = 15 * HZ,
+		.to_maxval = 15 * HZ,
+		.to_retries = 1,
+		.to_exponential = 1,
+	};
+	struct nfs_client *clp;
+
+	/*
+	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
+	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
+	 * (section 13.1 RFC 5661).
+	 */
+	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
+			     mds_clp->cl_rpcclient->cl_auth->au_flavor, 0);
+
+	dprintk("<-- %s %p\n", __func__, clp);
+	return clp;
+}
+EXPORT_SYMBOL(nfs4_set_ds_client);
 
 /*
  * Session has been established, and the client marked ready.
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5c156d3..764a235 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -148,16 +148,9 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fattr *);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern int nfs4_check_client_ready(struct nfs_client *clp);
-extern int nfs_sockaddr_cmp(const struct sockaddr *sa1,
-		const struct sockaddr *sa2);
-extern int nfs4_set_client(struct nfs_server *server,
-		const char *hostname,
-		const struct sockaddr *addr,
-		const size_t addrlen,
-		const char *ip_addr,
-		rpc_authflavor_t authflavour,
-		int proto, const struct rpc_timeout *timeparms,
-		u32 minorversion);
+extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
+					     const struct sockaddr *ds_addr,
+					     int ds_addrlen, int ds_proto);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index b1290ca..c46cb00 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -104,68 +104,43 @@ _data_server_lookup_locked(u32 ip_addr, u32 port)
 	return NULL;
 }
 
-/* Create an rpc to the data server defined in 'dev_list' */
+/*
+ * Create an rpc to the nfs4_pnfs_ds data server
+ * Currently only support IPv4
+ */
 static int
 nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 {
-	struct nfs_server	*tmp;
-	struct sockaddr_in	sin;
-	struct rpc_clnt		*mds_clnt = mds_srv->client;
-	struct nfs_client	*clp = mds_srv->nfs_client;
-	struct sockaddr		*mds_addr;
+	struct nfs_client *clp;
+	struct sockaddr_in sin;
 	int err = 0;
 
 	dprintk("--> %s ip:port %x:%hu au_flavor %d\n", __func__,
 		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
-		mds_clnt->cl_auth->au_flavor);
+		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
 
 	sin.sin_family = AF_INET;
 	sin.sin_addr.s_addr = ds->ds_ip_addr;
 	sin.sin_port = ds->ds_port;
 
-	/*
-	 * If this DS is also the MDS, use the MDS session only if the
-	 * MDS exchangeid flags show the EXCHGID4_FLAG_USE_PNFS_DS pNFS role.
-	 */
-	mds_addr = (struct sockaddr *)&clp->cl_addr;
-	if (nfs_sockaddr_cmp((struct sockaddr *)&sin, mds_addr)) {
+	clp = nfs4_set_ds_client(mds_srv->nfs_client, (struct sockaddr *)&sin,
+				 sizeof(sin), IPPROTO_TCP);
+	if (IS_ERR(clp)) {
+		err = PTR_ERR(clp);
+		goto out;
+	}
+
+	if ((clp->cl_exchange_flags & EXCHGID4_FLAG_MASK_PNFS) != 0) {
+		dprintk("%s [existing] ip=%x, port=%hu\n", __func__,
+			ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
+
 		if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
-			printk(KERN_INFO
-			       "ip:port %x:%hu is not a pNFS Data Server\n",
-			       ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
 			err = -ENODEV;
-		} else {
-			atomic_inc(&clp->cl_count);
-			ds->ds_clp = clp;
-			dprintk("%s Using MDS Session for DS\n", __func__);
+			goto out_put;
 		}
 		goto out;
 	}
 
-	/* Temporay server for nfs4_set_client */
-	tmp = kzalloc(sizeof(struct nfs_server), GFP_KERNEL);
-	if (!tmp)
-		goto out;
-
-	/*
-	 * Set a retrans, timeout interval, and authflavor equual to the MDS
-	 * values. Use the MDS nfs_client cl_ipaddr field so as to use the
-	 * same co_ownerid as the MDS.
-	 */
-	err = nfs4_set_client(tmp,
-			      mds_srv->nfs_client->cl_hostname,
-			      (struct sockaddr *)&sin,
-			      sizeof(struct sockaddr),
-			      mds_srv->nfs_client->cl_ipaddr,
-			      mds_clnt->cl_auth->au_flavor,
-			      IPPROTO_TCP,
-			      mds_clnt->cl_xprt->timeout,
-			      1 /* minorversion */);
-	if (err < 0)
-		goto out_free;
-
-	clp = tmp->nfs_client;
-
 	/* Ask for only the EXCHGID4_FLAG_USE_PNFS_DS pNFS role */
 	dprintk("%s EXCHANGE_ID for clp %p\n", __func__, clp);
 	clp->cl_exchange_flags = EXCHGID4_FLAG_USE_PNFS_DS;
@@ -177,8 +152,6 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 		goto out_put;
 
 	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
-		printk(KERN_INFO "ip:port %x:%hu is not a pNFS Data Server\n",
-		       ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
 		err = -ENODEV;
 		goto out_put;
 	}
@@ -191,20 +164,15 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	spin_unlock(&mds_srv->nfs_client->cl_lock);
 	clp->cl_last_renewal = jiffies;
 
-	clear_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
 	ds->ds_clp = clp;
 
-	dprintk("%s: ip=%x, port=%hu, rpcclient %p\n", __func__,
-				ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
-				clp->cl_rpcclient);
-out_free:
-	kfree(tmp);
+	dprintk("%s [new] ip=%x, port=%hu\n", __func__, ntohl(ds->ds_ip_addr),
+		ntohs(ds->ds_port));
 out:
-	dprintk("%s Returns %d\n", __func__, err);
 	return err;
 out_put:
 	nfs_put_client(clp);
-	goto out_free;
+	goto out;
 }
 
 static void
-- 
1.6.6

