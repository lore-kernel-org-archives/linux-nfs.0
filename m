Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56425 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751528AbdDRA0A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Apr 2017 20:26:00 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Tue, 18 Apr 2017 10:25:20 +1000
Cc: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
In-Reply-To: <20170414150940.GB5362@fieldses.org>
References: <20170414150440.GA5362@fieldses.org> <20170414150940.GB5362@fieldses.org>
Message-ID: <87h91mtvdb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 14 2017, J. Bruce Fields wrote:

> (Cc'd you, Neil, partly on the off chance you might have a better idea
> where this came from.  Looks to me like it may have been there forever,
> but, I haven't looked too hard yet.)
>

Hi Bruce,
 I can't say that I like this patch at all.

The problem is that:

	pages =3D size / PAGE_SIZE + 1; /* extra page as we hold both request and =
reply.
				       * We assume one is at most one page
				       */

this assumption is never verified.
To my mind, the "obvious" way to verify this assumption is that an
attempt to generate a multi-page reply should fail if there was a
multi-page request.
Failing if there was a little bit of extra noise at the end of the
request seems harsher than necessary, and could result in a regression.

We already know how big replies can get, so we can perform a complete
sanity check quite early:

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a08aeb56b8e4..14f4d425cf8c 100644
=2D-- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1196,6 +1196,12 @@ svc_process_common(struct svc_rqst *rqstp, struct kv=
ec *argv, struct kvec *resv)
 		goto err_bad_proc;
 	rqstp->rq_procinfo =3D procp;
=20
+	if ((procp->pc_xdrressize =3D=3D 0 ||
+	     procp->pc_xdrressize > XDR_QUADLEN(PAGE_SIZE)) &&
+	    rqstp->rq_arg.len > PAGE_SIZE)
+		/* The assumption about request/reply sizes in svc_init_buffer() is viol=
ated! */
+		goto err_garbage;
+
 	/* Syntactic check complete */
 	serv->sv_stats->rpccnt++;
=20

I haven't tested this at all and haven't even convinced myself that
it covers every case (though I cannot immediately think of any likely
corners).

Does it address your test case?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlj1XPAACgkQOeye3VZi
gbnMCA//ZLiXvmOMYg4RbEyK2rXY07MdTCQEkyb6PYZVZh/tEbdwtRDsf/a1hzwK
loU27YMU1O8pVI8N8bV9/yFIRDKfqj3IyowsOi4/pFEiublHE3ner1gxJbj1aR+L
Z9wQYZToYiwVmoUhbZxXydP4TMuMqXbhaJ03gzGrovZXSg5lgV+A+oQw6j+YE5ag
WRgiTPN/wyMMYy9Y0nvjZVh2LlDYCP8IRPJPi7otwcGYnZSkddca0wmvrcClE9S8
0MKqz5RCuSvf+x2sfR/ye4XZdtsIheQ61QlfDB1O/YMQyuT//Hj9TqX7DGqneVxo
N9KBob9ubE2xdbl1wcLpCOO2K0aNudKzk5v6sIAhpdFLyRWQdJysdVYzfi+gsF7l
gsYabD8xYJF1Lgq7HfXvdTF0skU48vc5JwQTtDmLLdyUrEQbVfazpZ5Y/eWttjq4
7Sr9d7fJDR/STd5APVlJrBvjkV3vgLYKhnJ1Yuy4JZ2kV1H8iTD5ZLwCvRlo7pp4
LQyxGgjEh4eWpgwFSC/vsPM2pmCvyuU2BmkRLXAAhmCSzZ6XK5/h9seYdmUohpNN
1X2h44QMf5Dlg8bl1IgepwLSQoWtkyhhpOA+cV2GBXgMEqMpgpZf/QNErdsvW920
H112RNrjt+fP23x8qqmfKzkHiYvsK6KdNi+za6IbWxiStJTv2CA=
=MLZy
-----END PGP SIGNATURE-----
--=-=-=--
