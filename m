From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Sun, 9 Nov 2008 19:52:59 -0500
Message-ID: <3EC9A304-36A0-465C-B82A-E3011CC8AD20@oracle.com>
References: <20081029173750.GD31936@fieldses.org> <1225302305994@dmwebmail.dmwebmail.chezphil.org> <20081029184153.GE31936@fieldses.org> <5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com> <20081029211145.GE1406@fieldses.org> <20081109192528.GE25568@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:27574 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146AbYKJAxf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Nov 2008 19:53:35 -0500
In-Reply-To: <20081109192528.GE25568@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 9, 2008, at Nov 9, 2008, 2:25 PM, J. Bruce Fields wrote:
> On Wed, Oct 29, 2008 at 05:11:45PM -0400, bfields wrote:
>> On Wed, Oct 29, 2008 at 04:30:32PM -0400, Chuck Lever wrote:
>>> I assume sync() is required because this logic performs a rename  
>>> as well
>>> as a simple write?
>>
>> I think an fsync() on the containing directory (together with an  
>> fsync()
>> of the file itself) would do the job if you wanted to avoid the  
>> globaly
>> sync().  I don't think ext3 is capable of doing anything finer- 
>> grained
>> than a whole-filesystem sync, though, so this doesn't help many  
>> people
>> in practice right now.
>>
>> In any case, the rename adds an extra level of safety by ensuring the
>> nsm state is updated atomically, so we shouldn't get rid of it.
>>
>>>> Anyway, I think the nsm state updating shouldn't matter if you  
>>>> don't
>>>> even have any peers to notify.
>>>
>>> It probably does matter.
>>>
>>> When a system is initially installed, it likely does not have a  
>>> state
>>> file in /var/lib/nfs.  This may be harmless if it's not present;
>>> rpc.statd probably does the right thing in this case.
>>
>> The "right thing" in that case would be, I guess, to create a state  
>> file
>> with "0" in it.  It doesn't do that.  So this patch *does* break  
>> stuff.
>> Oops!
>>
>> So should we revert it and do something else, or patch statd to  
>> create
>> a new state file if necessary?
>
> It looks like this still needs to be fixed?  I think it would be good
> enough just to teach rpc.nfsd to create the file if it doesn't exist.

Meh.  I'd rather manage the state file in one place, rather than have  
multiple user space entities fiddle with it.

I think we should find out exactly what breaks when sm-notify quits  
early.  Steve hasn't found a problem with the patch already in nfs- 
utils, but the corner cases here are really narrow.

Without a lot of testing (which we currently don't have the resources  
for), I don't feel 100% positive about sm-notify quitting early.  My  
preferred solution would involve working around the sync(2) call  
instead (ie fixing sm-notify so we don't need it, or somehow doing it  
in the background so it doesn't hold up the boot-up process).  I think  
we will end up waiting until this actually bites someone, but chances  
are it will be a long wait.

> --b.
>
>>
>>> However, the rest of the logic in nsm_get_state() is needed to  
>>> bump the
>>> system's state value properly after every reboot.  It may be
>>> inconsequential if there were no mounts or no NFS clients during the
>>> last reboot, but this is subtle.  I wouldn't bet on it.
>>
>> If the state is only every communicated to hosts by notifications,  
>> then
>> if we're not notifying, the update of the state can't matter.
>>
>> (So is that premise correct?)
>>
>> --b.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




