Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:56047 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab2BNPoL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Feb 2012 10:44:11 -0500
Received: by werb13 with SMTP id b13so51394wer.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Feb 2012 07:44:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F3A29E8.5000904@tonian.com>
References: <1328721042-9335-1-git-send-email-dros@netapp.com>
	<1CFC0549-DFAC-4530-A3A5-876DDAE8C5DE@oracle.com>
	<B22F73F9-8343-4543-922E-26F48AA78A90@netapp.com>
	<4F38C443.2060307@tonian.com>
	<AD23749C-B7A0-4144-AE9E-BD0C720B3916@netapp.com>
	<4F3A29E8.5000904@tonian.com>
Date: Tue, 14 Feb 2012 10:44:07 -0500
Message-ID: <CAHVgHyUoozfO2RDnPZz68-nDrPkdDjJbA4Od9YGXEOpZPsKPqg@mail.gmail.com>
Subject: Re: [PATCH] RFC: NFS - filelayout DS rpc mountstats support
From: Andy Adamson <androsadamson@gmail.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have an early patch set that prints session stats for MDS and for
DS. The DS pnfs_layoutdriver_type interface for session stats takes
the same arguments as the RPC iostats interface, a seq_file* and a
struct nfs4_deviceid_node.

>>>>>> + void (*ds_rpc_print_iostats) (struct seq_file *,
>>>>>> +                               struct nfs4_deviceid_node *);

We can use the same interface for RPC and session stats.  I suggest
you rename this to "ds_stats" and add an enum type to identify which
stats are being requested.

-->Andy

On Tue, Feb 14, 2012 at 4:31 AM, Benny Halevy <bhalevy@tonian.com> wrote:
> On 2012-02-13 19:58, Adamson, Dros wrote:
>>
>> On Feb 13, 2012, at 3:05 AM, Benny Halevy wrote:
>>
>>> Sorry for the late response.
>>>
>>> On 2012-02-08 23:04, Adamson, Dros wrote:
>>>>
>>>> On Feb 8, 2012, at 12:26 PM, Chuck Lever wrote:
>>>>
>>>>> Hi-
>>>>>
>>>>> On Feb 8, 2012, at 12:10 PM, Weston Andros Adamson wrote:
>>>>>
>>>>>> The per-op stats displayed in /self/proc/mountstats are collected in the sunrpc
>>>>>
>>>>> You mean /proc/self/mountstats here.
>>>>
>>>> oops!
>>>>
>>>>>
>>>>>> layer and are collected per rpc_client.  This has worked for nfs thus far
>>>>>> since only one nfs_client was ever associated with a mountpoint, but with
>>>>>> NFS4.1+PNFS+filelayout an nfs mount can have more than one nfs_client.
>>>>>>
>>>>>> This can be seen with a pnfs mount where no data server is the same as the MDS -
>>>>>> all reads, writes and commits will never make it into the current mountstats
>>>>>> output.
>>>>>>
>>>>>> I took the approach of keeping the stats from the MDS and DSs separate in the
>>>>>> /proc/self/mountstats output to avoid doing too much in the kernel, and to
>>>>>> expose the fact that these stats are from separate connections (maybe for later
>>>>>> use).
>>>>>>
>>>>>> This method has issues:
>>>>>>
>>>>>> 1) even changing the "statvers" of mountstats doesn't stop the userland
>>>>>>  mountstats(8) from trying to parse this output -- and it does so
>>>>>>  incorrectly.
>>>>>
>>>>> User land is broken then.  :-)
>>>>
>>>> Agreed!
>>>>
>>>>>
>>>>>> 2) when using DS multipath this method fails to count operations that happened
>>>>>>  on a different path to the same DS (after a failure).
>>>>
>>>> I should have noted that this isn't a problem yet because I haven't submitted the multipath failover patches :)
>>>>
>>>>>>
>>>>>> 3) currently this will display stats twice when DS == MDS.
>>>>>
>>>>> Why is this case hard to detect in the kernel or in mountstats?
>>>>
>>>> Not hard, just an issue with the current patch.
>>>>
>>>>>
>>>>>>
>>>>>> So... What should I do here?
>>>>>>
>>>>>> A different approach is to add support in net/sunrpc to specify a "parent"
>>>>>> stat structure so that operations on DS nfs_clients bump stats on
>>>>>> the main nfs_server->nfs_client->rpc_client.  This would take care of all the
>>>>>> issues with the current patch, but seems like a hack.
>>>>>
>>>>> Is this the same as displaying all data in one set of stats?
>>>>
>>>> Yes
>>>>
>>>>>
>>>>> Seems like that might be the best next step, then we can split up the MDS and DS stats at some later point.
>>>
>>> Splitting up the MDS/DS stats is important to tell when DS I/O is being
>>> done and how effective it is.
>>>
>>> Benny
>>>
>>
>> Agreed!  It just can't go into mountstats right away (due to statsvers= not being interpreted in mountstats(8)).  I'll make a second patch on top of my mountstats changes to add per-DS stats in /proc/fs/nfsfs/ and we can figure out if we want to add it to mountstats later.
>>
>> Does this sound OK?
>
> Absolutely.  Thanks!
>
> Benny
>
>>
>> -dros
>>
>>>>
>>>> Ok, I'll try to do that.
>>>>
>>>> Any advice on how to handle the "xprt: …" line?  Obviously the different underlying rpc_clients will have different values.  I'd have to look at mountstats(8) some more, but I *think* we could just make it a comma separated list.
>>>>
>>>> For the 'next step', we can use this patch - we just need to figure out where it should go.  Do we keep it in /proc/self/mountstats?  I think because of problem #2 we might want to move them out to somewhere in /proc/fs/nfsfs/ along with other per-DS statistics.
>>>>
>>>>>
>>>>>> One task that seems like a good thing to do is to fix mountstats(8) to respect
>>>>>> the "statsvers" value.
>>>>>
>>>>> Agree.
>>>>
>>>> I'll do this first.
>>>>
>>>> Thanks Chuck!
>>>>
>>>> -dros
>>>>
>>>>>
>>>>>>
>>>>>> Thoughts?
>>>>>> ---
>>>>>>
>>>>>> I cleaned up this patch, but I still have reservations (noted in commit message)
>>>>>>
>>>>>> fs/nfs/nfs4filelayout.c    |   23 +++++++++++++++++++++++
>>>>>> fs/nfs/pnfs.h              |   20 ++++++++++++++++++++
>>>>>> fs/nfs/pnfs_dev.c          |   25 +++++++++++++++++++++++++
>>>>>> fs/nfs/super.c             |    1 +
>>>>>> include/linux/nfs_iostat.h |    2 +-
>>>>>> 5 files changed, 70 insertions(+), 1 deletions(-)
>>>>>>
>>>>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>>>>> index 79be7ac..9410fd0 100644
>>>>>> --- a/fs/nfs/nfs4filelayout.c
>>>>>> +++ b/fs/nfs/nfs4filelayout.c
>>>>>> @@ -33,6 +33,8 @@
>>>>>> #include <linux/nfs_page.h>
>>>>>> #include <linux/module.h>
>>>>>>
>>>>>> +#include <linux/sunrpc/metrics.h>
>>>>>> +
>>>>>> #include "internal.h"
>>>>>> #include "nfs4filelayout.h"
>>>>>>
>>>>>> @@ -918,6 +920,26 @@ filelayout_free_deveiceid_node(struct nfs4_deviceid_node *d)
>>>>>>   nfs4_fl_free_deviceid(container_of(d, struct nfs4_file_layout_dsaddr, id_node));
>>>>>> }
>>>>>>
>>>>>> +static void
>>>>>> +filelayout_rpc_print_iostats(struct seq_file *m, struct nfs4_deviceid_node *d)
>>>>>> +{
>>>>>> + struct nfs4_file_layout_dsaddr *dsaddr;
>>>>>> + struct nfs4_pnfs_ds *ds;
>>>>>> + u32 i;
>>>>>> +
>>>>>> + dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
>>>>>> +
>>>>>> + for (i = 0; i < dsaddr->ds_num; i++) {
>>>>>> +         ds = dsaddr->ds_list[i];
>>>>>> +
>>>>>> +         if (ds && ds->ds_clp) {
>>>>>> +                 seq_printf(m, "  pnfs dataserver %s\n",
>>>>>> +                            ds->ds_remotestr);
>>>>>> +                 rpc_print_iostats(m, ds->ds_clp->cl_rpcclient);
>>>>>> +         }
>>>>>> + }
>>>>>> +}
>>>>>> +
>>>>>> static struct pnfs_layoutdriver_type filelayout_type = {
>>>>>>   .id                     = LAYOUT_NFSV4_1_FILES,
>>>>>>   .name                   = "LAYOUT_NFSV4_1_FILES",
>>>>>> @@ -932,6 +954,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
>>>>>>   .read_pagelist          = filelayout_read_pagelist,
>>>>>>   .write_pagelist         = filelayout_write_pagelist,
>>>>>>   .free_deviceid_node     = filelayout_free_deveiceid_node,
>>>>>> + .ds_rpc_print_iostats   = filelayout_rpc_print_iostats,
>>>>>> };
>>>>>>
>>>>>> static int __init nfs4filelayout_init(void)
>>>>>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>>>>>> index 53d593a..0a5e020 100644
>>>>>> --- a/fs/nfs/pnfs.h
>>>>>> +++ b/fs/nfs/pnfs.h
>>>>>> @@ -119,6 +119,9 @@ struct pnfs_layoutdriver_type {
>>>>>>   void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
>>>>>>                                struct xdr_stream *xdr,
>>>>>>                                const struct nfs4_layoutcommit_args *args);
>>>>>> +
>>>>>> + void (*ds_rpc_print_iostats) (struct seq_file *,
>>>>>> +                               struct nfs4_deviceid_node *);
>>>>>> };
>>>>>>
>>>>>> struct pnfs_layout_hdr {
>>>>>> @@ -239,6 +242,10 @@ void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
>>>>>> struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *);
>>>>>> bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
>>>>>> void nfs4_deviceid_purge_client(const struct nfs_client *);
>>>>>> +void nfs4_deviceid_rpc_print_iostats(struct seq_file *seq,
>>>>>> +                              const struct nfs_client *clp,
>>>>>> +                              const struct pnfs_layoutdriver_type *ld);
>>>>>> +
>>>>>>
>>>>>> static inline int lo_fail_bit(u32 iomode)
>>>>>> {
>>>>>> @@ -328,6 +335,14 @@ static inline int pnfs_return_layout(struct inode *ino)
>>>>>>   return 0;
>>>>>> }
>>>>>>
>>>>>> +static inline void
>>>>>> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
>>>>>> +{
>>>>>> + if (!pnfs_enabled_sb(nfss))
>>>>>> +         return;
>>>>>> + nfs4_deviceid_rpc_print_iostats(m, nfss->nfs_client,
>>>>>> +                                 nfss->pnfs_curr_ld);
>>>>>> +}
>>>>>> #else  /* CONFIG_NFS_V4_1 */
>>>>>>
>>>>>> static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
>>>>>> @@ -429,6 +444,11 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
>>>>>> static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
>>>>>> {
>>>>>> }
>>>>>> +
>>>>>> +static inline void
>>>>>> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
>>>>>> +{
>>>>>> +}
>>>>>> #endif /* CONFIG_NFS_V4_1 */
>>>>>>
>>>>>> #endif /* FS_NFS_PNFS_H */
>>>>>> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
>>>>>> index 4f359d2..277de87 100644
>>>>>> --- a/fs/nfs/pnfs_dev.c
>>>>>> +++ b/fs/nfs/pnfs_dev.c
>>>>>> @@ -115,6 +115,31 @@ nfs4_find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
>>>>>> }
>>>>>> EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
>>>>>>
>>>>>> +
>>>>>> +void
>>>>>> +nfs4_deviceid_rpc_print_iostats(struct seq_file *seq,
>>>>>> +                         const struct nfs_client *clp,
>>>>>> +                         const struct pnfs_layoutdriver_type *ld)
>>>>>> +{
>>>>>> + struct nfs4_deviceid_node *d;
>>>>>> + struct hlist_node *n;
>>>>>> + long h;
>>>>>> +
>>>>>> + if (!ld->ds_rpc_print_iostats)
>>>>>> +         return;
>>>>>> +
>>>>>> + rcu_read_lock();
>>>>>> + for (h = 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++) {
>>>>>> +         hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[h], node)
>>>>>> +                 if (d->ld == ld && d->nfs_client == clp) {
>>>>>> +                         if (atomic_read(&d->ref))
>>>>>> +                                 ld->ds_rpc_print_iostats(seq, d);
>>>>>> +                 }
>>>>>> + }
>>>>>> + rcu_read_unlock();
>>>>>> +}
>>>>>> +EXPORT_SYMBOL_GPL(nfs4_deviceid_rpc_print_iostats);
>>>>>> +
>>>>>> /*
>>>>>> * Remove a deviceid from cache
>>>>>> *
>>>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>>>>> index d18a90b..453e496 100644
>>>>>> --- a/fs/nfs/super.c
>>>>>> +++ b/fs/nfs/super.c
>>>>>> @@ -871,6 +871,7 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
>>>>>>   seq_printf(m, "\n");
>>>>>>
>>>>>>   rpc_print_iostats(m, nfss->client);
>>>>>> + pnfs_rpc_print_iostats(m, nfss);
>>>>>>
>>>>>>   return 0;
>>>>>> }
>>>>>> diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
>>>>>> index 8866bb3..7fe4605 100644
>>>>>> --- a/include/linux/nfs_iostat.h
>>>>>> +++ b/include/linux/nfs_iostat.h
>>>>>> @@ -21,7 +21,7 @@
>>>>>> #ifndef _LINUX_NFS_IOSTAT
>>>>>> #define _LINUX_NFS_IOSTAT
>>>>>>
>>>>>> -#define NFS_IOSTAT_VERS          "1.0"
>>>>>> +#define NFS_IOSTAT_VERS          "2.0"
>>>>>>
>>>>>> /*
>>>>>> * NFS byte counters
>>>>>> --
>>>>>> 1.7.4.4
>>>>>>
>>>>>
>>>>> --
>>>>> Chuck Lever
>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>
>>>>>
>>>>>
>>>>>
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
