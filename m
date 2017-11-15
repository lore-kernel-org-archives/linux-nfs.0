Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:45158 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751520AbdKOIOF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Nov 2017 03:14:05 -0500
Received: by mail-ua0-f196.google.com with SMTP id 108so10496107uaf.2
        for <linux-nfs@vger.kernel.org>; Wed, 15 Nov 2017 00:14:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOapt6=TOF=Q0rCgQEm-EqML1XNDtWJgjcp7Z5_Qenp8RXMZpw@mail.gmail.com>
References: <CAOapt6ko9Ue+Vf0TQNNNP+pSdbk09my_b9PjSF21Vg0v0nzAVw@mail.gmail.com>
 <1E02EBE8-9BB2-4E60-BB4D-92843D5A0941@oracle.com> <CAOapt6=TOF=Q0rCgQEm-EqML1XNDtWJgjcp7Z5_Qenp8RXMZpw@mail.gmail.com>
From: Anders Ossowicki <and@vmn.dk>
Date: Wed, 15 Nov 2017 09:14:03 +0100
Message-ID: <CAOapt6=wOfUBgTCvMBxs6B=xDQ_wp3VmKqUCuPmcJshiz-CkGA@mail.gmail.com>
Subject: Re: nfsd returns NFSERR_STALE when the inode of the rootdir of the
 nfs mount is > 2^32
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14 November 2017 at 19:11, Anders Ossowicki <and@vmn.dk> wrote:
> On 14 November 2017 at 18:12, Chuck Lever <chuck.lever@oracle.com> wrote:
>> But since you already have such inodes, NFS clients will
>> have to convert the numbers on the fly. You can use a boot
>> parameter on your clients:
>>
>>   nfs.enable_ino64=0
>>
>> According to comments in fs/nfs/inode.c .
>
> Thanks for the suggestion.
>
> I looked at nfs.enable_ino64 while tracking down this issue, but it
> looked like a client-side option to me, and the error happens in the
> nfsd code. I'll give a shot tomorrow.

No dice, unfortunately:

aowi@otto ~ $ dmesg|grep 'Kernel command line'
[    0.000000] Kernel command line:
BOOT_IMAGE=/boot/vmlinuz-3.19.0-77-generic
root=UUID=601cb526-8e11-4565-a5ed-0be619db7a5e ro quiet splash
nfs.enable_ino64=0 vt.handoff=7
aowi@otto ~ $ sudo mount -t nfs svin:/z/svin/aowitest/foo /mnt
aowi@otto ~ $ ls /mnt
ls: cannot open directory /mnt: Stale file handle

-- 
Anders Ossowicki
