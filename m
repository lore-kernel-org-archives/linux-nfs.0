From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS lock reclaiming not working on SLES9 SP2
Date: Fri, 17 Feb 2006 10:56:18 +0100
Message-ID: <20060217095618.GB25707@suse.de>
References: <20060217044448.16069.qmail@webmail34.rediffmail.com> <20060217092555.GA25707@suse.de> <1140169024.31913.2313.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Cc: asha yr <asha_yr@rediffmail.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FA2Lf-0007EX-KO
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 01:56:23 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FA2Ld-0004Ov-13
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 01:56:23 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1140169024.31913.2313.camel@hole.melbourne.sgi.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Feb 17, 2006 at 08:37:05PM +1100, Greg Banks wrote:
> In his trace, the client wasn't sending any LOCK calls at all
> for multiple minutes after receiving the NOTIFY.

Ah, you're right. I wasn't paying attention to the time stamps.

It seems the problem is that we're now using hostnames to identify lockd
peers, but you mounted the file system using the ipaddr:/path.

Could you please try the attached patch?

Thanks
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=statd-hostname-fix

 fs/lockd/host.c             |    5 +++--
 fs/lockd/statd.c            |    2 +-
 fs/lockd/svc4proc.c         |    2 +-
 fs/lockd/svcproc.c          |    2 +-
 include/linux/lockd/lockd.h |    2 +-
 5 files changed, 7 insertions(+), 6 deletions(-)

Index: build/fs/lockd/host.c
===================================================================
--- build.orig/fs/lockd/host.c
+++ build/fs/lockd/host.c
@@ -274,7 +274,7 @@ void nlm_release_host(struct nlm_host *h
  * Given an IP address, initiate recovery and ditch all locks.
  */
 void
-nlm_host_rebooted(const char *hostname, u32 new_state)
+nlm_host_rebooted(struct sockaddr_in *addr, const char *hostname, u32 new_state)
 {
 	struct nlm_host	*host, **hp;
 	int		hash;
@@ -287,7 +287,8 @@ nlm_host_rebooted(const char *hostname, 
 	/* Mark all matching hosts as having rebooted */
 	for (hash = 0; hash < NLM_HOST_NRHASH; hash++) {
 		for (hp = &nlm_hosts[hash]; (host = *hp); hp = &host->h_next) {
-			if (nlm_cmp_name(host->h_name, hostname)) {
+			if (nlm_cmp_name(host->h_name, hostname)
+			 || (addr && nlm_cmp_addr(&host->h_addr, addr))) {
 				if (host->h_nsmhandle)
 					host->h_nsmhandle->sm_monitored = 0;
 				host->h_rebooted = 1;
Index: build/fs/lockd/statd.c
===================================================================
--- build.orig/fs/lockd/statd.c
+++ build/fs/lockd/statd.c
@@ -311,7 +311,7 @@ nsmsvc_proc_notify(struct svc_rqst *rqst
 				           struct nsm_res  *resp)
 {
 	dprintk("statd: NOTIFY        called\n");
-	nlm_host_rebooted(argp->mon_name, argp->state);
+	nlm_host_rebooted(&rqstp->rq_addr, argp->mon_name, argp->state);
 	return rpc_success;
 }
 
Index: build/fs/lockd/svc4proc.c
===================================================================
--- build.orig/fs/lockd/svc4proc.c
+++ build/fs/lockd/svc4proc.c
@@ -427,7 +427,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *
 		return rpc_system_err;
 	}
 
-	nlm_host_rebooted(argp->mon, argp->state);
+	nlm_host_rebooted(NULL, argp->mon, argp->state);
 	return rpc_success;
 }
 
Index: build/fs/lockd/svcproc.c
===================================================================
--- build.orig/fs/lockd/svcproc.c
+++ build/fs/lockd/svcproc.c
@@ -455,7 +455,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *r
 		return rpc_system_err;
 	}
 
-	nlm_host_rebooted(argp->mon, argp->state);
+	nlm_host_rebooted(NULL, argp->mon, argp->state);
 	return rpc_success;
 }
 
Index: build/include/linux/lockd/lockd.h
===================================================================
--- build.orig/include/linux/lockd/lockd.h
+++ build/include/linux/lockd/lockd.h
@@ -166,7 +166,7 @@ struct nlm_host * nlm_get_host(struct nl
 void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
 extern struct nlm_host *nlm_find_client(void);
-extern void	  nlm_host_rebooted(const char *, u32);
+extern void	  nlm_host_rebooted(struct sockaddr_in *, const char *, u32);
 struct nsm_handle *nsm_find(const char *, int);
 void             nsm_release(struct nsm_handle *);
 

--VbJkn9YxBvnuCH5J--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
