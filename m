Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932260Ab0IGUa1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:30:27 -0400
Message-ID: <4C86A0E0.6050003@RedHat.com>
Date: Tue, 07 Sep 2010 16:30:24 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] mount.nfs: Prepare way for "vers=4,rdma" mounts
References: <20100907162156.3392.90376.stgit@seurat.1015granger.net> <20100907162638.3392.14786.stgit@seurat.1015granger.net> <4C869B70.4020405@RedHat.com> <8653371E-0798-4F57-9289-684A8D09B1C7@oracle.com>
In-Reply-To: <8653371E-0798-4F57-9289-684A8D09B1C7@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/07/2010 04:14 PM, Chuck Lever wrote:
> 
> On Sep 7, 2010, at 4:07 PM, Steve Dickson wrote:
> 
>>
>>
>> On 09/07/2010 12:26 PM, Chuck Lever wrote:
>>> At some point, when the kernel starts to support "vers=4,rdma" mounts,
>>> we will want the mount.nfs command to pass "vers=4,rdma" mounts
>>> instead of rejecting them.
>>>
>>> Assuming that the kernel will reject these today with EPROTONOSUPPORT,
>>> that would cause the version fallback logic to go to "vers=3,rdma"
>>> automatically.  So the extra check we have now is not needed anyway.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> utils/mount/stropts.c |    7 -------
>>> 1 files changed, 0 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index 9695c73..a8b22ce 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -302,13 +302,6 @@ static int nfs_set_version(struct nfsmount_info *mi)
>>>
>>> 	if (strncmp(mi->type, "nfs4", 4) == 0)
>>> 		mi->version = 4;
>>> -	else {
>>> -		unsigned long protocol;
>>> -		if (!nfs_nfs_protocol(mi->options, &protocol))
>>> -			return 0;
>>> -		if (protocol == NFSPROTO_RDMA)
>>> -			mi->version = 3;
>>> -	}
>>>
>>> 	/*
>>> 	 * If we still don't know, check for version-specific
>>>
>> This is a show stopper... We can default to v4 because the callbacks.
> 
> Again, this patch was for comments only, it isn't required.  
I guess I missed that in your description.

> But I don't understand your comment.
We can not default to v4 because of the callbacks.

> 
> We don't default to NFSv4 for RDMA today, because of the if clause I remove here.  
> If no version is specified, it defaults to vers=3 for RDMA mounts.
no... this is not the case with the above patched applied... 
I do have a way to test... 

> 
> I suggest we make it default to v4 in this case.  What is the callback requirement?
Its not clear they work... 

steved.

