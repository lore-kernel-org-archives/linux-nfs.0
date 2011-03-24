Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:33130 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab1CXQhH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2011 12:37:07 -0400
Message-ID: <4D8B732F.8020404@panasas.com>
Date: Thu, 24 Mar 2011 18:37:03 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
CC: Fred Isaman <iisaman@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 11/12] NFSv4.1: layoutcommit
References: <AANLkTinBuLxDq5zrxC=-0fS_md5CXTQAS_POsKA9issP@mail.gmail.com>
In-Reply-To: <AANLkTinBuLxDq5zrxC=-0fS_md5CXTQAS_POsKA9issP@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-03-24 15:57, William A. (Andy) Adamson wrote:
>>> Only whole file layout support means that there is only one IOMODE_RW layout
>>> segment.
>>>
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
>>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>>> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
>>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>>> Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
>>> Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
>>> Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
>>> Tested-by: Boaz Harrosh <bharrosh@panasas.com>
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>
>> The code in this patch is new and different enough from the one I/we
>> signed-off originally that they don't make sense here.
> 
> Hi Benny
> 
> OK with me
> 
>>>
>>> +             /* references matched in nfs4_layoutcommit_release */
>>> +             wdata->lseg->pls_lc_cred =
>>> +                     get_rpccred(wdata->args.context->state->owner->so_cred);
>>> +             mark_inode_dirty_sync(wdata->inode);
>>> +             dprintk("%s: Set layoutcommit for inode %lu ",
>>> +                     __func__, wdata->inode->i_ino);
>>> +     }
>>> +     if (end_pos > wdata->lseg->pls_end_pos)
>>> +             wdata->lseg->pls_end_pos = end_pos;
>>
>> The end_pos is essentially per inode, why maintain it per lseg?
>> How do you see this working with multiple lsegs in mind?
> 
> The end-pos is per lseg, not per inode - each layoutcommit applies to
> a range of WRITES for a layoutsegment over the LAYOUTCOMMIT range.
> 
> From Section 18.42.3
> .  The byte-range being committed is
>    specified through the byte-range (loca_offset and loca_length).  This
>    byte-range MUST overlap with one or more existing layouts previously
>    granted via LAYOUTGET
> 
> 
>    Also, loca_last_write_offset MUST overlap the range
>    described by loca_offset and loca_length.
> 
> For the multiple lseg case: if the lsegs are merged, bookeeping
> end_pos per lseg just works. If a layoutdriver does not use merged
> lsegs, then there is a bit of work to do to walk the list of lsegs and
> determine the final end_pos for a given LAYOUTCOMMIT.  If there are
> multiple non-contiguous lsegs, each used for WRITEs then multiple
> LAYOUTCOMMITs will need to be sent, otherwise the LAYOUTCOMMIT
> byte-range will not overlap as required.
> 

For the current layout types I believe that the LAYOUTCOMMIT can "merge"
multiple layout segments into a single LAYOUTCOMMIT, with a byte range
covering all segments and a last_byte_written offset which is just the maximum.
Future layout types may need this method though...

Benny

>>> +pnfs_layoutcommit_inode(struct inode *inode, int sync)
>>
>> "bool sync" makes more sense
> 
>>> +{
>>> +     struct nfs4_layoutcommit_data *data;
>>> +     struct nfs_inode *nfsi = NFS_I(inode);
>>> +     struct pnfs_layout_segment *lseg;
>>> +     struct rpc_cred *cred;
>>> +     loff_t end_pos;
>>> +     int status = 0;
>>> +
>>> +     dprintk("--> %s inode %lu\n", __func__, inode->i_ino);
>>> +
>>> +     /* Note kzalloc ensures data->res.seq_res.sr_slot == NULL */
>>> +     data = kzalloc(sizeof(*data), GFP_NOFS);
>>> +     spin_lock(&inode->i_lock);
>>> +
>>> +     if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
>>
>> previously (i.e. in the linux-pnfs tree :) this function is called only
>> if layoutcommit_needed(), now I worry may waste a kzalloc too frequently.
>> I suggest testing (and not clearing) NFS_INO_LAYOUTCOMMIT before doing
>> the allocation to prevent that.
> 
> Agreed.
> 
>>> +     end_pos = lseg->pls_end_pos;
>>> +     cred = lseg->pls_lc_cred;
>>> +     lseg->pls_end_pos = 0;
>>> +     lseg->pls_lc_cred = NULL;
>>> +
>>> +     if (!data) {
>>
>> eh?
>> why not test this before test_and_clear_bit(NFS_INO_LAYOUTCOMMIT ?
> 
> Because we should clear the LAYOUTCOMMIT needed information from the inode.
> The LAYOUTCOMMIT for the file layout is an optimization. If the client
> can't alloc the required buffer, the compound just won't be sent.
> 
> -->Andy
