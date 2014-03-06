Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46863 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbaCFFuM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 00:50:12 -0500
Date: Thu, 6 Mar 2014 16:50:04 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/8] sunrpc/auth: add 'rcu_walk' arg to rpc_lookup_cred.
Message-ID: <20140306165004.46c0d59e@notabene.brown>
In-Reply-To: <B5AA3471-423B-436C-B3A1-4579917913F6@primarydata.com>
References: <20140305025813.27421.23871.stgit@notabene.brown>
	<20140305030028.27421.14840.stgit@notabene.brown>
	<B5AA3471-423B-436C-B3A1-4579917913F6@primarydata.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/iP/204=+=3Dx9cfijVzff1E"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/iP/204=+=3Dx9cfijVzff1E
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Mar 2014 09:43:03 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

>=20
> On Mar 4, 2014, at 22:00, NeilBrown <neilb@suse.de> wrote:
>=20
> > This arg causes rpc_lookup_cred to set RPCAUTH_LOOKUP_RCU when
> > performing the credential lookup.  Most callers pass '0',
> > except nfs_permission() which passes (mask & MAY_NOT_BLOCK).
> >=20
>=20
> Why not just add a function rpc_lookup_cred_rcu() or rpc_lookup_cred_nobl=
ock() to cater for that one exception?

That certainly makes the patch smaller, and is probably a net win.

Thanks.
NeilBrown

=46rom b805a8f79a5527676b96b9654dd26d1b5bc03691 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Tue, 4 Mar 2014 15:28:43 +1100
Subject: [PATCH] sunrpc/auth: add rpc_lookup_cred_nonblock

This version of rpc_lookup_cred  sets RPCAUTH_LOOKUP_RCU when
performing the credential lookup.
nfs_permission() uses it in RCU-walk mode.

This doesn't speed up nfs_permission yet as it is not yet
safe to call nfs_do_access with the returned cred.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 7530acdc5c42..ede873e88acc 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2318,10 +2318,12 @@ force_lookup:
 		goto out_notsup;
=20
 	if (mask & MAY_NOT_BLOCK)
-		return -ECHILD;
-
-	cred =3D rpc_lookup_cred();
+		cred =3D rpc_lookup_cred_nonblock();
+	else
+		cred =3D rpc_lookup_cred();
 	if (!IS_ERR(cred)) {
+		if (mask & MAY_NOT_BLOCK)
+			return -ECHILD;
 		res =3D nfs_do_access(inode, cred, mask);
 		put_rpccred(cred);
 	} else
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 3f158ae1d6fd..28ffc8476875 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -154,6 +154,7 @@ void			rpc_destroy_generic_auth(void);
 void 			rpc_destroy_authunix(void);
=20
 struct rpc_cred *	rpc_lookup_cred(void);
+struct rpc_cred *	rpc_lookup_cred_nonblock(void);
 struct rpc_cred *	rpc_lookup_machine_cred(const char *service_name);
 int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index ed04869b2d4f..632f6eec8111 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -38,6 +38,11 @@ struct rpc_cred *rpc_lookup_cred(void)
 }
 EXPORT_SYMBOL_GPL(rpc_lookup_cred);
=20
+struct rpc_cred *rpc_lookup_cred_nonblock(void)
+{
+	return rpcauth_lookupcred(&generic_auth, 1);
+}
+
 /*
  * Public call interface for looking up machine creds.
  */

--Sig_/iP/204=+=3Dx9cfijVzff1E
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIUAwUBUxgMjDnsnt1WYoG5AQLdVg/3aN+4JWNCY23T7ZtlzMPVRzaXcmFEvlGB
GFhQfY5KoozGMuevPTmqmrlruzZsiQxLQ6QDELePkHhDUzOQpSVqJKb7Dtd4t092
BlOarpcYwS6Y4TcWnwPjjZ5Z4F7qySVdq0YyF7LDHXEY4Jv8T8pZvFX8oh6V5sHU
BrYR07lScE7aCZn1CgS94QSod3DSp9dAffngagVgQaIiuny3PUTodjJTtnJpjsfy
YX9OJVeiIi/AGvFQWH2CTHq1aXtjAk/vj0IjV/+kP8o+1NmaefQOIGfgZgZsrjxi
Bqv85IgAjRenRrg3e0gdh3V8TvAP6kHkdoDe0EGSGHI37px8QZP3lFjr6f1TVSrB
U/EzdTeWQEXmsRh4Rf77ezJqDGKtlPdKweB9VYuw+LjsdcHRc0k9sq8hMwzENwYi
S8vbQXqjkM6o6qACG/uDhuUq4+DRBt0LAAWgMjGoaY48ESntJ5Ufqzi3FAX5oHLF
p7djVe+vxs9FZTuhDjpQihV/6jqz6YVE9aSoT1KtXZh1ir9y2p6QVn0qqAJ9W33u
q2MYuYUFdas7jzusZh4+/+6rxg3CHrPhrw0K17xd8qRVq0HmINmIDLML0wxMphuU
zxodf94FWFTEverEBIlvMcqttLhHmSOXjnN3pwMXSxSKcWXRebEIZr99IIOtLJOB
jz4TKPzddA==
=jQCW
-----END PGP SIGNATURE-----

--Sig_/iP/204=+=3Dx9cfijVzff1E--
