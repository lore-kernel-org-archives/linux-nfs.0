From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 02/23] SUNRPC: Fix return type of svc_addr_len()
Date: Thu, 2 Apr 2009 18:43:18 -0400
Message-ID: <99151106-7989-4584-91EF-72395068E206@oracle.com>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net> <20090319004535.32404.37120.stgit@ingres.1015granger.net> <20090324203206.GH19389@fieldses.org> <49D4182F.20104@opengridcomputing.com> <20090402223949.GE18195@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:56866 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760469AbZDBWnk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:43:40 -0400
In-Reply-To: <20090402223949.GE18195@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 2, 2009, at 6:39 PM, J. Bruce Fields wrote:
> On Wed, Apr 01, 2009 at 08:43:11PM -0500, Tom Tucker wrote:
>> J. Bruce Fields wrote:
>>> On Wed, Mar 18, 2009 at 08:45:36PM -0400, Chuck Lever wrote:
>>>> The svc_addr_len() helper function can return a negative errno  
>>>> value,
>>>> but its return type is size_t, which is unsigned.
>>>>
>>>> The RDMA transport code passes this return value directly to  
>>>> memset(),
>>>> without checking first if it's negative.  This could cause  
>>>> memset() to
>>>> clobber a large piece of memory if svc_addr_len() has returned an
>>>> error.
>>>
>>> I'd still like to understand when this can happen, to better  
>>> understand
>>> how the error should be handled.
>>
>>
>> I don't think that the current code base can cause this to occur.
>>
>> My recollection is that this code was added at the time we were
>> in-flight with the IPv6 integration and I was somewhat  
>> uncomfortable bug
>> checking on an unknown address type, however, this may in fact be the
>> right thing to do.
>>
>> I think changing the return type to int is fine.
>
> OK, thanks.  So sounds like the consensus is that the return value
> should either trigger a BUG() or just be ignored.--b.

I crafted a new version of this patch where svc_addr_len() simply  
returns zero if it doesn't recognize the incoming address family, with  
no changes to the RDMA transport code.  I figure this is safer overall.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
