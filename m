Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f193.google.com ([209.85.166.193]:35269 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726225AbeIYCiu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Sep 2018 22:38:50 -0400
Received: by mail-it1-f193.google.com with SMTP id 139-v6so12368843itf.0
        for <linux-nfs@vger.kernel.org>; Mon, 24 Sep 2018 13:34:50 -0700 (PDT)
MIME-Version: 1.0
References: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
 <20180917211504.GA21269@fieldses.org> <CAMBWrQm2QRKNARwUf7pG_fG_ROcwXmT1PLfw5Y0ewhXzB9EqYA@mail.gmail.com>
 <20180917220107.GB21269@fieldses.org> <CAMBWrQmRtPHOFbiMsz2YAn-yQXCYjRBqq0zLJUB7snPg2MQ+tA@mail.gmail.com>
 <CAMBWrQmipZs4rwOUMhH59nHiWqyAcX7qsBG51ZWMYxWKzFZ47Q@mail.gmail.com>
 <20180918181901.GC1218@fieldses.org> <CAMBWrQmLDwhESALcH2kamrRr4VhRsgVP0kAMeiE2J0uubcfNNw@mail.gmail.com>
 <20180919200214.GB14422@fieldses.org> <CAMBWrQkQTzRj5RtqDWRen2YYKzaU_cewTu5UkUMD2Ysmd9wHkA@mail.gmail.com>
 <20180920183950.GA26850@fieldses.org>
In-Reply-To: <20180920183950.GA26850@fieldses.org>
From: Stan Hu <stanhu@gmail.com>
Date: Mon, 24 Sep 2018 13:34:38 -0700
Message-ID: <CAMBWrQmUwmFenuxhs_jYX90R8ZgQ7+8QbWm=FpJrp7yxEwNFCw@mail.gmail.com>
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 20, 2018 at 11:39 AM Bruce Fields <bfields@fieldses.org> wrote:

> > Last night I left my test running on for more than 30 minutes, and the
> > while loop still showed the stale data. I think I even turned off
> > attribute caching entirely to see if this would help, and it did not.
>
> Huh.  Then I'm back to thinking there's a client bug in the 4.0 case.
>

I've been doing more digging, and I think there is some issue with the
cache validation here. In NFS 4.1, it looks like in dir.c
nfs4_lookup_revalidate() calls nfs_lookup_revalidate() since the
NFS_CAP_ATOMIC_OPEN_V1 flag is active
(https://github.com/torvalds/linux/blob/v4.19-rc4/fs/nfs/dir.c#L1591).
On the other hand, since that flag isn't active for NFS 4.0, the
validation is much briefer
(https://github.com/torvalds/linux/blob/v4.19-rc4/fs/nfs/dir.c#L1599-L1628).

I'm not sure if the comment in
https://github.com/torvalds/linux/blob/v4.19-rc4/fs/nfs/dir.c#L1630
actually reflects what's happening. If I look at the stack trace of
the next file open call, I don't see additional validation:

Sep 24 20:20:38 test-kernel kernel: [ 1145.233460] Call Trace:
Sep 24 20:20:38 test-kernel kernel: [ 1145.233462]  dump_stack+0x8e/0xd5
Sep 24 20:20:38 test-kernel kernel: [ 1145.233480]
nfs4_file_open+0x56/0x2a0 [nfsv4]
Sep 24 20:20:38 test-kernel kernel: [ 1145.233488]  ?
nfs42_clone_file_range+0x1c0/0x1c0 [nfsv4]
Sep 24 20:20:38 test-kernel kernel: [ 1145.233490]  do_dentry_open+0x1f6/0x360
Sep 24 20:20:38 test-kernel kernel: [ 1145.233492]  vfs_open+0x2f/0x40
Sep 24 20:20:38 test-kernel kernel: [ 1145.233493]  path_openat+0x2e8/0x1690
Sep 24 20:20:38 test-kernel kernel: [ 1145.233496]  ?
mem_cgroup_try_charge+0x8b/0x190
Sep 24 20:20:38 test-kernel kernel: [ 1145.233497]  do_filp_open+0x9b/0x110
Sep 24 20:20:38 test-kernel kernel: [ 1145.233499]  ?
__check_object_size+0xb8/0x1b0
Sep 24 20:20:38 test-kernel kernel: [ 1145.233501]  ? __alloc_fd+0x46/0x170
Sep 24 20:20:38 test-kernel kernel: [ 1145.233503]  do_sys_open+0x1ba/0x250
Sep 24 20:20:38 test-kernel kernel: [ 1145.233505]  ? do_sys_open+0x1ba/0x250
Sep 24 20:20:38 test-kernel kernel: [ 1145.233507]  __x64_sys_openat+0x20/0x30
Sep 24 20:20:38 test-kernel kernel: [ 1145.233508]  do_syscall_64+0x65/0x130

If I naively apply this patch:

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8bfaa658b2c1..6e3ece2e6984 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1631,7 +1631,7 @@ static int nfs4_lookup_revalidate(struct dentry
*dentry, unsigned int flags)
        ret = 1;

 out:
-       return ret;
+       return nfs_lookup_revalidate(dentry, flags);

 no_open:
        return nfs_lookup_revalidate(dentry, flags);

Things behave as expected on NFS 4.0. What's the right fix here?
