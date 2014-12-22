Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:57107 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800AbaLVCXG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Dec 2014 21:23:06 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so3496874iec.24
        for <linux-nfs@vger.kernel.org>; Sun, 21 Dec 2014 18:23:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <549097AA.4060302@Netapp.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
 <1418756513-95187-9-git-send-email-loghyr@primarydata.com> <549097AA.4060302@Netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Mon, 22 Dec 2014 10:22:44 +0800
Message-ID: <CA+a=Yy7Y-t+_jM_Nx9Mnkatfq=aKngLMM9bv0hAPn9YCB28iyA@mail.gmail.com>
Subject: Re: [PATCH 08/50] nfsv3: introduce nfs3_set_ds_client
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 17, 2014 at 4:35 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> On 12/16/2014 02:01 PM, Tom Haynes wrote:
>> From: Peng Tao <tao.peng@primarydata.com>
>>
>> The flexfiles layout wants to create DS connection over NFSv3.
>> Add nfs3_set_ds_client to allow that to happen.
>>
>> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
>> Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
>> ---
>>  fs/nfs/internal.h   |  7 +++++++
>>  fs/nfs/nfs3client.c | 34 ++++++++++++++++++++++++++++++++++
>>  fs/nfs/nfs3super.c  |  2 +-
>>  3 files changed, 42 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 7d7c36f..bf9f79f 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -193,6 +193,10 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
>>                                            rpc_authflavor_t au_flavor);
>>  extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
>>                                               struct inode *);
>> +extern struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
>> +                     const struct sockaddr *ds_addr, int ds_addrlen,
>> +                     int ds_proto, unsigned int ds_timeo,
>> +                     unsigned int ds_retrans, rpc_authflavor_t au_flavor);
>>  #ifdef CONFIG_PROC_FS
>>  extern int __init nfs_fs_proc_init(void);
>>  extern void nfs_fs_proc_exit(void);
>> @@ -381,6 +385,9 @@ extern void __exit unregister_nfs_fs(void);
>>  extern void nfs_sb_active(struct super_block *sb);
>>  extern void nfs_sb_deactive(struct super_block *sb);
>>
>> +/* nfs3super.c */
>> +extern struct nfs_subversion nfs_v3;
>> +
>>  /* namespace.c */
>>  #define NFS_PATH_CANONICAL 1
>>  extern char *nfs_path(char **p, struct dentry *dentry,
>> diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
>> index 8c1b437..52e2344 100644
>> --- a/fs/nfs/nfs3client.c
>> +++ b/fs/nfs/nfs3client.c
>> @@ -64,3 +64,37 @@ struct nfs_server *nfs3_clone_server(struct nfs_server *source,
>>               nfs_init_server_aclclient(server);
>>       return server;
>>  }
>> +
>> +/*
>> + * Set up a pNFS Data Server client over NFSv3.
>> + *
>> + * Return any existing nfs_client that matches server address,port,version
>> + * and minorversion.
>> + *
>> + * For a new nfs_client, use a soft mount (default), a low retrans and a
>> + * low timeout interval so that if a connection is lost, we retry through
>> + * the MDS.
>> + */
>> +struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
>> +             const struct sockaddr *ds_addr, int ds_addrlen,
>> +             int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
>> +             rpc_authflavor_t au_flavor)
>> +{
>> +     struct nfs_client_initdata cl_init = {
>> +             .addr = ds_addr,
>> +             .addrlen = ds_addrlen,
>> +             .nfs_mod = &nfs_v3,
>
> Can you use get_nfs_version() / put_nfs_version() here rather than exposing nfs_v3 to the entire client?
This is nfs3client.c. I don't think we need to reference nfsv3.ko itself.

>  If this *has* to be global then please put it in nfs3_fs.h.
yeah, makes sense. I'll move it there.

Thanks,
Tao

>
> Anna
>
>> +             .proto = ds_proto,
>> +             .net = mds_clp->cl_net,
>> +     };
>> +     struct rpc_timeout ds_timeout;
>> +     struct nfs_client *clp;
>> +
>> +     /* Use the MDS nfs_client cl_ipaddr. */
>> +     nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
>> +     clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
>> +                          au_flavor);
>> +
>> +     return clp;
>> +}
>> +EXPORT_SYMBOL_GPL(nfs3_set_ds_client);
>> diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
>> index 6af29c2..5c4394e 100644
>> --- a/fs/nfs/nfs3super.c
>> +++ b/fs/nfs/nfs3super.c
>> @@ -7,7 +7,7 @@
>>  #include "nfs3_fs.h"
>>  #include "nfs.h"
>>
>> -static struct nfs_subversion nfs_v3 = {
>> +struct nfs_subversion nfs_v3 = {
>>       .owner = THIS_MODULE,
>>       .nfs_fs   = &nfs_fs_type,
>>       .rpc_vers = &nfs_version3,
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
