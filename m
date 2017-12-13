Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:42308 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751975AbdLMPPt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Dec 2017 10:15:49 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 2/4] nfs: Referrals should use the same proto setting as their parent
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CB2E9621-0F9B-49A0-9A2B-59FA2F898976@oracle.com>
Date: Wed, 13 Dec 2017 10:15:44 -0500
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D528C470-FE2F-4E1B-9B77-B828163A99FB@oracle.com>
References: <20171204190904.18629.70341.stgit@manet.1015granger.net> <20171204191338.18629.29071.stgit@manet.1015granger.net> <396baae6-8372-e7bc-97e4-d5c27b341f8d@Netapp.com> <CB2E9621-0F9B-49A0-9A2B-59FA2F898976@oracle.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 5, 2017, at 2:04 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
>=20
>> On Dec 5, 2017, at 10:36 AM, Anna Schumaker =
<anna.schumaker@netapp.com> wrote:
>>=20
>> Hi Chuck,
>>=20
>> On 12/04/2017 02:13 PM, Chuck Lever wrote:
>>> Helen Chao <helen.chao@oracle.com> noticed that when a user
>>> traverses a referral on an NFS/RDMA mount, the resulting submount
>>> always uses TCP.
>>>=20
>>> This behavior does not match the vers=3D setting when traversing
>>> a referral (vers=3D4.1 is preserved). It also does not match the
>>> behavior of crossing from the pseudofs into a real filesystem
>>> (proto=3Drdma is preserved in that case).
>>>=20
>>> The Linux NFS client does not currently support the
>>> fs_locations_info attribute. The situation is similar for all
>>> NFSv4 servers I know of. Therefore until the community has broad
>>> support for fs_locations_info, when following a referral:
>>>=20
>>> - First try to connect with RPC-over-RDMA. This will fail quickly
>>>  if the client has no RDMA-capable interfaces.
>>>=20
>>> - If connecting with RPC-over-RDMA fails, or the RPC-over-RDMA
>>>  transport is not available, use TCP.
>>=20
>> Won't this have the opposite problem if the client and server have =
RDMA interfaces, but are currently mounted over TCP instead?
>=20
> The new behavior will prefer NFS/RDMA, yes. However, typically
> the referral will contain a hostname or IP address that either
> supports both or only TCP. In the former case, the client will
> now choose RDMA instead of TCP, and in the latter, it should
> always use TCP.
>=20
> IOW the referral has to point to a server IP address that can
> do either transport before the client can choose RDMA.

Any further comment? Is this patch series acceptable?


>> Anna
>>=20
>>>=20
>>> Reported-by: Helen Chao <helen.chao@oracle.com>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> fs/nfs/nfs4client.c    |   23 ++++++++++++++++++++---
>>> fs/nfs/nfs4namespace.c |    2 --
>>> 2 files changed, 20 insertions(+), 5 deletions(-)
>>>=20
>>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>>> index 12bbab0..a3d5592 100644
>>> --- a/fs/nfs/nfs4client.c
>>> +++ b/fs/nfs/nfs4client.c
>>> @@ -1114,19 +1114,36 @@ struct nfs_server =
*nfs4_create_referral_server(struct nfs_clone_mount *data,
>>> 	/* Initialise the client representation from the parent server =
*/
>>> 	nfs_server_copy_userdata(server, parent_server);
>>>=20
>>> -	/* Get a client representation.
>>> -	 * Note: NFSv4 always uses TCP, */
>>> +	/* Get a client representation */
>>> +#ifdef CONFIG_SUNRPC_XPRT_RDMA
>>> +	rpc_set_port(data->addr, NFS_RDMA_PORT);
>>> 	error =3D nfs4_set_client(server, data->hostname,
>>> 				data->addr,
>>> 				data->addrlen,
>>> 				parent_client->cl_ipaddr,
>>> -				rpc_protocol(parent_server->client),
>>> +				XPRT_TRANSPORT_RDMA,
>>> +				parent_server->client->cl_timeout,
>>> +				parent_client->cl_mvops->minor_version,
>>> +				parent_client->cl_net);
>>> +	if (!error)
>>> +		goto init_server;
>>> +#endif	/* CONFIG_SUNRPC_XPRT_RDMA */
>>> +
>>> +	rpc_set_port(data->addr, NFS_PORT);
>>> +	error =3D nfs4_set_client(server, data->hostname,
>>> +				data->addr,
>>> +				data->addrlen,
>>> +				parent_client->cl_ipaddr,
>>> +				XPRT_TRANSPORT_TCP,
>>> 				parent_server->client->cl_timeout,
>>> 				parent_client->cl_mvops->minor_version,
>>> 				parent_client->cl_net);
>>> 	if (error < 0)
>>> 		goto error;
>>>=20
>>> +#ifdef CONFIG_SUNRPC_XPRT_RDMA
>>> +init_server:
>>> +#endif
>>> 	error =3D nfs_init_server_rpcclient(server, =
parent_server->client->cl_timeout, data->authflavor);
>>> 	if (error < 0)
>>> 		goto error;
>>> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
>>> index 8c3f327..24f06dc 100644
>>> --- a/fs/nfs/nfs4namespace.c
>>> +++ b/fs/nfs/nfs4namespace.c
>>> @@ -270,8 +270,6 @@ static struct vfsmount *try_location(struct =
nfs_clone_mount *mountdata,
>>> 		if (mountdata->addrlen =3D=3D 0)
>>> 			continue;
>>>=20
>>> -		rpc_set_port(mountdata->addr, NFS_PORT);
>>> -
>>> 		memcpy(page2, buf->data, buf->len);
>>> 		page2[buf->len] =3D '\0';
>>> 		mountdata->hostname =3D page2;
>>>=20

--
Chuck Lever



