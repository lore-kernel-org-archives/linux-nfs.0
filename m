Return-Path: <SRS0=AoDj=NU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBEF3C43441
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 00:45:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 87F6020855
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 00:45:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87F6020855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727307AbeKIKXi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Nov 2018 05:23:38 -0500
Received: from mx2.suse.de ([195.135.220.15]:53690 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727076AbeKIKXi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Nov 2018 05:23:38 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 4D5A5AC6F;
        Fri,  9 Nov 2018 00:45:25 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Date:   Fri, 09 Nov 2018 11:45:17 +1100
Cc:     Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 22/23] SUNRPC: simplify auth_unix.
In-Reply-To: <C718BB53-55C5-47E2-AB92-C4ACB79496F1@oracle.com>
References: <154156285766.24086.14262073575778354276.stgit@noble> <154156395162.24086.1172828418426764708.stgit@noble> <4A3FA05E-EF4E-4857-A541-E863C5C6198D@oracle.com> <87va58wdkz.fsf@notabene.neil.brown.name> <C718BB53-55C5-47E2-AB92-C4ACB79496F1@oracle.com>
Message-ID: <87h8grw02q.fsf@notabene.neil.brown.name>
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

On Thu, Nov 08 2018, Chuck Lever wrote:
>
> Point taken, but having a single mempool for all RPC transports
> and users is also going to be a shared resource that can
> bottleneck.

Agreed.
mempools will only access the pre-allocated memory if a regular
kmalloc(GFP_NOWAIT) fails.  I asked an mm developer about this once as
it seemed backwards, and he pointed out that kmalloc is much more
optimised than mempools.  It often only accesses per-cpu resources,
which is much faster than taking a spinlock.  Learning that helped me
understand some of this stuff better.

>
> I guess that's an argument in favor of building creds on demand
> rather than keeping them in a hash table, isn't it. :-)

I think it is.  Thanks!!!

NeilBrown


>
>
>>> In addition, the comment near unx_marshal suggests we should
>>> cache the marshaled on-the-wire version of the credential instead
>>> of building it in the RPC Call buffer every time. That would
>>> require keeping the creds around.
>>=20
>> That comment has been there since 2.1.32 and has not be acted on.  There
>> seems little reason to expect that to change.  Caching doesn't seem to
>> have been found to be necessary in practice.
>>=20
>>>=20
>>> Have you measured a significant difference in throughput with
>>> this patch? Have you considered improving the lookup speed of
>>> the hash table by making the buckets into rb-trees, for example?
>>=20
>> No, I haven't measured.
>> I might have briefly considered changing to an rb-tree, but as the
>> current hashtable doesn't actually contain anything of value, I would
>> have quickly discarded the idea.
>>=20
>> If I wanted to further improve performance, I would look at ways to
>> bypass the "lookup_cred" step completely.
>> unx_marshal only needs the generic "struct cred", so there should be no
>> need to have a 'struct rpc_cred' at all.
>>=20
>> If this series is accepted, I'll (hopefully) look into seeing how
>> practical that is.
>>=20
>> Thanks again,
>> NeilBrown
>>=20
>>=20
>>>=20
>>>=20
>>>>  As the lookup can happen during write-out, use a mempool
>>>>  to ensure forward progress.
>>>>  This means that we cannot compare two credentials for
>>>>  equality by comparing the pointers, but we never do that anyway.
>>>>=20
>>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>>> ---
>>>> net/sunrpc/auth.c      |    1=20
>>>> net/sunrpc/auth_unix.c |  101 +++++++++++++++-------------------------=
--------
>>>> 2 files changed, 32 insertions(+), 70 deletions(-)
>>>>=20
>>>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>>>> index 867ea9834bde..a07a7c59d3a4 100644
>>>> --- a/net/sunrpc/auth.c
>>>> +++ b/net/sunrpc/auth.c
>>>> @@ -651,6 +651,7 @@ rpcauth_init_cred(struct rpc_cred *cred, const str=
uct auth_cred *acred,
>>>> 	INIT_LIST_HEAD(&cred->cr_lru);
>>>> 	refcount_set(&cred->cr_count, 1);
>>>> 	cred->cr_auth =3D auth;
>>>> +	cred->cr_flags =3D 0;
>>>> 	cred->cr_ops =3D ops;
>>>> 	cred->cr_expire =3D jiffies;
>>>> 	cred->cr_cred =3D get_cred(acred->cred);
>>>> diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
>>>> index bff113a411e0..387f6b3ffbea 100644
>>>> --- a/net/sunrpc/auth_unix.c
>>>> +++ b/net/sunrpc/auth_unix.c
>>>> @@ -11,16 +11,11 @@
>>>> #include <linux/types.h>
>>>> #include <linux/sched.h>
>>>> #include <linux/module.h>
>>>> +#include <linux/mempool.h>
>>>> #include <linux/sunrpc/clnt.h>
>>>> #include <linux/sunrpc/auth.h>
>>>> #include <linux/user_namespace.h>
>>>>=20
>>>> -struct unx_cred {
>>>> -	struct rpc_cred		uc_base;
>>>> -	kgid_t			uc_gid;
>>>> -	kgid_t			uc_gids[UNX_NGROUPS];
>>>> -};
>>>> -#define uc_uid			uc_base.cr_uid
>>>>=20
>>>> #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
>>>> # define RPCDBG_FACILITY	RPCDBG_AUTH
>>>> @@ -28,6 +23,7 @@ struct unx_cred {
>>>>=20
>>>> static struct rpc_auth		unix_auth;
>>>> static const struct rpc_credops	unix_credops;
>>>> +static mempool_t		*unix_pool;
>>>>=20
>>>> static struct rpc_auth *
>>>> unx_create(const struct rpc_auth_create_args *args, struct rpc_clnt *c=
lnt)
>>>> @@ -42,15 +38,6 @@ static void
>>>> unx_destroy(struct rpc_auth *auth)
>>>> {
>>>> 	dprintk("RPC:       destroying UNIX authenticator %p\n", auth);
>>>> -	rpcauth_clear_credcache(auth->au_credcache);
>>>> -}
>>>> -
>>>> -static int
>>>> -unx_hash_cred(struct auth_cred *acred, unsigned int hashbits)
>>>> -{
>>>> -	return hash_64(from_kgid(&init_user_ns, acred->cred->fsgid) |
>>>> -		((u64)from_kuid(&init_user_ns, acred->cred->fsuid) <<
>>>> -			(sizeof(gid_t) * 8)), hashbits);
>>>> }
>>>>=20
>>>> /*
>>>> @@ -59,53 +46,24 @@ unx_hash_cred(struct auth_cred *acred, unsigned in=
t hashbits)
>>>> static struct rpc_cred *
>>>> unx_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int fl=
ags)
>>>> {
>>>> -	return rpcauth_lookup_credcache(auth, acred, flags, GFP_NOFS);
>>>> -}
>>>> -
>>>> -static struct rpc_cred *
>>>> -unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int f=
lags, gfp_t gfp)
>>>> -{
>>>> -	struct unx_cred	*cred;
>>>> -	unsigned int groups =3D 0;
>>>> -	unsigned int i;
>>>> +	struct rpc_cred *ret =3D mempool_alloc(unix_pool, GFP_NOFS);
>>>>=20
>>>> 	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
>>>> 			from_kuid(&init_user_ns, acred->cred->fsuid),
>>>> 			from_kgid(&init_user_ns, acred->cred->fsgid));
>>>>=20
>>>> -	if (!(cred =3D kmalloc(sizeof(*cred), gfp)))
>>>> -		return ERR_PTR(-ENOMEM);
>>>> -
>>>> -	rpcauth_init_cred(&cred->uc_base, acred, auth, &unix_credops);
>>>> -	cred->uc_base.cr_flags =3D 1UL << RPCAUTH_CRED_UPTODATE;
>>>> -
>>>> -	if (acred->cred && acred->cred->group_info !=3D NULL)
>>>> -		groups =3D acred->cred->group_info->ngroups;
>>>> -	if (groups > UNX_NGROUPS)
>>>> -		groups =3D UNX_NGROUPS;
>>>> -
>>>> -	cred->uc_gid =3D acred->cred->fsgid;
>>>> -	for (i =3D 0; i < groups; i++)
>>>> -		cred->uc_gids[i] =3D acred->cred->group_info->gid[i];
>>>> -	if (i < UNX_NGROUPS)
>>>> -		cred->uc_gids[i] =3D INVALID_GID;
>>>> -
>>>> -	return &cred->uc_base;
>>>> -}
>>>> -
>>>> -static void
>>>> -unx_free_cred(struct unx_cred *unx_cred)
>>>> -{
>>>> -	dprintk("RPC:       unx_free_cred %p\n", unx_cred);
>>>> -	put_cred(unx_cred->uc_base.cr_cred);
>>>> -	kfree(unx_cred);
>>>> +	rpcauth_init_cred(ret, acred, auth, &unix_credops);
>>>> +	ret->cr_flags =3D 1UL << RPCAUTH_CRED_UPTODATE;
>>>> +	return ret;
>>>> }
>>>>=20
>>>> static void
>>>> unx_free_cred_callback(struct rcu_head *head)
>>>> {
>>>> -	struct unx_cred *unx_cred =3D container_of(head, struct unx_cred, uc=
_base.cr_rcu);
>>>> -	unx_free_cred(unx_cred);
>>>> +	struct rpc_cred *rpc_cred =3D container_of(head, struct rpc_cred, cr=
_rcu);
>>>> +	dprintk("RPC:       unx_free_cred %p\n", rpc_cred);
>>>> +	put_cred(rpc_cred->cr_cred);
>>>> +	mempool_free(rpc_cred, unix_pool);
>>>> }
>>>>=20
>>>> static void
>>>> @@ -115,30 +73,32 @@ unx_destroy_cred(struct rpc_cred *cred)
>>>> }
>>>>=20
>>>> /*
>>>> - * Match credentials against current process creds.
>>>> - * The root_override argument takes care of cases where the caller may
>>>> - * request root creds (e.g. for NFS swapping).
>>>> + * Match credentials against current the auth_cred.
>>>> */
>>>> static int
>>>> -unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
>>>> +unx_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
>>>> {
>>>> -	struct unx_cred	*cred =3D container_of(rcred, struct unx_cred, uc_ba=
se);
>>>> 	unsigned int groups =3D 0;
>>>> 	unsigned int i;
>>>>=20
>>>> +	if (cred->cr_cred =3D=3D acred->cred)
>>>> +		return 1;
>>>>=20
>>>> -	if (!uid_eq(cred->uc_uid, acred->cred->fsuid) || !gid_eq(cred->uc_gi=
d, acred->cred->fsgid))
>>>> +	if (!uid_eq(cred->cr_cred->fsuid, acred->cred->fsuid) || !gid_eq(cre=
d->cr_cred->fsgid, acred->cred->fsgid))
>>>> 		return 0;
>>>>=20
>>>> 	if (acred->cred && acred->cred->group_info !=3D NULL)
>>>> 		groups =3D acred->cred->group_info->ngroups;
>>>> 	if (groups > UNX_NGROUPS)
>>>> 		groups =3D UNX_NGROUPS;
>>>> +	if (cred->cr_cred->group_info =3D=3D NULL)
>>>> +		return groups =3D=3D 0;
>>>> +	if (groups !=3D cred->cr_cred->group_info->ngroups)
>>>> +		return 0;
>>>> +
>>>> 	for (i =3D 0; i < groups ; i++)
>>>> -		if (!gid_eq(cred->uc_gids[i], acred->cred->group_info->gid[i]))
>>>> +		if (!gid_eq(cred->cr_cred->group_info->gid[i], acred->cred->group_i=
nfo->gid[i]))
>>>> 			return 0;
>>>> -	if (groups < UNX_NGROUPS && gid_valid(cred->uc_gids[groups]))
>>>> -		return 0;
>>>> 	return 1;
>>>> }
>>>>=20
>>>> @@ -150,9 +110,10 @@ static __be32 *
>>>> unx_marshal(struct rpc_task *task, __be32 *p)
>>>> {
>>>> 	struct rpc_clnt	*clnt =3D task->tk_client;
>>>> -	struct unx_cred	*cred =3D container_of(task->tk_rqstp->rq_cred, stru=
ct unx_cred, uc_base);
>>>> +	struct rpc_cred	*cred =3D task->tk_rqstp->rq_cred;
>>>> 	__be32		*base, *hold;
>>>> 	int		i;
>>>> +	struct group_info *gi =3D cred->cr_cred->group_info;
>>>>=20
>>>> 	*p++ =3D htonl(RPC_AUTH_UNIX);
>>>> 	base =3D p++;
>>>> @@ -163,11 +124,12 @@ unx_marshal(struct rpc_task *task, __be32 *p)
>>>> 	 */
>>>> 	p =3D xdr_encode_array(p, clnt->cl_nodename, clnt->cl_nodelen);
>>>>=20
>>>> -	*p++ =3D htonl((u32) from_kuid(&init_user_ns, cred->uc_uid));
>>>> -	*p++ =3D htonl((u32) from_kgid(&init_user_ns, cred->uc_gid));
>>>> +	*p++ =3D htonl((u32) from_kuid(&init_user_ns, cred->cr_cred->fsuid));
>>>> +	*p++ =3D htonl((u32) from_kgid(&init_user_ns, cred->cr_cred->fsgid));
>>>> 	hold =3D p++;
>>>> -	for (i =3D 0; i < UNX_NGROUPS && gid_valid(cred->uc_gids[i]); i++)
>>>> -		*p++ =3D htonl((u32) from_kgid(&init_user_ns, cred->uc_gids[i]));
>>>> +	if (gi)
>>>> +		for (i =3D 0; i < UNX_NGROUPS && i < gi->ngroups; i++)
>>>> +			*p++ =3D htonl((u32) from_kgid(&init_user_ns, gi->gid[i]));
>>>> 	*hold =3D htonl(p - hold - 1);		/* gid array length */
>>>> 	*base =3D htonl((p - base - 1) << 2);	/* cred length */
>>>>=20
>>>> @@ -214,12 +176,13 @@ unx_validate(struct rpc_task *task, __be32 *p)
>>>>=20
>>>> int __init rpc_init_authunix(void)
>>>> {
>>>> -	return rpcauth_init_credcache(&unix_auth);
>>>> +	unix_pool =3D mempool_create_kmalloc_pool(16, sizeof(struct rpc_cred=
));
>>>> +	return unix_pool ? 0 : -ENOMEM;
>>>> }
>>>>=20
>>>> void rpc_destroy_authunix(void)
>>>> {
>>>> -	rpcauth_destroy_credcache(&unix_auth);
>>>> +	mempool_destroy(unix_pool);
>>>> }
>>>>=20
>>>> const struct rpc_authops authunix_ops =3D {
>>>> @@ -228,9 +191,7 @@ const struct rpc_authops authunix_ops =3D {
>>>> 	.au_name	=3D "UNIX",
>>>> 	.create		=3D unx_create,
>>>> 	.destroy	=3D unx_destroy,
>>>> -	.hash_cred	=3D unx_hash_cred,
>>>> 	.lookup_cred	=3D unx_lookup_cred,
>>>> -	.crcreate	=3D unx_create_cred,
>>>> };
>>>>=20
>>>> static
>>>>=20
>>>>=20
>>>=20
>>> --
>>> Chuck Lever
>
> --
> Chuck Lever

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlvk2J4ACgkQOeye3VZi
gbkufA/9FgmAQYsP+8Ict7s0FzDsxoy5gJup8U+y6Awt9jnwXBw/yvtY4LU24/1A
uv9rPnG+huqYEJLc+goJWaTbclCUW7jyxSWowkTTl1wwfo1bSxJcPSNakO16waEW
mZQ7djS6to43OSZr+6sasP/TrMckCHf6NL1KSmyek4K7HuBPrjXx7d2ZEupGKIw2
bW2Jmse7E0o1y3th9VUInrTI9twWZ454XLXlWl4tBadW9xgXJwAhra5P2leSgajG
TQj4IqnMkpJL8PgNjyGW/I4lByIQ+3YGR+DEKOsYc5nJYnYqyP53/IfMKo0jAf0K
qRv1B6aqnJ+wrdgBEqivYgo9QSJ87LP738hbkbVSt5zB0cZbr50lICmK3MSSrbz9
RFk3Yi3bxJsNKQ/pN9QWjaXktJ8p33L7HUUsRPT4Z0sBp4EKgCVdn2Illb4Uugsw
eIdRr680lqlZrf4QX85P+6XhiRu0rq8/PXwacovUbkxU3Lj6Bxj3XN2HUYocA+MD
JTtSa1kZVoIoke7qaOJWCQufpaKNa6X4tPMMaSTB98PxkYlJ5Yye3Y1ylj5KM6bJ
/zNllNwuQaFbJxqg27zXJn3CP0qWHUvgR2cOX3ZQs3VpVMKglwzVT+aH6AWWly6F
ZcECjEFsOM+WJQDB5C0A8/C2vAmteYKU5E3x3VIy4CVZZGZfZJ0=
=YKjy
-----END PGP SIGNATURE-----
--=-=-=--
