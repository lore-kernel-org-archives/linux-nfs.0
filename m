Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:29762 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933051Ab0BFANV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2010 19:13:21 -0500
Message-ID: <4B6CB3C7.8070001@oracle.com>
Date: Fri, 05 Feb 2010 19:11:51 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
CC: Alexandros Batsakis <batsakis@netapp.com>, linux-nfs@vger.kernel.org,
        trond@netapp.com
Subject: Re: [PATCH 6/6] RPC: adjust timeout for connect, bind, restablish
 so that they sensitive to the major time out value
References: <1265155576-7618-1-git-send-email-batsakis@netapp.com> <1265155576-7618-2-git-send-email-batsakis@netapp.com> <1265155576-7618-3-git-send-email-batsakis@netapp.com> <1265155576-7618-4-git-send-email-batsakis@netapp.com> <1265155576-7618-5-git-send-email-batsakis@netapp.com> <1265155576-7618-6-git-send-email-batsakis@netapp.com> <1265155576-7618-7-git-send-email-batsakis@netapp.com> <4B6C7BCA.2040806@oracle.com> <383F4881-BD88-4155-B605-4D24F5B05BDD@netapp.com> <4B6C9FA7.2010702@oracle.com> <77EBFB14-A6B6-41DC-90DC-7A00548DFAEA@netapp.com>
In-Reply-To: <77EBFB14-A6B6-41DC-90DC-7A00548DFAEA@netapp.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/05/2010 06:04 PM, Batsakis, Alexandros wrote:
>
>
> On Feb 5, 2010, at 14:47, "Chuck Lever" <chuck.lever@oracle.com> wrote:
>
>> On 02/05/2010 05:14 PM, Batsakis, Alexandros wrote:
>>> Yeah sure,
>>>
>>> So imagine that for a specific connection the remaining major timeo
>>> value is 30secs. Xs_connect has a default timeout before attempting to
>>> reconnect of 60secs. The user (NFS) expects to "hear back" from the rpc
>>> layer within the timeout as in often cases e.g. lease renewal, it's of
>>> no benefit for an operation to reach the server at a later time and miss
>>> the critical time because it was sleeping for an arbitrary amount of
>>> time.

Maybe you want RPC_TASK_SOFTCONN for NFSv4 renewals instead of 
RPC_TASK_SOFT.  This would cause the RENEW request to fail immediately 
if the transport can't connect.

>>>
>>> My patch ensures that the reconnection attempts happen within the
>>> user-specified limits by replacing the 60secs default timeout with a
>>> value that is less than the time to expire. If this is not ideal the
>>> user should readjust the timeout value.
>>>
>>> Does it make sense?
>>
>> That's better, but this explanation needs to accompany the patch, as
>> the long description. It's hard for reviewers who are not familiar
>> with the constraints on NFSv4 RENEW to understand what you're trying
>> to fix. Same comment applies to the other patches in your series, I
>> think. (And see further comments in the code below).
>>
>
> Yeah you are right about that
>
>> You are changing a generic part of the RPC client to fix an issue with
>> one specific NFSv4 procedure, it seems to me. Did you actually observe
>> a situation where the reconnect delay caused the server to miss a
>> RENEW request?
>>
>
> Yeah, it's very easy to reproduce too

Can you describe the scenario more precisely?  If I wanted to reproduce 
this here, how would I do it?

>> There are good reasons why there is a timeout before reestablishing a
>> connection. Have you tested this patch with NFSv3 servers that are
>> going up and down repeatedly, for example? I think skipping the
>> reconnect delay could have consequences for the cases which the
>> original xs_connect logic is supposed to address, and it's not
>> something we want in many other cases.
>>
>
> I am not skipping the reconnect delay. What i am saying is that it seems
> wrong to me to hard-code the reconnection delay. Why 60secs for example
> ? To me it seems that this value should be related to the timeout. Do
> you disagree ?

Hrm.  It looks like the TCP re-establish timeout starts at 3 seconds, 
and then backs off to 5 minutes.  So, it's not fixed, it's related to 
how quickly the server responds to the client's connect() attempt.

The reestablish timer is meant to prevent a client with pending requests 
from hammering an overloaded (or rebooting) server with connection 
requests.  It's purpose is markedly different than the purpose of an 
individual RPC retransmit timer.

>> Perhaps a better idea would be to mark these particular RPCs with some
>> kind of indication that the RPC client has to connect immediately for
>> this request, if possible. Similar to RPC_TASK_SOFTCONN.
>
>> In general, sunrpc.ko has a problem with this kind of "urgent" RPC
>> request. If the RPC backlog queue is large for a particular rpc_clnt,
>> it can often take many seconds (like longer than the major timeout)
>> for a request to actually get down to the transport and get sent. I
>> don't see that these timeout changes necessarily address that at all.
>>
>
> Bu if the timeout has expired rpc_execute will quit the task anyways.
> What is the downside of instead of sleeping for a long, arbitrary period
> to wake up and poll the server at intervals that actually make some
> sense to the client?

If the 5 minute backoff maximum is too long, then you can easily reduce 
that maximum (which is probably not unreasonable).  We originally had 
the client retrying to connect every 3 seconds, but it was thought that 
would put unnecessary load on servers.

-- 
chuck[dot]lever[at]oracle[dot]com
