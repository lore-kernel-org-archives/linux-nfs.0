From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Mon, 21 Jul 2008 12:49:49 +1000
Message-ID: <18563.63821.501053.402741@notabene.brown>
References: <18556.40594.897682.204554@notabene.brown>
	<76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
	<18559.53893.95829.499988@notabene.brown>
	<76bd70e30807190909n12b9f70an87ccb62198c3a7d@mail.gmail.com>
	<18562.57287.656749.540603@notabene.brown>
	<76bd70e30807201828t70d5b1d0m4c242c5c8864c3bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Chuck Lever" <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42822 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759923AbYGUCt6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Jul 2008 22:49:58 -0400
In-Reply-To: message from Chuck Lever on Sunday July 20
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sunday July 20, chucklever@gmail.com wrote:
> On Sun, Jul 20, 2008 at 2:48 AM, Neil Brown <neilb@suse.de> wrote:
> >
> > Any chance of pulling these out and sending them upstream now?  or is
> > the IPv6 series very close to release?
> 
> IPv6 is actively being worked on.  I expect all these will be
> available in the next 6 months.  However this specific set of patches
> is dependent on some extensive changes (like, a complete
> re-implementation of mount's portmap client).  Pulling them out now
> would be a lot of work and I'm not sure it's worth the distraction to
> the IPv6 effort, which essentially needed to be complete last month.

Fair enough....
Last month hasn't finished yet, has it?  That would be awkward.  There
is still lots to be done in June :-)

> 
> I've expected some problems in this area, and the only thing I can
> hope for is that people will diligently report problems.  If you have
> specific problems with the text-based implementation, I'd like to hear
> about them so we can clear them up as quickly as possible.  I never
> claimed that work is complete yet.

Just that "portmap doesn't respond to UDP" causes problems.

> 
> > I'd just like to get the regression fixed.
> 
> Me too.
> 
> Is it not sufficient to use connected UDP sockets in both user space
> and the kernel, and fix the kernel to return EPROTONOTSUPP where
> appropriate?

Well I just noticed that it is now "fixed" in the kernel by defaulting
"mount_server" to use TCP when "nfs_server" is using TCP.
 commit 259875efed06d6936f54c9a264e868937f1bc217

However I would like nfs-utils to work well with all released kernels
(or at least those release this millennium) where possible.  So while
a kernel fix is good, it isn't a panacea.

> 
> A healing balm for those who would like to use late model nfs-utils
> releases but don't want the hassle of the remaining bugs in the
> text-based mounts may be in order.  It would be easy to add a
> configure switch to use only the legacy ABI interface for mount.nfs.

While tempting, I don't think that is a good idea.  As you say, we
want people to report bugs.
Maybe if we had a switch to use the legacy ABI (the inverse of your
short-lived "-s") that might have helped.  But it is too late to
bother with that now I think.  'string options' mostly works and is
clearly the right way forward.  Let's go there.

How about this?
It always does "probe_bothports" before a mount so we get the retry
heuristics that are useful, but the probe_port does *not* ping the
actual service, as that can consume a precious reserved port, and
shouldn't be needed.

If mount still fails, try with a ping to get the old, thorough,
behaviour.

This goes on top of the patch to use connected UDP ports to talk to
portmap.

NeilBrown

>From 852424a9a02dbe1a7c3b75a014bc71cad2ab6d5e Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Mon, 21 Jul 2008 12:45:50 +1000
Subject: [PATCH] Check nfs options (vers/protocol) before trying mount.

As the kernels nfs-mount client does not have heuristics to pick the
best protocol/version, also check with portmap to find what is
available before requesting a mount.

However don't try to 'ping' the services.  For NFS, this ping would
need to come from a reserved port, and these are a scarce resource.

If the mount found, retry the probe doing any ping that might be
needed in the hope of finding the problem.

Note: this patch also removes the (recently added) setting of
mountport= in the mount arguments. This is because:
  1/ the kernel can find it easily itself
  2/ it could confuse unmount which may be run much later
      when mountd is running on a different port.


Signed-off-by: Neil Brown <neilb@suse.de>
---
 utils/mount/network.c  |   35 +++++++++++++++++++++--------------
 utils/mount/network.h  |    2 +-
 utils/mount/nfsmount.c |    2 +-
 utils/mount/stropts.c  |   18 +++++++-----------
 4 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index ff50512..e53bd53 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -500,9 +500,11 @@ static unsigned short getport(struct sockaddr_in *saddr,
  * Use the portmapper to discover whether or not the service we want is
  * available. The lists 'versions' and 'protos' define ordered sequences
  * of service versions and udp/tcp protocols to probe for.
+ * If 'ping' is set, set an RPC NULL request to make sure the service
+ * is there.  Else just assume that it is.
  */
 static int probe_port(clnt_addr_t *server, const unsigned long *versions,
-			const unsigned int *protos)
+			const unsigned int *protos, int ping)
 {
 	struct sockaddr_in *saddr = &server->saddr;
 	struct pmap *pmap = &server->pmap;
@@ -530,7 +532,8 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
 							_("UDP") : _("TCP"),
 						p_port);
                                 }
-				if (clnt_ping(saddr, prog, *p_vers, *p_prot, NULL))
+				if (!ping ||
+				    clnt_ping(saddr, prog, *p_vers, *p_prot, NULL))
 					goto out_ok;
 			}
 		}
@@ -567,7 +570,7 @@ out_ok:
 	return 1;
 }
 
-static int probe_nfsport(clnt_addr_t *nfs_server)
+static int probe_nfsport(clnt_addr_t *nfs_server, int ping)
 {
 	struct pmap *pmap = &nfs_server->pmap;
 
@@ -575,12 +578,14 @@ static int probe_nfsport(clnt_addr_t *nfs_server)
 		return 1;
 
 	if (nfs_mount_data_version >= 4)
-		return probe_port(nfs_server, probe_nfs3_first, probe_tcp_first);
+		return probe_port(nfs_server, probe_nfs3_first, probe_tcp_first,
+				  ping);
 	else
-		return probe_port(nfs_server, probe_nfs2_only, probe_udp_only);
+		return probe_port(nfs_server, probe_nfs2_only, probe_udp_only,
+				  ping);
 }
 
-static int probe_mntport(clnt_addr_t *mnt_server)
+static int probe_mntport(clnt_addr_t *mnt_server, int ping)
 {
 	struct pmap *pmap = &mnt_server->pmap;
 
@@ -588,9 +593,11 @@ static int probe_mntport(clnt_addr_t *mnt_server)
 		return 1;
 
 	if (nfs_mount_data_version >= 4)
-		return probe_port(mnt_server, probe_mnt3_first, probe_udp_first);
+		return probe_port(mnt_server, probe_mnt3_first, probe_udp_first,
+				  ping);
 	else
-		return probe_port(mnt_server, probe_mnt1_first, probe_udp_only);
+		return probe_port(mnt_server, probe_mnt1_first, probe_udp_only,
+				  ping);
 }
 
 /**
@@ -603,7 +610,7 @@ static int probe_mntport(clnt_addr_t *mnt_server)
  *
  * A side effect of calling this function is that rpccreateerr is set.
  */
-int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
+int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server, int ping)
 {
 	struct pmap *nfs_pmap = &nfs_server->pmap;
 	struct pmap *mnt_pmap = &mnt_server->pmap;
@@ -625,9 +632,9 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 
 	for (; *probe_vers; probe_vers++) {
 		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
-		if ((res = probe_nfsport(nfs_server) != 0)) {
+		if ((res = probe_nfsport(nfs_server, ping) != 0)) {
 			mnt_pmap->pm_vers = *probe_vers;
-			if ((res = probe_mntport(mnt_server)) != 0)
+			if ((res = probe_mntport(mnt_server, ping)) != 0)
 				return 1;
 			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
 		}
@@ -645,9 +652,9 @@ out_bad:
 	return 0;
 
 version_fixed:
-	if (!probe_nfsport(nfs_server))
+	if (!probe_nfsport(nfs_server, ping))
 		goto out_bad;
-	return probe_mntport(mnt_server);
+	return probe_mntport(mnt_server, ping);
 }
 
 static int probe_statd(void)
@@ -714,7 +721,7 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 	enum clnt_stat res = 0;
 	int msock;
 
-	if (!probe_mntport(mnt_server))
+	if (!probe_mntport(mnt_server, 0))
 		return 0;
 	clnt = mnt_openclnt(mnt_server, &msock);
 	if (!clnt)
diff --git a/utils/mount/network.h b/utils/mount/network.h
index a4dba1b..6c2013f 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -39,7 +39,7 @@ typedef struct {
 static const struct timeval TIMEOUT = { 20, 0 };
 static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
-int probe_bothports(clnt_addr_t *, clnt_addr_t *);
+int probe_bothports(clnt_addr_t *, clnt_addr_t *, int);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_name_to_address(const char *, const sa_family_t,
 		struct sockaddr *, socklen_t *);
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 6355681..905d61d 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -129,7 +129,7 @@ nfs_call_mount(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server,
 	enum clnt_stat stat;
 	int msock;
 
-	if (!probe_bothports(mnt_server, nfs_server))
+	if (!probe_bothports(mnt_server, nfs_server, 1))
 		goto out_bad;
 
 	clnt = mnt_openclnt(mnt_server, &msock);
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 09fca86..767d481 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -314,7 +314,7 @@ static int nfs_is_permanent_error(int error)
  * Returns a new group of mount options if successful; otherwise
  * NULL is returned if some failure occurred.
  */
-static struct mount_options *nfs_rewrite_mount_options(char *str)
+static struct mount_options *nfs_rewrite_mount_options(char *str, int ping)
 {
 	struct mount_options *options;
 	char *option, new_option[64];
@@ -405,7 +405,7 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 	po_remove_all(options, "tcp");
 	po_remove_all(options, "udp");
 
-	if (!probe_bothports(&mnt_server, &nfs_server)) {
+	if (!probe_bothports(&mnt_server, &nfs_server, ping)) {
 		errno = ESPIPE;
 		goto err;
 	}
@@ -441,11 +441,6 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 	if (po_append(options, new_option) == PO_FAILED)
 		goto err;
 
-	snprintf(new_option, sizeof(new_option) - 1,
-		 "mountport=%lu", mnt_server.pmap.pm_port);
-	if (po_append(options, new_option) == PO_FAILED)
-		goto err;
-
 	errno = 0;
 	return options;
 
@@ -486,13 +481,13 @@ static int nfs_sys_mount(const struct nfsmount_info *mi, const char *type,
  * 'extra_opts' are updated to reflect the mount options that worked.
  * If the retry fails, 'options' and 'extra_opts' are left unchanged.
  */
-static int nfs_retry_nfs23mount(struct nfsmount_info *mi)
+static int nfs_try_nfs23mount_probe(struct nfsmount_info *mi, int ping)
 {
 	struct mount_options *retry_options;
 	char *retry_str = NULL;
 	char **extra_opts = mi->extra_opts;
 
-	retry_options = nfs_rewrite_mount_options(*extra_opts);
+	retry_options = nfs_rewrite_mount_options(*extra_opts, ping);
 	if (!retry_options)
 		return 0;
 
@@ -547,7 +542,7 @@ static int nfs_try_nfs23mount(struct nfsmount_info *mi)
 	if (mi->fake)
 		return 1;
 
-	if (nfs_sys_mount(mi, "nfs", *extra_opts))
+	if (nfs_try_nfs23mount_probe(mi, 0))
 		return 1;
 
 	/*
@@ -557,7 +552,8 @@ static int nfs_try_nfs23mount(struct nfsmount_info *mi)
 	if (errno != EOPNOTSUPP && errno != EPROTONOSUPPORT)
 		return 0;
 
-	return nfs_retry_nfs23mount(mi);
+	/* Probe harder */
+	return nfs_try_nfs23mount_probe(mi, 1);
 }
 
 /*
-- 
1.5.6.3

