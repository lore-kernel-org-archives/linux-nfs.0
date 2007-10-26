From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 26/27] SUNRPC: RPC program information is stored in
	unsigned	integers
Date: Fri, 26 Oct 2007 13:32:56 -0400
Message-ID: <20071026173256.31475.3060.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlTSG-0001Hq-Jt
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:58:44 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT3Z-0006pN-3W
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:33:13 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Clean up: When looping over RPC version and procedure numbers, use
unsigned index variables.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/stats.c |    4 ++--
 net/sunrpc/svc.c   |    5 +++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 4d4f373..9d1f182 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -33,7 +33,7 @@ struct proc_dir_entry	*proc_net_rpc = NULL;
 static int rpc_proc_show(struct seq_file *seq, void *v) {
 	const struct rpc_stat	*statp = seq->private;
 	const struct rpc_program *prog = statp->program;
-	int		i, j;
+	unsigned int i, j;
 
 	seq_printf(seq,
 		"net %u %u %u %u\n",
@@ -81,7 +81,7 @@ void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp) {
 	const struct svc_program *prog = statp->program;
 	const struct svc_procedure *proc;
 	const struct svc_version *vers;
-	int		i, j;
+	unsigned int i, j;
 
 	seq_printf(seq,
 		"net %u %u %u %u\n",
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 4695ad7..c14630f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -363,7 +363,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	   void (*shutdown)(struct svc_serv *serv))
 {
 	struct svc_serv	*serv;
-	int vers;
+	unsigned int vers;
 	unsigned int xdrsize;
 	unsigned int i;
 
@@ -736,7 +736,8 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
 {
 	struct svc_program	*progp;
 	unsigned long		flags;
-	int			i, error = 0, dummy;
+	unsigned int		i;
+	int			error = 0, dummy;
 
 	if (!port)
 		clear_thread_flag(TIF_SIGPENDING);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
