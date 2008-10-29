From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Wed, 29 Oct 2008 14:41:53 -0400
Message-ID: <20081029184153.GE31936@fieldses.org>
References: <20081029173750.GD31936@fieldses.org> <1225302305994@dmwebmail.dmwebmail.chezphil.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45709 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841AbYJ2Sly (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2008 14:41:54 -0400
In-Reply-To: <1225302305994-YnoLgZYwwYuCbKHnblo0pmrPP3OPMK55cpQHUIT47Ck@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 29, 2008 at 05:45:05PM +0000, Phil Endecott wrote:
> J. Bruce Fields wrote:
>> On Wed, Oct 29, 2008 at 05:30:03PM +0000, Phil Endecott wrote:
>>> J. Bruce Fields wrote:
>>>> On Wed, Oct 29, 2008 at 12:13:20AM +0000, Phil Endecott wrote:
>>>>> Dear Experts,
>>>>>
>>>>> sm-notify was taking a long time while my laptop booted.  This 
>>>>> was odd because I use NFS only rarely - via autofs - on that 
>>>>> machine, and sm-notify actually has no-one to notify most of the 
>>>>> time.  So I have patched it as follows.  Is this a legitimate 
>>>>> thing to do?
>>>>
>>>> It looks like your patch was committed to nfs-utils a couple weeks ago:
>>>> see c8d18e26d2a53d9036a32c2dafebccaf4ce1634d from
>>>>
>>>> 	git://linux-nfs.org/nfs-utils
>>>>
>>>> --b.
>>>
>>> How curious.  I guess someone saw my Debian bug report.  No mention 
>>> of  it on this list as far as I can see though.
>>>
>>> I presume from this that it is considered a safe thing to do.
>>
>> It looks right to me.  Hopefully somebody actually has tested this on a
>> client that holds locks when it reboots?
>
> Not me.

Ugh.

We really need someone doing regular lock recovery tests with both the
latest kernel and latest nfs-utils.

Ideally we'd also have tests that could be easily run by anyone.  Though
there may be too many site-specific details involved in writing scripts
that interact with (and reboot) multiple machines.

>> I remember this was one of the things Arjan mentioned having to disable
>> in his "5-second boot" talk at the Linux Plumbers Conference, so you're
>> not the only one to have noticed the problem....
>
> Yes; I noticed the huge pause due to the sync() and applied this fix.   
> It was only later that I looked at Arjan's slides (I had to wait until  
> someone had converted then from PowerPoint to PDF...) and saw that he  
> had the same thing in his bootchart.

Oh, so the time was all spent in the sync() in nsm_get_state()?

Anyway, I think the nsm state updating shouldn't matter if you don't
even have any peers to notify.

--b.
