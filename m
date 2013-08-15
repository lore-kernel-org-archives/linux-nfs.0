Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48686 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758072Ab3HOOTU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Aug 2013 10:19:20 -0400
Date: Thu, 15 Aug 2013 10:19:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Jan Stancek <jstancek@redhat.com>, linux-nfs@vger.kernel.org,
        bfields@redhat.com, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: fix NFSv3 with sec=krb5 and CONFIG_NFS_V3_ACL=y
Message-ID: <20130815141917.GR17781@fieldses.org>
References: <682ebd8ecc7309b18396da356a0feb38bfa41674.1372692346.git.jstancek@redhat.com>
 <20130708201643.GI29071@fieldses.org>
 <1157529877.873319.1373353194344.JavaMail.root@redhat.com>
 <20130726220924.GG30651@fieldses.org>
 <20130815100244.370de645@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130815100244.370de645@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 15, 2013 at 10:02:44AM -0400, Jeff Layton wrote:
> On Fri, 26 Jul 2013 18:09:24 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Tue, Jul 09, 2013 at 02:59:54AM -0400, Jan Stancek wrote:
> > > 
> > > 
> > > 
> > > 
> > > ----- Original Message -----
> > > > From: "J. Bruce Fields" <bfields@fieldses.org>
> > > > To: "Jan Stancek" <jstancek@redhat.com>
> > > > Cc: linux-nfs@vger.kernel.org, bfields@redhat.com, "Trond Myklebust" <Trond.Myklebust@netapp.com>
> > > > Sent: Monday, 8 July, 2013 10:16:43 PM
> > > > Subject: Re: [PATCH] NFS: fix NFSv3 with sec=krb5 and CONFIG_NFS_V3_ACL=y
> > > > 
> > > > On Mon, Jul 01, 2013 at 05:32:34PM +0200, Jan Stancek wrote:
> > > > > Starting with commit:
> > > > >   commit f994c43d19a9116727d4c228d3f13db595bff562
> > > > >   Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > >   Date:   Thu Nov 1 12:14:14 2012 -0400
> > > > >       SUNRPC: Clean up rpc_bind_new_program
> > > > > 
> > > > > operations on directory mounted with -onfsvers=3,tcp,sec=krb5 fail
> > > > > with Input/Output error after ~60 second timeout. This is presumably
> > > > > because upcalls for 'nfsacl' are not getting anywhere.
> > > > > 
> > > > > This patch enables pipe dir for nfsacl_program and changes its name
> > > > > to 'nfs'. This name will be used in upcalls and whole setup should
> > > > > work as it did in past - just with nfs/hostname principal.
> > > > 
> > > > I think this was the problem that nfs-utils commits
> > > > 
> > > > 	a1f8afc560 gssd: Remove insane sanity checks of the service name
> > > > 	a56989b665 gssd: Handle the target name correctly
> > > > 
> > > > were supposed to fix?
> > > > 
> > > > But perhaps the kernel needs a fix too to fix a regression with old
> > > > userspace.
> > > 
> > > I saw this error with nfs-utils.1.2.9-rc1, which should already contain
> > > those 2 commits.
> > 
> > Actually, I think your patch is just a subset of Trond's
> > http://mid.gmane.org/<4FA345DA4F4AE44899BD2B03EEEC2FA9092EC392@SACEXCMBX04-PRD.hq.netapp.com>
> > 
> > Trond, is there a reason that never got applied?
> > 
> > --b.
> > 
> 
> Hmm...gmane just says "No such article" when I feed it the above URL.
> Do you know what the title of the email was?

Argh sorry hadn't noticed that was private mail.

Last I checked actually neither of these patches fixed v3/krb5 for me.

--b.

Here is v2 with appropriate service names for mountd, statd, etc.


8<---------------------------------------------------------------
>From dc26f423d25db3c72922b3a6e53abf22022a7238 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sat, 17 Nov 2012 10:53:16 -0500
Subject: [PATCH v2] SUNRPC: Ensure that the RPCSEC_GSS daemon uses the
 correct service names

Fix the upcalls to use the right service names for gssd.
The old version of the rpc.gssd upcall expects the service name to
be either "nfs" or "nfs4_cb", which it will then concatenate with
the server name to create a target name of nfs@<server> or
nfs4_cb@<server>

If the kernel is using the new 'v1' upcall, rpc.gssd expects the
"target=" argument to be in the form <service>@<server>, while
we're currently sending just the server name. Fix that...

Finally, make sure that we set the correct service names for lockd,
statd and mountd in case we want to convert those to use rpcsec_gss
at some point in the future.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/lockd/clntxdr.c             | 1 +
 fs/lockd/mon.c                 | 1 +
 fs/nfs/client.c                | 1 +
 fs/nfs/mount_clnt.c            | 1 +
 fs/nfs/nfs3client.c            | 1 +
 fs/nfsd/nfs4callback.c         | 1 +
 include/linux/sunrpc/clnt.h    | 1 +
 net/sunrpc/auth_gss/auth_gss.c | 4 +++-
 net/sunrpc/rpc_pipe.c          | 3 ++-
 9 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index 982d267..b742ebc 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -620,6 +620,7 @@ static struct rpc_stat		nlm_rpc_stats;
 
 const struct rpc_program	nlm_program = {
 		.name		= "lockd",
+		.service_name	= "nlockmgr",
 		.number		= NLM_PROGRAM,
 		.nrvers		= ARRAY_SIZE(nlm_versions),
 		.version	= nlm_versions,
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 3d7e09b..f90f216 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -608,6 +608,7 @@ static struct rpc_stat		nsm_stats;
 
 static const struct rpc_program nsm_program = {
 		.name		= "statd",
+		.service_name	= "status",
 		.number		= NSM_PROGRAM,
 		.nrvers		= ARRAY_SIZE(nsm_version),
 		.version	= nsm_version,
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8b39a42..19ff341 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -72,6 +72,7 @@ static const struct rpc_version *nfs_version[5] = {
 
 const struct rpc_program nfs_program = {
 	.name			= "nfs",
+	.service_name		= "nfs",
 	.number			= NFS_PROGRAM,
 	.nrvers			= ARRAY_SIZE(nfs_version),
 	.version		= nfs_version,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 015f71f..cdad1f0 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -511,6 +511,7 @@ static struct rpc_stat mnt_stats;
 
 static const struct rpc_program mnt_program = {
 	.name		= "mount",
+	.service_name	= "mountd",
 	.number		= NFS_MNT_PROGRAM,
 	.nrvers		= ARRAY_SIZE(mnt_version),
 	.version	= mnt_version,
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index b3fc65e..20b3693 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -10,6 +10,7 @@ static const struct rpc_version *nfsacl_version[] = {
 
 const struct rpc_program nfsacl_program = {
 	.name			= "nfsacl",
+	.service_name		= "nfs",
 	.number			= NFS_ACL_PROGRAM,
 	.nrvers			= ARRAY_SIZE(nfsacl_version),
 	.version		= nfsacl_version,
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index bdf29c9..6e3c9f1 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -618,6 +618,7 @@ static struct rpc_stat cb_stats = {
 #define NFS4_CALLBACK 0x40000000
 static const struct rpc_program cb_program = {
 	.name			= "nfs4_cb",
+	.service_name		= "nfs4_cb",
 	.number			= NFS4_CALLBACK,
 	.nrvers			= ARRAY_SIZE(nfs_cb_version),
 	.version		= nfs_cb_version,
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 34206b8..d1e4f09 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -70,6 +70,7 @@ struct rpc_clnt {
 #define RPC_MAXVERSION		4
 struct rpc_program {
 	const char *		name;		/* protocol name */
+	const char *		service_name;	/* protocol service name */
 	u32			number;		/* program number */
 	unsigned int		nrvers;		/* number of versions */
 	const struct rpc_version **	version;	/* version array */
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 909dc0c..b19dab8 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -403,7 +403,9 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 				   gss_msg->uid);
 	p += gss_msg->msg.len;
 	if (clnt->cl_principal) {
-		len = sprintf(p, "target=%s ", clnt->cl_principal);
+		len = sprintf(p, "target=%s@%s ",
+				clnt->cl_program->service_name,
+				clnt->cl_principal);
 		p += len;
 		gss_msg->msg.len += len;
 	}
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index e659def..078bc9b 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -406,7 +406,8 @@ rpc_show_info(struct seq_file *m, void *v)
 	rcu_read_lock();
 	seq_printf(m, "RPC server: %s\n",
 			rcu_dereference(clnt->cl_xprt)->servername);
-	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_protname,
+	seq_printf(m, "service: %s (%d) version %d\n",
+			clnt->cl_program->service_name,
 			clnt->cl_prog, clnt->cl_vers);
 	seq_printf(m, "address: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR));
 	seq_printf(m, "protocol: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_PROTO));
-- 
1.7.11.7


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
