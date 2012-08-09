Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:38445 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261Ab2HIL5P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 07:57:15 -0400
MIME-Version: 1.0
In-Reply-To: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
Date: Thu, 9 Aug 2012 20:57:14 +0900
Message-ID: <CAKYAXd9QyKtH7ZvCJs=X2DxhDn9_THXUooWVCWkxuEhizWgmsA@mail.gmail.com>
Subject: Re: [PATCH v5 00/19] vfs: add the ability to retry on ESTALE to
 several syscalls
From: Namjae Jeon <linkinjeon@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        michael.brantley@deshaw.com, hch@infradead.org, miklos@szeredi.hu,
        pstaubach@exagrid.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff.

I still found ESTALE error although patching these patch-set.
Is test method correct that I try to run estale_test on each nfs
server and client at the same time ?

./estale_test
chmod: Stale NFS[  281.720000] ##### send signal from USER, SIG : 2,
estale_test(107)->estale_test(102) sys_kill
[  281.728000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(103) sys_kill
[  281.736000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(104) sys_kill
[  281.744000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(105) sys_kill
[  281.752000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(106) sys_kill
[  281.760000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(107) sys_kill
[  281.768000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(108) sys_kill
[  281.780000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(109) sys_kill
[  281.788000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(110) sys_kill
[  281.796000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(111) sys_kill
[  281.804000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(112) sys_kill
[  281.812000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(113) sys_kill
[  281.820000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(114) sys_kill
[  281.828000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(115) sys_kill
[  281.840000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(116) sys_kill
[  281.848000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(117) sys_kill
[  281.856000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(118) sys_kill
[  281.864000] ##### send signal from USER, SIG : 15,
estale_test(102)->estale_test(119) sys_kill
 file handle
VDLinux#> chdir: Stale NFS[  282.664000] ##### send signal from USER,
SIG : 2, estale_test(120)->???(102) sys_kill
 file handle

Thanks.

2012/8/8, Jeff Layton <jlayton@redhat.com>:
> This patchset is a respin of the one I sent on July 26th. The main
> reason for the resend is to deal with some recent changes in namei.c
> that created some merge conflicts.
>
> This series depends on the "audit" series that I also sent on July 26th.
> That set didn't need any changes, so I'm not planning to resend it.
>
> This set is also available via the "estale" branch of my git tree:
>
>     git://git.samba.org/jlayton/linux.git estale
>
> I'd like to see this go in for 3.7 if at all possible.
>
> The original cover letter text follows:
>
> ESTALE errors are a source of pain for many users, primarily those who
> are doing work on NFS. When userspace provides a path to a syscall, then
> there's really little excuse for returning ESTALE. If userspace gave us
> a path that we had to lookup in order to do the call, then it's not
> particularly helpful to return ESTALE just because that path went stale
> before we could do the actual operation.
>
> We can and should do better here. The kernel should instead catch that
> error and retry the lookup and call, while forcing a revalidation of all
> dentries involved.
>
> Unfortunately fixing this requires touching the syscalls themselves, or
> at least their immediate helper functions. Not all syscalls can be
> retried -- only those that take a pathname as an argument.
>
> With this patchset, I've decided to take the relatively less
> controversial approach of just having the kernel retry once when it gets
> an ESTALE error. I still think that it's not as strong as it should be,
> but it should improve the situation in many common cases.
>
> I've also tried to engineer this in such a way that if we do decide that
> we need to retry more than once, then it should be easy to change that
> later. This should cover all of the syscalls in fs/stat.c and
> fs/namei.c, and a few from fs/open.c.
>
> Once these are merged, I'll look at adding similar handling to other
> path-based syscalls in a later set. A quick look shows that we have
> about 50-odd path-based syscalls that will need similar handling, so
> this is just a start.
>
> Jeff Layton (19):
>   vfs: add a retry_estale helper function to handle retries on ESTALE
>   vfs: add a kern_path_at function
>   vfs: make fstatat retry on ESTALE errors from getattr call
>   vfs: fix readlinkat to retry on ESTALE
>   vfs: remove user_path_at_empty
>   vfs: turn "empty" arg in getname_flags into a bool
>   vfs: add new "reval" argument to kern_path_create
>   vfs: fix mknodat to retry on ESTALE errors
>   vfs: fix mkdir to retry on ESTALE errors
>   vfs: fix symlinkat to retry on ESTALE errors
>   vfs: fix linkat to retry on ESTALE errors
>   vfs: make rmdir retry on ESTALE errors
>   vfs: make do_unlinkat retry on ESTALE errors
>   vfs: fix renameat to retry on ESTALE errors
>   vfs: remove user_path_parent
>   vfs: have do_sys_truncate retry once on an ESTALE error
>   vfs: have faccessat retry once on an ESTALE error
>   vfs: have chdir retry lookup and call once on ESTALE error
>   vfs: make chroot retry once on ESTALE error
>
>  drivers/base/devtmpfs.c |   7 +-
>  fs/namei.c              | 357
> ++++++++++++++++++++++++++++++------------------
>  fs/open.c               | 234 ++++++++++++++++++-------------
>  fs/stat.c               |  44 ++++--
>  include/linux/fs.h      |  22 +++
>  include/linux/namei.h   |   4 +-
>  net/unix/af_unix.c      |   2 +-
>  7 files changed, 422 insertions(+), 248 deletions(-)
>
> --
> 1.7.11.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
