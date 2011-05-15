Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755657Ab1EOQh5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 May 2011 12:37:57 -0400
Subject: Re: [PATCH] NFS: pnfs IPv6 support
Content-Type: text/plain; charset=us-ascii
From: Dros Adamson <dros@netapp.com>
In-Reply-To: <4DCF8A57.6070201@desy.de>
Date: Sun, 15 May 2011 12:37:38 -0400
Cc: trond@netapp.com, NFS list <linux-nfs@vger.kernel.org>
Message-Id: <697D02EC-AC0F-4501-9EF6-069F25B10857@netapp.com>
References: <1305407199-15206-1-git-send-email-dros@netapp.com> <alpine.LNX.2.00.1105150919440.12006@anahit.desy.de> <4DCF8A57.6070201@desy.de>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 15, 2011, at 4:09 AM, Tigran Mkrtchyan wrote:

> On 05/15/2011 09:23 AM, Tigran Mkrtchyan wrote:
>> 
>> 
>> On Sat, 14 May 2011, Weston Andros Adamson wrote:
>> 
>>> Handle ipv6 remote addresses from GETDEVICEINFO
>>> 
>>> - supports netid "tcp" for ipv4 and "tcp6" for ipv6 as rfc 5665 specifies
>>> - added ds_remotestr to avoid having to handle different AFs in every dprintk
>>> - tested against pynfs 4.1 server, submitting ipv6 support patch to pynfs
>>> 
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> 
>>> NOTE: checkpatch.pl complains about a printk() call in print_ds() that doesn't
>>>     include a KERN_ facility level.  I'm not sure if I should change this or
>>>     what I should change it to.
>>> 
>>> I am also working on parsing and storing multipath info for dataservers, but
>>> I'm going to treat that as a separate patch
>>> 
>>> fs/nfs/nfs4filelayout.c    |    7 +-
>>> fs/nfs/nfs4filelayout.h    |    5 +-
>>> fs/nfs/nfs4filelayoutdev.c |  246 ++++++++++++++++++++++++++++++++------------
>>> 3 files changed, 184 insertions(+), 74 deletions(-)
>>> 
>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>> index be79dc9..583adb3 100644
>>> --- a/fs/nfs/nfs4filelayout.c
>>> +++ b/fs/nfs/nfs4filelayout.c
>>> @@ -343,8 +343,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
>>>        set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
>>>        return PNFS_NOT_ATTEMPTED;
>>>    }
>>> -    dprintk("%s USE DS:ip %x %hu\n", __func__,
>>> -        ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
>>> +    dprintk("%s USE DS: %s\n", __func__, ds->ds_remotestr);
>>> 
>>>    /* No multipath support. Use first DS */
>>>    data->ds_clp = ds->ds_clp;
>>> @@ -383,9 +382,9 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
>>>        set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
>>>        return PNFS_NOT_ATTEMPTED;
>>>    }
>>> -    dprintk("%s ino %lu sync %d req %Zu@%llu DS:%x:%hu\n", __func__,
>>> +    dprintk("%s ino %lu sync %d req %Zu@%llu DS: %s\n", __func__,
>>>        data->inode->i_ino, sync, (size_t) data->args.count, offset,
>>> -        ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
>>> +        ds->ds_remotestr);
>>> 
>>>    data->write_done_cb = filelayout_write_done_cb;
>>>    data->ds_clp = ds->ds_clp;
>>> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
>>> index 2b461d7..1dfd7eb 100644
>>> --- a/fs/nfs/nfs4filelayout.h
>>> +++ b/fs/nfs/nfs4filelayout.h
>>> @@ -49,8 +49,9 @@ enum stripetype4 {
>>> /* Individual ip address */
>>> struct nfs4_pnfs_ds {
>>>    struct list_head    ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
>>> -    u32            ds_ip_addr;
>>> -    u32            ds_port;
>>> +    struct sockaddr_storage    ds_addr;
>>> +    size_t            ds_addrlen;
>>> +    char            *ds_remotestr;    /* human readable addr+port */
>>>    struct nfs_client    *ds_clp;
>>>    atomic_t        ds_count;
>>> };
>>> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
>>> index db07c7a..7f77cd1 100644
>>> --- a/fs/nfs/nfs4filelayoutdev.c
>>> +++ b/fs/nfs/nfs4filelayoutdev.c
>>> @@ -80,11 +80,11 @@ print_ds(struct nfs4_pnfs_ds *ds)
>>>        printk("%s NULL device\n", __func__);
>>>        return;
>>>    }
>>> -    printk("        ip_addr %x port %hu\n"
>>> +    printk("        ds %s\n"
>>>        "        ref count %d\n"
>>>        "        client %p\n"
>>>        "        cl_exchange_flags %x\n",
>>> -        ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
>>> +        ds->ds_remotestr,
>>>        atomic_read(&ds->ds_count), ds->ds_clp,
>>>        ds->ds_clp ? ds->ds_clp->cl_exchange_flags : 0);
>>> }
>>> @@ -112,17 +112,45 @@ void print_deviceid(struct nfs4_deviceid *id)
>>> 
>>> /* nfs4_ds_cache_lock is held */
>>> static struct nfs4_pnfs_ds *
>>> -_data_server_lookup_locked(u32 ip_addr, u32 port)
>>> +_data_server_lookup_locked(struct sockaddr *addr, size_t addrlen)
>>> {
>>>    struct nfs4_pnfs_ds *ds;
>>> -
>>> -    dprintk("_data_server_lookup: ip_addr=%x port=%hu\n",
>>> -            ntohl(ip_addr), ntohs(port));
>>> +    struct sockaddr_in *a, *b;
>>> +    struct sockaddr_in6 *a6, *b6;
>>> 
>>>    list_for_each_entry(ds, &nfs4_data_server_cache, ds_node) {
>>> -        if (ds->ds_ip_addr == ip_addr &&
>>> -            ds->ds_port == port) {
>>> -            return ds;
>>> +        if (addr->sa_family != ds->ds_addr.ss_family)
>>> +            continue;
>>> +
>>> +        switch (addr->sa_family) {
>>> +        case AF_INET:
>>> +            a = (struct sockaddr_in *)addr;
>>> +            b = (struct sockaddr_in *)&ds->ds_addr;
>>> +
>>> +            if (a->sin_addr.s_addr == b->sin_addr.s_addr &&
>>> +                a->sin_port == b->sin_port)
>>> +                return ds;
>>> +            break;
>>> +
>>> +        case AF_INET6:
>>> +            a6 = (struct sockaddr_in6 *)addr;
>>> +            b6 = (struct sockaddr_in6 *)&ds->ds_addr;
>>> +
>>> +            /* LINKLOCAL addresses must have matching scope_id */
>>> +            if (ipv6_addr_scope(&a6->sin6_addr) ==
>>> +                IPV6_ADDR_SCOPE_LINKLOCAL &&
>>> +                a6->sin6_scope_id != b6->sin6_scope_id)
>>> +                continue;
>>> +
>>> +            if (ipv6_addr_equal(&a6->sin6_addr, &b6->sin6_addr) &&
>>> +                a6->sin6_port == b6->sin6_port)
>>> +                return ds;
>>> +            break;
>>> +
>>> +        default:
>>> +            dprintk("%s: unhandled address family: %u\n",
>>> +                __func__, addr->sa_family);
>>> +            return NULL;
>>>        }
>>>    }
>>>    return NULL;
>>> @@ -136,19 +164,14 @@ static int
>>> nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
>>> {
>>>    struct nfs_client *clp;
>>> -    struct sockaddr_in sin;
>>>    int status = 0;
>>> 
>>> -    dprintk("--> %s ip:port %x:%hu au_flavor %d\n", __func__,
>>> -        ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
>>> +    dprintk("--> %s addr %s au_flavor %d\n", __func__, ds->ds_remotestr,
>>>        mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
>>> 
>>> -    sin.sin_family = AF_INET;
>>> -    sin.sin_addr.s_addr = ds->ds_ip_addr;
>>> -    sin.sin_port = ds->ds_port;
>>> -
>>> -    clp = nfs4_set_ds_client(mds_srv->nfs_client, (struct sockaddr *)&sin,
>>> -                 sizeof(sin), IPPROTO_TCP);
>>> +    clp = nfs4_set_ds_client(mds_srv->nfs_client,
>>> +                 (struct sockaddr *)&ds->ds_addr,
>>> +                 ds->ds_addrlen, IPPROTO_TCP);
>>>    if (IS_ERR(clp)) {
>>>        status = PTR_ERR(clp);
>>>        goto out;
>>> @@ -160,8 +183,8 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
>>>            goto out_put;
>>>        }
>>>        ds->ds_clp = clp;
>>> -        dprintk("%s [existing] ip=%x, port=%hu\n", __func__,
>>> -            ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
>>> +        dprintk("%s [existing] server=%s\n", __func__,
>>> +            ds->ds_remotestr);
>>>        goto out;
>>>    }
>>> 
>>> @@ -180,8 +203,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
>>>        goto out_put;
>>> 
>>>    ds->ds_clp = clp;
>>> -    dprintk("%s [new] ip=%x, port=%hu\n", __func__, ntohl(ds->ds_ip_addr),
>>> -        ntohs(ds->ds_port));
>>> +    dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
>>> out:
>>>    return status;
>>> out_put:
>>> @@ -198,6 +220,7 @@ destroy_ds(struct nfs4_pnfs_ds *ds)
>>> 
>>>    if (ds->ds_clp)
>>>        nfs_put_client(ds->ds_clp);
>>> +    kfree(ds->ds_remotestr);
>>>    kfree(ds);
>>> }
>>> 
>>> @@ -224,8 +247,56 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
>>>    kfree(dsaddr);
>>> }
>>> 
>>> +/*
>>> + * Set ds->ds_remotestr to human readable format of address to avoid
>>> + * complicated setup around many dprinks().
>>> + *
>>> + * As it's only for debugging, this doesn't error out on kmalloc failure and
>>> + * the remotestr will just be displayed as "(null)"
>>> + */
>>> +static void
>>> +nfs4_pnfs_set_remotestr(struct nfs4_pnfs_ds *ds, gfp_t gfp_flags)
>>> +{
>>> +    char buf[INET6_ADDRSTRLEN + IPV6_SCOPE_ID_LEN];
>>> +    char *startsep = "";
>>> +    char *endsep = "";
>>> +    size_t len;
>>> +    uint16_t port;
>>> +
>>> +    switch (ds->ds_addr.ss_family) {
>>> +    case AF_INET:
>>> +        port = ((struct sockaddr_in *)&ds->ds_addr)->sin_port;
>>> +        break;
>>> +    case AF_INET6:
>>> +        startsep = "[";
>>> +        endsep = "]";
>>> +        port = ((struct sockaddr_in6 *)&ds->ds_addr)->sin6_port;
>>> +        break;
>>> +    default:
>>> +        dprintk("%s: Unknown address family %u\n",
>>> +            __func__, ds->ds_addr.ss_family);
>>> +        return;
>>> +    }
>>> +
>>> +    if (!rpc_ntop((struct sockaddr *)&ds->ds_addr, buf, sizeof(buf))) {
>>> +        dprintk("%s: error printing addr\n", __func__);
>>> +        return;
>>> +    }
>>> +
>>> +    len = strlen(buf) + strlen(startsep) + strlen(endsep) + 1 + 5 + 1;
>>> +    ds->ds_remotestr = kzalloc(len, gfp_flags);
>>> +
>>> +    if (unlikely(!ds->ds_remotestr)) {
>>> +        dprintk("%s: couldn't alloc ds_remotestr\n", __func__);
>>> +        return;
>>> +    }
>>> +
>>> +    snprintf(ds->ds_remotestr, len, "%s%s%s:%u",
>>> +         startsep, buf, endsep, port);
>> 
>> should be ntohs(port) to print correct value.
>> 
>> Still does not work to me. But I will try to figure this out.
>> 
> After fixing issue on my side got cthon tests to pass.
> 
> 
> Thanks.
>> Tigran.

Great!  I don't know how I missed the ntohs, posting updated patch soon.

Thanks for testing!

-dros