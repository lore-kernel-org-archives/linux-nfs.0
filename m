From: "Phil Endecott" <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Wed, 29 Oct 2008 17:45:05 +0000
Message-ID: <1225302305994@dmwebmail.dmwebmail.chezphil.org>
References: <20081029173750.GD31936@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; format="flowed"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from japan.chezphil.org ([77.240.5.4]:1473 "EHLO japan.chezphil.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754161AbYJ2RpJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2008 13:45:09 -0400
Received: from localhost ([127.0.0.1] helo=chezphil.org)
	by japan.chezphil.org with esmtp (Exim 4.69)
	(envelope-from <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>)
	id 1KvF6S-0004Hl-NZ
	for linux-nfs@vger.kernel.org; Wed, 29 Oct 2008 17:45:08 +0000
In-Reply-To: <20081029173750.GD31936@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Oct 29, 2008 at 05:30:03PM +0000, Phil Endecott wrote:
>> J. Bruce Fields wrote:
>>> On Wed, Oct 29, 2008 at 12:13:20AM +0000, Phil Endecott wrote:
>>>> Dear Experts,
>>>>
>>>> sm-notify was taking a long time while my laptop booted.  This was 
>>>> odd because I use NFS only rarely - via autofs - on that machine, and 
>>>> sm-notify actually has no-one to notify most of the time.  So I have 
>>>> patched it as follows.  Is this a legitimate thing to do?
>>>
>>> It looks like your patch was committed to nfs-utils a couple weeks ago:
>>> see c8d18e26d2a53d9036a32c2dafebccaf4ce1634d from
>>>
>>> 	git://linux-nfs.org/nfs-utils
>>>
>>> --b.
>>
>> How curious.  I guess someone saw my Debian bug report.  No mention of  
>> it on this list as far as I can see though.
>>
>> I presume from this that it is considered a safe thing to do.
>
> It looks right to me.  Hopefully somebody actually has tested this on a
> client that holds locks when it reboots?

Not me.

> I remember this was one of the things Arjan mentioned having to disable
> in his "5-second boot" talk at the Linux Plumbers Conference, so you're
> not the only one to have noticed the problem....

Yes; I noticed the huge pause due to the sync() and applied this fix.  
It was only later that I looked at Arjan's slides (I had to wait until 
someone had converted then from PowerPoint to PDF...) and saw that he 
had the same thing in his bootchart.


Phil.



