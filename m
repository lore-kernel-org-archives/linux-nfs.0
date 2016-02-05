Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:33289 "EHLO
	mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138AbcBERt5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 12:49:57 -0500
Received: by mail-yw0-f170.google.com with SMTP id z185so56882339ywf.0
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 09:49:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3714E63E-275C-4AFC-BFA7-0208500FC39E@oracle.com>
References: <20160203154411.13868.48268.stgit@klimt.1015granger.net>
 <20160203155138.13868.38423.stgit@klimt.1015granger.net> <CANjDDBgcNhpcyMpUF7SbD5eHZeXhx5ge+qSyfhhtHQbW-Gaqew@mail.gmail.com>
 <3714E63E-275C-4AFC-BFA7-0208500FC39E@oracle.com>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Fri, 5 Feb 2016 23:19:17 +0530
Message-ID: <CANjDDBj56NoQBAVH6jfMAbfraOuGfA=ZVip-RVRp63NycpH2AQ@mail.gmail.com>
Subject: Re: [PATCH v1 02/10] svcrdma: Make svc_rdma_get_frmr() not sleep
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 5, 2016 at 9:59 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> On Feb 5, 2016, at 5:15 AM, Devesh Sharma <devesh.sharma@broadcom.com> wrote:
>>
>> As I understand, you are pre-allocating because alloc_mr() can sleep
>> so separate it out while map-frmr-wqe would be non-blocking context by
>> definition, we are on the same page?
>
> alloc_mr() can sleep, and so can kmalloc(GFP_KERNEL).
> Currently svc_rdma_get_frmr() is called in a worker thread,
> so it's in a process context and can sleep, but if we were
> to move the RDMA Read logic into a softIRQ context (say,
> invoked during Receive processing), it would be a problem
> to sleep.

Got it.

>
> Another goal is to get rid of memory allocation operations
> that can fail in low memory situations in areas of the code
> where an error is hard to handle.

>
> So the patch description is misleading and incorrect.

Got it

>
> However, the problem with pre-allocating frmrs is that it
> is not possible for the server to determine how many will
> be needed at accept time. The maximum number depends on the
> largest possible ULP payload size, the page list depth of
> the server's device, and the maximum chunk size the client
> is using (it could be as small as 4KB for some registration
> modes). That would mean allocating thousands per connection
> up front to cover every contingency.

Can't it decide on the fly? start with 'n' smaller size of frmrs
where 'n' is derived from some static calculation. Then if the
connection demands bigger size, increase the depth of all 'n' frmrs and
reuse them till the life of the connection. if it demands more frmr,
don't do anything
and try to manage with 'n'. Does it makes sense I am sure I am missing
few points here.

>
> Perhaps a better solution would be to understand how to
> deal with an frmr allocation failure in rdma_read_chunk_frmr().
> I think just dropping the connection would be reasonable.
> If ib_post_recv() fails, for example, this is exactly what
> the server does.

Dropping the connection seems logical, however, I think it would be
a harsh decision for any hypothetical device which has less IB/RoCE
resources e.g. any given VM in SRIOV enabled environment where lots
of VFs are enabled.

As suggested earlier in this mail,  just continue the connection with whatever
resources it has would let low-resource-device still to use it. if
the system is recovered from memory-pressure, the allocations would
succeed eventually.
drawback is performance penalty.

>
> Christoph says he is about to modify or replace the NFS
> server's RDMA Read code paths, however.
>
> I'll drop this one.
>
>
>> On Wed, Feb 3, 2016 at 9:21 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> Want to call it in a context that cannot sleep. So pre-alloc
>>> the memory and the MRs.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   44 ++++++++++++++++++++++++++----
>>> 1 file changed, 38 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> index 5763825..02eee12 100644
>>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> @@ -949,7 +949,7 @@ static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
>>>        return ERR_PTR(-ENOMEM);
>>> }
>>>
>>> -static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
>>> +static void svc_rdma_destroy_frmrs(struct svcxprt_rdma *xprt)
>>> {
>>>        struct svc_rdma_fastreg_mr *frmr;
>>>
>>> @@ -963,6 +963,37 @@ static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
>>>        }
>>> }
>>>
>>> +static bool svc_rdma_prealloc_frmrs(struct svcxprt_rdma *xprt)
>>> +{
>>> +       struct ib_device *dev = xprt->sc_cm_id->device;
>>> +       unsigned int i;
>>> +
>>> +       /* Pre-allocate based on the maximum amount of payload
>>> +        * the server's HCA can handle per RDMA Read, to keep
>>> +        * the number of MRs per connection in check.
>>> +        *
>>> +        * If a client sends small Read chunks (eg. it may be
>>> +        * using physical registration), more RDMA Reads per
>>> +        * NFS WRITE will be needed.  svc_rdma_get_frmr() dips
>>> +        * into its reserve in that case. Better would be for
>>> +        * the server to reduce the connection's credit limit.
>>> +        */
>>> +       i = 1 + RPCSVC_MAXPAGES / dev->attrs.max_fast_reg_page_list_len;
>>> +       i *= xprt->sc_max_requests;
>>> +
>>> +       while (i--) {
>>> +               struct svc_rdma_fastreg_mr *frmr;
>>> +
>>> +               frmr = rdma_alloc_frmr(xprt);
>>> +               if (!frmr) {
>>> +                       dprintk("svcrdma: No memory for request map\n");
>>> +                       return false;
>>> +               }
>>> +               list_add(&frmr->frmr_list, &xprt->sc_frmr_q);
>>> +       }
>>> +       return true;
>>> +}
>>> +
>>> struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
>>> {
>>>        struct svc_rdma_fastreg_mr *frmr = NULL;
>>> @@ -975,10 +1006,9 @@ struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
>>>                frmr->sg_nents = 0;
>>>        }
>>>        spin_unlock_bh(&rdma->sc_frmr_q_lock);
>>> -       if (frmr)
>>> -               return frmr;
>>> -
>>> -       return rdma_alloc_frmr(rdma);
>>> +       if (!frmr)
>>> +               return ERR_PTR(-ENOMEM);
>>> +       return frmr;
>>> }
>>>
>>> void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
>>> @@ -1149,6 +1179,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>>                        dev->attrs.max_fast_reg_page_list_len;
>>>                newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
>>>                newxprt->sc_reader = rdma_read_chunk_frmr;
>>> +               if (!svc_rdma_prealloc_frmrs(newxprt))
>>> +                       goto errout;
>>>        }
>>>
>>>        /*
>>> @@ -1310,7 +1342,7 @@ static void __svc_rdma_free(struct work_struct *work)
>>>                xprt->xpt_bc_xprt = NULL;
>>>        }
>>>
>>> -       rdma_dealloc_frmr_q(rdma);
>>> +       svc_rdma_destroy_frmrs(rdma);
>>>        svc_rdma_destroy_ctxts(rdma);
>>>        svc_rdma_destroy_maps(rdma);
>>>
>
> --
> Chuck Lever
>
>
>
>
