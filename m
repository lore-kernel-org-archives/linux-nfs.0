Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:36946 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758674Ab3BGP6g convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2013 10:58:36 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] SUNRPC: Refactor nfsd4_do_encode_secinfo()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130207150213.GC3222@fieldses.org>
Date: Thu, 7 Feb 2013 10:58:25 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <87316F41-4E5E-473C-A372-0AFC6721A355@oracle.com>
References: <20130201220308.13518.82164.stgit@seurat.1015granger.net> <20130207150213.GC3222@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 7, 2013, at 10:02 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Fri, Feb 01, 2013 at 05:43:44PM -0500, Chuck Lever wrote:
>> Clean up.  This matches a similar API for the client side, and
>> keeps ULP fingers out the of the GSS mech switch.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Acked-by: J. Bruce Fields <bfields@redhat.com>
>> ---
>> 
>> Bruce-
>> 
>> This version of the patch follows the existing logic in
>> nfsd4_do_encode_secinfo(): If the RPC layer can't find GSS info
>> that matches an export security flavor, it assumes the flavor is
>> not a GSS pseudoflavor, and simply puts it on the wire.
>> 
>> However, if the below XDR encoding logic is given a legitimate GSS
>> pseudoflavor but the RPC layer says it does not support that
>> pseudoflavor for some reason, then we leak GSS pseudoflavor numbers
>> onto the wire.
>> 
>> I confirmed this happens by blacklisting rpcsec_gss_krb5, then
>> attempted a client transition from the pseudo-fs to a Kerberos-only
>> share.  The client received a flavor list containing the Kerberos
>> pseudoflavor numbers, rather than GSS tuples.
>> 
>> The encoder logic can check that each pseudoflavor is less than
>> MAXFLAVOR before writing it into the buffer, to prevent this.  But
>> after "nflavs" is written into the XDR buffer, the encoder can't
>> skip writing flavor information into the buffer when it discovers
>> the RPC layer doesn't support that flavor.
>> 
>> Is there some way of writing "nflavs" into the XDR buffer after
>> the loop that writes the flavor information is complete?
> 
> Yes, you can save a pointer and then go back and fill that in--see
> encode_fattr for an example.

Thanks, I will submit an additional patch that describes this issue and fixes it.

I asked David Noveck, as one of the authors of RFC 3530, whether an NFS server should return a zero-length flavor list or an error if SECINFO can't find any flavors a client is allowed to use. His opinion was to return NFS4_OK and a zero-length flavor list.


> 
> --b.
> 
>> 
>> What if "nflavs" turns out to be zero?  RFC 3530bis, 15.33.4 does
>> not explicitly say what should be done if the array of security
>> mechanisms for that client and file handle contains zero items.
>> 
>> Or is there a better way to handle this situation?  Also, should we
>> care about this scenario?
>> 
>> 
>> fs/nfsd/nfs4xdr.c                     |   24 +++++++++++------------
>> include/linux/sunrpc/auth.h           |    2 ++
>> include/linux/sunrpc/gss_api.h        |    3 +++
>> net/sunrpc/auth.c                     |   34 +++++++++++++++++++++++++++++++++
>> net/sunrpc/auth_gss/auth_gss.c        |    1 +
>> net/sunrpc/auth_gss/gss_mech_switch.c |   34 +++++++++++++++++++++++++++++++--
>> 6 files changed, 83 insertions(+), 15 deletions(-)
>> 
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 0dc1158..424f5a2 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -3127,10 +3127,9 @@ nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
>> 
>> static __be32
>> nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
>> -			 __be32 nfserr,struct svc_export *exp)
>> +			 __be32 nfserr, struct svc_export *exp)
>> {
>> -	int i = 0;
>> -	u32 nflavs;
>> +	u32 i, nflavs;
>> 	struct exp_flavor_info *flavs;
>> 	struct exp_flavor_info def_flavs[2];
>> 	__be32 *p;
>> @@ -3161,30 +3160,29 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
>> 	WRITE32(nflavs);
>> 	ADJUST_ARGS();
>> 	for (i = 0; i < nflavs; i++) {
>> -		u32 flav = flavs[i].pseudoflavor;
>> -		struct gss_api_mech *gm = gss_mech_get_by_pseudoflavor(flav);
>> +		struct rpcsec_gss_info info;
>> 
>> -		if (gm) {
>> +		if (rpcauth_get_gssinfo(flavs[i].pseudoflavor, &info) == 0) {
>> 			RESERVE_SPACE(4);
>> 			WRITE32(RPC_AUTH_GSS);
>> 			ADJUST_ARGS();
>> -			RESERVE_SPACE(4 + gm->gm_oid.len);
>> -			WRITE32(gm->gm_oid.len);
>> -			WRITEMEM(gm->gm_oid.data, gm->gm_oid.len);
>> +			RESERVE_SPACE(4 + info.oid.len);
>> +			WRITE32(info.oid.len);
>> +			WRITEMEM(info.oid.data, info.oid.len);
>> 			ADJUST_ARGS();
>> 			RESERVE_SPACE(4);
>> -			WRITE32(0); /* qop */
>> +			WRITE32(info.qop);
>> 			ADJUST_ARGS();
>> 			RESERVE_SPACE(4);
>> -			WRITE32(gss_pseudoflavor_to_service(gm, flav));
>> +			WRITE32(info.service);
>> 			ADJUST_ARGS();
>> -			gss_mech_put(gm);
>> 		} else {
>> 			RESERVE_SPACE(4);
>> -			WRITE32(flav);
>> +			WRITE32(flavs[i].pseudoflavor);
>> 			ADJUST_ARGS();
>> 		}
>> 	}
>> +
>> out:
>> 	if (exp)
>> 		exp_put(exp);
>> diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
>> index 476e97c..c34ac17 100644
>> --- a/include/linux/sunrpc/auth.h
>> +++ b/include/linux/sunrpc/auth.h
>> @@ -105,6 +105,7 @@ struct rpc_authops {
>> 	void			(*pipes_destroy)(struct rpc_auth *);
>> 	int			(*list_pseudoflavors)(rpc_authflavor_t *, int);
>> 	rpc_authflavor_t	(*info2flavor)(struct rpcsec_gss_info *);
>> +	int			(*flavor2info)(rpc_authflavor_t, struct rpcsec_gss_info *);
>> };
>> 
>> struct rpc_credops {
>> @@ -140,6 +141,7 @@ int			rpcauth_unregister(const struct rpc_authops *);
>> struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
>> void			rpcauth_release(struct rpc_auth *);
>> rpc_authflavor_t	rpcauth_get_pseudoflavor(rpc_authflavor_t, struct rpcsec_gss_info *);
>> +int			rpcauth_get_gssinfo(rpc_authflavor_t, struct rpcsec_gss_info *);
>> int			rpcauth_list_flavors(rpc_authflavor_t *, int);
>> struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int);
>> void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
>> diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
>> index e8299b2..dc1e51b 100644
>> --- a/include/linux/sunrpc/gss_api.h
>> +++ b/include/linux/sunrpc/gss_api.h
>> @@ -132,6 +132,9 @@ void gss_mech_unregister(struct gss_api_mech *);
>> /* Given a GSS security tuple, look up a pseudoflavor */
>> rpc_authflavor_t gss_mech_info2flavor(struct rpcsec_gss_info *);
>> 
>> +/* Given a pseudoflavor, look up a GSS security tuple */
>> +int gss_mech_flavor2info(rpc_authflavor_t, struct rpcsec_gss_info *);
>> +
>> /* Returns a reference to a mechanism, given a name like "krb5" etc. */
>> struct gss_api_mech *gss_mech_get_by_name(const char *);
>> 
>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>> index ec18827..4c551f9 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -158,6 +158,40 @@ rpcauth_get_pseudoflavor(rpc_authflavor_t flavor, struct rpcsec_gss_info *info)
>> EXPORT_SYMBOL_GPL(rpcauth_get_pseudoflavor);
>> 
>> /**
>> + * rpcauth_get_gssinfo - find GSS tuple matching a GSS pseudoflavor
>> + * @pseudoflavor: GSS pseudoflavor to match
>> + * @info: rpcsec_gss_info structure to fill in
>> + *
>> + * Returns zero and fills in "info" if pseudoflavor matches a
>> + * supported mechanism.
>> + */
>> +int
>> +rpcauth_get_gssinfo(rpc_authflavor_t pseudoflavor, struct rpcsec_gss_info *info)
>> +{
>> +	rpc_authflavor_t flavor = pseudoflavor_to_flavor(pseudoflavor);
>> +	const struct rpc_authops *ops;
>> +	int result;
>> +
>> +	if ((ops = auth_flavors[flavor]) == NULL)
>> +		request_module("rpc-auth-%u", flavor);
>> +	spin_lock(&rpc_authflavor_lock);
>> +	ops = auth_flavors[flavor];
>> +	if (ops == NULL || !try_module_get(ops->owner)) {
>> +		spin_unlock(&rpc_authflavor_lock);
>> +		return -ENOENT;
>> +	}
>> +	spin_unlock(&rpc_authflavor_lock);
>> +
>> +	result = -ENOENT;
>> +	if (ops->flavor2info != NULL)
>> +		result = ops->flavor2info(pseudoflavor, info);
>> +
>> +	module_put(ops->owner);
>> +	return result;
>> +}
>> +EXPORT_SYMBOL_GPL(rpcauth_get_gssinfo);
>> +
>> +/**
>>  * rpcauth_list_flavors - discover registered flavors and pseudoflavors
>>  * @array: array to fill in
>>  * @size: size of "array"
>> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
>> index 4522297..ade24b2 100644
>> --- a/net/sunrpc/auth_gss/auth_gss.c
>> +++ b/net/sunrpc/auth_gss/auth_gss.c
>> @@ -1630,6 +1630,7 @@ static const struct rpc_authops authgss_ops = {
>> 	.pipes_destroy	= gss_pipes_dentries_destroy,
>> 	.list_pseudoflavors = gss_mech_list_pseudoflavors,
>> 	.info2flavor	= gss_mech_info2flavor,
>> +	.flavor2info	= gss_mech_flavor2info,
>> };
>> 
>> static const struct rpc_credops gss_credops = {
>> diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
>> index c8da89e..a8d6ee5 100644
>> --- a/net/sunrpc/auth_gss/gss_mech_switch.c
>> +++ b/net/sunrpc/auth_gss/gss_mech_switch.c
>> @@ -240,8 +240,6 @@ gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
>> 	return gm;
>> }
>> 
>> -EXPORT_SYMBOL_GPL(gss_mech_get_by_pseudoflavor);
>> -
>> /**
>>  * gss_mech_list_pseudoflavors - Discover registered GSS pseudoflavors
>>  * @array: array to fill in
>> @@ -314,6 +312,38 @@ rpc_authflavor_t gss_mech_info2flavor(struct rpcsec_gss_info *info)
>> 	return pseudoflavor;
>> }
>> 
>> +/**
>> + * gss_mech_flavor2info - look up a GSS tuple for a given pseudoflavor
>> + * @pseudoflavor: GSS pseudoflavor to match
>> + * @info: rpcsec_gss_info structure to fill in
>> + *
>> + * Returns zero and fills in "info" if pseudoflavor matches a
>> + * supported mechanism.  Otherwise a negative errno is returned.
>> + */
>> +int gss_mech_flavor2info(rpc_authflavor_t pseudoflavor, struct rpcsec_gss_info *info)
>> +{
>> +	struct gss_api_mech *gm;
>> +	int i;
>> +
>> +	gm = gss_mech_get_by_pseudoflavor(pseudoflavor);
>> +	if (gm == NULL)
>> +		return -ENOENT;
>> +
>> +	for (i = 0; i < gm->gm_pf_num; i++) {
>> +		if (gm->gm_pfs[i].pseudoflavor == pseudoflavor) {
>> +			memcpy(info->oid.data, gm->gm_oid.data, gm->gm_oid.len);
>> +			info->oid.len = gm->gm_oid.len;
>> +			info->qop = gm->gm_pfs[i].qop;
>> +			info->service = gm->gm_pfs[i].service;
>> +			gss_mech_put(gm);
>> +			return 0;
>> +		}
>> +	}
>> +
>> +	gss_mech_put(gm);
>> +	return -ENOENT;
>> +}
>> +
>> u32
>> gss_pseudoflavor_to_service(struct gss_api_mech *gm, u32 pseudoflavor)
>> {
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




