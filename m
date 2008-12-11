From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 18/27] NSM: Refactor nsm_handle creation into a helper
	function
Date: Thu, 11 Dec 2008 13:53:01 -0500
Message-ID: <20081211185301.GA23181@fieldses.org>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net> <20081206000409.24075.37859.stgit@ingres.1015granger.net> <20081210232830.GP1212@fieldses.org> <C1536996-3F69-458A-87D9-B7BE91043626@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50060 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068AbYLKSxF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Dec 2008 13:53:05 -0500
In-Reply-To: <C1536996-3F69-458A-87D9-B7BE91043626@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 11, 2008 at 12:09:49PM -0500, Chuck Lever wrote:
> On Dec 10, 2008, at Dec 10, 2008, 6:28 PM, J. Bruce Fields wrote:
>> On Fri, Dec 05, 2008 at 07:04:09PM -0500, Chuck Lever wrote:
>>> Clean up.
>>
>> The nsm_create_handle() thing is fine, but
>>
>>>
>>> We're about to get rid of the "goto retry" in nsm_get_handle().
>>
>> I'm not that interested in removing the "goto retry".  I realize  
>> tastes
>> differ here, but I don't see a great improvement.  The:
>>
>> 	retry:
>> 		look for something
>> 		oops, not there, allocate a new one
>> 		goto retry
>>
>> pattern is pretty common and I'm comfortable with it.
>
> Would we need the retry at all if we replaced nsm_lock with a mutex?   
> nlm_lookup_host() holds its mutex across a kzalloc() call.  We could do 
> the same here, and it would make this much more straightforward.
>
> Is there any real need for the atomic_dec_and_lock in nsm_release(), for 
> example?  That's not exactly a performance-critical code path.

Perhaps not, but I can't see any harm in leaving this as is.

--b.
