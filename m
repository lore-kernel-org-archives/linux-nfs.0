Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:50752 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963Ab0BHSpw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2010 13:45:52 -0500
Message-ID: <4B705B63.8060604@oracle.com>
Date: Mon, 08 Feb 2010 13:43:47 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/6] RPC: adjust timeout for connect, bind, restablish
 so that they sensitive to the major time out value
References: <1265155576-7618-1-git-send-email-batsakis@netapp.com> <1265155576-7618-2-git-send-email-batsakis@netapp.com> <1265155576-7618-3-git-send-email-batsakis@netapp.com> <1265155576-7618-4-git-send-email-batsakis@netapp.com> <1265155576-7618-5-git-send-email-batsakis@netapp.com> <1265155576-7618-6-git-send-email-batsakis@netapp.com> <1265155576-7618-7-git-send-email-batsakis@netapp.com> <4B6C7BCA.2040806@oracle.com> <383F4881-BD88-4155-B605-4D24F5B05BDD@netapp.com> <4B6C9FA7.2010702@oracle.com> <77EBFB14-A6B6-41DC-90DC-7A00548DFAEA@netapp.com> <4B6CB3C7.8070001@oracle.com> <B9364369CA66BF45806C2CD86EAB8BA60259D23D@SACMVEXC3-PRD.hq.netapp.com> <4B6E0EF5.70307@oracle.com> <2CDC4373-10AD-4F84-BA44-3C2106D590BE@netapp.com>
In-Reply-To: <2CDC4373-10AD-4F84-BA44-3C2106D590BE@netapp.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/06/2010 11:11 PM, Batsakis, Alexandros wrote:
>
>
> On Feb 6, 2010, at 16:53, "Chuck Lever" <chuck.lever@oracle.com> wrote:
>
>> On 02/05/2010 11:05 PM, Batsakis, Alexandros wrote:
>>>
>>> My replies marked with the "AB" prefix
>>>
>>> -----Original Message-----
>>> From: Chuck Lever [mailto:chuck.lever@oracle.com]
>>> Sent: Fri 2/5/2010 4:11 PM
>>> To: Batsakis, Alexandros
>>> Cc: Batsakis, Alexandros; linux-nfs@vger.kernel.org; Myklebust, Trond
>>> Subject: Re: [PATCH 6/6] RPC: adjust timeout for connect, bind,
>>> restablish so that they sensitive to the major time out value
>>>
>>> On 02/05/2010 06:04 PM, Batsakis, Alexandros wrote:
>>> >
>>> >
>>> > On Feb 5, 2010, at 14:47, "Chuck Lever" <chuck.lever@oracle.com>
>>> wrote:
>>> >
>>> >> On 02/05/2010 05:14 PM, Batsakis, Alexandros wrote:
>>> >>> Yeah sure,
>>> >>>
>>> >>> So imagine that for a specific connection the remaining major timeo
>>> >>> value is 30secs. Xs_connect has a default timeout before
>>> attempting to
>>> >>> reconnect of 60secs. The user (NFS) expects to "hear back" from
>>> the rpc
>>> >>> layer within the timeout as in often cases e.g. lease renewal,
>>> it's of
>>> >>> no benefit for an operation to reach the server at a later time and
>>> miss
>>> >>> the critical time because it was sleeping for an arbitrary amount of
>>> >>> time.
>>>
>>> Maybe you want RPC_TASK_SOFTCONN for NFSv4 renewals instead of
>>> RPC_TASK_SOFT. This would cause the RENEW request to fail immediately
>>> if the transport can't connect.
>>>
>>> AB: is this a new flag ? I am not familiar with it. Or are you proposing
>>> to add such a flag?
>>> It's not an unreasonable thing to do
>>
>> The flag was added recently (maybe in 2.6.33-rc?). It causes an
>> individual RPC request to fail immediately if the underlying transport
>> cannot be connected. It bypasses the reconnect timeout if the
>> transport is not already connected.
>>
>
> Oh OK. Maybe then it's a reasonable workaround to the reconnection
> policy changes. I think though that the rest of the changes wrt the
> major timeout are still valid. Also IMHO the max of 5min seems a lot,
> especially for operations that are state-oriented like in v4.0 and v4.1.

I'm not averse to reducing the maximum reconnect delay to something like 
60 seconds.  This might even be an acceptable work around for some of 
the issues you've raised.  Additional illumination of current reconnect 
behavior may find that it no longer behaves as expected in the quick 
server reboot cases, and that also should be addressed.

However, the fact that _all_ NFSv4 state-changing operations now have 
additional delivery constraints makes this an issue larger than RENEWD 
(which is the subject line of your original postings).  IMO sunrpc.ko is 
not currently prepared to handle that kind of timing constraint 
adequately.  Adjusting the retransmit behavior is simply not sufficient 
to address these problems (and perhaps it is even orthogonal to them).

-- 
chuck[dot]lever[at]oracle[dot]com
