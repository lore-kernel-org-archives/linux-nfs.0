Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:40652 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750767Ab3GJEcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Jul 2013 00:32:52 -0400
Date: Wed, 10 Jul 2013 14:32:33 +1000
From: NeilBrown <neilb@suse.de>
To: "J.Bruce Fields" <bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130710143233.77e35721@notabene.brown>
In-Reply-To: <20130710022735.GI8281@fieldses.org>
References: <20130710092255.0240a36d@notabene.brown>
	<20130710022735.GI8281@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/v=V+/5jC/x7b75x9g.PIKkj"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/v=V+/5jC/x7b75x9g.PIKkj
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 9 Jul 2013 22:27:35 -0400 "J.Bruce Fields" <bfields@citi.umich.edu>
wrote:

> On Wed, Jul 10, 2013 at 09:22:55AM +1000, NeilBrown wrote:
> >=20
> > Hi,
> >  I just noticed this commit:
> >=20
> > commit 9660439861aa8dbd5e2b8087f33e20760c2c9afc
> > Author: Olga Kornievskaia <aglo@citi.umich.edu>
> > Date:   Tue Oct 21 14:13:47 2008 -0400
> >=20
> >     svcrpc: take advantage of tcp autotuning
> >=20
> >=20
> > which I must confess surprised me.  I wonder if the full implications of
> > removing that functionality were understood.
> >=20
> > Previously nfsd would set the transmit buffer space for a connection to
> > ensure there is plenty to hold all replies.  Now it doesn't.
> >=20
> > nfsd refuses to accept a request if there isn't enough space in the tra=
nsmit
> > buffer to send a reply.  This is important to ensure that each reply ge=
ts
> > sent atomically without blocking and there is no risk of replies getting
> > interleaved.
> >=20
> > The server starts out with a large estimate of the reply space (1M) and=
 for
> > NFSv3 and v2 it quickly adjusts this down to something realistic.  For =
NFSv4
> > it is much harder to estimate the space needed so it just assumes every
> > reply will require 1M of space.
> >=20
> > This means that with NFSv4, as soon as you have enough concurrent reque=
sts
> > such that 1M each reserves all of whatever window size was auto-tuned, =
new
> > requests on that connection will be ignored.
> >
> > This could significantly limit the amount of parallelism that can be ac=
hieved
> > for a single TCP connection (and given that the Linux client strongly p=
refers
> > a single connection now, this could become more of an issue).
>=20
> Worse, I believe it can deadlock completely if the transmit buffer
> shrinks too far, and people really have run into this:
>=20
> 	http://mid.gmane.org/<20130125185748.GC29596@fieldses.org>
>=20
> Trond's suggestion looked at the time like it might work and be doable:
>=20
> 	http://mid.gmane.org/<4FA345DA4F4AE44899BD2B03EEEC2FA91833C1D8@sacexcmbx=
05-prd.hq.netapp.com>
>=20
> but I dropped it.

I would probably generalise Trond's suggestion and allow "N" extra requests
through that exceed the reservation, when N is related to the number of idle
threads.  squareroot might be nice, but half is probably easiest.

If any send takes more than 30 seconds the sk_sndtimeo will kick in and clo=
se
the connection so a really bad connection won't block threads indefinitely.


And yes - a nice test case would be good.

What do you think of the following (totally untested - just for comment)?

NeilBrown


diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xpr=
t.h
index b05963f..2fc92f1 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -81,6 +81,10 @@ struct svc_xprt {
=20
 	struct net		*xpt_net;
 	struct rpc_xprt		*xpt_bc_xprt;	/* NFSv4.1 backchannel */
+
+	atomic_t		xpt_extras;	/* Extra requests which
+						 * might block on send
+						 */
 };
=20
 static inline void unregister_xpt_user(struct svc_xprt *xpt, struct svc_xp=
t_user *u)
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 80a6640..fc366ca 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -165,6 +165,7 @@ void svc_xprt_init(struct net *net, struct svc_xprt_cla=
ss *xcl,
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
 	rpc_init_wait_queue(&xprt->xpt_bc_pending, "xpt_bc_pending");
 	xprt->xpt_net =3D get_net(net);
+	atomic_set(&xprt->xpt_extra, 0);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
=20
@@ -326,13 +327,21 @@ static void svc_thread_dequeue(struct svc_pool *pool,=
 struct svc_rqst *rqstp)
 	list_del(&rqstp->rq_list);
 }
=20
-static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
+static int svc_xprt_has_something_to_do(struct svc_xprt *xprt)
 {
 	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
-		return true;
-	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED)))
-		return xprt->xpt_ops->xpo_has_wspace(xprt);
-	return false;
+		return 1;
+	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED))) {
+		if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
+			if (atomic_read(&xprt->xpt_extra))
+				atomic_set(&xprt->xpt_extras, 0);
+			return 1;
+		} else {
+			atomic_inc(&xprt->xpt_extras);
+			return 2; /* only if free threads */
+		}
+	}
+	return 0;
 }
=20
 /*
@@ -345,8 +354,9 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp;
 	int cpu;
+	int todo =3D svc_xprt_has_something_to_do(xprt);
=20
-	if (!svc_xprt_has_something_to_do(xprt))
+	if (!todo)
 		return;
=20
 	cpu =3D get_cpu();
@@ -361,6 +371,19 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 		       "svc_xprt_enqueue: "
 		       "threads and transports both waiting??\n");
=20
+	if (todo =3D=3D 2) {
+		int free_needed =3D atomic_read(&xprt->xpt_extras) * 2;
+		list_for_each_entry(rqstp, &pool->sp_thread, rq_list)
+			if (--free_needed <=3D 0)
+				break;
+
+		if (free_needed > 0) {
+			/* Need more free threads before we allow this. */
+			atomic_add_unless(&xprt->xpt_extras, -1, 0);
+			goto out_unlock;
+		}
+	}
+
 	pool->sp_stats.packets++;
=20
 	/* Mark transport as busy. It will remain in this state until
@@ -371,6 +394,8 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
 		/* Don't enqueue transport while already enqueued */
 		dprintk("svc: transport %p busy, not enqueued\n", xprt);
+		if (todo =3D=3D 2)
+			atomic_add_unless(&xprt->xpt_extras, -1, 0);
 		goto out_unlock;
 	}
=20
@@ -466,6 +491,7 @@ static void svc_xprt_release(struct svc_rqst *rqstp)
 		printk(KERN_ERR "RPC request reserved %d but used %d\n",
 		       rqstp->rq_reserved,
 		       rqstp->rq_res.len);
+	atomic_add_unless(&xprt->xpt_extras, -1, 0);
=20
 	rqstp->rq_res.head[0].iov_len =3D 0;
 	svc_reserve(rqstp, 0);

--Sig_/v=V+/5jC/x7b75x9g.PIKkj
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUdzj4Tnsnt1WYoG5AQLrZA/+KtJp0o4GWZAeQlrIrGIis7PpqjqRtZ7C
sKl/nVE2/Qgv+o3BaPtwf4LlEBSrJzSxf0bCKTu92CVeptsH7X5j3r4V8oStUWsn
QpkNaTYyrSIlQeL3BIr6heI+m4zT+MaP4BsP85Bkk5NY0lNay0Sv258Jq/8FSbcd
Phgtg1JpPpwMcuXiAUz3DguVxgEMiA4hJ547fyXFrK5pNduyZYQIvNS95tP6lI5Z
03gMQU4Plqa0PYSWu/XH/av8srtuEW5V/VHxecuX8XeE3/6mLKVAQQALcFe3gpUA
fekozWXHxkC4J17VeHBSsCLAVZEvsIlBKP/LBFbVziN+EhGunZl7MPQBn/6c5PsV
uvmFoxeF3MSj3x7t/Y4FK35Yc60FWGkmABecTwY4mkz8ep5aFCT6YE0mxXo/jqjx
kf9RnplY1SPjt+ErfRdMRLVR71yBWI57iqi/N/eW2K1xzuq8pdGXKmzkzZJJyyx0
6KL0pwWG106oGq+XOGm/yDw9G7DWfR/wcKknyMtExLHPBj9Iv/artdfR2Tpo5h7u
Mw4FElZLHfQ8rVIFa+gMHvq+0G+tTeGdYtv16xxSK5Ch92oXKDqnpWrDyOIb/AgD
3NGcj1K6ibbHsZjLhvjJf+rmaKEkYYyQnzAd7z9VIIR4ZyvgRBswQdXgm0wUWT7b
xuevSvjZvS0=
=hzGa
-----END PGP SIGNATURE-----

--Sig_/v=V+/5jC/x7b75x9g.PIKkj--
