Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22040 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752870Ab1AGSmP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Jan 2011 13:42:15 -0500
Message-ID: <4D275E7F.5010704@netapp.com>
Date: Fri, 07 Jan 2011 13:42:07 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
To: Andy Adamson <andros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH v2 5/5] NFS: Determine initial mount security
References: <4D24CB32.7080509@netapp.com> <8AF961E3-D276-421C-80ED-E91991B48137@netapp.com>
In-Reply-To: <8AF961E3-D276-421C-80ED-E91991B48137@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/06/2011 07:58 PM, Andy Adamson wrote:
> 
> On Jan 5, 2011, at 2:49 PM, Bryan Schumaker wrote:
> 
>>
>> When sec=<something> is not presented as a mount option,
>> we should attempt to determine what security flavor the
>> server is using.
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>> fs/nfs/nfs4proc.c                     |   33 +++++++++++++++++++++++++++++++--
>> include/linux/sunrpc/gss_api.h        |    3 +++
>> net/sunrpc/auth_gss/gss_mech_switch.c |   16 ++++++++++++++++
>> 3 files changed, 50 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 4a1d79e..19ee25d 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -41,6 +41,7 @@
>> #include <linux/string.h>
>> #include <linux/slab.h>
>> #include <linux/sunrpc/clnt.h>
>> +#include <linux/sunrpc/gss_api.h>
>> #include <linux/nfs.h>
>> #include <linux/nfs4.h>
>> #include <linux/nfs_fs.h>
>> @@ -2171,15 +2172,43 @@ static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
>> 	return err;
>> }
>>
>> +static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
>> +				struct nfs_fsinfo *info, rpc_authflavor_t flavor)
>> +{
>> +	struct rpc_auth *auth;
>> +	int ret;
>> +
>> +	auth = rpcauth_create(flavor, server->client);
>> +	if (!auth) {
>> +		ret = -EIO;
>> +		goto out;
>> +	}
> 
> Are you leaking rpc_auth's?
> 
> -->Andy
> 

I don't think so... rpcauth_create() should take care of freeing the previous auth struct assigned to the rpc_client.

- Bryan
>> +	ret = nfs4_lookup_root(server, fhandle, info);
>> +	if (ret < 0)
>> +		ret = -EAGAIN;
>> +out:
>> +	return ret;
>> +}
>> +
>> /*
>>  * get the file handle for the "/" directory on the server
>>  */
>> static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
>> 			      struct nfs_fsinfo *info)
>> {
>> -	int status;
>> +	int i, len, status = 0;
>> +	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS + 2];
>>
>> -	status = nfs4_lookup_root(server, fhandle, info);
>> +	flav_array[0] = RPC_AUTH_UNIX;
>> +	len = gss_mech_list_pseudoflavors(&flav_array[1]);
>> +	flav_array[1+len] = RPC_AUTH_NULL;
>> +	len += 2;
>> +
>> +	for (i = 0; i < len; i++) {
>> +		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
>> +		if (status == 0)
>> +			break;
>> +	}
>> 	if (status == 0)
>> 		status = nfs4_server_capabilities(server, fhandle);
>> 	if (status == 0)
>> diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
>> index 5d8048b..332da61 100644
>> --- a/include/linux/sunrpc/gss_api.h
>> +++ b/include/linux/sunrpc/gss_api.h
>> @@ -126,6 +126,9 @@ struct gss_api_mech *gss_mech_get_by_name(const char *);
>> /* Similar, but get by pseudoflavor. */
>> struct gss_api_mech *gss_mech_get_by_pseudoflavor(u32);
>>
>> +/* Fill in an array with a list of supported pseudoflavors */
>> +int gss_mech_list_pseudoflavors(u32 *);
>> +
>> /* Just increments the mechanism's reference count and returns its input: */
>> struct gss_api_mech * gss_mech_get(struct gss_api_mech *);
>>
>> diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
>> index 6c844b0..e3c36a2 100644
>> --- a/net/sunrpc/auth_gss/gss_mech_switch.c
>> +++ b/net/sunrpc/auth_gss/gss_mech_switch.c
>> @@ -215,6 +215,22 @@ gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
>>
>> EXPORT_SYMBOL_GPL(gss_mech_get_by_pseudoflavor);
>>
>> +int gss_mech_list_pseudoflavors(rpc_authflavor_t *array_ptr)
>> +{
>> +	struct gss_api_mech *pos = NULL;
>> +	int i = 0;
>> +
>> +	spin_lock(&registered_mechs_lock);
>> +	list_for_each_entry(pos, &registered_mechs, gm_list) {
>> +		array_ptr[i] = pos->gm_pfs->pseudoflavor;
>> +		i++;
>> +	}
>> +	spin_unlock(&registered_mechs_lock);
>> +	return i;
>> +}
>> +
>> +EXPORT_SYMBOL_GPL(gss_mech_list_pseudoflavors);
>> +
>> u32
>> gss_svc_to_pseudoflavor(struct gss_api_mech *gm, u32 service)
>> {
>> -- 
>> 1.7.3.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

