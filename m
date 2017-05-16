Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36706 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750799AbdEPP71 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 May 2017 11:59:27 -0400
Received: by mail-qt0-f193.google.com with SMTP id j13so21411698qta.3
        for <linux-nfs@vger.kernel.org>; Tue, 16 May 2017 08:59:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170516140955.GZ7250@eguan.usersys.redhat.com>
References: <20170516140955.GZ7250@eguan.usersys.redhat.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 16 May 2017 11:59:25 -0400
Message-ID: <CAN-5tyHK5GAZk1_aAhcLjb5gAT5uoO5=k33VhUwuMS_MqHZNKA@mail.gmail.com>
Subject: Re: [4.12-rc1 regression] copy_file_range(2) stuck in infinite loop
To: Eryu Guan <eguan@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Olga Kornievskaia <kolga@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 16, 2017 at 10:09 AM, Eryu Guan <eguan@redhat.com> wrote:
> Hi all,
>
> fstests test generic/430 would hang when testing NFSv4.2 using 4.12-rc1
> kernel based client. And this is a regression, 4.11 kernel has no
> problem. A simple reproducer is like:
>
> # mount -t nfs -o vers=4.2 nfs-server:/export /mnt/nfs
> # xfs_io -fc "pwrite 0 4k" /mnt/nfs/testfile
> # xfs_io -fc "copy_range /mnt/nfs/testfile" /mnt/nfs/testfile.copy
>
> The last copy_range command never returns, and xfs_io process is in D
> state. Some kernel debug code shows that it stuck in infinite loop in
> nfs42_proc_copy(), _nfs42_proc_copy() always returns -EAGAIN.
>
> So this looks like a problem introduced by this commit
>
> commit e092693443b995c8e3a565a73b5fdb05f1260f9b
> Author: Olga Kornievskaia <kolga@netapp.com>
> Date:   Mon May 8 18:02:24 2017 -0400
>
>     NFS append COMMIT after synchronous COPY
>
>     Instead of messing with the commit path which has been causing issues,
>     add a COMMIT op after the COPY and ask for stable copies in the first
>     space.
>
>     It saves a round trip, since after the COPY, the client sends a COMMIT
>     anyway.
>
>     Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>     Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>
> Reverting this patch did solve the problem. If you need more info please
> let me know.

Thank you. That was a big typo. Should be if (nfs_write_verifier_cmp)
and not if (!). Sending a fix.

>
> Thanks,
> Eryu
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
