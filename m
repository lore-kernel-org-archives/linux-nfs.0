From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/23] SUNRPC: Fix return type of svc_addr_len()
Date: Thu, 2 Apr 2009 18:39:49 -0400
Message-ID: <20090402223949.GE18195@fieldses.org>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net> <20090319004535.32404.37120.stgit@ingres.1015granger.net> <20090324203206.GH19389@fieldses.org> <49D4182F.20104@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:47794 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761596AbZDBWjy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:39:54 -0400
In-Reply-To: <49D4182F.20104@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2009 at 08:43:11PM -0500, Tom Tucker wrote:
> J. Bruce Fields wrote:
>> On Wed, Mar 18, 2009 at 08:45:36PM -0400, Chuck Lever wrote:
>>> The svc_addr_len() helper function can return a negative errno value,
>>> but its return type is size_t, which is unsigned.
>>>
>>> The RDMA transport code passes this return value directly to memset(),
>>> without checking first if it's negative.  This could cause memset() to
>>> clobber a large piece of memory if svc_addr_len() has returned an
>>> error.
>>
>> I'd still like to understand when this can happen, to better understand
>> how the error should be handled.
>
>
> I don't think that the current code base can cause this to occur.
>
> My recollection is that this code was added at the time we were  
> in-flight with the IPv6 integration and I was somewhat uncomfortable bug  
> checking on an unknown address type, however, this may in fact be the  
> right thing to do.
>
> I think changing the return type to int is fine.

OK, thanks.  So sounds like the consensus is that the return value
should either trigger a BUG() or just be ignored.--b.
