From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfsstat --sleep=#
Date: Mon, 16 Mar 2009 12:33:22 -0400
Message-ID: <CCD8A8AE-9360-4D27-9872-26B2B7902FF1@oracle.com>
References: <49B86744.6060105@disney.com> <ADDF97BC-8B6A-4EFC-9242-C1454B8F423C@oracle.com> <20090312155055.GB2081@fieldses.org> <65B488F7-A902-4126-8E05-65622991D78C@oracle.com> <20090312162459.GC2081@fieldses.org> <49B93C10.5020208@disney.com> <20090312164818.GF2081@fieldses.org> <82886FA0-DF61-4979-B914-3CC59BAA2493@oracle.com> <20090312193210.GA7530@fieldses.org> <D5529973-DEFB-4D86-BB94-38EC03517B95@oracle.com> <49BE7BD6.3050303@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:40959 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbZCPQeE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Mar 2009 12:34:04 -0400
In-Reply-To: <49BE7BD6.3050303-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

On Mar 16, 2009, at Mar 16, 2009, 12:18 PM, Steve Dickson wrote:
> Chuck Lever wrote:
>> On Mar 12, 2009, at Mar 12, 2009, 3:32 PM, J. Bruce Fields wrote:
>>> On Thu, Mar 12, 2009 at 01:22:32PM -0400, Chuck Lever wrote:
>>>> Actually I would rather see the performance metrics scripts  
>>>> improved.
>>>> These tools give a lot more information than nfsstat ever will be  
>>>> able
>>>> to.
>>>
>>> Probably so, but those scripts are a bit hard to find, aren't they?
>>>
>>> We should
>>>    - get distributions to install them by default
>>>    - write man pages?
>>>    - add references to them where possible (from the nfsstat man
>>>      page, from howto's/faq's/?)
>>
>> Steve promised me Red Hat would take care of this when these were  
>> added
>> to nfs-utils last year.
> Not sure what I exactly promised (that's usually not my style 8-) )
> but those scripts definitely fell off my radar...

You promised to find an intern to compose man pages, and do the  
legwork needed to get these reviewed internally, and installed when  
nfs-utils is installed.  I think that last part requires constructing  
a suitable Makefile.am in the nfs-utils directory where these now  
live, and updating the parent Makefiles to invoke it.

There was some controversy over whether nfs-utils should have a  
dependency on having the Python interpreter installed.  Since Red Hat  
(for example) already uses Python for the system-config-foo utilities,  
this might not be too much of a problem.  In any event, if we decide  
that Python is not appropriate, it would be simple to convert the  
scripts to C, or even add this functionality to nfsstat (Bruce's  
suggestion).

>>> Until then, unfortunately, improvements to nfsstat are more useful,
>>> since nfsstat is the thing people are more likely to run across.
>>
>> Again, I think improving nfsstat at this point (which is merely for
>> compatibility with Solaris) would be wasted work, if we already have
>> what is needed in another tool.  The Python tools are much more
>> sophisticated, and it would be confusing to add their functionality  
>> to
>> nfsstat (e.g. why can I zero the legacy stats with the -z option, but
>> not the stats the come from /proc/self/mountstats?).
>>
>> Let's spend the effort on the tools that give us deeper results.
> I have to agree... I truly think there is a wealth of untapped  
> information
> in those mountstats... Just waiting for someone to dip them out...

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
