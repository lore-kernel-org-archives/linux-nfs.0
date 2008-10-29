From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Wed, 29 Oct 2008 16:30:32 -0400
Message-ID: <5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com>
References: <20081029173750.GD31936@fieldses.org> <1225302305994@dmwebmail.dmwebmail.chezphil.org> <20081029184153.GE31936@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:14881 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753750AbYJ2Uat (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2008 16:30:49 -0400
In-Reply-To: <20081029184153.GE31936@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 29, 2008, at 2:41 PM, J. Bruce Fields wrote:
> On Wed, Oct 29, 2008 at 05:45:05PM +0000, Phil Endecott wrote:
>> J. Bruce Fields wrote:
>>> On Wed, Oct 29, 2008 at 05:30:03PM +0000, Phil Endecott wrote:
>>>> J. Bruce Fields wrote:
>>>>> On Wed, Oct 29, 2008 at 12:13:20AM +0000, Phil Endecott wrote:
>>>>>> Dear Experts,
>>>>>>
>>>>>> sm-notify was taking a long time while my laptop booted.  This
>>>>>> was odd because I use NFS only rarely - via autofs - on that
>>>>>> machine, and sm-notify actually has no-one to notify most of the
>>>>>> time.  So I have patched it as follows.  Is this a legitimate
>>>>>> thing to do?
>>>>>
>>>>> It looks like your patch was committed to nfs-utils a couple  
>>>>> weeks ago:
>>>>> see c8d18e26d2a53d9036a32c2dafebccaf4ce1634d from
>>>>>
>>>>> 	git://linux-nfs.org/nfs-utils
>>>>>
>>>>> --b.
>>>>
>>>> How curious.  I guess someone saw my Debian bug report.  No mention
>>>> of  it on this list as far as I can see though.
>>>>
>>>> I presume from this that it is considered a safe thing to do.
>>>
>>> It looks right to me.  Hopefully somebody actually has tested this  
>>> on a
>>> client that holds locks when it reboots?
>>
>> Not me.
>
> Ugh.
>
> We really need someone doing regular lock recovery tests with both the
> latest kernel and latest nfs-utils.
>
> Ideally we'd also have tests that could be easily run by anyone.   
> Though
> there may be too many site-specific details involved in writing  
> scripts
> that interact with (and reboot) multiple machines.
>
>>> I remember this was one of the things Arjan mentioned having to  
>>> disable
>>> in his "5-second boot" talk at the Linux Plumbers Conference, so  
>>> you're
>>> not the only one to have noticed the problem....
>>
>> Yes; I noticed the huge pause due to the sync() and applied this fix.
>> It was only later that I looked at Arjan's slides (I had to wait  
>> until
>> someone had converted then from PowerPoint to PDF...) and saw that he
>> had the same thing in his bootchart.
>
> Oh, so the time was all spent in the sync() in nsm_get_state()?

I assume sync() is required because this logic performs a rename as  
well as a simple write?

> Anyway, I think the nsm state updating shouldn't matter if you don't
> even have any peers to notify.

It probably does matter.

When a system is initially installed, it likely does not have a state  
file in /var/lib/nfs.  This may be harmless if it's not present;  
rpc.statd probably does the right thing in this case.

However, the rest of the logic in nsm_get_state() is needed to bump  
the system's state value properly after every reboot.  It may be  
inconsequential if there were no mounts or no NFS clients during the  
last reboot, but this is subtle.  I wouldn't bet on it.

>
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



