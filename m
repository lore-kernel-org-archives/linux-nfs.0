From: NeilBrown <neilb@suse.de>
Subject: [PATCH 009 of 9] knfsd: Allow sockets to be passed to nfsd
	via 'portlist'
Date: Tue, 25 Jul 2006 11:55:08 +1000
Message-ID: <1060725015508.22007@suse.de>
References: <20060725114207.21779.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5C9E-0004eG-QE
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:48 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5C9E-0005ew-47
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:49 -0700
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


Userspace should create and bind a socket (but not connectted)
and write the 'fd' to portlist.  This will cause the nfs server
to listen on that socket.

To close a socket, the name of the socket - as read from 'portlist'
can be written to 'portlist' with a preceding '-'.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c               |   59 +++++++++++++++++++++++++++++++++------
 ./fs/nfsd/nfssvc.c               |    4 --
 ./include/linux/nfsd/nfsd.h      |    1 
 ./include/linux/sunrpc/svcsock.h |    6 +++
 ./net/sunrpc/svcsock.c           |   49 +++++++++++++++++++++++++++++---
 5 files changed, 102 insertions(+), 17 deletions(-)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2006-07-24 15:49:51.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2006-07-24 17:24:17.000000000 +1000
@@ -23,9 +23,11 @@
 #include <linux/pagemap.h>
 #include <linux/init.h>
 #include <linux/string.h>
+#include <linux/ctype.h>
 
 #include <linux/nfs.h>
 #include <linux/nfsd_idmap.h>
+#include <linux/lockd/bind.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/nfsd/nfsd.h>
@@ -425,16 +427,55 @@ static ssize_t write_versions(struct fil
 
 static ssize_t write_ports(struct file *file, char *buf, size_t size)
 {
-	/* for now, ignore what was written and just
-	 * return known ports
-	 * AF proto address port
+	if (size == 0) {
+		int len = 0;
+		lock_kernel();
+		if (nfsd_serv)
+			len = svc_sock_names(buf, nfsd_serv, NULL);
+		unlock_kernel();
+		return len;
+	}
+	/* Either a single 'fd' number is written, in which
+	 * case it must be for a socket of a supported family/protocol,
+	 * and we use it as an nfsd socket, or
+	 * A '-' followed by the 'name' of a socket in which case
+	 * we close the socket.
 	 */
-	int len = 0;
-	lock_kernel();
-	if (nfsd_serv)
-		len = svc_sock_names(buf, nfsd_serv);
-	unlock_kernel();
-	return len;
+	if (isdigit(buf[0])) {
+		char *mesg = buf;
+		int fd;
+		int err;
+		err = get_int(&mesg, &fd);
+		if (err)
+			return -EINVAL;
+		if (fd < 0)
+			return -EINVAL;
+		err = nfsd_create_serv();
+		if (!err) {
+			int proto = 0;
+			err = svc_addsock(nfsd_serv, fd, buf, &proto);
+			/* Decrease the count, but don't shutdown the
+			 * the service
+			 */
+			if (err >= 0)
+				lockd_up(proto);
+			nfsd_serv->sv_nrthreads--;
+		}
+		return err;
+	}
+	if (buf[0] == '-') {
+		char *toclose = kstrdup(buf+1, GFP_KERNEL);
+		int len = 0;
+		if (!toclose)
+			return -ENOMEM;
+		lock_kernel();
+		if (nfsd_serv)
+			len = svc_sock_names(buf, nfsd_serv, toclose);
+		unlock_kernel();
+		kfree(toclose);
+		return len;
+	}
+	return -EINVAL;
 }
 
 #ifdef CONFIG_NFSD_V4

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-07-24 15:49:51.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-07-24 15:53:37.000000000 +1000
@@ -196,7 +196,7 @@ void nfsd_reset_versions(void)
 }
 
 
-static inline int nfsd_create_serv(void)
+int nfsd_create_serv(void)
 {
 	int err = 0;
 	lock_kernel();
@@ -211,8 +211,6 @@ static inline int nfsd_create_serv(void)
 			       nfsd_last_thread);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
-	else
-		nfsd_serv->sv_nrthreads++;
 	unlock_kernel();
 	do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	return err;

diff .prev/include/linux/nfsd/nfsd.h ./include/linux/nfsd/nfsd.h
--- .prev/include/linux/nfsd/nfsd.h	2006-07-24 15:49:51.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2006-07-24 15:22:49.000000000 +1000
@@ -143,6 +143,7 @@ int nfsd_set_posix_acl(struct svc_fh *, 
 enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
 int nfsd_vers(int vers, enum vers_op change);
 void nfsd_reset_versions(void);
+int nfsd_create_serv(void);
 
 
 /* 

diff .prev/include/linux/sunrpc/svcsock.h ./include/linux/sunrpc/svcsock.h
--- .prev/include/linux/sunrpc/svcsock.h	2006-07-24 15:49:51.000000000 +1000
+++ ./include/linux/sunrpc/svcsock.h	2006-07-24 15:22:49.000000000 +1000
@@ -61,6 +61,10 @@ int		svc_recv(struct svc_serv *, struct 
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
 void		svc_sock_update_bufs(struct svc_serv *serv);
-int		svc_sock_names(char *buf, struct svc_serv *serv);
+int		svc_sock_names(char *buf, struct svc_serv *serv, char *toclose);
+int		svc_addsock(struct svc_serv *serv,
+			    int fd,
+			    char *name_return,
+			    int *proto);
 
 #endif /* SUNRPC_SVCSOCK_H */

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-07-24 15:49:51.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-07-25 11:25:50.000000000 +1000
@@ -31,6 +31,7 @@
 #include <linux/slab.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/file.h>
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <net/ip.h>
@@ -449,18 +450,23 @@ int one_sock_name(char *buf, struct svc_
 }
 
 int
-svc_sock_names(char *buf, struct svc_serv *serv)
+svc_sock_names(char *buf, struct svc_serv *serv, char *toclose)
 {
-	struct svc_sock *svsk;
+	struct svc_sock *svsk, *closesk = NULL;
 	int len = 0;
 
 	if (!serv) return 0;
 	spin_lock(&serv->sv_lock);
 	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list) {
 		int onelen = one_sock_name(buf+len, svsk);
-		len += onelen;
+		if (toclose && strcmp(toclose, buf+len) == 0)
+			closesk = svsk;
+		else
+			len += onelen;
 	}
 	spin_unlock(&serv->sv_lock);
+	if (closesk)
+		svc_delete_socket(closesk);
 	return len;
 }
 EXPORT_SYMBOL(svc_sock_names);
@@ -1415,6 +1421,38 @@ svc_setup_socket(struct svc_serv *serv, 
 	return svsk;
 }
 
+int svc_addsock(struct svc_serv *serv,
+		int fd,
+		char *name_return,
+		int *proto)
+{
+	int err = 0;
+	struct socket *so = sockfd_lookup(fd, &err);
+	struct svc_sock *svsk = NULL;
+
+	if (!so)
+		return err;
+	if (so->sk->sk_family != AF_INET)
+		err =  -EAFNOSUPPORT;
+	else if (so->sk->sk_protocol != IPPROTO_TCP &&
+	    so->sk->sk_protocol != IPPROTO_UDP)
+		err =  -EPROTONOSUPPORT;
+	else if (so->state > SS_UNCONNECTED)
+		err = -EISCONN;
+	else {
+		svsk = svc_setup_socket(serv, so, &err, 1);
+		if (svsk)
+			err = 0;
+	}
+	if (err) {
+		sockfd_put(so);
+		return err;
+	}
+	if (proto) *proto = so->sk->sk_protocol;
+	return one_sock_name(name_return, svsk);
+}
+EXPORT_SYMBOL_GPL(svc_addsock);
+
 /*
  * Create socket for RPC service.
  */
@@ -1492,7 +1530,10 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	if (!svsk->sk_inuse) {
 		spin_unlock_bh(&serv->sv_lock);
-		sock_release(svsk->sk_sock);
+		if (svsk->sk_sock->file)
+			sockfd_put(svsk->sk_sock);
+		else
+			sock_release(svsk->sk_sock);
 		kfree(svsk);
 	} else {
 		spin_unlock_bh(&serv->sv_lock);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
