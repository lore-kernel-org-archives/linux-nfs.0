Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=BIGNUM_EMAILS,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0BA7C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 23:31:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C9AF420869
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 23:31:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728966AbeLSXbv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 18:31:51 -0500
Received: from mx2.suse.de ([195.135.220.15]:47520 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727703AbeLSXbu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 18:31:50 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 213C1B013;
        Wed, 19 Dec 2018 23:31:49 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Dan Carpenter <dan.carpenter@oracle.com>, jlayton@kernel.org
Date:   Thu, 20 Dec 2018 10:31:42 +1100
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [bug report] nfs: make sillyrename an async operation
In-Reply-To: <20181219103329.GA28137@kadam>
References: <20181219103329.GA28137@kadam>
Message-ID: <87a7l1um8x.fsf@notabene.neil.brown.name>
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

On Wed, Dec 19 2018, Dan Carpenter wrote:

> [ Ancient code.  But NeilB changed get_cred() recently so Smatch thinks
>   it understands it now.  - dan ]
>
> Hello Jeff Layton,
>
> The patch d3d4152a5d59: "nfs: make sillyrename an async operation"
> from Sep 17, 2010, leads to the following static checker warning:
>
> 	fs/nfs/unlink.c:351 nfs_async_rename()
> 	warn: 'data->cred' isn't an ERR_PTR

It would have been impressive to determine that at the time, though I
think it was true.
At the time it was rpc_lookup_cred(), that provided data->cred.
That was
        return rpcauth_lookupcred(&generic_auth, 0);
of which the key line is :
        ret =3D auth->au_ops->lookup_cred(auth, &acred, flags);

and generic_auth.au_ops->lookup_cred was
        return rpcauth_lookup_credcache(&generic_auth, acred, flags);

which can only return an error if
              cred->cr_ops->cr_init !=3D NULL &&
and
                int res =3D cred->cr_ops->cr_init(auth, cred);
                if (res < 0) {

There is no generic_auth.au_ops->cr_init, so no error can be return.

It is much easier to determine that now.

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Date: Thu, 20 Dec 2018 10:29:55 +1100
Subject: [PATCH] NFS: remove unnecessary test for IS_ERR(cred)

As gte_current_cred() cannot return an error,
this test is not necessary.
It hasn't been necessary for years, but it wasn't so obvious
before.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/unlink.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index a227ab7d6891..79b97b3c4427 100644
=2D-- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -348,11 +348,6 @@ nfs_async_rename(struct inode *old_dir, struct inode *=
new_dir,
 	task_setup_data.callback_data =3D data;
=20
 	data->cred =3D get_current_cred();
=2D	if (IS_ERR(data->cred)) {
=2D		struct rpc_task *task =3D ERR_CAST(data->cred);
=2D		kfree(data);
=2D		return task;
=2D	}
=20
 	msg.rpc_argp =3D &data->args;
 	msg.rpc_resp =3D &data->res;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlwa1N8ACgkQOeye3VZi
gblm6BAAimmZQX9ck4fTdE45HDqw/+UCWAXw3bt1BHWFJU39y5MAFBFPWyN77t8A
XQINl5uQUhCW9fKyT83UJoILngE+k0BhJlOgHG4MnKc/20GelYjGvRaqi2o+xLoA
40NUU9sIc//+YA6rEncrP5u5fo64KL/7HEOXrtPIGOK8s3Rsp+//wZ3wdKktzfkC
EzTZygTT8sMdAc/1VaEloaVL1gulaEdYNTEV7kbVTUWeh5Kv5xTB0LkpbWZILayl
6We6+ewTJ4+W01eRyNKy8qukPBV1+TE2asgXi9ZBCEs9QfLZZigKiNNoSoXpmZSo
972iJeSce74UEZ8uW9d4Gw/Wf5RPKnuL3qRP1Abp5xlB9AMQegCWGn/Q7Ia1w75O
WZWB5oSKaEaFPjbYT68Cce5k0AFjLno2no/5BHWsLjSQXzjC0OlJUGrDOA6ffBse
3KnlflX4rY7tQwsJtUloGbsQSrWEGighNMaM75q4h4fh07TqhTYi/bWN5x1Eeauv
CnBPXAH86W9dN8AKhHfepvSNs//xR5AvtogzDmfwmjaRoRZPgwIbkfntI450H5lL
ouAPO1lC0yOxwi4jkq7x8m58HuJm5VV6MnFXUQFnUkrLBZyH4mFWRgeCmwTG8oON
qw/4ViBGxcWocDhDHBneGjnJlnlIMtS8JKds85nD/RGXZaQc9XI=
=/s+/
-----END PGP SIGNATURE-----
--=-=-=--
