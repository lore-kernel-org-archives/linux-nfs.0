From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Sun, 9 Nov 2008 20:00:48 -0500
Message-ID: <A734325C-C2A1-4597-8009-532F5B2BAB6A@oracle.com>
References: <20081029173750.GD31936@fieldses.org> <1225302305994@dmwebmail.dmwebmail.chezphil.org> <20081029184153.GE31936@fieldses.org> <5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com> <20081029211145.GE1406@fieldses.org> <20081109192528.GE25568@fieldses.org> <3EC9A304-36A0-465C-B82A-E3011CC8AD20@oracle.com> <20081110005518.GA31166@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:25741 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309AbYKJBCN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Nov 2008 20:02:13 -0500
In-Reply-To: <20081110005518.GA31166@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 9, 2008, at Nov 9, 2008, 7:55 PM, J. Bruce Fields wrote:
> On Sun, Nov 09, 2008 at 07:52:59PM -0500, Chuck Lever wrote:
>> On Nov 9, 2008, at Nov 9, 2008, 2:25 PM, J. Bruce Fields wrote:
>>> On Wed, Oct 29, 2008 at 05:11:45PM -0400, bfields wrote:
>>>> On Wed, Oct 29, 2008 at 04:30:32PM -0400, Chuck Lever wrote:
>>>>> I assume sync() is required because this logic performs a rename
>>>>> as well
>>>>> as a simple write?
>>>>
>>>> I think an fsync() on the containing directory (together with an
>>>> fsync()
>>>> of the file itself) would do the job if you wanted to avoid the
>>>> globaly
>>>> sync().  I don't think ext3 is capable of doing anything finer-
>>>> grained
>>>> than a whole-filesystem sync, though, so this doesn't help many
>>>> people
>>>> in practice right now.
>>>>
>>>> In any case, the rename adds an extra level of safety by ensuring  
>>>> the
>>>> nsm state is updated atomically, so we shouldn't get rid of it.
>>>>
>>>>>> Anyway, I think the nsm state updating shouldn't matter if you
>>>>>> don't
>>>>>> even have any peers to notify.
>>>>>
>>>>> It probably does matter.
>>>>>
>>>>> When a system is initially installed, it likely does not have a
>>>>> state
>>>>> file in /var/lib/nfs.  This may be harmless if it's not present;
>>>>> rpc.statd probably does the right thing in this case.
>>>>
>>>> The "right thing" in that case would be, I guess, to create a state
>>>> file
>>>> with "0" in it.  It doesn't do that.  So this patch *does* break
>>>> stuff.
>>>> Oops!
>>>>
>>>> So should we revert it and do something else, or patch statd to
>>>> create
>>>> a new state file if necessary?
>>>
>>> It looks like this still needs to be fixed?  I think it would be  
>>> good
>>> enough just to teach rpc.nfsd to create the file if it doesn't  
>>> exist.
> 			^^^^^^^^
>
> (Err, sorry, note I meant rpc.statd, not rpc.nfsd.)
>
> --b.
>
>> Meh.  I'd rather manage the state file in one place, rather than have
>> multiple user space entities fiddle with it.

Acknowledged.  My comments below still stand, I think.  More testing!   
Yay!

>> I think we should find out exactly what breaks when sm-notify quits
>> early.  Steve hasn't found a problem with the patch already in nfs-
>> utils, but the corner cases here are really narrow.
>>
>> Without a lot of testing (which we currently don't have the resources
>> for), I don't feel 100% positive about sm-notify quitting early.  My
>> preferred solution would involve working around the sync(2) call  
>> instead
>> (ie fixing sm-notify so we don't need it, or somehow doing it in the
>> background so it doesn't hold up the boot-up process).  I think we  
>> will
>> end up waiting until this actually bites someone, but chances are  
>> it will
>> be a long wait.


In any event, I will keep this in mind (along with the idea of  
allowing only client or server peers to be notified of a reboot) as I  
audit this code for IPv6 support.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
