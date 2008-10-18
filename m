From: Guntsche Michael <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Subject: Kerberos authentication Problem with nfs3/4
Date: Sat, 18 Oct 2008 17:59:25 +0200
Message-ID: <14393409-84DC-42C1-9680-32A2B81A27BA@it-loops.com>
References: <20081018153037.GA27982@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bfields@citi.umich.edu
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:45807
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750824AbYJRP7a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Oct 2008 11:59:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Begin forwarded message:

> From: "J. Bruce Fields" <bfields@fieldses.org>
> Date: October 18, 2008 17:30:37 GMT+02:00
> To: Guntsche Michael <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
> Subject: Re: Kerberos authentication Problem with nfs3/4
>
> On Sat, Oct 18, 2008 at 05:03:26PM +0200, Guntsche Michael wrote:
>>
>> On Oct 18, 2008, at 14:57, Guntsche Michael wrote:
>>
>>> Hello list,
>>>
>>> I had my kerberised NFS4 and NFS3 setup running in test mode up to  
>>> the
>>> end of April.
>>> After seeing that there have been changes made to the recent code to
>>> make NFS3+Kerberos working without sec=sys I tried to mount my  
>>> exports
>>> again with kerberos auth enabled.
>>
>> Ok, I found the problem. Downgrading libnfsidmap to 0.20 makes the  
>> mount
>> succeed, with version 0.21 it does not work. To make sure that this  
>> is
>> not due a debian patch I downloaded the pristine source of both  
>> versions
>> and checked it again.
>>
>> According to the AUTHORS Bruce Fields is working on this library,  
>> so I
>> will try to contact him to work out why 0.21 is not working on my
>> system.
>
> nfsv4@linux-nfs.org or linux-nfs@vger.kernel.org would be the right
> place to ask about this.
>
> Is it possible you could be hitting this?:
>
> 	http://linux-nfs.org/pipermail/nfsv4/2008-October/009365.html

Apparently this never made it to the list, but only to myself and  
Bruce :)

Coming back to the problem. In my case the domain name and realm are  
the same. I'll try to find out, where the problem is triggered exactly.

Kind regards,
Michael
