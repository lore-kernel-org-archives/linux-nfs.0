From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: [PATCH] lockd: separate client and server hosts
Date: Wed, 22 May 2002 19:26:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020522192658.C11190@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17AZtn-0004jG-00
	for <nfs@lists.sourceforge.net>; Wed, 22 May 2002 10:27:48 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id TAA17878
          for <nfs@lists.sourceforge.net>; Wed, 22 May 2002 19:26:25 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g4MHQwI11267
	for nfs@lists.sourceforge.net; Wed, 22 May 2002 19:26:58 +0200
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,
I implemented what Trond suggested for separating client and server hosts. A
very basic test (all on the same host...) shown no problem.

It seems to me that the existing code should have been associated with bugs, as
the hosts known by the server were registered in the hash with their clnt ref,
or with the address of the host. There should have been trouble when the server
found a bad one. Maybe it never showed up or in very rare cases (or maybe I 
misunderstand some part of the code) (it is only a supposition as I haven't
thought about a real case where such a problem could happen).

Pat

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="separated-host.diff"

diff -u --recursive --new-file linux-2.4.18.trond_patch/fs/lockd/host.c linux-2.4.18.clean-separated_hosts/fs/lockd/host.c
--- linux-2.4.18.trond_patch/fs/lockd/host.c	Mon Oct  1 22:45:47 2001
+++ linux-2.4.18.clean-separated_hosts/fs/lockd/host.c	Fri May 24 23:24:50 2002
@@ -62,7 +62,7 @@
 nlm_match_host(struct nlm_host *host, struct svc_client *clnt,
 					struct sockaddr_in *sin)
 {
-	if (clnt)
+	if (clnt || host->h_exportent)
 		return host->h_exportent == clnt;
 	return nlm_cmp_addr(&host->h_addr, sin);
 }
diff -u --recursive --new-file linux-2.4.18.trond_patch/fs/lockd/svc4proc.c linux-2.4.18.clean-separated_hosts/fs/lockd/svc4proc.c
--- linux-2.4.18.trond_patch/fs/lockd/svc4proc.c	Fri May 24 19:57:43 2002
+++ linux-2.4.18.clean-separated_hosts/fs/lockd/svc4proc.c	Fri May 24 23:24:50 2002
@@ -470,8 +470,10 @@
 	if (!(call = nlmclnt_alloc_call()))
 		return rpc_system_err;
 
-	host = nlmclnt_lookup_host(&rqstp->rq_addr,
+	if (proc == NLMPROC_GRANTED_RES)
+		host = nlmclnt_lookup_host(&rqstp->rq_addr,
 				rqstp->rq_prot, rqstp->rq_vers);
+	else host = nlmsvc_lookup_host(rqstp);
 	if (!host) {
 		kfree(call);
 		return rpc_system_err;
diff -u --recursive --new-file linux-2.4.18.trond_patch/fs/lockd/svclock.c linux-2.4.18.clean-separated_hosts/fs/lockd/svclock.c
--- linux-2.4.18.trond_patch/fs/lockd/svclock.c	Fri May 24 19:57:43 2002
+++ linux-2.4.18.clean-separated_hosts/fs/lockd/svclock.c	Fri May 24 23:24:51 2002
@@ -176,8 +176,7 @@
 	struct nlm_rqst		*call;
 
 	/* Create host handle for callback */
-	host = nlmclnt_lookup_host(&rqstp->rq_addr,
-				rqstp->rq_prot, rqstp->rq_vers);
+	host = nlmsvc_lookup_host(rqstp);
 	if (host == NULL)
 		return NULL;
 
diff -u --recursive --new-file linux-2.4.18.trond_patch/fs/lockd/svcproc.c linux-2.4.18.clean-separated_hosts/fs/lockd/svcproc.c
--- linux-2.4.18.trond_patch/fs/lockd/svcproc.c	Fri May 24 19:57:43 2002
+++ linux-2.4.18.clean-separated_hosts/fs/lockd/svcproc.c	Fri May 24 23:24:51 2002
@@ -498,8 +498,10 @@
 	if (!(call = nlmclnt_alloc_call()))
 		return rpc_system_err;
 
-	host = nlmclnt_lookup_host(&rqstp->rq_addr,
+	if (proc == NLMPROC_GRANTED_RES)
+		host = nlmclnt_lookup_host(&rqstp->rq_addr,
 				rqstp->rq_prot, rqstp->rq_vers);
+	else host = nlmsvc_lookup_host(rqstp);
 	if (!host) {
 		kfree(call);
 		return rpc_system_err;

--bp/iNruPH9dso1Pn--

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
