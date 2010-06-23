Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55608 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788Ab0FWAcb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jun 2010 20:32:31 -0400
Received: by fxm10 with SMTP id 10so2777769fxm.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jun 2010 17:32:29 -0700 (PDT)
In-Reply-To: <4C20EC0E.7070601@gmail.com>
References: <AANLkTimkEM7CPctkwYiWa-rGXDs3EHNl-hldu5fQYqRo@mail.gmail.com>
	<4C20EC0E.7070601@gmail.com>
Date: Wed, 23 Jun 2010 08:32:29 +0800
Message-ID: <AANLkTilIwm8fxUqJ3IwRrPLqr7o8D4TPnDzps8mp7dB-@mail.gmail.com>
Subject: Re: How to increase rsize/wsize ?
From: Yan Rui <rui.yan@gmail.com>
To: Dean Hildebrand <seattleplus@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Dean,

The max_block_size is 256KB on my nfs server.   By changing it to a
1MB,  I can mount a share with a bigger rsize/wsize now.  Thank you
very much!

Cheers,
Rui

On Wed, Jun 23, 2010 at 12:59 AM, Dean Hildebrand <seattleplus@gmail.com> wrote:
> What's the value of /proc/fs/nfsd/max_block_size?  I'm not sure how it is
> set, but it does not default to the max.
> Dean
>
> On 6/21/2010 8:29 AM, Yan Rui wrote:
>>
>> Hi,
>>
>> I failed to mount a nfs share with a bigger rsize/wsize (in my case,
>> 512K).   The biggest rsize/wsize I can get is only 256KB on my Ubuntu
>> 9.10 server box.  Can anyone give me some suggestions?
>>
>> root@d03:~# exportfs -v
>> /tmp<world>(rw,wdelay,root_squash,no_subtree_check)
>>
>> root@d04:~# mount -t nfs -o wsize=524288,rsize=524288 d03:/tmp /mnt/nfs
>>
>> root@d04:~# nfsstat -m
>> /mnt/nfs from d03:/tmp
>>  Flags:
>>  rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.0.0.3,mountvers=3,mountproto=tcp,addr=10.0.0.3
>>
>> root@d03:~# uname -a
>> Linux d03 2.6.31-14-server #48-Ubuntu SMP Fri Oct 16 15:07:34 UTC 2009
>> x86_64 GNU/Linux
>>
>> root@d03:~# dpkg -l | grep nfs
>> ii  nfs-common                        1:1.2.0-2ubuntu8
>>  NFS support files common to client and serve
>> ii  nfs-kernel-server                 1:1.2.0-2ubuntu8
>>  support for NFS kernel server
>>
>> According to NFS-HOWTO, I have checked the kernel const
>> NFSSVC_MAXBLKSIZE.  It is 1M on 2.6.31.
>>
>> Any comments will be appreciated!
>>
>> Regards,
>> Rui
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
