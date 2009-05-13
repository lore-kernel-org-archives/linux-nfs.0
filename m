From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2.6.30] svcrdma: clean up error paths.
Date: Wed, 13 May 2009 17:42:23 -0500
Message-ID: <4A0B4CCF.4090506@opengridcomputing.com>
References: <20090429191400.29365.36715.stgit@build.ogc.int> <20090503184223.GB20762@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: tom@opengridcomputing.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:46981 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751088AbZEMWmP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2009 18:42:15 -0400
In-Reply-To: <20090503184223.GB20762@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Bruce,

J. Bruce Fields wrote:
> On Wed, Apr 29, 2009 at 02:14:00PM -0500, Steve Wise wrote:
>   
>> These fixes resolved crashes due to resource leak BUG_ON checks. The
>> resource leaks were detected by introducing asynchronous transport errors.
>>     
>
> Thanks, applied for 2.6.30.  (And also appropriate for stable (2.6.29),
> I assume?)
>
> But, could someone take a closer look at the error paths here?  Questions:
>
> 	- svc_rdma_post_recv() does a svc_rdma_put_context() on error--
> 	  are you sure its caller needs to as well?
>   

The svc_rdma_put_context() call inside svc_rdma_post_recv() is for the 
recv context that was allocated inside that function.  The caller, in 
this case send_reply() also does a svc_rdma_put_context(), but that is 
for the send context.   So I think this is correct.


> 	- In send_reply, some of the cleanout is shared between the
> 	  first return -ENOTCONN and the final err: cleanup.  Could we
> 	  add another err: label and share some of that cleanup?
>   

The only common logic I see is the svc_rdma_put_context() call that 
could be shared.  But one case calls it with free_pages == 1 after the 
pages have been mapped, and the other with 0 since no pages are mapped 
at that point (when the call to svc_rdma_post_recv() fails).   So I'm 
not sure its worth doing?

 
Steve.
