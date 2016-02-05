Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37759 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753542AbcBEQ3j convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 11:29:39 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH v1 02/10] svcrdma: Make svc_rdma_get_frmr() not sleep
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANjDDBgcNhpcyMpUF7SbD5eHZeXhx5ge+qSyfhhtHQbW-Gaqew@mail.gmail.com>
Date: Fri, 5 Feb 2016 11:29:35 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3714E63E-275C-4AFC-BFA7-0208500FC39E@oracle.com>
References: <20160203154411.13868.48268.stgit@klimt.1015granger.net> <20160203155138.13868.38423.stgit@klimt.1015granger.net> <CANjDDBgcNhpcyMpUF7SbD5eHZeXhx5ge+qSyfhhtHQbW-Gaqew@mail.gmail.com>
To: Devesh Sharma <devesh.sharma@broadcom.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 5, 2016, at 5:15 AM, Devesh Sharma <devesh.sharma@broadcom.com> wrote:
> 
> As I understand, you are pre-allocating because alloc_mr() can sleep
> so separate it out while map-frmr-wqe would be non-blocking context by
> definition, we are on the same page?

alloc_mr() can sleep, and so can kmalloc(GFP_KERNEL).
Currently svc_rdma_get_frmr() is called in a worker thread,
so it's in a process context and can sleep, but if we were
to move the RDMA Read logic into a softIRQ context (say,
invoked during Receive processing), it would be a problem
to sleep.

Another goal is to get rid of memory allocation operations
that can fail in low memory situations in areas of the code
where an error is hard to handle.

So the patch description is misleading and incorrect.

However, the problem with pre-allocating frmrs is that it
is not possible for the server to determine how many will
be needed at accept time. The maximum number depends on the
largest possible ULP payload size, the page list depth of
the server's device, and the maximum chunk size the client
is using (it could be as small as 4KB for some registration
modes). That would mean allocating thousands per connection
up front to cover every contingency.

Perhaps a better solution would be to understand how to
deal with an frmr allocation failure in rdma_read_chunk_frmr().
I think just dropping the connection would be reasonable.
If ib_post_recv() fails, for example, this is exactly what
the server does.

Christoph says he is about to modify or replace the NFS
server's RDMA Read code paths, however.

I'll drop this one.


> On Wed, Feb 3, 2016 at 9:21 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Want to call it in a context that cannot sleep. So pre-alloc
>> the memory and the MRs.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   44 ++++++++++++++++++++++++++----
>> 1 file changed, 38 insertions(+), 6 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 5763825..02eee12 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -949,7 +949,7 @@ static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
>>        return ERR_PTR(-ENOMEM);
>> }
>> 
>> -static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
>> +static void svc_rdma_destroy_frmrs(struct svcxprt_rdma *xprt)
>> {
>>        struct svc_rdma_fastreg_mr *frmr;
>> 
>> @@ -963,6 +963,37 @@ static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
>>        }
>> }
>> 
>> +static bool svc_rdma_prealloc_frmrs(struct svcxprt_rdma *xprt)
>> +{
>> +       struct ib_device *dev = xprt->sc_cm_id->device;
>> +       unsigned int i;
>> +
>> +       /* Pre-allocate based on the maximum amount of payload
>> +        * the server's HCA can handle per RDMA Read, to keep
>> +        * the number of MRs per connection in check.
>> +        *
>> +        * If a client sends small Read chunks (eg. it may be
>> +        * using physical registration), more RDMA Reads per
>> +        * NFS WRITE will be needed.  svc_rdma_get_frmr() dips
>> +        * into its reserve in that case. Better would be for
>> +        * the server to reduce the connection's credit limit.
>> +        */
>> +       i = 1 + RPCSVC_MAXPAGES / dev->attrs.max_fast_reg_page_list_len;
>> +       i *= xprt->sc_max_requests;
>> +
>> +       while (i--) {
>> +               struct svc_rdma_fastreg_mr *frmr;
>> +
>> +               frmr = rdma_alloc_frmr(xprt);
>> +               if (!frmr) {
>> +                       dprintk("svcrdma: No memory for request map\n");
>> +                       return false;
>> +               }
>> +               list_add(&frmr->frmr_list, &xprt->sc_frmr_q);
>> +       }
>> +       return true;
>> +}
>> +
>> struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
>> {
>>        struct svc_rdma_fastreg_mr *frmr = NULL;
>> @@ -975,10 +1006,9 @@ struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
>>                frmr->sg_nents = 0;
>>        }
>>        spin_unlock_bh(&rdma->sc_frmr_q_lock);
>> -       if (frmr)
>> -               return frmr;
>> -
>> -       return rdma_alloc_frmr(rdma);
>> +       if (!frmr)
>> +               return ERR_PTR(-ENOMEM);
>> +       return frmr;
>> }
>> 
>> void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
>> @@ -1149,6 +1179,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>                        dev->attrs.max_fast_reg_page_list_len;
>>                newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
>>                newxprt->sc_reader = rdma_read_chunk_frmr;
>> +               if (!svc_rdma_prealloc_frmrs(newxprt))
>> +                       goto errout;
>>        }
>> 
>>        /*
>> @@ -1310,7 +1342,7 @@ static void __svc_rdma_free(struct work_struct *work)
>>                xprt->xpt_bc_xprt = NULL;
>>        }
>> 
>> -       rdma_dealloc_frmr_q(rdma);
>> +       svc_rdma_destroy_frmrs(rdma);
>>        svc_rdma_destroy_ctxts(rdma);
>>        svc_rdma_destroy_maps(rdma);
>> 

--
Chuck Lever




