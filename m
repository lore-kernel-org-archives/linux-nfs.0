From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] NFS: Use cached nlm_host when calling nlmclnt_proc()
Date: Tue, 8 Jan 2008 13:47:10 -0500
Message-ID: <F5B71FA6-521E-4BF6-B869-163007E1CA63@oracle.com>
References: <20080108153221.20097.13404.stgit@manray.1015granger.net> <20080108164251.GB20897@infradead.org> <8E9A424E-BB8E-411E-816E-3D7C9DF4D779@oracle.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:27058 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbYAHSsA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 13:48:00 -0500
In-Reply-To: <8E9A424E-BB8E-411E-816E-3D7C9DF4D779@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 8, 2008, at 12:03 PM, Chuck Lever wrote:
> Hi Christoph-
>
> On Jan 8, 2008, at 11:42 AM, Christoph Hellwig wrote:
>> On Tue, Jan 08, 2008 at 10:32:22AM -0500, Chuck Lever wrote:
>>> +int nlmclnt_proc(struct nlm_host *host, int cmd, struct  
>>> file_lock *fl)
>>>  {
>>>  	struct nlm_rqst		*call;
>>>  	sigset_t		oldset;
>>>  	unsigned long		flags;
>>> +	int			status;
>>>
>>>  	if (host == NULL)
>>>  		return -ENOLCK;
>>
>> I think this check can just go away aswell.
>
> Yeah, I guess that's right.  NFS_MOUNT_NONLM is set during mount  
> processing if the NLM couldn't acquire an appropriate nlm_host for  
> this mount point, and NFS_MOUNT_NONLM gates the call to the NFS  
> version specific lock calls.
>
> It should probably also dump a warning into the kernel log if the  
> admin requested "lock" and got "nolock" instead.  That could  
> certainly change application behavior unexpectedly!

After a closer look at this, it appears that if nfs_start_lockd()  
fails, the whole mount request fails, so no new warning is needed,  
and setting NONLM is superfluous.

This is actually safer behavior -- if the admin requested locking and  
the client couldn't deliver, the safest thing to do is prevent the  
mount.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



