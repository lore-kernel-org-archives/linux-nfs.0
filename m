From: NeilBrown <neilb@suse.de>
Subject: [PATCH 014 of 19] knfsd: lockd: optionally use hostnames for
	identifying peers
Date: Fri, 1 Sep 2006 14:39:22 +1000
Message-ID: <1060901043922.27606@suse.de>
References: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0oU-0005uZ-LE
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:30 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0oU-0001VI-JZ
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:31 -0700
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

  This patch adds the nsm_use_hostnames sysctl and module param. If
  set, lockd will use the client's name (as given in the NLM
  arguments) to find the NSM handle. This makes recovery work when the
  NFS peer is multi-homed, and the reboot notification arrives from a
  different IP than the original lock calls.

Signed-off-by: Olaf Kirch <okir@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/host.c                |    6 +++++-
 ./fs/lockd/mon.c                 |   12 +++++++++---
 ./fs/lockd/svc.c                 |   10 ++++++++++
 ./include/linux/lockd/lockd.h    |    1 +
 ./include/linux/lockd/sm_inter.h |    2 ++
 5 files changed, 27 insertions(+), 4 deletions(-)

diff .prev/fs/lockd/host.c ./fs/lockd/host.c
--- .prev/fs/lockd/host.c	2006-09-01 12:11:07.000000000 +1000
+++ ./fs/lockd/host.c	2006-09-01 12:11:16.000000000 +1000
@@ -462,7 +462,11 @@ __nsm_find(const struct sockaddr_in *sin
 	list_for_each(pos, &nsm_handles) {
 		nsm = list_entry(pos, struct nsm_handle, sm_link);
 
-		if (!nlm_cmp_addr(&nsm->sm_addr, sin))
+		if (hostname && nsm_use_hostnames) {
+			if (strlen(nsm->sm_name) != hostname_len
+			 || memcmp(nsm->sm_name, hostname, hostname_len))
+				continue;
+		} else if (!nlm_cmp_addr(&nsm->sm_addr, sin))
 			continue;
 		atomic_inc(&nsm->sm_count);
 		goto out;

diff .prev/fs/lockd/mon.c ./fs/lockd/mon.c
--- .prev/fs/lockd/mon.c	2006-09-01 12:11:07.000000000 +1000
+++ ./fs/lockd/mon.c	2006-09-01 12:11:16.000000000 +1000
@@ -47,6 +47,7 @@ nsm_mon_unmon(struct nsm_handle *nsm, u3
 	}
 
 	memset(&args, 0, sizeof(args));
+	args.mon_name = nsm->sm_name;
 	args.addr = nsm->sm_addr.sin_addr.s_addr;
 	args.prog = NLM_PROGRAM;
 	args.vers = 3;
@@ -150,7 +151,7 @@ nsm_create(void)
 static u32 *
 xdr_encode_common(struct rpc_rqst *rqstp, u32 *p, struct nsm_args *argp)
 {
-	char	buffer[20];
+	char	buffer[20], *name;
 
 	/*
 	 * Use the dotted-quad IP address of the remote host as
@@ -158,8 +159,13 @@ xdr_encode_common(struct rpc_rqst *rqstp
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
 	 || !(p = xdr_encode_string(p, utsname()->nodename)))
 		return ERR_PTR(-EIO);
 	*p++ = htonl(argp->prog);

diff .prev/fs/lockd/svc.c ./fs/lockd/svc.c
--- .prev/fs/lockd/svc.c	2006-09-01 12:11:07.000000000 +1000
+++ ./fs/lockd/svc.c	2006-09-01 12:15:24.000000000 +1000
@@ -61,6 +61,7 @@ static DECLARE_WAIT_QUEUE_HEAD(lockd_exi
 static unsigned long		nlm_grace_period;
 static unsigned long		nlm_timeout = LOCKD_DFLT_TIMEO;
 static int			nlm_udpport, nlm_tcpport;
+int				nsm_use_hostnames = 0;
 
 /*
  * Constants needed for the sysctl interface.
@@ -395,6 +396,14 @@ static ctl_table nlm_sysctls[] = {
 		.extra1		= (int *) &nlm_port_min,
 		.extra2		= (int *) &nlm_port_max,
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
 
@@ -483,6 +492,7 @@ module_param_call(nlm_udpport, param_set
 		  &nlm_udpport, 0644);
 module_param_call(nlm_tcpport, param_set_port, param_get_int,
 		  &nlm_tcpport, 0644);
+module_param(nsm_use_hostnames, bool, 0644);
 
 /*
  * Initialising and terminating the module.

diff .prev/include/linux/lockd/lockd.h ./include/linux/lockd/lockd.h
--- .prev/include/linux/lockd/lockd.h	2006-09-01 12:11:05.000000000 +1000
+++ ./include/linux/lockd/lockd.h	2006-09-01 12:16:06.000000000 +1000
@@ -142,6 +142,7 @@ extern struct svc_procedure	nlmsvc_proce
 #endif
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
+extern int			nsm_use_hostnames;
 
 /*
  * Lockd client functions

diff .prev/include/linux/lockd/sm_inter.h ./include/linux/lockd/sm_inter.h
--- .prev/include/linux/lockd/sm_inter.h	2006-09-01 12:11:07.000000000 +1000
+++ ./include/linux/lockd/sm_inter.h	2006-09-01 12:11:16.000000000 +1000
@@ -28,6 +28,8 @@ struct nsm_args {
 	u32		prog;		/* RPC callback info */
 	u32		vers;
 	u32		proc;
+
+	char *		mon_name;
 };
 
 /*

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
