From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 17:17:30 -0400
Message-ID: <1248211050.21343.38.camel@heimdal.trondhjem.org>
References: <4A64EB1F.4000602@candelatech.com>
	 <1248178527.5222.0.camel@heimdal.trondhjem.org>
	 <4A65F184.5060802@candelatech.com>
	 <1248196339.21343.8.camel@heimdal.trondhjem.org>
	 <4A65FCB2.6080903@candelatech.com>
	 <1248199140.21343.17.camel@heimdal.trondhjem.org>
	 <4A660295.9020807@candelatech.com>
	 <1248200897.21343.19.camel@heimdal.trondhjem.org>
	 <4A6609A9.3000504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756196AbZGUVRi@vger.kernel.org>
In-Reply-To: <4A6609A9.3000504@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-07-21 at 11:32 -0700, Ben Greear wrote:
> On 07/21/2009 11:28 AM, Trond Myklebust wrote:
> > On Tue, 2009-07-21 at 11:01 -0700, Ben Greear wrote:
> >> On 07/21/2009 10:59 AM, Trond Myklebust wrote:
> >>> On Tue, 2009-07-21 at 10:36 -0700, Ben Greear wrote:
> >>>> On 07/21/2009 10:12 AM, Trond Myklebust wrote:
> >>>>> On Tue, 2009-07-21 at 09:49 -0700, Ben Greear wrote:
> >>>>>> On 07/21/2009 05:15 AM, Trond Myklebust wrote:
> >>>>>>
> >>>>>>> What does /var/lib/nfs/v4recovery look like on the server?
> >>>>>> The server was misconfigured, but I still think the client should
> >>>>>> behave better in this case.  If you cannot reproduce it, let me know
> >>>>>> and I can try to be more specific.  If you still want the v4recovery
> >>>>>> information, let me know and I'll send it.
> >>>>> So how should the client behave, when a screwed up server allows it to
> >>>>> mount but starts returning illegal values for setclientid? The only
> >>>>> thing I can see we could do is to tell the user EINSANESERVER...
> >>>> Well, it could just fail the mount and give up and not overly spam
> >>>> /var/log/messages in a tight loop perhaps?
> >>> This doesn't happen at mount time. It happens when you open a file.
> >> Not for me, and evidently not for the other person that reported
> >> similar results.  All I had to do was attempt the mount (which never
> >> completed).
> >>
> >> Thanks,
> >> Ben
> >
> > Ah... You have NFS_V4_1 enabled despite the Kconfig warning... Does the
> > bug occur when you turn this off too?
> 
> Yes, it did.

OK. The following patch should fix that particular regression.

Note that there is a bug remaining inside nfs4_init_session(): we
shouldn't be copying the rsize/wsize into the nfs_client if the latter
was already initialised. I'm going to leave that for the moment, though,
since that bug wasn't introduced by my patch, and it doesn't affect
NFSv4.0.

Cheers,
  Trond
-----------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
NFSv4: Fix an NFSv4 mount regression

Commit 008f55d0e019943323c20a03493a2ba5672a4cc8 (nfs41: recover lease in
_nfs4_lookup_root) forces the state manager to always run on mount. This is
a bug in the case of NFSv4.0, which doesn't require us to send a
setclientid until we want to grab file state.

In any case, this is completely the wrong place to be doing state
management. Moving that code into nfs4_init_session...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c   |   18 +++---------------
 fs/nfs/nfs4_fs.h  |    6 ++++++
 fs/nfs/nfs4proc.c |   24 +++++++++++++++++-------
 3 files changed, 26 insertions(+), 22 deletions(-)


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c2d0616..8d25ccb 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1242,20 +1242,6 @@ error:
 	return error;
 }
 
-/*
- * Initialize a session.
- * Note: save the mount rsize and wsize for create_server negotiation.
- */
-static void nfs4_init_session(struct nfs_client *clp,
-			      unsigned int wsize, unsigned int rsize)
-{
-#if defined(CONFIG_NFS_V4_1)
-	if (nfs4_has_session(clp)) {
-		clp->cl_session->fc_attrs.max_rqst_sz = wsize;
-		clp->cl_session->fc_attrs.max_resp_sz = rsize;
-	}
-#endif /* CONFIG_NFS_V4_1 */
-}
 
 /*
  * Session has been established, and the client marked ready.
@@ -1350,7 +1336,9 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	BUG_ON(!server->nfs_client->rpc_ops);
 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
 
-	nfs4_init_session(server->nfs_client, server->wsize, server->rsize);
+	error = nfs4_init_session(server);
+	if (error < 0)
+		goto error;
 
 	/* Probe the root fh to retrieve its FSID */
 	error = nfs4_path_walk(server, mntfh, data->nfs_server.export_path);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 61bc3a3..6ea07a3 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -220,6 +220,7 @@ extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
 extern int nfs4_proc_create_session(struct nfs_client *, int reset);
 extern int nfs4_proc_destroy_session(struct nfs4_session *);
+extern int nfs4_init_session(struct nfs_server *server);
 #else /* CONFIG_NFS_v4_1 */
 static inline int nfs4_setup_sequence(struct nfs_client *clp,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
@@ -227,6 +228,11 @@ static inline int nfs4_setup_sequence(struct nfs_client *clp,
 {
 	return 0;
 }
+
+static inline int nfs4_init_session(struct nfs_server *server)
+{
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 extern struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff0c080..df24f67 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2040,15 +2040,9 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	int status;
 
 	nfs_fattr_init(info->fattr);
-	status = nfs4_recover_expired_lease(server);
-	if (!status)
-		status = nfs4_check_client_ready(server->nfs_client);
-	if (!status)
-		status = nfs4_call_sync(server, &msg, &args, &res, 0);
-	return status;
+	return nfs4_call_sync(server, &msg, &args, &res, 0);
 }
 
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -4793,6 +4787,22 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 	return status;
 }
 
+int nfs4_init_session(struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+	int ret;
+
+	if (!nfs4_has_session(clp))
+		return 0;
+
+	clp->cl_session->fc_attrs.max_rqst_sz = server->wsize;
+	clp->cl_session->fc_attrs.max_resp_sz = server->rsize;
+	ret = nfs4_recover_expired_lease(server);
+	if (!ret)
+		ret = nfs4_check_client_ready(clp);
+	return ret;
+}
+
 /*
  * Renew the cl_session lease.
  */
