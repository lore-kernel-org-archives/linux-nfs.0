Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:30201 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932080AbdGLRTE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Jul 2017 13:19:04 -0400
Content-Type: text/plain; charset=utf-8
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v3 10/42] NFS export nfs4_async_handle_error
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <8f0c7b41-4504-2322-70b6-7ad5b25a69ca@gmail.com>
Date: Wed, 12 Jul 2017 13:18:42 -0400
CC: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>, <linux-nfs@vger.kernel.org>
Message-ID: <8C5EEC5B-D0FF-4911-A039-796695E72288@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-11-kolga@netapp.com>
 <8f0c7b41-4504-2322-70b6-7ad5b25a69ca@gmail.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 12, 2017, at 9:56 AM, Anna Schumaker <schumaker.anna@gmail.com> =
wrote:
>=20
> Hi Olga,
>=20
> On 07/11/2017 12:43 PM, Olga Kornievskaia wrote:
>> Make this function available to nfs42proc.c
>=20
> I'm confused about why this patch is needed.  Aren't NFS v4.2 and =
nfs4_async_handle_error()
> both built into the NFSv4.ko module?
>=20

You are right I don=E2=80=99t need the EXPORT_SYMBOL chunk but I need =
the function to be callable from outside of nfs4proc.c
=20
> Anna
>=20
>>=20
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>> fs/nfs/nfs4_fs.h  | 3 +++
>> fs/nfs/nfs4proc.c | 3 ++-
>> 2 files changed, 5 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>> index af285cc..f5d014e 100644
>> --- a/fs/nfs/nfs4_fs.h
>> +++ b/fs/nfs/nfs4_fs.h
>> @@ -244,6 +244,9 @@ int nfs4_replace_transport(struct nfs_server =
*server,
>>=20
>> /* nfs4proc.c */
>> extern int nfs4_handle_exception(struct nfs_server *, int, struct =
nfs4_exception *);
>> +extern int nfs4_async_handle_error(struct rpc_task *task,
>> +				   struct nfs_server *server,
>> +				   struct nfs4_state *state, long =
*timeout);
>> extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
>> 			  struct rpc_message *, struct =
nfs4_sequence_args *,
>> 			  struct nfs4_sequence_res *, int);
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index b37e528..fdb6b76 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -548,7 +548,7 @@ int nfs4_handle_exception(struct nfs_server =
*server, int errorcode, struct nfs4_
>> 	return ret;
>> }
>>=20
>> -static int
>> +int
>> nfs4_async_handle_error(struct rpc_task *task, struct nfs_server =
*server,
>> 			struct nfs4_state *state, long *timeout)
>> {
>> @@ -569,6 +569,7 @@ int nfs4_handle_exception(struct nfs_server =
*server, int errorcode, struct nfs4_
>> 		return -EAGAIN;
>> 	return 0;
>> }
>> +EXPORT_SYMBOL_GPL(nfs4_async_handle_error);
>>=20
>> /*
>>  * Return 'true' if 'clp' is using an rpc_client that is integrity =
protected
>>=20

