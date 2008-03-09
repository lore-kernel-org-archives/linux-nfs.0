From: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Subject: Re: NFS server waking up sleeping disks
Date: Sun, 09 Mar 2008 20:50:34 +0100
Message-ID: <47D43F8A.1050508@foo-lounge.de>
References: <1204969522.11220.680.camel@hurina>	 <47D29BC2.9000806@foo-lounge.de> <1205018864.11220.689.camel@hurina> <47D35249.7020000@foo-lounge.de> <CFB019DD-6BDA-4007-B4AA-3E06C58196FD@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server3.hostprice.de ([213.239.211.250]:58194 "EHLO
	server3.hostprice.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931AbYCITu7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Mar 2008 15:50:59 -0400
In-Reply-To: <CFB019DD-6BDA-4007-B4AA-3E06C58196FD@iki.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Timo Sirainen wrote:
> On Mar 9, 2008, at 4:58 AM, Timo Reimann wrote:
> 
>>>> However, there is no `ls' or similar call required to wake up my disk.
>>>> It just happens.
>>>
>>> Thanks, mountd is indeed the problem:
>>>
>>> I'll go figure out why it's doing this.
>>
>> If you find a solution prior to the other guys who offered their help to
>> me, please let us (especially me :) ) know.
> 
> Well, after half an hour of looking at mountd and libblk code and trying
> to figure out why I can't seem to find the code for what I see in the
> strace, I finally found out the mountd sources were newer than what I
> was using and this issue was already fixed (Debian unstable):
> 
> This appears to fix my problem, although it'll probably takes a few days
> until I'm sure. This is the second time already when I've wasted a lot
> of time trying to figure out a problem, only to find out that
> dist-upgrade would have solved it. Have to remember to do that the next
> time. :)

Thanks a lot for the hint, that seems to have fixed it for me as well. I
was previously looking over the changelog too but couldn't relate any of
the entries to my issue successfully. Double-checking whatever I was
doing might have helped my case as well. :)

Like you, I won't be absolutely sure before at least 24h of testing have
passed, but so far there hasn't been a single undesirable spinup of my
backup disk for the last couple of hours. As mentioned before, my disk
wouldn't stay quiet for more than 25 minutes.

For whom it may concern: I'm running Ubuntu Gutsy and did a backport of
nfs-utils 1.1.1-12ubuntu3, currently contained in Hardy.


Cheers,

--Timo
