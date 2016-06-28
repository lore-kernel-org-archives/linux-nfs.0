Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:41501 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673AbcF1Sf1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jun 2016 14:35:27 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v2] nfs4: clnt: respect noresvport when establishing
 connections to DSes
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
References: <1465840655-3927-1-git-send-email-tigran.mkrtchyan@desy.de>
 <17992391.19912565.1467040819602.JavaMail.zimbra@desy.de>
CC: <linux-nfs@vger.kernel.org>
Message-ID: <29e874d6-5f3a-7a5e-829f-341d6d140396@Netapp.com>
Date: Tue, 28 Jun 2016 14:35:18 -0400
MIME-Version: 1.0
In-Reply-To: <17992391.19912565.1467040819602.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tigran,

On 06/27/2016 11:20 AM, Mkrtchyan, Tigran wrote:
> 
> 
> Trond, Anna,
> 
> any update on this (and corresponding one for flexfile layout)?

The patch looks okay to me.  I'll let Trond decide about the corresponding flexfile patch.

Anna
> 
> Tigran.
> 
> ----- Original Message -----
>> From: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
>> To: linux-nfs@vger.kernel.org
>> Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>, "Anna Schumaker" <Anna.Schumaker@netapp.com>, "Tigran
>> Mkrtchyan" <tigran.mkrtchyan@desy.de>
>> Sent: Monday, June 13, 2016 7:57:35 PM
>> Subject: [PATCH v2] nfs4: clnt: respect noresvport when establishing connections to DSes
> 
>> result:
>>
>> $ mount -o vers=4.1 dcache-lab007:/ /pnfs
>> $ cp /etc/profile /pnfs
>> tcp        0      0 131.169.185.68:1005     131.169.191.141:32049   ESTABLISHED
>> tcp        0      0 131.169.185.68:751      131.169.191.144:2049    ESTABLISHED
>> $
>>
>> $ mount -o vers=4.1,noresvport dcache-lab007:/ /pnfs
>> $ cp /etc/profile /pnfs
>> tcp        0      0 131.169.185.68:34894    131.169.191.141:32049   ESTABLISHED
>> tcp        0      0 131.169.185.68:35722    131.169.191.144:2049    ESTABLISHED
>> $
>>
>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> ---
>> fs/nfs/internal.h   | 2 +-
>> fs/nfs/nfs4client.c | 9 ++++++---
>> fs/nfs/pnfs_nfs.c   | 2 +-
>> 3 files changed, 8 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 5154fa6..67b9345 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -184,7 +184,7 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server
>> *,
>> 					   rpc_authflavor_t);
>> extern int nfs_wait_client_init_complete(const struct nfs_client *clp);
>> extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
>> -extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
>> +extern struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
>> 					     const struct sockaddr *ds_addr,
>> 					     int ds_addrlen, int ds_proto,
>> 					     unsigned int ds_timeo,
>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>> index 10410e8..1d36e7f 100644
>> --- a/fs/nfs/nfs4client.c
>> +++ b/fs/nfs/nfs4client.c
>> @@ -842,7 +842,7 @@ error:
>>  * low timeout interval so that if a connection is lost, we retry through
>>  * the MDS.
>>  */
>> -struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
>> +struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
>> 		const struct sockaddr *ds_addr, int ds_addrlen,
>> 		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
>> 		u32 minor_version, rpc_authflavor_t au_flavor)
>> @@ -853,7 +853,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client*
>> mds_clp,
>> 		.nfs_mod = &nfs_v4,
>> 		.proto = ds_proto,
>> 		.minorversion = minor_version,
>> -		.net = mds_clp->cl_net,
>> +		.net = mds_srv->nfs_client->cl_net,
>> 	};
>> 	struct rpc_timeout ds_timeout;
>> 	struct nfs_client *clp;
>> @@ -863,13 +863,16 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client*
>> mds_clp,
>> 		return ERR_PTR(-EINVAL);
>> 	cl_init.hostname = buf;
>>
>> +	if (mds_srv->flags & NFS_MOUNT_NORESVPORT)
>> +		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
>> +
>> 	/*
>> 	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
>> 	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
>> 	 * (section 13.1 RFC 5661).
>> 	 */
>> 	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
>> -	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
>> +	clp = nfs_get_client(&cl_init, &ds_timeout, mds_srv->nfs_client->cl_ipaddr,
>> 			     au_flavor);
>>
>> 	dprintk("<-- %s %p\n", __func__, clp);
>> diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
>> index 0dfc476..a3e3157 100644
>> --- a/fs/nfs/pnfs_nfs.c
>> +++ b/fs/nfs/pnfs_nfs.c
>> @@ -682,7 +682,7 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server
>> *mds_srv,
>> 		dprintk("%s: DS %s: trying address %s\n",
>> 			__func__, ds->ds_remotestr, da->da_remotestr);
>>
>> -		clp = nfs4_set_ds_client(mds_srv->nfs_client,
>> +		clp = nfs4_set_ds_client(mds_srv,
>> 					(struct sockaddr *)&da->da_addr,
>> 					da->da_addrlen, IPPROTO_TCP,
>> 					timeo, retrans, minor_version,
>> --
>> 2.5.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

