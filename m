Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:54416 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851Ab2BWQI2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 11:08:28 -0500
Message-ID: <4F466467.3030506@steve-ss.com>
Date: Thu, 23 Feb 2012 17:08:07 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
References: <4F40053A.3090301@steve-ss.com> <4F412E2F.9070200@steve-ss.com> <4F45E78E.8050501@steve-ss.com> <20120223063913.5736a5b1@tlielax.poochiereds.net> <4F4628B8.90401@steve-ss.com> <20120223144053.GA25010@fieldses.org> <4F465C3A.9080802@steve-ss.com> <20120223154215.GA26706@fieldses.org>
In-Reply-To: <20120223154215.GA26706@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/23/2012 04:42 PM, J. Bruce Fields wrote:
> On Thu, Feb 23, 2012 at 04:33:14PM +0100, steve wrote:
>> On 02/23/2012 03:40 PM, J. Bruce Fields wrote:
>>> On Thu, Feb 23, 2012 at 12:53:28PM +0100, steve wrote:
>>>> Hi Jeff
>>>> Thanks for the reply. I'm trying to make the files created in a
>>>> share take on group rw.
>>>>
>>>> The trouble is that I've already tried setting the acl's via
>>>> nfs4_setfacl on the mounted share too (please see details below).
>>>> The acl + appears on the unmounted share and behaves as expected
>>>> even when it is not mounted. The mounted share however ignores the
>>>> acl I've set. I've tried remounting but still no acl is effective.
>>>> My workaround is to scan the folder and change the files to group rw
>>>> every few seconds.
>>> Without looking at your details, apologies:
>>>
>>> First, if you want an ace on a directory to be inherited by files and
>>> directories created under that directory, make sure you're setting the f
>>> and d flags (see nfs4_getfacl -H).
>>>
>>> Second, there's a umask problem: posix acl inheritance overrides the
>>> umask, but nfs4 acl inheritance isn't doing that.  (The client combines
>>> the create mode and the umask and sets both together, there's no way for
>>> the server to even tell what the umask is.)
>>>
>>> (We should do something about this if we can: maybe modifying the client
>>> to scan the directory acl for any inheritable aces and leaving out the
>>> umask if they're found?  It has the obvious race, but I seem to recall
>>> we live with that in the v3 case.  Or maybe there's something more
>>> clever, but this comes up every now and then and I can't remember a
>>> better solution.)
>>>
>>> --b.
>> Hi again
>> I have this:
>> nfs4_getfacl /mnt/CACTUS/dropbox/
>>
>> A::OWNER@:rwaDxtTcCy
>> A::GROUP@:rwaDxtcy
>> A::EVERYONE@:tcy
>> A:fdi:OWNER@:rwaDxtTcCy
>> A:fdi:GROUP@:rwaDtcy
>> A:fdi:EVERYONE@:tcy
>>
>> but files are created:
>> steve6@hh3:/mnt/CACTUS/dropbox>   touch h3
>>    ls -la
>> total 8
>> drwxrws--- 2 root   suseusers 4096 Feb 19 11:21 .
>> drwxr-xr-x 9 root   root      4096 Feb 19 11:11 ..
>> -rw-rw---- 1 steve6 suseusers    0 Feb 19 11:13 h
>> -rw-r----- 1 steve6 suseusers    0 Feb 19 11:21 h3
>>
>> where h is a file created on the unmounted share and h3 on the nfs4
>> mounted share. IOW the file created does not have group rw.
>> Ahhgghh!!
> Right, so see the second point above: what's your umask?  (output of the
> "umask" command.)
>
> --b.
>
>> Can anyone see anything wrong?
>>
>> Thanks so much for your patience.
>> Steve.
>>

OK. I see what you mean. umask 0022
So I can have a group rw with posix but not with nfs4_setfacl:-(

That's on openSUSE who default to 0022. The default on Ubuntu is 0002 so 
presumably we could have group rw over nfs4 there out of the box?

Is it a lot of work to implement umask override for nfs4? Or make it an 
option perhaps?

At the moment I'm using a big hammer and scanning the share every 4 
seconds to change the permissions of any files created there. My other 
thought was to have the share on a different partition, umask it to 0002 
and export that. But these are workarounds. It would be really good to 
have the nfs4 acls do it.

Thanks again,
Steve



