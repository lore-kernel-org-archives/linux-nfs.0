Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:40237 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbaH3AjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Aug 2014 20:39:17 -0400
Received: by mail-qa0-f54.google.com with SMTP id x12so2922188qac.27
        for <linux-nfs@vger.kernel.org>; Fri, 29 Aug 2014 17:39:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140829230147.GD7996@ZenIV.linux.org.uk>
References: <CAHQdGtT4kbPqQvD_fu7c_5_CqK8FCpA5mJsVdh=KxoE9_vXRzw@mail.gmail.com>
 <20140829205817.GB7996@ZenIV.linux.org.uk> <CAHQdGtRBqmsfeVVysTnTEELHuwiPwvsyTHtoRAsfSS0aSyCbfQ@mail.gmail.com>
 <20140829230147.GD7996@ZenIV.linux.org.uk>
From: Peng Tao <tao.peng@primarydata.com>
Date: Sat, 30 Aug 2014 08:38:56 +0800
Message-ID: <CAKVebiWBU3du650yeTMfaFuLr=WLUBc2RukFGyBF6Qgxd6zA8Q@mail.gmail.com>
Subject: Re: VFS regression: commit aba809cf0944 breaks MNT_SHRINKABLE
 automounted partitions
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 30, 2014 at 7:01 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Fri, Aug 29, 2014 at 05:47:58PM -0400, Trond Myklebust wrote:
>
>> Note that the issue happens with NFSv4 or NFSv4.1 (not NFSv3).
>
> That's what I'd been using for testing.
>
>> Note that on my system, if I call 'umount' a second time after getting
>> the 'device is busy' error, then it succeeds. It looks as if the first
>> call to 'umount /mnt' causes the directory /mnt/export to clear,
>> causing the second 'umount /mnt' to succeeed (unless I try to access
>> /mnt/export again):
Just to be clear, it is what I saw as well. I did not get permanent
-EBUSY and I could umount /mnt if I run `umount /mnt` twice.

And I did not do git bisect. I had doubts in the code so I found the
specific commit to revert it and it worked. But if it is some other
commit in the middle, I could have missed it.

My theory to blame aba809cf0944 is that in
do_umount()->shrink_submounts()->umount_tree(), it transfers parent
mnt refcount (held by child mnt) to mnt_ex_mountpoint but that is put
_after_ do_umount() calls propagate_mount_busy(mnt, 2). So
propagate_mount_busy() would fail do_refcount_check(). Does it make
sense to you?

>
> Now, that smells like a different bug - see if commit ab8f2c from -next
> helps with that one.
>
I cherri-picked it and it still failed with -EBUSY.

Cheers,
Tao
