Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f50.google.com ([209.85.166.50]:40058 "EHLO
        mail-io1-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727672AbeIRC0b (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 22:26:31 -0400
Received: by mail-io1-f50.google.com with SMTP id l14-v6so12687508iob.7
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 13:57:29 -0700 (PDT)
MIME-Version: 1.0
From: Stan Hu <stanhu@gmail.com>
Date: Mon, 17 Sep 2018 13:57:17 -0700
Message-ID: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
Subject: Stale data after file is renamed while another process has an open
 file handle
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On both kernels in Ubuntu 16.04 (4.4.0-130) and CentOS 7.3
(3.10.0-862.11.6.el7.x86_64) with NFS 4.1, I'm seeing an issue where
stale data is shown if a file remains open on one machine, and the
file is overwritten via a rename() on another. Here's my test:

1. On node A, create two different files on a shared NFS mount:
"test1.txt" and "test2.txt".
2. On node B, continuously show the contents of the first file: "while
true; do cat test1.txt; done"
3. On node B, run a process that keeps "test1.txt" open. For example,
with Python, run:
     f = open('/nfs-mount/test.txt', 'r')
4. Rename test2.txt via "mv -f test2.txt test1.txt"

On node B, I see the contents of the original test1.txt indefinitely,
even after I disabled attribute caching and the lookup cache. I can
make the while loop in step 2 show the new content if I perform one of
these actions:

1. Run "ls /nfs-mount"
2. Close the open file in step 3

I suspect the first causes the readdir cache revalidation to happen.

Is this intended behavior, or is there a better way to achieve
consistency here without performing one of these actions?

Note that with an Isilon NFS server, instead of seeing stale content,
I see "Stale file handle" errors indefinitely unless I perform one of
the corrective steps.
