Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:59099 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437Ab2EOJsV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 05:48:21 -0400
Message-ID: <4FB22658.9010909@panasas.com>
Date: Tue, 15 May 2012 12:48:08 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Johannes Schild <JSchild@gmx.de>
CC: <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: Questions about Exofs
References: <20120515090332.182970@gmx.net>
In-Reply-To: <20120515090332.182970@gmx.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/15/2012 12:03 PM, Johannes Schild wrote:

> Hi,
> 
> i try to set up the object-based layout with pnfs.
> I am using the OSC-OSD as target. It works well and i can login.
> Trying the scripts "do-*" from git://git.open-osd.org/open-osd.git the do-osd script works for me. The do-exofs doesnt, here i have some question:
> 
> 1. Is the UUID in the do-exofs script optional?
> 


No it is not optional

> 2. If no how can i get it for my device?
> 


Exactly! the ./do-exofs format command will set this for you, as well as mkfs.exofs the
FS for you.

> 3. It is mandatory to use raid-driver (raid456) in the script? Why?
> 


What? where? Rrrr you are right. this is a very old tree. Let me see
if I have something newer to push. It should all load automatically now.

But yes the dependency on raid456.ko is built in. Though if you use
raid=0 on the format command line it will not be used in run time.

> 
> The error is: 
> mount -t exofs -o osdname=d2683732-c906-4ee1-9dbd-c10c27bb40df,pid=0x10000,_netdev /dev/osd0 /mnt/osd0/
> mount: wrong fs type, bad option, bad superblock on /dev/osd0,
>        missing codepage or helper program, or other error
>        In some cases useful info is found in syslog - try
>        dmesg | tail  or so
> 
> dmesg says:
> exofs: Unable to mount exofs on (null) pid=0x0 err=-22
> 


Probably you forgot the "./do-exofs format" stage. Please read the script
before, you might need to edit it. It is the stage that calls mkfs.exofs
to make a new filesystem for you. (An OSD is a raw device that can host
many filesystems each in it's own osd-partition.

> 
> Thanks for answering my questions.


> Regards
> Johannes
> 


Cheers
Boaz

