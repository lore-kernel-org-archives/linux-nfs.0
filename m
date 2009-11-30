From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Mon, 30 Nov 2009 12:52:54 -0500
Message-ID: <3602FF45-7293-49E2-BC06-F3BEBF83FD94@oracle.com>
References: <19211.7054.291514.185591@notabene.brown> <4B0BEDDB.1010203@RedHat.com> <4B13C48E.5020009@RedHat.com> <C027313D-A09F-4A72-926A-3D0EC2795E73@oracle.com> <4B1403CA.8050107@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:41824 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbZK3Rxh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2009 12:53:37 -0500
In-Reply-To: <4B1403CA.8050107-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 30, 2009, at 12:41 PM, Steve Dickson wrote:
> On 11/30/2009 11:43 AM, Chuck Lever wrote:
>> On Nov 30, 2009, at 8:11 AM, Steve Dickson wrote:
>>> Sorry for the delayed response, I took some time off...
>>>
>>> On 11/24/2009 09:29 AM, Steve Dickson wrote:
>>>>
>>>>
>>>> On 11/23/2009 06:32 PM, Neil Brown wrote:
>>>>>
>>>>> Hi,
>>>>> I recently packaged nfs-utils 1.2.1 for openSUSE and fairly  
>>>>> quickly
>>>>> got a bug report - "-o nfsvers=3" was needed to mount NFSv3
>>>>> filesystems.
>>>>>
>>>>> mount.nfs in 1.2.1 will first try a v4 mount but will fall-back  
>>>>> to v3
>>>>> if it gets ENOENT.  This works fine.
>>>>> However for kernel prior to 2.6.25, you don't get ENOENT, you get
>>>>> EPERM.
>>>>> In that case the fall-back to v3 doesn't happen and you get a  
>>>>> failure
>>>>> to mount.
>>>>>
>>>>> So I think we need to fall back on EPERM as well.  See below.
>>>> I already posted this patch on the v4 mailing list
>>>> http://linux-nfs.org/pipermail/nfsv4/2009-November/011595.html
>>>> but it got shot down...  at least that's how I interpreted the
>>>> responses...
>>>>
>>>> But I do thing we need this, since there are so many server
>>>> that will simple break if we don't... Agreed?
>>>
>>> There appears to be a consensus that we need to do something
>>> but no agreement on what....
>>>
>>> I believe the options are:
>>>  1) Start servers with '-N 4' when there is no root configured.
>>>     * The problem I see with this is, in the event v4 support is  
>>> wanted
>>>       its yet another configuration knob that has to be turned,
>>> basically
>>>       making it more difficult for people use v4.
>>>
>>>  2) Change the kernel to return NFS4ERR_SERVERFAULT when there is no
>>>     root configured.
>>>     * I see this is yet another errno the mounting code has to deal
>>> with..
>>>       We are up to two errnos, do we really want to add a third?
>>>
>>> Neither one of these solutions deal with legacy servers or move
>>> the "v4 technology" forward... IMHO...
>>
>> To quote Yoda, "No.  There is another."
>>
>> Distributions can choose to revert the recently added behavior which
>> makes mount.nfs try vers=4 by default.  That's what the mount config
>> file is for, yes?  That seems like a responsible choice, given the
>> number of legacy servers still in the field.
> Yes... That was the main reason for the configuration file.
>
>> At some later point (say, when your pseudoroot work is more widely
>> deployed), distributions can make vers=4 the default as shipped  
>> simply
>> by flipping a switch in the mount config file.  For now, the default
>> behavior stays the same, with an option for individual sites to try
>> something new.  In my opinion, default behavior out of the shrinkwrap
>> should always be the behavior most likely to work in any  
>> environment --
>> principle of least surprise, and all that sort of thing.
> Not matter how or when we flip the switch, we'll have to deal
> with the legacy servers...

Well, the point of waiting would be so that the proportion of legacy  
servers would become relatively insignificant.  And, a number of  
reasonable longer term solutions which have been proposed here could  
be deployed in the meantime.

>> This seems like the way we normally deploy new features like this,  
>> and
>> would give the many very recent changes in mount.nfs more soak time  
>> with
>> early adopters before we force them on everyone.
> Take a look at the Fedora 12... Its set up exactly as you just  
> described
> with only difference vers=3 is set in the configuration file...

Perhaps that should be the upstream default as well, for now, so other  
distributors aren't taken by surprise when they update to 1.2.1.  Just  
a thought.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




