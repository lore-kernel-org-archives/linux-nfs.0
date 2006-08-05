From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 15/22] lockd: optionally use hostnames for identifying
	peers
Date: Sat, 5 Aug 2006 15:06:48 +0200
Message-ID: <20060805130648.GA8092@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrm-00079r-RN
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:58 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lrm-0003MZ-EG
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:59 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id E20AF1FFD7
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:48 +0200 (CEST)
To: nfs@lists.sourceforge.net
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
Subject: lockd: optionally use hostnames for identifying peers

  This patch adds the nsm_use_hostnames sysctl. If set, lockd will use
  the client's name (as given in the NLM arguments) to find the NSM
  handle. This makes recovery work when the NFS peer is multi-homed, and
  the reboot notification arrives from a different IP than the original
  lock calls.

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/host.c                |    5 +++++
 fs/lockd/mon.c                 |   12 +++++++++---
 fs/lockd/svc.c                 |    9 +++++++++
 include/linux/lockd/lockd.h    |    1 +
 include/linux/lockd/sm_inter.h |    2 ++
 5 files changed, 26 insertions(+), 3 deletions(-)

Index: build/fs/lockd/host.c
===================================================================
--- build.orig/fs/lockd/host.c
+++ build/fs/lockd/host.c
@@ -498,6 +498,11 @@ __nsm_find(const struct sockaddr_in *sin
 	list_for_each(pos, &nsm_handles) {
 		nsm = list_entry(pos, struct nsm_handle, sm_link);
 
+		if (hostname && nsm_use_hostnames) {
+			if (strlen(nsm->sm_name) != hostname_len
+			 || memcmp(nsm->sm_name, hostname, hostname_len))
+				continue;
+		} else
 		if (!nlm_cmp_addr(&nsm->sm_addr, sin))
 			continue;
 		atomic_inc(&nsm->sm_count);
Index: build/fs/lockd/mon.c
===================================================================
--- build.orig/fs/lockd/mon.c
+++ build/fs/lockd/mon.c
@@ -47,6 +47,7 @@ nsm_mon_unmon(struct nsm_handle *nsm, u3
 	}
 
 	memset(&args, 0, sizeof(args));
+	args.mon_name = nsm->sm_name;
 	args.addr = nsm->sm_addr.sin_addr.s_addr;
 	args.prog = NLM_PROGRAM;
 	args.vers = 3;
@@ -157,7 +158,7 @@ out_err:
 static u32 *
 xdr_encode_common(struct rpc_rqst *rqstp, u32 *p, struct nsm_args *argp)
 {
-	char	buffer[20];
+	char	buffer[20], *name;
 
 	/*
 	 * Use the dotted-quad IP address of the remote host as
@@ -165,8 +166,13 @@ xdr_encode_common(struct rpc_rqst *rqstp
 	 * hostname first for whatever remote hostname it receives,
 	 * so this works alright.
 	 */
-	sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(argp->addr));
-	if (!(p = xdr_encode_string(p, buffer))
+	if (nsm_use_hostnames) {
+		name = argp->mon_name;
+	} else {
+		sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(argp->addr));
+		name = buffer;
+	}
+	if (!(p = xdr_encode_string(p, name))
 	 || !(p = xdr_encode_string(p, system_utsname.nodename)))
 		return ERR_PTR(-EIO);
 	*p++ = htonl(argp->prog);
Index: build/fs/lockd/svc.c
===================================================================
--- build.orig/fs/lockd/svc.c
+++ build/fs/lockd/svc.c
@@ -60,6 +60,7 @@ static unsigned long		nlm_grace_period;
 static unsigned long		nlm_timeout = LOCKD_DFLT_TIMEO;
 static int			nlm_udpport, nlm_tcpport;
 int				nlm_max_hosts = 256;
+int				nsm_use_hostnames = 0;
 
 /*
  * Constants needed for the sysctl interface.
@@ -376,6 +377,14 @@ static ctl_table nlm_sysctls[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nsm_use_hostnames",
+		.data		= &nsm_use_hostnames,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 
 	{ .ctl_name = 0 }
 };
Index: build/include/linux/lockd/lockd.h
===================================================================
--- build.orig/include/linux/lockd/lockd.h
+++ build/include/linux/lockd/lockd.h
@@ -144,6 +144,7 @@ extern struct svc_procedure	nlmsvc_proce
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
 extern int			nlm_max_hosts;
+extern int			nsm_use_hostnames;
 
 /*
  * Lockd client functions
Index: build/include/linux/lockd/sm_inter.h
===================================================================
--- build.orig/include/linux/lockd/sm_inter.h
+++ build/include/linux/lockd/sm_inter.h
@@ -28,6 +28,8 @@ struct nsm_args {
 	u32		prog;		/* RPC callback info */
 	u32		vers;
 	u32		proc;
+
+	char *		mon_name;
 };
 
 /*

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
