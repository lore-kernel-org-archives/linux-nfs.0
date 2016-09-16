Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:32435 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751968AbcIPVhu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2016 17:37:50 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Frank Sorenson <sorenson@redhat.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: include gid in the rpc_cred_cache hash
Date: Fri, 16 Sep 2016 21:37:39 +0000
Message-ID: <7EC0B2B1-CE1A-4509-9FE2-A5D6529626DA@primarydata.com>
References: <1474056735-4008-1-git-send-email-sorenson@redhat.com>
In-Reply-To: <1474056735-4008-1-git-send-email-sorenson@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 16, 2016, at 16:12, Frank Sorenson <sorenson@redhat.com> wrote:
>=20
> The current rpc_cred_cache hashtable uses only the uid in the hash
> computation.  rpc_creds created with the same uid but different
> gids will all go on the same hash chain.
>=20
> In certain usage patterns, such as the following, this can lead to
> extremely long hash chains for these uids, while the rest of the
> hashtable remains nearly empty. This causes very high cpu usage
> in rpcauth_lookup_credcache, and slow performance for that uid.
>=20
>    for (i =3D 0 ; i < 100000 ; i++) {
>        setregid(-1, i);
>        stat(path, &st);
>    }
>=20
> Add the gid to the hash algorithm to distribute the rpc_creds
> throughout the cache to avoid long individual hash chains.
>=20
> Signed-off-by: Frank Sorenson <sorenson@redhat.com>
>=20
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index a7e42f9..2260e58 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -538,6 +538,14 @@ rpcauth_cache_enforce_limit(void)
> =09rpcauth_cache_do_shrink(nr_to_scan);
> }
>=20
> +static unsigned int
> +rpcauth_hash_acred(struct auth_cred *acred, unsigned int hashbits)
> +{
> +=09return hash_64(from_kgid(&init_user_ns, acred->gid) |
> +=09=09(from_kuid(&init_user_ns, acred->uid) << (sizeof(gid_t) * 8)),
> +=09=09hashbits);
> +}
> +

NACK. The choice of only using the uid when hashing was deliberate; RPCSEC_=
GSS is keyed only on the uid=85=20
If you want to do this in order to accelerate AUTH_SYS lookups, then you ne=
ed to push the hashing down to the auth flavour ops.

