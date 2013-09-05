Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f43.google.com ([209.85.212.43]:56521 "EHLO
	mail-vb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439Ab3IEPoa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Sep 2013 11:44:30 -0400
Received: by mail-vb0-f43.google.com with SMTP id h11so1255925vbh.2
        for <linux-nfs@vger.kernel.org>; Thu, 05 Sep 2013 08:44:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378395094.5450.7.camel@leira.trondhjem.org>
References: <1378394074-2165-1-git-send-email-andros@netapp.com>
	<1378395094.5450.7.camel@leira.trondhjem.org>
Date: Thu, 5 Sep 2013 11:44:29 -0400
Message-ID: <CAHVgHyVWAsGUK9cTnekChFeCf8JbMRocioPrvAz6_EV8V7zCNQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv4.1 Use MDS auth flavor for data server connection
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 5, 2013 at 11:31 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2013-09-05 at 11:14 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible"
>> uses the nfs_client cl_rpcclient for all state management operations, and
>> will use krb5i or auth_sys with no regard to the mount command authflavor
>> choice.
>>
>> The MDS, as any NFSv4.1 mount point, uses the nfs_server rpc client for all
>> non-state management operations with a different nfs_server for each fsid
>> encountered traversing the mount point, each with a potentially different
>> auth flavor.
>>
>> pNFS data servers are not mounted in the normal sense as there is no associated
>> nfs_server structure. Data servers can also export multiple fsids, each with
>> a potentially different auth flavor.
>>
>> Data servers need to use the same authflavor as the MDS server rpc client for
>> non-state management operations. Populate a list of rpc clients with the MDS
>> server rpc client auth flavor for the DS to use.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfs/internal.h           |  2 ++
>>  fs/nfs/nfs4client.c         | 75 +++++++++++++++++++++++++++++++++++++++++++++
>>  fs/nfs/nfs4filelayout.c     | 35 ++++++++++++++++-----
>>  include/linux/nfs_fs_sb.h   |  1 +
>>  include/linux/sunrpc/clnt.h |  2 ++
>>  net/sunrpc/clnt.c           |  1 +
>>  6 files changed, 108 insertions(+), 8 deletions(-)
>>
> <snip>
>> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
>> index 76c0bf6..3919f2b 100644
>> --- a/include/linux/sunrpc/clnt.h
>> +++ b/include/linux/sunrpc/clnt.h
>> @@ -35,6 +35,8 @@ struct rpc_clnt {
>>       atomic_t                cl_count;       /* Number of references */
>>       struct list_head        cl_clients;     /* Global list of clients */
>>       struct list_head        cl_tasks;       /* List of tasks */
>> +     struct list_head        cl_ds_clnts;    /* list of per auth flavor
>> +                                                data servers */
>
> This list doesn't belong in the RPC layer. Please make a separate
> structure that lives in the NFS layer, and that owns the rpc_clnt.
>
> IOW something along the lines of:
>
> struct nfs_ds_server {
>         struct list_head list;  /* ds_clp->cl_ds_clients */
>         struct rpc_clnt *rpc_clnt;
> };

OK

-->Andy
>
>>       spinlock_t              cl_lock;        /* spinlock */
>>       struct rpc_xprt __rcu * cl_xprt;        /* transport */
>>       struct rpc_procinfo *   cl_procinfo;    /* procedure info */
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index baf0df6..3c18394 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -356,6 +356,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
>>               goto out_no_stats;
>>       clnt->cl_program  = program;
>>       INIT_LIST_HEAD(&clnt->cl_tasks);
>> +     INIT_LIST_HEAD(&clnt->cl_ds_clnts);
>>       spin_lock_init(&clnt->cl_lock);
>>
>>       if (!xprt_bound(xprt))
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
