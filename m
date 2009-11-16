From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] mount: ECONNREFUSED is a permanent error
Date: Mon, 16 Nov 2009 14:47:14 -0500
Message-ID: <4B01AC42.5040902@RedHat.com>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net> <20091008173703.12619.35788.stgit@matisse.1015granger.net> <4B019664.3020002@RedHat.com> <E5331E4C-EE5B-4C60-9330-1B81F2FA065B@ORACLE.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993AbZKPTrN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 14:47:13 -0500
In-Reply-To: <E5331E4C-EE5B-4C60-9330-1B81F2FA065B-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/16/2009 01:16 PM, Chuck Lever wrote:
> 
> On Nov 16, 2009, at 1:13 PM, Steve Dickson wrote:
> 
>>
>>
>> On 10/08/2009 01:37 PM, Chuck Lever wrote:
>>> I had assumed early on that mount.nfs should retry a refused connection.
>>>
>>> Apparently this is not the case.  Legacy mount.nfs4 fails immediately
>>> if the NFS server refuses the connection.  Legacy mount.nfs and
>>> text-based mount.nfs both fail immediately if the rpcbind service is
>>> refusing connections.
>>>
>>> So, banish ECONNREFUSED returns from mount(2) to the domain of
>>> permanent errors.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> utils/mount/stropts.c |    1 -
>>> 1 files changed, 0 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index 069bdc1..0685caa 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -639,7 +639,6 @@ static int nfs_is_permanent_error(int error)
>>>     switch (error) {
>>>     case ESTALE:
>>>     case ETIMEDOUT:
>>> -    case ECONNREFUSED:
>>>         return 0;    /* temporary */
>>>     default:
>>>         return 1;    /* permanent */
>>>
>> I'm going to hold of on this one... I just think we should
>> continue to try on ECONNREFUSED errors until the retry timer pops...
> 
> I thought we had agreed that ECONNREFUSED should be retried (ie this
> particular patch was vetoed a while ago).  
Right... Just clearing my que... ;-)

> Currently it is retried for NFSv4, but not for NFSv2/3, and I have 
> a patch that makes v2/v3 retry.
Post it when its ready...

steved.

