From: Peter Staubach <staubach@redhat.com>
Subject: Re: [Bugme-new] [Bug 11448] New: NFS client has inconsistent write
 flushing to non-linux serversa
Date: Fri, 29 Aug 2008 13:14:09 -0400
Message-ID: <48B82E61.6060609@redhat.com>
References: <bug-11448-10286@http.bugzilla.kernel.org/> <20080828132753.08bfe05f.akpm@linux-foundation.org> <20080829170838.GA7099@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	doug-rDJHdQPhaF8@public.gmane.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44652 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192AbYH2RO1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Aug 2008 13:14:27 -0400
In-Reply-To: <20080829170838.GA7099@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Aug 28, 2008 at 01:27:53PM -0700, Andrew Morton wrote:
>   
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>>
>> On Thu, 28 Aug 2008 11:41:08 -0700 (PDT)
>> bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
>>     
>>> NFS client writes to Sun Solaris 10 U4 server. 
>>> at some point in time, there is an empty portion of the output file from the
>>> writer containing missing data (shows as NULL bytes from another NFS client
>>> issuing a tail -f on the file being written). 
>>> confirmed that the file as exists on the NFS server is sparse, missing bytes
>>> (not necessarily multiple of 512 or 1024, one sample is a gap of 3818 bytes,
>>> another is 1895 bytes, another is 423 bytes)
>>>       
>
> Seems like something that could happen if for example two write rpc's
> got reordered on the network.  That's not necessarily a bug--the nfs
> client isn't required to wait for confirmation of every previous write
> before sending the next one.
>
> However if the client isn't flushing dirty data to the server before
> returning from close, then that's a violation of NFS's close-to-open
> semantics:...
>
>   
>>> if you do a read of the entire file from the NFS client doing the writing, it
>>> causes the non-flushed writes to be instantly flushed to the server followed by
>>> a NFS3 commit operation. The data then can be seen on all other NFS clients.
>>>
>>> If you do an open of the file alone, no flush
>>> if you do an open and a close, no flush
>>>       
>
> ... so this "close, no flush" could be a bug (depending on who is doing
> that close when--I don't completely understand the described situation).

I suspect that this last might depend upon 1) what options were used
when the file system was mounted and 2) how the file was opened.  The
flush-on-close wouldn't be needed if the file was opened read-only.

It seems a little odd that the holes aren't page aligned or page
sized multiples.

What application is being used to generate the file which is showing
these holes?

    Thanx...

       ps
