Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:51565 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753891AbbEUIdn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2015 04:33:43 -0400
Date: Thu, 21 May 2015 14:03:25 +0530 (IST)
From: Govindarajulu Varadarajan <_govind@gmx.com>
To: Piotr Szymaniak <szarpaj@grubelek.pl>
cc: Chris Mason <clm@fb.com>, Govindarajulu Varadarajan <_govind@gmx.com>,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, jbacik@fb.com, dsterba@suse.cz
Subject: Re: btrfs: kernel BUG at mm/page-writeback.c:2286!
In-Reply-To: <20150519135416.GO2539@wloczykij>
Message-ID: <alpine.LNX.2.03.1505211400350.19285@ws.cisco>
References: <alpine.LNX.2.03.1505191317300.21108@ws.cisco> <555B3DEE.1000900@fb.com> <20150519135416.GO2539@wloczykij>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 19 May 2015, Piotr Szymaniak wrote:

> On Tue, May 19, 2015 at 09:43:10AM -0400, Chris Mason wrote:
>> On 05/19/2015 03:55 AM, Govindarajulu Varadarajan wrote:
>>> 2286--->BUG_ON(!PageLocked(page));
>>>
>>> [  166.769868] BTRFS info (device sdf): no csum found for inode 1154
>>> start 43192320
>>> [  166.774334] BTRFS info (device sdf): csum failed ino 1154 extent
>>> 4434247680 csum 1388825687 wanted 0 mirror 0
>>
>>
>> Josef and I both missed this the first time you pasted it, but the
>> unlocked page is almost certainly related to this csum error.  While
>> we're looking at things can you please scrub?
>
> Hi,
>
> In the original report there was:
>
>> [root@stg ~]#btrfs scru status /mnt/stg
>> scrub status for dd10b751-d2aa-40d1-971f-e15b0062dd11
>>         scrub started at Tue May 19 03:33:26 2015 and finished after 468 seconds
>>         total bytes scrubbed: 101.80GiB with 0 errors
>
> Correct me if I'm wrong, but I think that Govindarajulu Varadarajan made the
> scrub _after_ the crash.
>

I ran the scrub before and after the crash. Scrub shows 0 error but then I
access the file which is corrupt, I get I/O error and csum failure
in kernel log.
