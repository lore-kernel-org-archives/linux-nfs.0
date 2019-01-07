Return-Path: <SRS0=jPLZ=PP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED136C43387
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 06:54:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C6E802085A
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 06:54:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726448AbfAGGyA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Jan 2019 01:54:00 -0500
Received: from mx2.suse.de ([195.135.220.15]:60700 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725550AbfAGGyA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Jan 2019 01:54:00 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
X-Amavis-Alert: BAD HEADER SECTION, Duplicate header field: "Cc"
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 52A15AC3A;
        Mon,  7 Jan 2019 06:53:59 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 07 Jan 2019 17:53:52 +1100
Cc:     Dan Carpenter <dan.carpenter@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: remove pointless test in unx_match()
In-Reply-To: <20181221091024.GF2735@kadam>
References: <20181221091024.GF2735@kadam>
Message-ID: <87d0p9j6v3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


As reported by Dan Carpenter, this test for acred->cred being set is
inconsistent with the dereference of the pointer a few lines earlier.

An 'auth_cred' *always* has ->cred set - every place that creates one
initializes this field, often as the first thing done.

So remove this test.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/auth_unix.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 387f6b3ffbea..770e338a9b11 100644
=2D-- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -87,7 +87,7 @@ unx_match(struct auth_cred *acred, struct rpc_cred *cred,=
 int flags)
 	if (!uid_eq(cred->cr_cred->fsuid, acred->cred->fsuid) || !gid_eq(cred->cr=
_cred->fsgid, acred->cred->fsgid))
 		return 0;
=20
=2D	if (acred->cred && acred->cred->group_info !=3D NULL)
+	if (acred->cred->group_info !=3D NULL)
 		groups =3D acred->cred->group_info->ngroups;
 	if (groups > UNX_NGROUPS)
 		groups =3D UNX_NGROUPS;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlwy94AACgkQOeye3VZi
gbkmNBAAsEkiHcQGNncfs9tfsmt8mh8RCkAh0RbTkIbkLfsBFZp4a/8JXvl3Nzkl
YjwpgsLPnVFj729GW6IosR9UzEITxYNaBKrb09YP95Z1mWqIAxzN6tPeL7XBRHcY
EVGOS/48O6eA/GXZqFkTfjEs2mdDoFd6gMR2PvEr9C5GaDMvezgy0Q0Zk6QALFcP
Ma/ct9AAG76Rl45IvzuyqUqWFY1zJ5u+dfrBYvnPA3G/0padbnl1pE0Gmq79xryC
RUwCdsT9kk6P2gs8U9841TekMpXrkMvlRTVvH4QIsRAcLKDmpfeW6juAtqIJvBSO
bBotskbQzTmC7aMAzW90GZr9Zux0RobfX31ma8MnV6AnAA9/JwLr+MfXKcZq3tiM
82Bt0606yaYGa9lT0bdq6M9RYmnwfQ8O/zOU3KANRVB9d63onlTs2FAIQFQB11H1
injmkSBTlj19rvas9IACO6bl+xefJrwsObPpxTfa+JyBZs3z1OC/IBxlWt4WAKR/
dKYHCKb4aNwLSABqxIKPmug85nqcd2OWI1SFaS7QbODvoMOWc9/Nhq5XDLiwBHwh
LdiZI5GcW4GtjKap9UvJ9Eks88Xwp73U5oNJuCgLVlYYpyRkmaruoxTZqtG82RSf
FUSjXyYhDJAgSPqZYNcrxmqUoiyH2TL4ZPFE3QSKIAOSJinFxNY=
=UTAX
-----END PGP SIGNATURE-----
--=-=-=--
