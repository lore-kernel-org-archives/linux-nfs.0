Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:65401 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab2BMIF3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 03:05:29 -0500
Received: by eaah12 with SMTP id h12so1695299eaa.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 00:05:27 -0800 (PST)
Message-ID: <4F38C443.2060307@tonian.com>
Date: Mon, 13 Feb 2012 10:05:23 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] RFC: NFS - filelayout DS rpc mountstats support
References: <1328721042-9335-1-git-send-email-dros@netapp.com> <1CFC0549-DFAC-4530-A3A5-876DDAE8C5DE@oracle.com> <B22F73F9-8343-4543-922E-26F48AA78A90@netapp.com>
In-Reply-To: <B22F73F9-8343-4543-922E-26F48AA78A90@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the late response.

On 2012-02-08 23:04, Adamson, Dros wrote:
> 
> On Feb 8, 2012, at 12:26 PM, Chuck Lever wrote:
> 
>> Hi-
>>
>> On Feb 8, 2012, at 12:10 PM, Weston Andros Adamson wrote:
>>
>>> The per-op stats displayed in /self/proc/mountstats are collected in the sunrpc
>>
>> You mean /proc/self/mountstats here.
> 
> oops!
> 
>>
>>> layer and are collected per rpc_client.  This has worked for nfs thus far
>>> since only one nfs_client was ever associated with a mountpoint, but with
>>> NFS4.1+PNFS+filelayout an nfs mount can have more than one nfs_client.
>>>
>>> This can be seen with a pnfs mount where no data server is the same as the MDS -
>>> all reads, writes and commits will never make it into the current mountstats
>>> output.
>>>
>>> I took the approach of keeping the stats from the MDS and DSs separate in the
>>> /proc/self/mountstats output to avoid doing too much in the kernel, and to
>>> expose the fact that these stats are from separate connections (maybe for later
>>> use).
>>>
>>> This method has issues:
>>>
>>> 1) even changing the "statvers" of mountstats doesn't stop the userland
>>>   mountstats(8) from trying to parse this output -- and it does so
>>>   incorrectly.
>>
>> User land is broken then.  :-)
> 
> Agreed!
> 
>>
>>> 2) when using DS multipath this method fails to count operations that happened
>>>   on a different path to the same DS (after a failure).
> 
> I should have noted that this isn't a problem yet because I haven't submitted the multipath failover patches :)
> 
>>>
>>> 3) currently this will display stats twice when DS == MDS.
>>
>> Why is this case hard to detect in the kernel or in mountstats?
> 
> Not hard, just an issue with the current patch.
> 
>>
>>>
>>> So... What should I do here?
>>>
>>> A different approach is to add support in net/sunrpc to specify a "parent"
>>> stat structure so that operations on DS nfs_clients bump stats on
>>> the main nfs_server->nfs_client->rpc_client.  This would take care of all the
>>> issues with the current patch, but seems like a hack.
>>
>> Is this the same as displaying all data in one set of stats?
> 
> Yes
> 
>>
>> Seems like that might be the best next step, then we can split up the MDS and DS stats at some later point.

Splitting up the MDS/DS stats is important to tell when DS I/O is being
done and how effective it is.

Benny

> 
> Ok, I'll try to do that.
> 
> Any advice on how to handle the "xprt: …" line?  Obviously the different underlying rpc_clients will have different values.  I'd have to look at mountstats(8) some more, but I *think* we could just make it a comma separated list.
> 
> For the 'next step', we can use this patch - we just need to figure out where it should go.  Do we keep it in /proc/self/mountstats?  I think because of problem #2 we might want to move them out to somewhere in /proc/fs/nfsfs/ along with other per-DS statistics.
> 
>>
>>> One task that seems like a good thing to do is to fix mountstats(8) to respect
>>> the "statsvers" value.
>>
>> Agree.
> 
> I'll do this first.
> 
> Thanks Chuck!
> 
> -dros
> 
>>
>>>
>>> Thoughts?
>>> ---
>>>
>>> I cleaned up this patch, but I still have reservations (noted in commit message)
>>>
>>> fs/nfs/nfs4filelayout.c    |   23 +++++++++++++++++++++++
>>> fs/nfs/pnfs.h              |   20 ++++++++++++++++++++
>>> fs/nfs/pnfs_dev.c          |   25 +++++++++++++++++++++++++
>>> fs/nfs/super.c             |    1 +
>>> include/linux/nfs_iostat.h |    2 +-
>>> 5 files changed, 70 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>> index 79be7ac..9410fd0 100644
>>> --- a/fs/nfs/nfs4filelayout.c
>>> +++ b/fs/nfs/nfs4filelayout.c
>>> @@ -33,6 +33,8 @@
>>> #include <linux/nfs_page.h>
>>> #include <linux/module.h>
>>>
>>> +#include <linux/sunrpc/metrics.h>
>>> +
>>> #include "internal.h"
>>> #include "nfs4filelayout.h"
>>>
>>> @@ -918,6 +920,26 @@ filelayout_free_deveiceid_node(struct nfs4_deviceid_node *d)
>>> 	nfs4_fl_free_deviceid(container_of(d, struct nfs4_file_layout_dsaddr, id_node));
>>> }
>>>
>>> +static void
>>> +filelayout_rpc_print_iostats(struct seq_file *m, struct nfs4_deviceid_node *d)
>>> +{
>>> +	struct nfs4_file_layout_dsaddr *dsaddr;
>>> +	struct nfs4_pnfs_ds *ds;
>>> +	u32 i;
>>> +
>>> +	dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
>>> +
>>> +	for (i = 0; i < dsaddr->ds_num; i++) {
>>> +		ds = dsaddr->ds_list[i];
>>> +
>>> +		if (ds && ds->ds_clp) {
>>> +			seq_printf(m, "  pnfs dataserver %s\n",
>>> +				   ds->ds_remotestr);
>>> +			rpc_print_iostats(m, ds->ds_clp->cl_rpcclient);
>>> +		}
>>> +	}
>>> +}
>>> +
>>> static struct pnfs_layoutdriver_type filelayout_type = {
>>> 	.id			= LAYOUT_NFSV4_1_FILES,
>>> 	.name			= "LAYOUT_NFSV4_1_FILES",
>>> @@ -932,6 +954,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
>>> 	.read_pagelist		= filelayout_read_pagelist,
>>> 	.write_pagelist		= filelayout_write_pagelist,
>>> 	.free_deviceid_node	= filelayout_free_deveiceid_node,
>>> +	.ds_rpc_print_iostats	= filelayout_rpc_print_iostats,
>>> };
>>>
>>> static int __init nfs4filelayout_init(void)
>>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>>> index 53d593a..0a5e020 100644
>>> --- a/fs/nfs/pnfs.h
>>> +++ b/fs/nfs/pnfs.h
>>> @@ -119,6 +119,9 @@ struct pnfs_layoutdriver_type {
>>> 	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
>>> 				     struct xdr_stream *xdr,
>>> 				     const struct nfs4_layoutcommit_args *args);
>>> +
>>> +	void (*ds_rpc_print_iostats) (struct seq_file *,
>>> +				      struct nfs4_deviceid_node *);
>>> };
>>>
>>> struct pnfs_layout_hdr {
>>> @@ -239,6 +242,10 @@ void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
>>> struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *);
>>> bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
>>> void nfs4_deviceid_purge_client(const struct nfs_client *);
>>> +void nfs4_deviceid_rpc_print_iostats(struct seq_file *seq,
>>> +				     const struct nfs_client *clp,
>>> +				     const struct pnfs_layoutdriver_type *ld);
>>> +
>>>
>>> static inline int lo_fail_bit(u32 iomode)
>>> {
>>> @@ -328,6 +335,14 @@ static inline int pnfs_return_layout(struct inode *ino)
>>> 	return 0;
>>> }
>>>
>>> +static inline void
>>> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
>>> +{
>>> +	if (!pnfs_enabled_sb(nfss))
>>> +		return;
>>> +	nfs4_deviceid_rpc_print_iostats(m, nfss->nfs_client,
>>> +					nfss->pnfs_curr_ld);
>>> +}
>>> #else  /* CONFIG_NFS_V4_1 */
>>>
>>> static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
>>> @@ -429,6 +444,11 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
>>> static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
>>> {
>>> }
>>> +
>>> +static inline void
>>> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
>>> +{
>>> +}
>>> #endif /* CONFIG_NFS_V4_1 */
>>>
>>> #endif /* FS_NFS_PNFS_H */
>>> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
>>> index 4f359d2..277de87 100644
>>> --- a/fs/nfs/pnfs_dev.c
>>> +++ b/fs/nfs/pnfs_dev.c
>>> @@ -115,6 +115,31 @@ nfs4_find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
>>> }
>>> EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
>>>
>>> +
>>> +void
>>> +nfs4_deviceid_rpc_print_iostats(struct seq_file *seq,
>>> +				const struct nfs_client *clp,
>>> +				const struct pnfs_layoutdriver_type *ld)
>>> +{
>>> +	struct nfs4_deviceid_node *d;
>>> +	struct hlist_node *n;
>>> +	long h;
>>> +
>>> +	if (!ld->ds_rpc_print_iostats)
>>> +		return;
>>> +
>>> +	rcu_read_lock();
>>> +	for (h = 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++) {
>>> +		hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[h], node)
>>> +			if (d->ld == ld && d->nfs_client == clp) {
>>> +				if (atomic_read(&d->ref))
>>> +					ld->ds_rpc_print_iostats(seq, d);
>>> +			}
>>> +	}
>>> +	rcu_read_unlock();
>>> +}
>>> +EXPORT_SYMBOL_GPL(nfs4_deviceid_rpc_print_iostats);
>>> +
>>> /*
>>> * Remove a deviceid from cache
>>> *
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index d18a90b..453e496 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -871,6 +871,7 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
>>> 	seq_printf(m, "\n");
>>>
>>> 	rpc_print_iostats(m, nfss->client);
>>> +	pnfs_rpc_print_iostats(m, nfss);
>>>
>>> 	return 0;
>>> }
>>> diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
>>> index 8866bb3..7fe4605 100644
>>> --- a/include/linux/nfs_iostat.h
>>> +++ b/include/linux/nfs_iostat.h
>>> @@ -21,7 +21,7 @@
>>> #ifndef _LINUX_NFS_IOSTAT
>>> #define _LINUX_NFS_IOSTAT
>>>
>>> -#define NFS_IOSTAT_VERS		"1.0"
>>> +#define NFS_IOSTAT_VERS		"2.0"
>>>
>>> /*
>>> * NFS byte counters
>>> -- 
>>> 1.7.4.4
>>>
>>
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>>
> 
