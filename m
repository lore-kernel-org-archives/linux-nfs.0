From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH  7/17] svcrdma: Fix error handling during listening
 endpoint creation
Date: Tue, 06 May 2008 19:48:02 -0500
Message-ID: <C4466672.4AFDC%tom@opengridcomputing.com>
References: <20080506212249.GN13484@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:4875 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752165AbYEGAsQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 20:48:16 -0400
In-Reply-To: <20080506212249.GN13484@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 5/6/08 4:22 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, May 06, 2008 at 09:48:06AM -0500, Tom Tucker wrote:
>> 
>> 
>> 
>> On 5/5/08 5:41 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> 
>>> On Fri, May 02, 2008 at 11:28:39AM -0500, Tom Tucker wrote:
>>>> A listening endpoint isn't known to the generic transport switch until
>>>> the svc_create_xprt function returns without error. Calling
>>>> svc_xprt_put within the xpo_create function causes the module reference
>>>> count to be erroneously decremented.
>>> 
>>> There's some redundant code in these three error paths; would the usual
>>> kernel-style "goto cleanup" thing help?
>> 
>> I think code-size it's a wash, but it might look more familiar.
> 
> Yeah, we try to stick to the same idioms as used elsewhere when it's
> easy to.
> 
> Doesn't have to be done now, though.
> 
>> BTW, I noticed that the error path above returns a positive errno :-\,
>> so that needs to be fixed too.
> 
> Oops, didn't catch that.  I'll expect a patch?

I've got updates to three of the patches. I'm just retesting to make sure I
didn't inadvertently break something. I'll get the three updated patches to
you by tomorrow.

Tom

> 
> --b.


