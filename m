Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:48895 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438Ab3A3T7A convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 14:59:00 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] SUNRPC: Pin GSS module while handling flavor lookups
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA918343D1F@sacexcmbx05-prd.hq.netapp.com>
Date: Wed, 30 Jan 2013 14:58:56 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <FED713AB-B6C5-4CC6-9BC6-44A92173E893@oracle.com>
References: <20130130193120.1289.33936.stgit@seurat.1015granger.net> <4FA345DA4F4AE44899BD2B03EEEC2FA918343D1F@sacexcmbx05-prd.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 30, 2013, at 2:55 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c index 32e305b..0cfffbc
>> 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -157,6 +157,41 @@ rpcauth_lookup_gss_pseudoflavor(struct
>> rpcsec_gss_info *info)
>> EXPORT_SYMBOL_GPL(rpcauth_lookup_gss_pseudoflavor);
>> 
>> /**
>> + * rpcauth_lookup_gss_info - find GSS tuple matching a pseudoflavor
>> + * @pseudoflavor: GSS pseudoflavor to match
>> + * @info: rpcsec_gss_info structure to fill in
>> + *
>> + * Returns zero and fills in "info" if pseudoflavor matches a
>> + * supported mechanism.
>> + */
>> +int
>> +rpcauth_lookup_gss_info(rpc_authflavor_t pseudoflavor, struct
>> +rpcsec_gss_info *info) {
>> +	const struct rpc_authops *ops;
>> +	int result;
>> +
>> +	if ((ops = auth_flavors[pseudoflavor]) == NULL)
>> +		request_module("rpc-auth-%u", RPC_AUTH_GSS);
>> +	spin_lock(&rpc_authflavor_lock);
>> +	ops = auth_flavors[pseudoflavor];
>> +	if (ops == NULL || !try_module_get(ops->owner)) {
>> +		spin_unlock(&rpc_authflavor_lock);
>> +		dprintk("RPC:       %s: failed to pin module\n", __func__);
>> +		return -ENOMEM;
> 
> Wouldn't ENOENT make more sense? This isn't a memory allocation issue.

I wasn't sure what to return here.  -ENOENT is fine by me.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




