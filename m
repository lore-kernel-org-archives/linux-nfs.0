Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:20073 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542Ab0LPOtD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 09:49:03 -0500
Message-ID: <4D0A26DC.5090908@panasas.com>
Date: Thu, 16 Dec 2010 16:49:00 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 22/22] pnfs-submit: Turn off layoutcommits
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>	<1291944177-7819-23-git-send-email-iisaman@netapp.com>	<4D0A0A77.9010802@panasas.com> <AANLkTinqnA2Qd68FB=ptoeSxrTd8FD47GezUn_83KtGf@mail.gmail.com>
In-Reply-To: <AANLkTinqnA2Qd68FB=ptoeSxrTd8FD47GezUn_83KtGf@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/16/2010 04:13 PM, Fred Isaman wrote:
> On Thu, Dec 16, 2010 at 7:47 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 12/10/2010 03:22 AM, Fred Isaman wrote:
>>> Recent changes to close can delay pending layoutcommit until umount,
>>> when the async layoutcommits can come tricklng in after we have destroyed
>>> the session.
>>
>> Then "Recent changes" are broken and should be fixed. It was fine
>> before. New broken code is not acceptable.
>>
>>> Since file does not need them, just turn them off for
>>> the moment.  Non-file layouts will probably have to trigger them in
>>> some fashion at close.
>>>
>>
>> Rrrr. Are we back to this argument. We stand down win an argument
>> and 2 weeks later you are back on it has if we never talked about it.
>>
>> NO!!! only "coherent clustered filesystems" do not need them. It has
>> nothing to do with layout type. A none-clustered aggregated parallel
>> filesystem will need them just the same as blocks and objects.
>>
>> AND THE STD DOES NOT GIVE YOU A CHOICE!!!
> 
> You keep saying this, but just repeating it does not convince me.
> Could you please take the time to explain *why* they are needed.  A
> separate thread in the ietf list would be great.  Because right now,
> Andy and I are coding and preparing for submission to Trond under the
> assumption that they are possibly a nice optimization, but are never
> actually needed for the file layout.
> 
> Fred
> 

I have many times. You are being forgetful. Last bakeathon Mike, I think
or someone, had a proposition talk that "since layoutcommit is use less,
lets make it optional". And we went into a long argument about that. Until
finally Trond came to the rescue and explained very clearly. Better then
I ever could, that if you want to keep current reboot semantics a client
must send a successful layoutcommit after all successful DS commits before
it can free it's dirty pages. layoutcommit is the writing of meta data after
the write of data, and is, just as important, a part of a file.

Consider an spNFS type filesystem that keeps all meta-data on MDS and
the data on disjoint independent DSs. None of the servers see the same
data and the MDS is just another client + Meta information. layoutcommit
is the point data is exposed outside and also the point meta-data is persisted
(Somewhere). Failing to do layoutcommits will not enable me to do such
simple, scalable and possibly reliable FSs. The authors of the STD did
envision such systems and invented the layoutcommit. (There is the issue of
the changed_attribute of a crashing writing client but this is solvable with
very simple MDS-to-DS communication, and is another matter)

The fact that we had the above talk also proves another thing. That the 
STD does not make layoutcommit optional, hence the request to make it
optional.

And nothing of the above is new. I have stated that many times and
you keep "forgetting".

BTW: An object based filesystem could be implemented just as well
over files as over objects. Save the RAID5 stuff. Objects being
partition/objectid numeric file names, and uid/gid games for fencing
off / access permission. In such a system layoutcommits serve the
same purpose as in objects, but with a files layout

You can call me and we can talk about it if you need to. But do
You agree that the current STD text mandates it?

Boaz
