Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36925 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbFCV45 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2015 17:56:57 -0400
Message-ID: <556F7824.9020401@oracle.com>
Date: Wed, 03 Jun 2015 14:56:52 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFS/RDMA Release resources in svcrdma when device
 is removed
References: <556F4A0C.2030804@oracle.com> <35CA749D-949B-4C07-8B75-218C0CA036B7@oracle.com> <72BBBB34-149E-4E97-AC89-D55B08BF675D@oracle.com>
In-Reply-To: <72BBBB34-149E-4E97-AC89-D55B08BF675D@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/03/2015 11:49 AM, Chuck Lever wrote:
> 
> On Jun 3, 2015, at 2:44 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>>
>> On Jun 3, 2015, at 2:40 PM, Shirley Ma <shirley.ma@oracle.com> wrote:
>>
>>> When removing underlying RDMA device, the rmmod will hang forever if there
>>> are any outstanding NFS/RDMA client mounts. The outstanding NFS/RDMA counts 
>>> could also prevent the server from shutting down. Further debugging shows 
>>> that the existing connections are not teared down and resource are not 
>>> released when receiving RDMA_CM_EVENT_DEVICE_REMOVAL event. It seems the 
>>> original code missing svc_xprt_put() in RDMA_CM_EVENT_REMOVAL event handler 
>>> thus svc_xprt_free is never invoked to release the existing connection resources.
>>>
>>> The patch has been passed removing, adding device back and forth without 
>>> stopping NFS/RDMA service. This will also allow a device to be unplugged 
>>> and swapped out without shutting down NFS service.
> 
> And maybe also add:
> 
> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=252

Yes, this patch has addressed above problem too. I forgot this bug.
 
> here.
> 
>>> Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
>>
>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>>
>>> ---
>>> net/sunrpc/xprtrdma/svc_rdma_transport.c | 1 +
>>> 1 file changed, 1 insertion(+)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> index f609c1c..2b82569 100644
>>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> @@ -673,6 +673,7 @@ static int rdma_cma_handler(struct rdma_cm_id *cma_id,
>>> 		if (xprt) {
>>> 			set_bit(XPT_CLOSE, &xprt->xpt_flags);
>>> 			svc_xprt_enqueue(xprt);
>>> +			svc_xprt_put(xprt);
>>> 		}
>>> 		break;
>>> 	default:
>>>
>>> Shirley
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
