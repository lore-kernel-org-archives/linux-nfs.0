Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24691 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594AbbHFR4c convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2015 13:56:32 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] IB/core: Make ib_dealloc_pd return void
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55C2795C.7060700@Netapp.com>
Date: Thu, 6 Aug 2015 13:56:19 -0400
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Sagi Grimberg <sagig@mellanox.com>, Chien Yen <chien.yen@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Message-Id: <93DCD6DA-4CB5-4EE6-B073-E516CF3E41AA@oracle.com>
References: <20150805203431.GB30271@obsidianresearch.com> <C771535C-C9AD-4AC1-81BF-2A4122D5EDAE@oracle.com> <55C2795C.7060700@Netapp.com>
To: Doug Ledford <dledford@redhat.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 5, 2015, at 5:00 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> On 08/05/2015 04:50 PM, Chuck Lever wrote:
>> 
>> On Aug 5, 2015, at 4:34 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
>> 
>>> The majority of callers never check the return value, and even if they
>>> did, they can't do anything about a failure.
>>> 
>>> All possible failure cases represent a bug in the caller, so just
>>> WARN_ON inside the function instead.
>>> 
>>> This fixes a few random errors:
>>> net/rd/iw.c infinite loops while it fails. (racing with EBUSY?)
>>> 
>>> This also lays the ground work to get rid of error return from the
>>> drivers. Most drivers do not error, the few that do are broken since
>>> it cannot be handled.
>>> 
>>> Since uverbs can legitimately make use of EBUSY, open code the
>>> check.
>>> 
>>> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
>>> ---
>>> drivers/infiniband/core/uverbs_cmd.c       | 22 ++++++++++++++++------
>>> drivers/infiniband/core/verbs.c            | 26 ++++++++++++++++++++------
>>> drivers/infiniband/ulp/ipoib/ipoib_verbs.c |  4 +---
>>> drivers/infiniband/ulp/iser/iser_verbs.c   |  2 +-
>>> include/rdma/ib_verbs.h                    |  6 +-----
>>> net/rds/iw.c                               |  5 +----
>>> net/sunrpc/xprtrdma/verbs.c                |  2 +-
>>> 7 files changed, 41 insertions(+), 26 deletions(-)
>>> 
>>> Doug, this applies after the local_dma_lkey cleanup series.
>>> 
>>> Lightly tested with ipoib/uverbs/umad on mlx4.
>>> 
>>> This patch will expose buggy ULPs, I would not be too surprised to see
>>> a report of the WARN_ON triggering...
>>> 
>>> diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
>>> index 258485ee46b2..4c98696e3626 100644
>>> --- a/drivers/infiniband/core/uverbs_cmd.c
>>> +++ b/drivers/infiniband/core/uverbs_cmd.c
>>> @@ -606,6 +606,7 @@ ssize_t ib_uverbs_dealloc_pd(struct ib_uverbs_file *file,
>>> {
>>> 	struct ib_uverbs_dealloc_pd cmd;
>>> 	struct ib_uobject          *uobj;
>>> +	struct ib_pd		   *pd;
>>> 	int                         ret;
>>> 
>>> 	if (copy_from_user(&cmd, buf, sizeof cmd))
>>> @@ -614,15 +615,20 @@ ssize_t ib_uverbs_dealloc_pd(struct ib_uverbs_file *file,
>>> 	uobj = idr_write_uobj(&ib_uverbs_pd_idr, cmd.pd_handle, file->ucontext);
>>> 	if (!uobj)
>>> 		return -EINVAL;
>>> +	pd = uobj->object;
>>> 
>>> -	ret = ib_dealloc_pd(uobj->object);
>>> -	if (!ret)
>>> -		uobj->live = 0;
>>> -
>>> -	put_uobj_write(uobj);
>>> +	if (atomic_read(&pd->usecnt)) {
>>> +		ret = -EBUSY;
>>> +		goto err_put;
>>> +	}
>>> 
>>> +	ret = pd->device->dealloc_pd(uobj->object);
>>> +	WARN_ONCE(ret, "Infiniband HW driver failed dealloc_pd");
>>> 	if (ret)
>>> -		return ret;
>>> +		goto err_put;
>>> +
>>> +	uobj->live = 0;
>>> +	put_uobj_write(uobj);
>>> 
>>> 	idr_remove_uobj(&ib_uverbs_pd_idr, uobj);
>>> 
>>> @@ -633,6 +639,10 @@ ssize_t ib_uverbs_dealloc_pd(struct ib_uverbs_file *file,
>>> 	put_uobj(uobj);
>>> 
>>> 	return in_len;
>>> +
>>> +err_put:
>>> +	put_uobj_write(uobj);
>>> +	return ret;
>>> }
>>> 
>>> struct xrcd_table_entry {
>>> diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
>>> index bb561c8e51ad..b13f7a9240b5 100644
>>> --- a/drivers/infiniband/core/verbs.c
>>> +++ b/drivers/infiniband/core/verbs.c
>>> @@ -260,18 +260,32 @@ struct ib_pd *ib_alloc_pd(struct ib_device *device)
>>> }
>>> EXPORT_SYMBOL(ib_alloc_pd);
>>> 
>>> -int ib_dealloc_pd(struct ib_pd *pd)
>>> +/**
>>> + * ib_dealloc_pd - Deallocates a protection domain.
>>> + * @pd: The protection domain to deallocate.
>>> + *
>>> + * It is an error to call this function while any resources in the pd still
>>> + * exist.  The caller is responsible to synchronously destroy them and
>>> + * guarantee no new allocations will happen.
>>> + */
>>> +void ib_dealloc_pd(struct ib_pd *pd)
>>> {
>>> +	int ret;
>>> +
>>> 	if (pd->local_mr) {
>>> -		if (ib_dereg_mr(pd->local_mr))
>>> -			return -EBUSY;
>>> +		ret = ib_dereg_mr(pd->local_mr);
>>> +		WARN_ON(ret);
>>> 		pd->local_mr = NULL;
>>> 	}
>>> 
>>> -	if (atomic_read(&pd->usecnt))
>>> -		return -EBUSY;
>>> +	/* uverbs manipulates usecnt with proper locking, while the kabi
>>> +	   requires the caller to guarantee we can't race here. */
>>> +	WARN_ON(atomic_read(&pd->usecnt));
>>> 
>>> -	return pd->device->dealloc_pd(pd);
>>> +	/* Making delalloc_pd a void return is a WIP, no driver should return
>>> +	   an error here. */
>>> +	ret = pd->device->dealloc_pd(pd);
>>> +	WARN_ONCE(ret, "Infiniband HW driver failed dealloc_pd");
>>> }
>>> EXPORT_SYMBOL(ib_dealloc_pd);
>>> 
>>> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_verbs.c b/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
>>> index 8c451983d8a5..78845b6e8b81 100644
>>> --- a/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
>>> +++ b/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
>>> @@ -280,9 +280,7 @@ void ipoib_transport_dev_cleanup(struct net_device *dev)
>>> 		priv->wq = NULL;
>>> 	}
>>> 
>>> -	if (ib_dealloc_pd(priv->pd))
>>> -		ipoib_warn(priv, "ib_dealloc_pd failed\n");
>>> -
>>> +	ib_dealloc_pd(priv->pd);
>>> }
>>> 
>>> void ipoib_event(struct ib_event_handler *handler,
>>> diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
>>> index 52268356c79e..6e984e4b553b 100644
>>> --- a/drivers/infiniband/ulp/iser/iser_verbs.c
>>> +++ b/drivers/infiniband/ulp/iser/iser_verbs.c
>>> @@ -201,7 +201,7 @@ static void iser_free_device_ib_res(struct iser_device *device)
>>> 
>>> 	(void)ib_unregister_event_handler(&device->event_handler);
>>> 	(void)ib_dereg_mr(device->mr);
>>> -	(void)ib_dealloc_pd(device->pd);
>>> +	ib_dealloc_pd(device->pd);
>>> 
>>> 	kfree(device->comps);
>>> 	device->comps = NULL;
>>> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
>>> index eaec3081fb87..4aaab4fe459c 100644
>>> --- a/include/rdma/ib_verbs.h
>>> +++ b/include/rdma/ib_verbs.h
>>> @@ -2139,11 +2139,7 @@ int ib_find_pkey(struct ib_device *device,
>>> 
>>> struct ib_pd *ib_alloc_pd(struct ib_device *device);
>>> 
>>> -/**
>>> - * ib_dealloc_pd - Deallocates a protection domain.
>>> - * @pd: The protection domain to deallocate.
>>> - */
>>> -int ib_dealloc_pd(struct ib_pd *pd);
>>> +void ib_dealloc_pd(struct ib_pd *pd);
>>> 
>>> /**
>>> * ib_create_ah - Creates an address handle for the given address vector.
>>> diff --git a/net/rds/iw.c b/net/rds/iw.c
>>> index 589935661d66..5f228e00ad09 100644
>>> --- a/net/rds/iw.c
>>> +++ b/net/rds/iw.c
>>> @@ -149,10 +149,7 @@ static void rds_iw_remove_one(struct ib_device *device)
>>> 	if (rds_iwdev->mr)
>>> 		ib_dereg_mr(rds_iwdev->mr);
>>> 
>>> -	while (ib_dealloc_pd(rds_iwdev->pd)) {
>>> -		rdsdebug("Failed to dealloc pd %p\n", rds_iwdev->pd);
>>> -		msleep(1);
>>> -	}
>>> +	ib_dealloc_pd(rds_iwdev->pd);
>>> 
>>> 	list_del(&rds_iwdev->list);
>>> 	kfree(rds_iwdev);
>>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>>> index 891c4ede2c20..afd504375a9a 100644
>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>> @@ -624,7 +624,7 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
>>> 
>>> 	/* If the pd is still busy, xprtrdma missed freeing a resource */
>>> 	if (ia->ri_pd && !IS_ERR(ia->ri_pd))
>>> -		WARN_ON(ib_dealloc_pd(ia->ri_pd));
>>> +		ib_dealloc_pd(ia->ri_pd);
>>> }
>>> 
>>> /*
>> 
>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>> 
>> Does this hunk or the xprtrdma changes in the local DMA lkey
>> series need an Acked-by: from Anna?
> 
> If it's a client side change, then yeah it'll need an Acked-by from me.  I'm not sure if I've seen the DMA lkey changes yet, can somebody point me to them?
> 
> This hunk looks fine to me:
> 
> 	Acked-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Thanks, Anna.

My concern is:

Developers for the other ULPs appear to be on linux-rdma
already, and that work is typically submitted through
Doug anyway.

But the RPC/RDMA pieces are maintained separately, as
part of NFS. I'm an area expert, but not a maintainer; I
can review patches, but I can't Ack them.

I'm on both lists. I've tried to catch things on a case
by case basis, but it's becoming difficult due to the
recent high rate of change.

May I propose a little extra process for patches that
touch RPC/RDMA, to make sure they get the proper review
and Acked-by?

For any patches that touch files under net/sunrpc, please
cc: linux-nfs@vger.kernel.org. Folks on linux-nfs will
sort out who needs to respond.

Thoughts?


--
Chuck Lever



