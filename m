From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/10] lockd: struct nlm_reboot should contain a full
	socket address
Date: Wed, 1 Oct 2008 16:51:56 -0400
Message-ID: <20081001205156.GF10937@fieldses.org>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net> <20080917161811.4963.60224.stgit@ellison.1015granger.net> <20080926230938.GK7138@fieldses.org> <E908BC09-5443-440E-9402-E2E319A3BD8E@oracle.com> <20081001181801.GF6001@fieldses.org> <59C7F69A-58EA-41F9-888E-C11039302755@oracle.com> <20081001200839.GB10937@fieldses.org> <DD686EBC-B11C-4BBF-8BBC-1A6504290132@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51335 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133AbYJAUv6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Oct 2008 16:51:58 -0400
In-Reply-To: <DD686EBC-B11C-4BBF-8BBC-1A6504290132@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 01, 2008 at 04:42:51PM -0400, Chuck Lever wrote:
> On Oct 1, 2008, at Oct 1, 2008, 4:08 PM, J. Bruce Fields wrote:
>> On Wed, Oct 01, 2008 at 03:40:05PM -0400, Chuck Lever wrote:
>>> Right.  I couldn't think of something simpler.
>>>
>>> rpc.statd has to continue to work with legacy kernels where the  
>>> first 4
>>> bytes of the opaque are a 32-bit sin_addr field and the following 12
>>> bytes are zero.
>>
>> Wait a minute, there's something not right there: rpc.statd shouldn't
>> interpret the contents of the opaque field at all, should it?
>
> Yes, our rpc.statd and lockd should agree on the contents and  
> interpretation of the opaque field.  The field is opaque because it's  
> internal content is not defined by a standard.  It's a cookie, just like 
> a file handle.
>
> I would certainly *prefer* the use of an entirely arbitrary cookie, but 
> that's not the way Linux happens to work today.

I'm pretty certain it does--at least on the rpc.statd size.  (Any
evidence to the contrary.)  Sure, it means something to the kernel, but
that's just for the kernel's convenience.  We can do whatever we want in
the kernel.

--b.
