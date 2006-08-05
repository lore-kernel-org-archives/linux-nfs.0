From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 8/22] lockd: make the nsm upcalls use the nsm_handle
Date: Sat, 5 Aug 2006 15:06:48 +0200
Message-ID: <20060805130648.GA8054@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrf-00078F-66
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:51 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lre-0003Kh-R8
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:51 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 5DBCA101AF
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
Subject: lockd: make the nsm upcalls use the nsm_handle

  This converts the statd upcalls to use the nsm_handle

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/mon.c                 |   30 ++++++++++++++++++------------
 include/linux/lockd/sm_inter.h |    1 -
 2 files changed, 18 insertions(+), 13 deletions(-)

Index: build/fs/lockd/mon.c
===================================================================
--- build.orig/fs/lockd/mon.c
+++ build/fs/lockd/mon.c
@@ -30,7 +30,7 @@ u32				nsm_local_state;
  * Common procedure for SM_MON/SM_UNMON calls
  */
 static int
-nsm_mon_unmon(struct nlm_host *host, u32 proc, struct nsm_res *res)
+nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 {
 	struct rpc_clnt	*clnt;
 	int		status;
@@ -46,10 +46,10 @@ nsm_mon_unmon(struct nlm_host *host, u32
 		goto out;
 	}
 
-	args.addr = host->h_addr.sin_addr.s_addr;
-	args.proto= (host->h_proto<<1) | host->h_server;
+	memset(&args, 0, sizeof(args));
+	args.addr = nsm->sm_addr.sin_addr.s_addr;
 	args.prog = NLM_PROGRAM;
-	args.vers = host->h_version;
+	args.vers = 3;
 	args.proc = NLMPROC_NSM_NOTIFY;
 	memset(res, 0, sizeof(*res));
 
@@ -80,7 +80,7 @@ nsm_monitor(struct nlm_host *host)
 	if (nsm->sm_monitored)
 		return 0;
 
-	status = nsm_mon_unmon(host, SM_MON, &res);
+	status = nsm_mon_unmon(nsm, SM_MON, &res);
 
 	if (status < 0 || res.status != 0)
 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", host->h_name);
@@ -99,16 +99,20 @@ nsm_unmonitor(struct nlm_host *host)
 	struct nsm_res	res;
 	int		status = 0;
 
-	dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
 	if (nsm == NULL)
 		return 0;
 	host->h_nsmhandle = NULL;
 
-	if (!host->h_killed) {
-		status = nsm_mon_unmon(host, SM_UNMON, &res);
+	if (atomic_read(&nsm->sm_count) == 1
+	 && nsm->sm_monitored && !nsm->sm_sticky) {
+		dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
+
+		status = nsm_mon_unmon(nsm, SM_UNMON, &res);
 		if (status < 0)
-			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n", host->h_name);
-		nsm->sm_monitored = 0;
+			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
+					host->h_name);
+		else
+			nsm->sm_monitored = 0;
 	}
 	nsm_release(nsm);
 	return status;
@@ -178,9 +182,11 @@ xdr_encode_mon(struct rpc_rqst *rqstp, u
 	p = xdr_encode_common(rqstp, p, argp);
 	if (IS_ERR(p))
 		return PTR_ERR(p);
+
+	/* Surprise - there may even be room for an IPv6 address now */
 	*p++ = argp->addr;
-	*p++ = argp->vers;
-	*p++ = argp->proto;
+	*p++ = 0;
+	*p++ = 0;
 	*p++ = 0;
 	rqstp->rq_slen = xdr_adjust_iovec(rqstp->rq_svec, p);
 	return 0;
Index: build/include/linux/lockd/sm_inter.h
===================================================================
--- build.orig/include/linux/lockd/sm_inter.h
+++ build/include/linux/lockd/sm_inter.h
@@ -28,7 +28,6 @@ struct nsm_args {
 	u32		prog;		/* RPC callback info */
 	u32		vers;
 	u32		proc;
-	u32		proto;		/* protocol (udp/tcp) plus server/client flag */
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
