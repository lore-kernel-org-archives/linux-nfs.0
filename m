Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:60119 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab2G0CWI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 22:22:08 -0400
MIME-Version: 1.0
In-Reply-To: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
References: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
Date: Fri, 27 Jul 2012 11:15:23 +0900
Message-ID: <CAKYAXd99VMYSX=k9eadB6MZvjQjQrOngOjUicjo+c9LtHvpz9w@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] vfs: add the ability to retry on ESTALE to
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

Which testcase(or test method) do I use to know improved point from
ESTALE error ?
I want to know before & after using testcase with this patch-set.

Thanks.

2012/7/26, Jeff Layton <jlayton@redhat.com>:
> This patchset is a respin of the one I sent on June 29th. The main
> reason for the resend is to deal with some minor merge conflicts that
> have cropped up due to recent changes.
>
> This series depends on the "audit" series that I sent earlier today.
> It's also available via the "estale" branch of my git tree:
>
>     git://git.samba.org/jlayton/linux.git estale
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
> fs/namei.c.
>
> Once these are merged, I'll look at adding similar handling to other
> path-based syscalls in a later set. A quick look shows that we have
> about 50-odd path-based syscalls that will need similar handling, so
> this is just a start.
>
> Jeff Layton (17):
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
>
>  drivers/base/devtmpfs.c |   7 +-
>  fs/namei.c              | 407
> +++++++++++++++++++++++++++++-------------------
>  fs/open.c               | 162 ++++++++++---------
>  fs/stat.c               |  44 ++++--
>  include/linux/fs.h      |  22 +++
>  include/linux/namei.h   |   4 +-
>  net/unix/af_unix.c      |   3 +-
>  7 files changed, 400 insertions(+), 249 deletions(-)
>
> --
> 1.7.11.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
