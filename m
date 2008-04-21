From: Wendy Cheng <wcheng@netapp.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 21 Apr 2008 14:28:37 -0400
Message-ID: <480CDCD5.7030009@netapp.com>
References: <480902CA.1070805@redhat.com> <48090356.9020703@redhat.com> <20080418203225.GD28277@fieldses.org> <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com> <20080421000214.GA5453@fieldses.org> <24c1515f0804201749x47bee916y9970fe1102bfb5@mail.gmail.com> <20080421021153.GC5453@fieldses.org> <20080421070107.454cfad2@tleilax.poochiereds.net> <20080421133940.GB28795@fieldses.org> <20080421101003.4e9d85a6@tleilax.poochiereds.net> <20080421173227.GE4379@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jeff Layton <jlayton@redhat.com>,
	Janne Karhunen <janne.karhunen@gmail.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51653 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755218AbYDUS0q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Apr 2008 14:26:46 -0400
In-Reply-To: <20080421173227.GE4379@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Mon, Apr 21, 2008 at 10:10:03AM -0400, Jeff Layton wrote:
>   
>> On Mon, 21 Apr 2008 09:39:40 -0400
>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>
>>     
>>> On Mon, Apr 21, 2008 at 07:01:07AM -0400, Jeff Layton wrote:
>>>       
>>>> On Sun, 20 Apr 2008 22:11:53 -0400
>>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>
>>>>         
>>>>> On Sun, Apr 20, 2008 at 08:49:52PM -0400, Janne Karhunen wrote:
>>>>>           
>>>>>> Yes, but loopback can also be spoofed.
>>>>>>             
>>>>> Is that true?  I thought the kernel discarded packets from interfaces
>>>>> other than lo claiming to be from 127.*.*.*.
>>>>>
>>>>>           
>>>> I think that's the case only if you have rp_filter turned on. It
>>>> usually is these days, but there are some situations where it doesn't
>>>> do what's expected (vlans, for instance), and has to be disabled.
>>>>         
>>> Well, if you believe Documentation/filesystems/proc.txt on rp_filter:
>>>
>>> 	"Integer value determines if a source validation should be made.
>>> 	1 means yes, 0 means no.  Disabled by default, but
>>> 	local/broadcast address spoofing is always on."
>>>
>>> But I haven't tested this or looked at the code.
>>>
>>> --b.
>>>       
>> I think that's basically correct, but most modern distros turn it on by
>> default. From the default /etc/sysctl.conf on my fedora box:
>>
>> net.ipv4.conf.default.rp_filter = 1
>>
>> ...it's generally a good thing to enable, but there are places where it
>> needs to be disabled. For instance, my Linksys WRT54g is doing firewall
>> duties and has it disabled because the switch ports on it are segmented
>> with VLANs and rp_filter interferes with that.
>>     
>
> Actually, the specific question here is: say you have an ethernet
> interface 192.168.0.1.  Will the kernel deliver a packet that comes from
> the network and has source address 192.168.0.1?
>   

I doubt it will. Remember one of my old patches (patch 3 & 4) ?
https://www.redhat.com/archives/cluster-devel/2007-April/msg00028.html
https://www.redhat.com/archives/cluster-devel/2007-April/msg00032.html 
(patch 3)
https://www.redhat.com/archives/cluster-devel/2007-April/msg00031.html 
(patch 4)

I think you have to specifically hack the kernel (as I did) but I don't 
have linux source code in front of me at this moment.

-- Wendy


