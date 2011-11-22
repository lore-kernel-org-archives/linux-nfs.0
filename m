Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp02.citrix.com ([66.165.176.63]:53629 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab1KVMCU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Nov 2011 07:02:20 -0500
Message-ID: <4ECB8F47.105@citrix.com>
Date: Tue, 22 Nov 2011 12:02:15 +0000
From: Andrew Cooper <andrew.cooper3@citrix.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: NFS TCP race condition with SOCK_ASYNC_NOSPACE
References: <4EC6A681.30902@citrix.com>	  <1321642368.2653.35.camel@lade.trondhjem.org> <4EC6AC47.60404@citrix.com>	 <1321643673.2653.41.camel@lade.trondhjem.org> <4EC6B82B.3000701@citrix.com>	 <4ECA94F9.4090503@citrix.com> <1321961913.3323.67.camel@lade.trondhjem.org>
In-Reply-To: <1321961913.3323.67.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 22/11/11 11:38, Trond Myklebust wrote:
> On Mon, 2011-11-21 at 18:14 +0000, Andrew Cooper wrote: 
>> Following some debugging, I believe that the attached patch fixes the
>> problem.
>>
>> Simply returning EAGAIN is not sufficient, as the task does not get
>> requeued, and times out 13 seconds later (as per our mount options). 
>> Setting the SOCK_ASYNC_NOSPACE bit causes the requeue to happen.
>>
>> I realize that this is a gross hack and I should probably not be using
>> SOCK_ASYNC_NOSPACE in that way.  Is there a better way to achieve the
>> same solution?
>>
> What you are doing will cause the request to be put to sleep with no
> guarantee that it will ever be woken up. Why would we want to do that if
> there is no report of a tcp window/buffer space congestion?

But the reason we get to this code is because there was a report of
space collision.  What would you suggest instead?  Changing
xs_{tcp,udp}_send_request() to retry in this case would defeat the point
of having xs_nospace().

What should happen is the request getting re-queued to run at the next
available opportunity, rather than perhaps sleeping for a certain length
of time.  At the moment, leaving SOCK_ASYNC_NOSPACE unset causes the
request to never be woken, whereas setting that bit seems to always be
re-queued at some near point in the future.

-- 
Andrew Cooper - Dom0 Kernel Engineer, Citrix XenServer
T: +44 (0)1223 225 900, http://www.citrix.com

