From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2.6.30] svcrdma: clean up error paths.
Date: Thu, 14 May 2009 17:17:02 -0400
Message-ID: <20090514211702.GI8367@fieldses.org>
References: <20090429191400.29365.36715.stgit@build.ogc.int> <20090503184223.GB20762@fieldses.org> <4A0B4CCF.4090506@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@opengridcomputing.com, linux-nfs@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:49170 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079AbZENVRC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 May 2009 17:17:02 -0400
In-Reply-To: <4A0B4CCF.4090506@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 13, 2009 at 05:42:23PM -0500, Steve Wise wrote:
> Hey Bruce,
>
> J. Bruce Fields wrote:
>> On Wed, Apr 29, 2009 at 02:14:00PM -0500, Steve Wise wrote:
>>   
>>> These fixes resolved crashes due to resource leak BUG_ON checks. The
>>> resource leaks were detected by introducing asynchronous transport errors.
>>>     
>>
>> Thanks, applied for 2.6.30.  (And also appropriate for stable (2.6.29),
>> I assume?)
>>
>> But, could someone take a closer look at the error paths here?  Questions:
>>
>> 	- svc_rdma_post_recv() does a svc_rdma_put_context() on error--
>> 	  are you sure its caller needs to as well?
>>   
>
> The svc_rdma_put_context() call inside svc_rdma_post_recv() is for the  
> recv context that was allocated inside that function.  The caller, in  
> this case send_reply() also does a svc_rdma_put_context(), but that is  
> for the send context.   So I think this is correct.
>
>> 	- In send_reply, some of the cleanout is shared between the
>> 	  first return -ENOTCONN and the final err: cleanup.  Could we
>> 	  add another err: label and share some of that cleanup?
>>   
>
> The only common logic I see is the svc_rdma_put_context() call that  
> could be shared.  But one case calls it with free_pages == 1 after the  
> pages have been mapped, and the other with 0 since no pages are mapped  
> at that point (when the call to svc_rdma_post_recv() fails).   So I'm  
> not sure its worth doing?

No, I think you're probably right about both of these.  Thanks for
taking a look.

--b.
