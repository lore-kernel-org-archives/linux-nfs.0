Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:38036 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031833Ab2CPHqE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 03:46:04 -0400
MIME-Version: 1.0
In-Reply-To: <1331859549.25523.5.camel@lade.trondhjem.org>
References: <1331836132-2053-1-git-send-email-vtrivedi018@gmail.com>
	<1331859549.25523.5.camel@lade.trondhjem.org>
Date: Fri, 16 Mar 2012 13:16:01 +0530
Message-ID: <CAKX=r8D3iYvvf8T+yK6VDHEzdY9zGtPHK5-0xm8ZaBU2aLKWhw@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFS: fix sb->s_id in nfs debug prints
From: Vivek Trivedi <vtrivedi018@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Namjae Jeon <linkinjeon@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,
I agree that s_id is fs specific.

If a NFS client is connected to multiple NFS servers and we want to
analyse NFS IO using rpcdebug prints, ps and top ..
If we store s_id in decimal, it will be a little easier to relate NFS
debug prints with *each* NFS flusher thread activity.

AFIK, In NFS, s_id is mainly used in debug prints, so storing s_id in
decimal may increase readability in NFS debug prints.

Is there any harm if we store NFS s_id in decimal ?
Please let me know your opinion.

Thanks,
Vivek

On Fri, Mar 16, 2012 at 6:29 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2012-03-15 at 23:58 +0530, Vivek Trivedi wrote:
>> NFS bdi flush thread in ps output is printed like "flush-<major number
>> in decimal>:<minor number in decimal>"
>> For example:
>> $ ps aux | grep flush
>>  2079 root         0 SW   [flush-0:18]
>>                                  ^^^^
>>
>> nfs_bdi_register()
>> ==> bdi_register_dev()
>> ==> bdi_register(bdi, NULL, "%u:%u", MAJOR(dev), MINOR(dev));
>>                              ^^^^^
>>
>> However, NFS sb->s_id store major:minor number in hex:
>>
>> nfs_initialise_sb()
>> ==>         snprintf(sb->s_id, sizeof(sb->s_id),
>>                  "%x:%x", MAJOR(sb->s_dev), MINOR(sb->s_dev));
>>                   ^^^^^
>>
>> If we enable nfs debug prints using command:
>> $ rpcdebug -m nfs -s all
>>
>> write to a file:
>> $ dd if=/dev/zero of=<NFS Mount>/testfile.txt bs=32768 count=1
>>
>> Without Patch:
>> [ 2431.032000] NFS:     0 initiated write call (req 0:12/40, 32768 bytes
>> @ offset 0)                                         ^^^^
>>
>> With Patch:
>> [ 2431.032000] NFS:     0 initiated write call (req 0:18/40, 32768 bytes
>> @ offset 0)                                         ^^^^
>>
>> We should store NFS "s->s_id" in decimal to avoid confusion between NFS
>> flush thread name(in ps output) and NFS debug prints.
>
> Why do we care? The s_id is entirely filesystem-specific so it shouldn't
> be compared to the properties of VFS objects anyway.
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
