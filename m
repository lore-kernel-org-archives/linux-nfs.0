From: NeilBrown <neilb@suse.de>
Subject: [PATCH 008 of 9] knfsd: Define new nfsdfs file: portlist -
	contains list of ports.
Date: Tue, 25 Jul 2006 11:55:02 +1000
Message-ID: <1060725015502.21995@suse.de>
References: <20060725114207.21779.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5C98-0004dV-V0
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:43 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5C98-0005dn-Lz
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:43 -0700
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


This file will list all ports that nfsd has open.
Default when TCP enabled will be
   ipv4 udp 0.0.0.0 2049
   ipv4 tcp 0.0.0.0 2049

Later, the list of ports will be settable.

'portlist' chosen rather than 'ports', to avoid unnecessary confusion with
non-mainline patches which created 'ports' with different semantics.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c               |   19 +++++++++++++++++++
 ./include/linux/sunrpc/svcsock.h |    1 +
 ./net/sunrpc/svcsock.c           |   37 +++++++++++++++++++++++++++++++++++++
 3 files changed, 57 insertions(+)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2006-07-24 15:17:36.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2006-07-24 15:21:44.000000000 +1000
@@ -27,6 +27,7 @@
 #include <linux/nfs.h>
 #include <linux/nfsd_idmap.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/svcsock.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
@@ -51,6 +52,7 @@ enum {
 	NFSD_Fh,
 	NFSD_Threads,
 	NFSD_Versions,
+	NFSD_Ports,
 	/*
 	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
 	 * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
@@ -74,6 +76,7 @@ static ssize_t write_getfs(struct file *
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_versions(struct file *file, char *buf, size_t size);
+static ssize_t write_ports(struct file *file, char *buf, size_t size);
 #ifdef CONFIG_NFSD_V4
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
@@ -90,6 +93,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Versions] = write_versions,
+	[NFSD_Ports] = write_ports,
 #ifdef CONFIG_NFSD_V4
 	[NFSD_Leasetime] = write_leasetime,
 	[NFSD_RecoveryDir] = write_recoverydir,
@@ -419,6 +423,20 @@ static ssize_t write_versions(struct fil
 	return len;
 }
 
+static ssize_t write_ports(struct file *file, char *buf, size_t size)
+{
+	/* for now, ignore what was written and just
+	 * return known ports
+	 * AF proto address port
+	 */
+	int len = 0;
+	lock_kernel();
+	if (nfsd_serv)
+		len = svc_sock_names(buf, nfsd_serv);
+	unlock_kernel();
+	return len;
+}
+
 #ifdef CONFIG_NFSD_V4
 extern time_t nfs4_leasetime(void);
 
@@ -482,6 +500,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},

diff .prev/include/linux/sunrpc/svcsock.h ./include/linux/sunrpc/svcsock.h
--- .prev/include/linux/sunrpc/svcsock.h	2006-07-24 15:21:44.000000000 +1000
+++ ./include/linux/sunrpc/svcsock.h	2006-07-24 15:21:44.000000000 +1000
@@ -61,5 +61,6 @@ int		svc_recv(struct svc_serv *, struct 
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
 void		svc_sock_update_bufs(struct svc_serv *serv);
+int		svc_sock_names(char *buf, struct svc_serv *serv);
 
 #endif /* SUNRPC_SVCSOCK_H */

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-07-24 15:21:44.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-07-24 15:21:44.000000000 +1000
@@ -429,6 +429,43 @@ out:
 }
 
 /*
+ * Report socket names for nfsdfs
+ */
+int one_sock_name(char *buf, struct svc_sock *svsk)
+{
+	int len;
+	switch(svsk->sk_sk->sk_family) {
+	case AF_INET:
+		len = sprintf(buf, "ipv4 %s %u.%u.%u.%u %d\n",
+			      svsk->sk_sk->sk_protocol==IPPROTO_UDP?
+			      "udp" : "tcp",
+			      NIPQUAD(inet_sk(svsk->sk_sk)->rcv_saddr),
+			      inet_sk(svsk->sk_sk)->num);
+		break;
+	default: len = sprintf(buf, "*unknown-%d*\n",
+			       svsk->sk_sk->sk_family);
+	}
+	return len;
+}
+
+int
+svc_sock_names(char *buf, struct svc_serv *serv)
+{
+	struct svc_sock *svsk;
+	int len = 0;
+
+	if (!serv) return 0;
+	spin_lock(&serv->sv_lock);
+	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list) {
+		int onelen = one_sock_name(buf+len, svsk);
+		len += onelen;
+	}
+	spin_unlock(&serv->sv_lock);
+	return len;
+}
+EXPORT_SYMBOL(svc_sock_names);
+
+/*
  * Check input queue length
  */
 static int

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
