From: NeilBrown <neilb@suse.de>
Subject: [PATCH 006 of 6] knfsd: Allow sockets to be passed to nfsd
	via 'portlist'
Date: Mon, 3 Jul 2006 16:19:42 +1000
Message-ID: <1060703061942.7161@suse.de>
References: <20060703161408.7009.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxHmh-0004l1-3a
	for nfs@lists.sourceforge.net; Sun, 02 Jul 2006 23:19:51 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FxHmg-0007c5-Gc
	for nfs@lists.sourceforge.net; Sun, 02 Jul 2006 23:19:51 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 94277EED8
	for <nfs@lists.sourceforge.net>; Mon,  3 Jul 2006 08:19:48 +0200 (CEST)
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


Userspace should create and bind a socket (but not connectted)
and write the 'fd' to portlist.  This will cause the nfs server
to listen on that socket.

To close a socket, the name of the socket - as read from 'portlist'
can be written to 'portlist' with a preceding '-'.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c               |   59 +++++++++++++++++++++++++++++++++------
 ./fs/nfsd/nfssvc.c               |    2 -
 ./include/linux/nfsd/nfsd.h      |    1 
 ./include/linux/sunrpc/svcsock.h |    6 +++
 ./net/sunrpc/svcsock.c           |   39 +++++++++++++++++++++++--
 5 files changed, 93 insertions(+), 14 deletions(-)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2006-07-03 15:46:44.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2006-07-03 16:12:42.000000000 +1000
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
+			if (!err >= 0)
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
--- .prev/fs/nfsd/nfssvc.c	2006-07-03 15:16:40.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-07-03 16:07:21.000000000 +1000
@@ -196,7 +196,7 @@ void nfsd_reset_versions(void)
 }
 
 
-static inline int nfsd_create_serv(void)
+int nfsd_create_serv(void)
 {
 	int err = 0;
 	lock_kernel();

diff .prev/include/linux/nfsd/nfsd.h ./include/linux/nfsd/nfsd.h
--- .prev/include/linux/nfsd/nfsd.h	2006-07-03 14:48:36.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2006-07-03 16:07:36.000000000 +1000
@@ -143,6 +143,7 @@ int nfsd_set_posix_acl(struct svc_fh *, 
 enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
 int nfsd_vers(int vers, enum vers_op change);
 void nfsd_reset_versions(void);
+int nfsd_create_serv(void);
 
 
 /* 

diff .prev/include/linux/sunrpc/svcsock.h ./include/linux/sunrpc/svcsock.h
--- .prev/include/linux/sunrpc/svcsock.h	2006-07-03 15:46:44.000000000 +1000
+++ ./include/linux/sunrpc/svcsock.h	2006-07-03 16:11:05.000000000 +1000
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
--- .prev/net/sunrpc/svcsock.c	2006-07-03 15:46:44.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-07-03 16:11:40.000000000 +1000
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
@@ -1415,6 +1421,31 @@ svc_setup_socket(struct svc_serv *serv, 
 	return svsk;
 }
 
+int svc_addsock(struct svc_serv *serv,
+		int fd,
+		char *name_return,
+		int *proto)
+{
+	int err = 0;
+	struct socket *so = sockfd_lookup(fd, &err);
+	struct svc_sock *svsk;
+
+	if (!so)
+		return err;
+	if (so->sk->sk_family != AF_INET)
+		return -EAFNOSUPPORT;
+	if (so->sk->sk_protocol != IPPROTO_TCP &&
+	    so->sk->sk_protocol != IPPROTO_UDP)
+		return -EPROTONOSUPPORT;
+	/* Should check TCP socket is listening, not connected */
+	svsk = svc_setup_socket(serv, so, &err, 1);
+	if (!svsk)
+		return err;
+	if (proto) *proto = so->sk->sk_protocol;
+	return one_sock_name(name_return, svsk);
+}
+EXPORT_SYMBOL_GPL(svc_addsock);
+
 /*
  * Create socket for RPC service.
  */
@@ -1492,6 +1523,8 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	if (!svsk->sk_inuse) {
 		spin_unlock_bh(&serv->sv_lock);
+		if (svsk->sk_sock->file)
+			sockfd_put(svsk->sk_sock);
 		sock_release(svsk->sk_sock);
 		kfree(svsk);
 	} else {

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
