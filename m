Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from interlinx.bc.ca ([66.11.173.224]:53747 "EHLO
	linux.interlinx.bc.ca" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755915Ab1C3MJO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Mar 2011 08:09:14 -0400
Message-ID: <4D931D67.3050003@interlinx.bc.ca>
Date: Wed, 30 Mar 2011 08:09:11 -0400
From: "Brian J. Murrell" <brian@interlinx.bc.ca>
To: Trond.Myklebust@netapp.com
CC: kwc@citi.umich.edu, linux-nfs@vger.kernel.org
Subject: Re: different kernels mean NFS4/GSSAPI works or doesn't
References: <imbb8m$uiv$1@dough.gmane.org>	 <AANLkTimFJ2fMn805jY91u8FQihib8GfJ=8S7Yy4y47R3@mail.gmail.com>	 <4D89D36D.3090207@interlinx.bc.ca>	 <AANLkTi=b1z0MrYYQmidbra0EHanegcLO5qoOScLq21rb@mail.gmail.com>	 <4D8A0C9F.8090300@interlinx.bc.ca> <1300900035.11677.12.camel@lade.trondhjem.org> <4D8F30C1.9030304@interlinx.bc.ca>
In-Reply-To: <4D8F30C1.9030304@interlinx.bc.ca>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFCDFDD37E7E5ED29DCF7D206"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------enigFCDFDD37E7E5ED29DCF7D206
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11-03-27 08:42 AM, Brian J. Murrell wrote:
>=20
> It seems the problem was introduced in 2.6.32.12.  I don't really know
> which commit between 2.6.32.11 and 2.6.32.12 though.  In fact I don't
> even know where to find these so-called .11 and .12 4th order of
> releases to see what all went into it.

OK.  So I have linux-2.6.32.11.tar.bz2 and patch-2.6.32.12.bz2 from
kernel.org.

patch-2.6.32.12.bz2 doesn't apply cleanly to the linux-2.6.32.11 tree
that's in linux-2.6.32.11.tar.bz2 though:

# bzcat ../patch-2.6.32.12.bz2 | patch -p1 --dry-run
patching file Documentation/Changes
Reversed (or previously applied) patch detected!  Assume -R? [n]

Looking at the patch and the tree, indeed, the hunk the patch is trying
to apply:

--- a/Documentation/Changes
+++ b/Documentation/Changes
@@ -49,6 +49,8 @@ o  oprofile               0.9                     #
oprofiled --version
 o  udev                   081                     # udevinfo -V
 o  grub                   0.93                    # grub --version
 o  mcelog		  0.6
+o  iptables               1.4.1                   # iptables -V
+

Is already in 2.6.32.11:

o  udev                   081                     # udevinfo -V
o  grub                   0.93                    # grub --version
o  mcelog		  0.6
o  iptables               1.4.1                   # iptables -V


Kernel compilation
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

What am I missing about this patch file?

>> You can
>> probably restrict yourself to bisecting changes to include/linux/sunrp=
c,
>> net/sunrpc and net/sunrpc/auth_gss.

In any case, that .12 patch file has the following changes to files
matching /sunrpc/ (apologies for the wrapping -- stupid thunderbird has
no way to turn that off unless I compose HTML mails):

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gs=
s.c
index fc6a43c..2370ab4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -485,7 +485,7 @@ gss_refresh_upcall(struct rpc_task *task)
 	dprintk("RPC: %5u gss_refresh_upcall for uid %u\n", task->tk_pid,
 								cred->cr_uid);
 	gss_msg =3D gss_setup_upcall(task->tk_client, gss_auth, cred);
-	if (IS_ERR(gss_msg) =3D=3D -EAGAIN) {
+	if (PTR_ERR(gss_msg) =3D=3D -EAGAIN) {
 		/* XXX: warning on the first, under the assumption we
 		 * shouldn't normally hit this case on a refresh. */
 		warn_gssd();
@@ -644,7 +644,22 @@ gss_pipe_downcall(struct file *filp, const char
__user *src, size_t mlen)
 	p =3D gss_fill_context(p, end, ctx, gss_msg->auth->mech);
 	if (IS_ERR(p)) {
 		err =3D PTR_ERR(p);
-		gss_msg->msg.errno =3D (err =3D=3D -EAGAIN) ? -EAGAIN : -EACCES;
+		switch (err) {
+		case -EACCES:
+			gss_msg->msg.errno =3D err;
+			err =3D mlen;
+			break;
+		case -EFAULT:
+		case -ENOMEM:
+		case -EINVAL:
+		case -ENOSYS:
+			gss_msg->msg.errno =3D -EAGAIN;
+			break;
+		default:
+			printk(KERN_CRIT "%s: bad return from "
+				"gss_fill_context: %ld\n", __func__, err);
+			BUG();
+		}
 		goto err_release_msg;
 	}
 	gss_msg->ctx =3D gss_get_ctx(ctx);
@@ -1258,9 +1273,8 @@ alloc_enc_pages(struct rpc_rqst *rqstp)
 	rqstp->rq_release_snd_buf =3D priv_release_snd_buf;
 	return 0;
 out_free:
-	for (i--; i >=3D 0; i--) {
-		__free_page(rqstp->rq_enc_pages[i]);
-	}
+	rqstp->rq_enc_pages_num =3D i;
+	priv_release_snd_buf(rqstp);
 out:
 	return -EAGAIN;
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c
b/net/sunrpc/auth_gss/gss_krb5_mech.c
index ef45eba..2deb0ed 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -131,8 +131,10 @@ gss_import_sec_context_kerberos(const void *p,
 	struct	krb5_ctx *ctx;
 	int tmp;

-	if (!(ctx =3D kzalloc(sizeof(*ctx), GFP_NOFS)))
+	if (!(ctx =3D kzalloc(sizeof(*ctx), GFP_NOFS))) {
+		p =3D ERR_PTR(-ENOMEM);
 		goto out_err;
+	}

 	p =3D simple_get_bytes(p, end, &ctx->initiate, sizeof(ctx->initiate));
 	if (IS_ERR(p))
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c
b/net/sunrpc/auth_gss/gss_mech_switch.c
index 6efbb0c..76e4c6f 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -252,7 +252,7 @@ gss_import_sec_context(const void *input_token,
size_t bufsize,
 		       struct gss_ctx		**ctx_id)
 {
 	if (!(*ctx_id =3D kzalloc(sizeof(**ctx_id), GFP_KERNEL)))
-		return GSS_S_FAILURE;
+		return -ENOMEM;
 	(*ctx_id)->mech_type =3D gss_mech_get(mech);

 	return mech->gm_ops
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 49278f8..27a2378 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -587,6 +587,8 @@ static struct dentry
*__rpc_lookup_create_exclusive(struct dentry *parent,
 	struct dentry *dentry;

 	dentry =3D __rpc_lookup_create(parent, name);
+	if (IS_ERR(dentry))
+		return dentry;
 	if (dentry->d_inode =3D=3D NULL)
 		return dentry;
 	dput(dentry);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index df124f7..3fbd6ba 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -711,7 +711,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	spin_unlock_bh(&pool->sp_lock);

 	len =3D 0;
-	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
+	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+		dprintk("svc_recv: found XPT_CLOSE\n");
+		svc_delete_xprt(xprt);
+	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt =3D xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
@@ -737,7 +740,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			svc_xprt_received(newxpt);
 		}
 		svc_xprt_received(xprt);
-	} else if (!test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+	} else {
 		dprintk("svc: server %p, pool %u, transport %p, inuse=3D%d\n",
 			rqstp, pool->sp_id, xprt,
 			atomic_read(&xprt->xpt_ref.refcount));
@@ -750,11 +753,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		dprintk("svc: got len=3D%d\n", len);
 	}

-	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
-		dprintk("svc_recv: found XPT_CLOSE\n");
-		svc_delete_xprt(xprt);
-	}
-
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len =3D=3D 0 || len =3D=3D -EAGAIN) {
 		rqstp->rq_res.len =3D 0;
@@ -900,11 +898,8 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 	if (test_bit(XPT_TEMP, &xprt->xpt_flags))
 		serv->sv_tmpcnt--;

-	for (dr =3D svc_deferred_dequeue(xprt); dr;
-	     dr =3D svc_deferred_dequeue(xprt)) {
-		svc_xprt_put(xprt);
+	while ((dr =3D svc_deferred_dequeue(xprt)) !=3D NULL)
 		kfree(dr);
-	}

 	svc_xprt_put(xprt);
 	spin_unlock_bh(&serv->sv_lock);
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 117f68a..97cc3de 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -655,23 +655,25 @@ static struct unix_gid *unix_gid_lookup(uid_t uid)
 		return NULL;
 }

-static int unix_gid_find(uid_t uid, struct group_info **gip,
-			 struct svc_rqst *rqstp)
+static struct group_info *unix_gid_find(uid_t uid, struct svc_rqst *rqst=
p)
 {
-	struct unix_gid *ug =3D unix_gid_lookup(uid);
+	struct unix_gid *ug;
+	struct group_info *gi;
+	int ret;
+
+	ug =3D unix_gid_lookup(uid);
 	if (!ug)
-		return -EAGAIN;
-	switch (cache_check(&unix_gid_cache, &ug->h, &rqstp->rq_chandle)) {
+		return ERR_PTR(-EAGAIN);
+	ret =3D cache_check(&unix_gid_cache, &ug->h, &rqstp->rq_chandle);
+	switch (ret) {
 	case -ENOENT:
-		*gip =3D NULL;
-		return 0;
+		return ERR_PTR(-ENOENT);
 	case 0:
-		*gip =3D ug->gi;
-		get_group_info(*gip);
+		gi =3D get_group_info(ug->gi);
 		cache_put(&ug->h, &unix_gid_cache);
-		return 0;
+		return gi;
 	default:
-		return -EAGAIN;
+		return ERR_PTR(-EAGAIN);
 	}
 }

@@ -681,6 +683,8 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	struct sockaddr_in *sin;
 	struct sockaddr_in6 *sin6, sin6_storage;
 	struct ip_map *ipm;
+	struct group_info *gi;
+	struct svc_cred *cred =3D &rqstp->rq_cred;

 	switch (rqstp->rq_addr.ss_family) {
 	case AF_INET:
@@ -722,6 +726,17 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 			ip_map_cached_put(rqstp, ipm);
 			break;
 	}
+
+	gi =3D unix_gid_find(cred->cr_uid, rqstp);
+	switch (PTR_ERR(gi)) {
+	case -EAGAIN:
+		return SVC_DROP;
+	case -ENOENT:
+		break;
+	default:
+		put_group_info(cred->cr_group_info);
+		cred->cr_group_info =3D gi;
+	}
 	return SVC_OK;
 }

@@ -818,19 +833,11 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32
*authp)
 	slen =3D svc_getnl(argv);			/* gids length */
 	if (slen > 16 || (len -=3D (slen + 2)*4) < 0)
 		goto badcred;
-	if (unix_gid_find(cred->cr_uid, &cred->cr_group_info, rqstp)
-	    =3D=3D -EAGAIN)
+	cred->cr_group_info =3D groups_alloc(slen);
+	if (cred->cr_group_info =3D=3D NULL)
 		return SVC_DROP;
-	if (cred->cr_group_info =3D=3D NULL) {
-		cred->cr_group_info =3D groups_alloc(slen);
-		if (cred->cr_group_info =3D=3D NULL)
-			return SVC_DROP;
-		for (i =3D 0; i < slen; i++)
-			GROUP_AT(cred->cr_group_info, i) =3D svc_getnl(argv);
-	} else {
-		for (i =3D 0; i < slen ; i++)
-			svc_getnl(argv);
-	}
+	for (i =3D 0; i < slen; i++)
+		GROUP_AT(cred->cr_group_info, i) =3D svc_getnl(argv);
 	if (svc_getu32(argv) !=3D htonl(RPC_AUTH_NULL) || svc_getu32(argv) !=3D=
 0) {
 		*authp =3D rpc_autherr_badverf;
 		return SVC_DENIED;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1c246a4..70b0a22 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -968,6 +968,7 @@ static int svc_tcp_recv_record(struct svc_sock
*svsk, struct svc_rqst *rqstp)
 	return len;
  err_delete:
 	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+	svc_xprt_received(&svsk->sk_xprt);
  err_again:
 	return -EAGAIN;
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 37c5475..5cdbf7c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1926,6 +1926,11 @@ static void xs_tcp_setup_socket(struct rpc_xprt
*xprt,
 	case -EALREADY:
 		xprt_clear_connecting(xprt);
 		return;
+	case -EINVAL:
+		/* Happens, for instance, if the user specified a link
+		 * local IPv6 address without a scope-id.
+		 */
+		goto out;
 	}
 out_eagain:
 	status =3D -EAGAIN;

Anything jump out at you?

b.


--------------enigFCDFDD37E7E5ED29DCF7D206
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2THWcACgkQl3EQlGLyuXCToACgzOWphuoxklxHWXLSjnc6E/ZQ
FfAAoPs3kTCOx3f5Up8FgxciOtVG8Ejp
=RsGp
-----END PGP SIGNATURE-----

--------------enigFCDFDD37E7E5ED29DCF7D206--
