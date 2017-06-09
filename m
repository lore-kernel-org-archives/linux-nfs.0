Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19543 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751649AbdFITMi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jun 2017 15:12:38 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 04/13] xprtrdma: Rename rpcrdma_req::rl_free
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5332A4D9-ADC4-4DA4-A20E-ACC6019F83BF@oracle.com>
Date: Fri, 9 Jun 2017 15:12:33 -0400
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C0C5BD8B-9D97-48F4-A0AD-C7FC17DA9C00@oracle.com>
References: <20170608154339.18945.5500.stgit@manet.1015granger.net> <20170608155212.18945.37327.stgit@manet.1015granger.net> <7ee9b1fd-9628-2767-444e-90c6736d63f9@Netapp.com> <5332A4D9-ADC4-4DA4-A20E-ACC6019F83BF@oracle.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 9, 2017, at 3:03 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Jun 9, 2017, at 2:58 PM, Anna Schumaker <Anna.Schumaker@Netapp.com> wrote:
>> 
>> Hi Chuck,
>> 
>> On 06/08/2017 11:52 AM, Chuck Lever wrote:
>>> Clean up: I'm about to use the rl_free field for purposes other than
>>> a free list. So use a more generic name.
>>> 
>>> This is a refactoring change only.
>>> 
>>> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=305
>>> Fixes: 68791649a725 ('xprtrdma: Invalidate in the RPC reply ... ')
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> net/sunrpc/xprtrdma/verbs.c     |    9 ++++-----
>>> net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
>>> 2 files changed, 5 insertions(+), 6 deletions(-)
>>> 
>>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>>> index a8be66d..df72224 100644
>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>> @@ -971,7 +971,6 @@ struct rpcrdma_req *
>>> 	if (req == NULL)
>>> 		return ERR_PTR(-ENOMEM);
>>> 
>>> -	INIT_LIST_HEAD(&req->rl_free);
>> 
>> Does rl_list still need to get initialized somewhere?
> 
> rl_free/rl_list isn't the anchor of a list. It is only
> ever a member of a list. So this INIT_LIST_HEAD is actually
> unnecessary.

Or, put another way: since list_empty() is not used
on this field anywhere, it shouldn't be necessary to
ensure it is initialized.


>> Thanks,
>> Anna
>> 
>>> 	spin_lock(&buffer->rb_reqslock);
>>> 	list_add(&req->rl_all, &buffer->rb_allreqs);
>>> 	spin_unlock(&buffer->rb_reqslock);
>>> @@ -1055,7 +1054,7 @@ struct rpcrdma_rep *
>>> 			goto out;
>>> 		}
>>> 		req->rl_backchannel = false;
>>> -		list_add(&req->rl_free, &buf->rb_send_bufs);
>>> +		list_add(&req->rl_list, &buf->rb_send_bufs);
>>> 	}
>>> 
>>> 	INIT_LIST_HEAD(&buf->rb_recv_bufs);
>>> @@ -1084,8 +1083,8 @@ struct rpcrdma_rep *
>>> 	struct rpcrdma_req *req;
>>> 
>>> 	req = list_first_entry(&buf->rb_send_bufs,
>>> -			       struct rpcrdma_req, rl_free);
>>> -	list_del(&req->rl_free);
>>> +			       struct rpcrdma_req, rl_list);
>>> +	list_del(&req->rl_list);
>>> 	return req;
>>> }
>>> 
>>> @@ -1268,7 +1267,7 @@ struct rpcrdma_req *
>>> 
>>> 	spin_lock(&buffers->rb_lock);
>>> 	buffers->rb_send_count--;
>>> -	list_add_tail(&req->rl_free, &buffers->rb_send_bufs);
>>> +	list_add_tail(&req->rl_list, &buffers->rb_send_bufs);
>>> 	if (rep) {
>>> 		buffers->rb_recv_count--;
>>> 		list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
>>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> index 1c23117..ad918c8 100644
>>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> @@ -340,7 +340,7 @@ enum {
>>> 
>>> struct rpcrdma_buffer;
>>> struct rpcrdma_req {
>>> -	struct list_head	rl_free;
>>> +	struct list_head	rl_list;
>>> 	unsigned int		rl_mapped_sges;
>>> 	unsigned int		rl_connect_cookie;
>>> 	struct rpcrdma_buffer	*rl_buffer;
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



