Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:6185 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754713AbbGUUSu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2015 16:18:50 -0400
Subject: Re: [PATCH v3 15/15] core: Remove the ib_reg_phys_mr() and
 ib_rereg_phys_mr() verbs
To: Chuck Lever <chuck.lever@oracle.com>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190446.10997.83633.stgit@manet.1015granger.net>
 <55AEA6A4.8020204@Netapp.com>
 <D4DD6D9E-1660-4424-9A2A-54AE85368A7A@oracle.com>
CC: <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <55AEA926.5070200@Netapp.com>
Date: Tue, 21 Jul 2015 16:18:46 -0400
MIME-Version: 1.0
In-Reply-To: <D4DD6D9E-1660-4424-9A2A-54AE85368A7A@oracle.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/21/2015 04:16 PM, Chuck Lever wrote:
> Hi Anna-
> 
> 
> On Jul 21, 2015, at 4:08 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
>> Hey Chuck,
>>
>> Just a heads up that this patch should go through the infiniband tree, and not NFS :).
> 
> The IB maintainer has ACK’d it, so it can go through NFS. It depends
> on changes in an earlier patch in this series.

Fair enough!  I didn't realize Doug was the IB maintainer.

Anna
> 
> 
>> Thanks,
>> Anna
>>
>> On 07/20/2015 03:04 PM, Chuck Lever wrote:
>>> The verbs are obsolete. The ib_rereg_phys_mr() verb is not used by
>>> kernel ULPs, and the last ib_reg_phys_mr() call site in the kernel
>>> tree has now been removed.
>>>
>>> Two staging tree call sites remain in the Lustre client. The Lustre
>>> team has been notified of the deprecation of reg_phys_mr.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> Acked-by: Doug Ledford <dledford@redhat.com>
>>> ---
>>> drivers/infiniband/core/verbs.c |   67 ---------------------------------------
>>> include/rdma/ib_verbs.h         |   46 ---------------------------
>>> 2 files changed, 113 deletions(-)
>>>
>>> diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
>>> index bac3fb4..30eb245 100644
>>> --- a/drivers/infiniband/core/verbs.c
>>> +++ b/drivers/infiniband/core/verbs.c
>>> @@ -1144,73 +1144,6 @@ struct ib_mr *ib_get_dma_mr(struct ib_pd *pd, int mr_access_flags)
>>> }
>>> EXPORT_SYMBOL(ib_get_dma_mr);
>>>
>>> -struct ib_mr *ib_reg_phys_mr(struct ib_pd *pd,
>>> -			     struct ib_phys_buf *phys_buf_array,
>>> -			     int num_phys_buf,
>>> -			     int mr_access_flags,
>>> -			     u64 *iova_start)
>>> -{
>>> -	struct ib_mr *mr;
>>> -	int err;
>>> -
>>> -	err = ib_check_mr_access(mr_access_flags);
>>> -	if (err)
>>> -		return ERR_PTR(err);
>>> -
>>> -	if (!pd->device->reg_phys_mr)
>>> -		return ERR_PTR(-ENOSYS);
>>> -
>>> -	mr = pd->device->reg_phys_mr(pd, phys_buf_array, num_phys_buf,
>>> -				     mr_access_flags, iova_start);
>>> -
>>> -	if (!IS_ERR(mr)) {
>>> -		mr->device  = pd->device;
>>> -		mr->pd      = pd;
>>> -		mr->uobject = NULL;
>>> -		atomic_inc(&pd->usecnt);
>>> -		atomic_set(&mr->usecnt, 0);
>>> -	}
>>> -
>>> -	return mr;
>>> -}
>>> -EXPORT_SYMBOL(ib_reg_phys_mr);
>>> -
>>> -int ib_rereg_phys_mr(struct ib_mr *mr,
>>> -		     int mr_rereg_mask,
>>> -		     struct ib_pd *pd,
>>> -		     struct ib_phys_buf *phys_buf_array,
>>> -		     int num_phys_buf,
>>> -		     int mr_access_flags,
>>> -		     u64 *iova_start)
>>> -{
>>> -	struct ib_pd *old_pd;
>>> -	int ret;
>>> -
>>> -	ret = ib_check_mr_access(mr_access_flags);
>>> -	if (ret)
>>> -		return ret;
>>> -
>>> -	if (!mr->device->rereg_phys_mr)
>>> -		return -ENOSYS;
>>> -
>>> -	if (atomic_read(&mr->usecnt))
>>> -		return -EBUSY;
>>> -
>>> -	old_pd = mr->pd;
>>> -
>>> -	ret = mr->device->rereg_phys_mr(mr, mr_rereg_mask, pd,
>>> -					phys_buf_array, num_phys_buf,
>>> -					mr_access_flags, iova_start);
>>> -
>>> -	if (!ret && (mr_rereg_mask & IB_MR_REREG_PD)) {
>>> -		atomic_dec(&old_pd->usecnt);
>>> -		atomic_inc(&pd->usecnt);
>>> -	}
>>> -
>>> -	return ret;
>>> -}
>>> -EXPORT_SYMBOL(ib_rereg_phys_mr);
>>> -
>>> int ib_query_mr(struct ib_mr *mr, struct ib_mr_attr *mr_attr)
>>> {
>>> 	return mr->device->query_mr ?
>>> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
>>> index b0f898e..43c1cf0 100644
>>> --- a/include/rdma/ib_verbs.h
>>> +++ b/include/rdma/ib_verbs.h
>>> @@ -2760,52 +2760,6 @@ static inline void ib_dma_free_coherent(struct ib_device *dev,
>>> }
>>>
>>> /**
>>> - * ib_reg_phys_mr - Prepares a virtually addressed memory region for use
>>> - *   by an HCA.
>>> - * @pd: The protection domain associated assigned to the registered region.
>>> - * @phys_buf_array: Specifies a list of physical buffers to use in the
>>> - *   memory region.
>>> - * @num_phys_buf: Specifies the size of the phys_buf_array.
>>> - * @mr_access_flags: Specifies the memory access rights.
>>> - * @iova_start: The offset of the region's starting I/O virtual address.
>>> - */
>>> -struct ib_mr *ib_reg_phys_mr(struct ib_pd *pd,
>>> -			     struct ib_phys_buf *phys_buf_array,
>>> -			     int num_phys_buf,
>>> -			     int mr_access_flags,
>>> -			     u64 *iova_start);
>>> -
>>> -/**
>>> - * ib_rereg_phys_mr - Modifies the attributes of an existing memory region.
>>> - *   Conceptually, this call performs the functions deregister memory region
>>> - *   followed by register physical memory region.  Where possible,
>>> - *   resources are reused instead of deallocated and reallocated.
>>> - * @mr: The memory region to modify.
>>> - * @mr_rereg_mask: A bit-mask used to indicate which of the following
>>> - *   properties of the memory region are being modified.
>>> - * @pd: If %IB_MR_REREG_PD is set in mr_rereg_mask, this field specifies
>>> - *   the new protection domain to associated with the memory region,
>>> - *   otherwise, this parameter is ignored.
>>> - * @phys_buf_array: If %IB_MR_REREG_TRANS is set in mr_rereg_mask, this
>>> - *   field specifies a list of physical buffers to use in the new
>>> - *   translation, otherwise, this parameter is ignored.
>>> - * @num_phys_buf: If %IB_MR_REREG_TRANS is set in mr_rereg_mask, this
>>> - *   field specifies the size of the phys_buf_array, otherwise, this
>>> - *   parameter is ignored.
>>> - * @mr_access_flags: If %IB_MR_REREG_ACCESS is set in mr_rereg_mask, this
>>> - *   field specifies the new memory access rights, otherwise, this
>>> - *   parameter is ignored.
>>> - * @iova_start: The offset of the region's starting I/O virtual address.
>>> - */
>>> -int ib_rereg_phys_mr(struct ib_mr *mr,
>>> -		     int mr_rereg_mask,
>>> -		     struct ib_pd *pd,
>>> -		     struct ib_phys_buf *phys_buf_array,
>>> -		     int num_phys_buf,
>>> -		     int mr_access_flags,
>>> -		     u64 *iova_start);
>>> -
>>> -/**
>>>  * ib_query_mr - Retrieves information about a specific memory region.
>>>  * @mr: The memory region to retrieve information about.
>>>  * @mr_attr: The attributes of the specified memory region.
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 

