From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Fri, 01 Nov 2002 01:56:23 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021101.015623.48537031.taka@valinux.co.jp>
References: <15808.28897.595522.855723@notabene.cse.unsw.edu.au>
	<20021031.110659.42769812.taka@valinux.co.jp>
	<20021101.004052.85418463.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187Ijf-0006NN-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 09:04:00 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <20021101.004052.85418463.taka@valinux.co.jp>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

> > The rest of the zero copy stuff should fit in quite easily, with the
> > possible exception of single-copy writes: I haven't looked very hard
> > at that yet.
> 
> I just ported part of the zero copy stuff against linux-2.5.45.
> single-copy writes and per-cpu sokcets are not included yet.
> And I fixed a problem that NFS over TCP wouldn't work. 

I also ported the per-cpu socket patch against linux2.5.45.


--- include/linux/sunrpc/svcsock.h.ORG3	Fri Nov  1 01:29:52 2030
+++ include/linux/sunrpc/svcsock.h	Fri Nov  1 01:31:28 2030
@@ -51,6 +51,7 @@ struct svc_sock {
 	int			sk_reclen;	/* length of record */
 	int			sk_tcplen;	/* current read length */
 	time_t			sk_lastrecv;	/* time of last received request */
+	struct svc_sock		**sk_shadow;	/* shadow sockets for sending */
 };
 
 /*
--- net/sunrpc/svcsock.c.ORG3	Fri Nov  1 01:30:14 2030
+++ net/sunrpc/svcsock.c	Fri Nov  1 01:51:34 2030
@@ -64,7 +64,9 @@
 
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
-					 int *errp, int pmap_reg);
+					 int *errp, int type);
+#define SVSK_PMAP_REGISTER	1
+#define SVSK_SHADOW		2
 static void		svc_udp_data_ready(struct sock *, int);
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
@@ -259,6 +261,8 @@ svc_sock_put(struct svc_sock *svsk)
 	if (!--(svsk->sk_inuse) && test_bit(SK_DEAD, &svsk->sk_flags)) {
 		spin_unlock_bh(&serv->sv_lock);
 		dprintk("svc: releasing dead socket\n");
+		if (svsk->sk_shadow)
+			kfree(svsk->sk_shadow);
 		sock_release(svsk->sk_sock);
 		kfree(svsk);
 	}
@@ -326,6 +330,27 @@ svc_wake_up(struct svc_serv *serv)
 	spin_unlock_bh(&serv->sv_lock);
 }
 
+static inline struct svc_sock *
+svc_get_svsk(struct svc_rqst *rqstp)
+{
+	struct svc_sock	*svsk = rqstp->rq_sock;
+#ifdef CONFIG_SMP
+	if (svsk->sk_shadow) {
+		struct svc_sock	*shadow = svsk->sk_shadow[smp_processor_id()];
+		if (shadow) {
+			struct svc_serv	*serv = svsk->sk_server;
+			svsk = shadow;
+			if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
+				svc_sock_setbufsize(svsk->sk_sock,
+					(serv->sv_nrthreads+3) * serv->sv_bufsz,
+					(serv->sv_nrthreads+3) * serv->sv_bufsz);
+		}
+
+	}
+#endif
+	return svsk;
+}
+
 /*
  * Generic sendto routine
  */
@@ -333,7 +358,7 @@ static int
 svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 {
 	mm_segment_t	oldfs;
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk = svc_get_svsk(rqstp);
 	struct socket	*sock = svsk->sk_sock;
 	struct msghdr	msg;
 	int		slen;
@@ -1228,7 +1253,7 @@ svc_send(struct svc_rqst *rqstp)
  */
 static struct svc_sock *
 svc_setup_socket(struct svc_serv *serv, struct socket *sock,
-					int *errp, int pmap_register)
+					int *errp, int type)
 {
 	struct svc_sock	*svsk;
 	struct sock	*inet;
@@ -1249,6 +1274,7 @@ svc_setup_socket(struct svc_serv *serv, 
 	svsk->sk_owspace = inet->write_space;
 	svsk->sk_server = serv;
 	svsk->sk_lastrecv = CURRENT_TIME;
+	svsk->sk_shadow = NULL;
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 	sema_init(&svsk->sk_sem, 1);
 
@@ -1261,7 +1287,7 @@ if (svsk->sk_sk == NULL)
 	printk(KERN_WARNING "svsk->sk_sk == NULL after svc_prot_init!\n");
 
 	/* Register socket with portmapper */
-	if (*errp >= 0 && pmap_register)
+	if (*errp >= 0 && type == SVSK_PMAP_REGISTER)
 		*errp = svc_register(serv, inet->protocol,
 				     ntohs(inet_sk(inet)->sport));
 
@@ -1273,13 +1299,13 @@ if (svsk->sk_sk == NULL)
 
 
 	spin_lock_bh(&serv->sv_lock);
-	if (!pmap_register) {
+	if (type == SVSK_PMAP_REGISTER || type == SVSK_SHADOW) {
+		clear_bit(SK_TEMP, &svsk->sk_flags);
+		list_add(&svsk->sk_list, &serv->sv_permsocks);
+	} else {
 		set_bit(SK_TEMP, &svsk->sk_flags);
 		list_add(&svsk->sk_list, &serv->sv_tempsocks);
 		serv->sv_tmpcnt++;
-	} else {
-		clear_bit(SK_TEMP, &svsk->sk_flags);
-		list_add(&svsk->sk_list, &serv->sv_permsocks);
 	}
 	spin_unlock_bh(&serv->sv_lock);
 
@@ -1288,6 +1314,61 @@ if (svsk->sk_sk == NULL)
 	return svsk;
 }
 
+
+/*
+ * Create a shadow socket which has the same sport of given svsk.
+ * Let each cpu have its own socket to send packets. 
+ */
+static int
+svc_create_shadow_socket(struct svc_serv *serv, struct svc_sock	*svsk,
+				int protocol, struct sockaddr_in *sin)
+{
+#ifdef CONFIG_SMP
+	int		error;
+	struct socket	*newsock;
+	struct svc_sock	*newsvsk;
+	int		i;
+
+	if (num_online_cpus() == 1)
+		return 0;
+
+	svsk->sk_shadow = kmalloc(sizeof(struct svc_sock*)*NR_CPUS, GFP_KERNEL);
+	if (!svsk->sk_shadow)
+		return -ENOMEM;
+
+	memset(svsk->sk_shadow, 0, sizeof(struct svc_sock*)*NR_CPUS);
+
+	for (i = 0; i < NR_CPUS; i++) {
+		if (!cpu_online(i))
+			continue;
+
+		if ((error = sock_create(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &newsock)) < 0)
+			return error;
+		if ((newsvsk = svc_setup_socket(serv, newsock, &error, SVSK_SHADOW)) == NULL) {
+			sock_release(newsock);
+			return error;
+		}
+		/*
+		 * Make the newsvsk as shadow of the svsk.
+		 */
+		newsock->sk->reuse = 1; /* allow address reuse */
+		error = newsock->ops->bind(newsock, (struct sockaddr *) sin,
+						sizeof(*sin));
+		if (error < 0) {
+			sock_release(newsock);
+			kfree(newsvsk);
+			return error;
+		}
+		/*
+		 * Unhash the newsocket not to receive packets.
+		 */
+		newsock->sk->prot->unhash(newsock->sk);
+		svsk->sk_shadow[i] = newsvsk;
+	}
+#endif
+	return 0;
+}
+
 /*
  * Create socket for RPC service.
  */
@@ -1327,8 +1408,13 @@ svc_create_socket(struct svc_serv *serv,
 			goto bummer;
 	}
 
-	if ((svsk = svc_setup_socket(serv, sock, &error, 1)) != NULL)
-		return 0;
+	if ((svsk = svc_setup_socket(serv, sock, &error, SVSK_PMAP_REGISTER)) == NULL)
+		goto bummer;
+
+	if (protocol == IPPROTO_UDP && sin != NULL)
+		svc_create_shadow_socket(serv, svsk, protocol, sin);
+
+	return 0;
 
 bummer:
 	dprintk("svc: svc_create_socket error = %d\n", -error);
@@ -1367,6 +1453,8 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	if (!svsk->sk_inuse) {
 		spin_unlock_bh(&serv->sv_lock);
+		if (svsk->sk_shadow)
+			kfree(svsk->sk_shadow);
 		sock_release(svsk->sk_sock);
 		kfree(svsk);
 	} else {


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
