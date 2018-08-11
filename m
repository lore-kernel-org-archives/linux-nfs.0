Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua1-f50.google.com ([209.85.222.50]:33277 "EHLO
        mail-ua1-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727348AbeHKQ2w (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Aug 2018 12:28:52 -0400
Received: by mail-ua1-f50.google.com with SMTP id i4-v6so4838973uak.0
        for <linux-nfs@vger.kernel.org>; Sat, 11 Aug 2018 06:54:35 -0700 (PDT)
MIME-Version: 1.0
From: gy Lee <guguyayak@gmail.com>
Date: Sat, 11 Aug 2018 21:56:47 +0800
Message-ID: <CAP9+kVBvXYZNCNErJscN34r638mje0_Qow8H5Mc8-13d4zJvbQ@mail.gmail.com>
Subject: It possible for invalidate_inode_pages2 to fail with an EBUSY
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,All,
My kernel version is 4.14.0, centos system.
I ran into a problem that was very similar to a previous question. The
git information for the problem is as follows:

commit id : 874f946376de57c8d6230b30ad71f742883fee3a
When invalidating the page cache for a regular file, we want to first
sync all dirty data to disk and then call invalidate_inode_pages2().
The latter relies on nfs_launder_page() and nfs_release_page() to deal
respectively with dirty pages, and unstable written pages. When commit
9590544694bec ("NFS: avoid deadlocks with loop-back mounted
NFS filesystems.") changed the behaviour of nfs_release_page(), then it
made it possible for invalidate_inode_pages2() to fail with an EBUSY.
Unfortunately, that error is then propagated back to read(). Let's
therefore work around the problem for now by protecting the call
to sync the data and invalidate_inode_pages2() so that they are atomic
w.r.t. the addition of new writes.
Later on, we can revisit whether or not we still need nfs_launder_page()
and nfs_release_page().
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

However, in the later revisions, the modification of this part was
modified, and now I have encountered this problem. I tried a lot of
methods and didn't solve the problem successfully, so I asked for help
from you.

My business model is mixed read and write, EBUSY error is returned in
the read request, and the function call flow is:
> nfs_file_read -> nfs_revalidate_mapping -> invalidate_inode_pages2 -> invalidate_inode_pages2_range -> invalidate_complete_page2 -> nfs_release_page -> PagePrivate(page)

PagePrivate(page) return true,so invalidate_inode_pages2_range return -EBUSY.


Thanks for any help!
