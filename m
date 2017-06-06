Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [195.159.176.226] ([195.159.176.226]:38740 "EHLO
        blaine.gmane.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdFFQrA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jun 2017 12:47:00 -0400
Received: from list by blaine.gmane.org with local (Exim 4.84_2)
        (envelope-from <glN-linux-nfs@m.gmane.org>)
        id 1dIHd6-00065N-Ew
        for linux-nfs@vger.kernel.org; Tue, 06 Jun 2017 18:46:52 +0200
To: linux-nfs@vger.kernel.org
From: Lutz Vieweg <lvml@5t9.de>
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
Date: Tue, 06 Jun 2017 18:46:51 +0200
Message-ID: <5936DC7B.8040804@5t9.de>
References: <20151012164846.GA5017@draconx.ca>   <20151012192538.GG28755@fieldses.org> <20151012194647.GJ28755@fieldses.org>     <20151013030136.GA7081@draconx.ca>      <20151013065225.44c5581d@synchrony.poochiereds.net>     <CADyTPEyUKNdYuj0LwoX-r6jJJ0tEufwyA_mEKE=OVniX9rXPog@mail.gmail.com>    <CADyTPEx=h95ODeG3BixMHc=kxLmkFt+aVyS+V_bK-b=CqK4_6Q@mail.gmail.com> <1469814735.19411.1.camel@poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
In-Reply-To: <1469814735.19411.1.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/29/2016 07:52 PM, Jeff Layton wrote:
>>>>>>>>    fcntl(7, F_SETLK, {type=F_RDLCK, whence=SEEK_SET,
>>>>>>>> start=1073741824, len=1}) = -1 EIO (Input/output error)
>>
>> Unfortunately I did not manage to perform a network capture last time
>> due to power loss.  I did not hit this issue again until yesterday (~9
>> months later), this time after 45 days of uptime.
>>
>> Kernel versions now are: 4.5.1 on the server, and 4.4.3 on the client.

I wanted to add that I, too, have one NFS client and server
(running linux-4.11.0 on both the server and the client)
currently in the same kind of state:

I can reproduce in 100% of the cases that the following commands:

> rm -f x.sqlite
> sqlite3 x.sqlite "PRAGMA case_sensitive_like=1;PRAGMA synchronous=OFF;PRAGMA recursive_triggers=ON;PRAGMA foreign_keys=OFF;PRAGMA locking_mode = NORMAL;PRAGMA journal_mode =  TRUNCATE;"

result in:

>  "Error: disk I/O error"

on the client - while working fine on the NFS server - with the same kind
of strace output:

>  fcntl(3, F_SETLK, {type=F_RDLCK, whence=SEEK_SET, start=1073741824, len=1}) = -1 EIO (Input/output error)
>  write(2, "Error: disk I/O error\n", 22Error: disk I/O error

But unlike the original reporter, we use the NFS v3 protocol:
> server:/data on /data type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,soft,proto=tcp,timeo=600,retrans=2,sec=sys,mountvers=3,mountport=20048,mountproto=udp,local_lock=none)

If you want me to try or trace something on the client,
I'm willing to help.

Regards,

Lutz Vieweg


