From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/27] NSM: Add dprintk() calls in nsm_find and
	nsm_release
Date: Wed, 10 Dec 2008 16:14:40 -0500
Message-ID: <20081210211440.GI1212@fieldses.org>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net> <20081206000252.24075.51827.stgit@ingres.1015granger.net> <20081210210501.GG1212@fieldses.org> <8CE84D92-B1D9-4A91-BCDC-385653C8DE0E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49541 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783AbYLJVOm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2008 16:14:42 -0500
In-Reply-To: <8CE84D92-B1D9-4A91-BCDC-385653C8DE0E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 10, 2008 at 04:10:41PM -0500, Chuck Lever wrote:
>
> On Dec 10, 2008, at Dec 10, 2008, 4:05 PM, J. Bruce Fields wrote:
>
>> On Fri, Dec 05, 2008 at 07:02:53PM -0500, Chuck Lever wrote:
>>> Introduce some dprintk() calls in fs/lockd/mon.c that are enabled by
>>> the NLMDBG_MONITOR flag.  These report when we find, create, and
>>> release nsm_handles.
>>>
>>> Since printk() can sleep, these are placed outside the nsm_lock
>>> spinlock.
>>
>> Nope, printk() is designed to be callable from anywhere.  (This is
>> documented e.g. in kernel/printk.c:printk().)  I've applied the
>> following; look OK?
>
> That's fine, but it will make applying later patches more difficult.
>
> I can fix this up in my repo and resend subsequent patches if you like, 
> or you can just delete that last sentence in the description, and apply 
> this patch as is.

Yeah, already applied, figuring it'd save a round trip.  I think you'd
told me before you preferred fixing up yourself and resending, and I'd
forgotten; I'll try to remember that next time.

--b.
