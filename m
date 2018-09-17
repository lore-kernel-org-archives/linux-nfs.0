Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53060 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726844AbeIRCoJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Sep 2018 22:44:09 -0400
Date: Mon, 17 Sep 2018 17:15:04 -0400
To: Stan Hu <stanhu@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
Message-ID: <20180917211504.GA21269@fieldses.org>
References: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 17, 2018 at 01:57:17PM -0700, Stan Hu wrote:
> On both kernels in Ubuntu 16.04 (4.4.0-130) and CentOS 7.3
> (3.10.0-862.11.6.el7.x86_64) with NFS 4.1, I'm seeing an issue where
> stale data is shown if a file remains open on one machine, and the
> file is overwritten via a rename() on another. Here's my test:
> 
> 1. On node A, create two different files on a shared NFS mount:
> "test1.txt" and "test2.txt".
> 2. On node B, continuously show the contents of the first file: "while
> true; do cat test1.txt; done"
> 3. On node B, run a process that keeps "test1.txt" open. For example,
> with Python, run:
>      f = open('/nfs-mount/test.txt', 'r')
> 4. Rename test2.txt via "mv -f test2.txt test1.txt"
> 
> On node B, I see the contents of the original test1.txt indefinitely,
> even after I disabled attribute caching and the lookup cache. I can
> make the while loop in step 2 show the new content if I perform one of
> these actions:
> 
> 1. Run "ls /nfs-mount"
> 2. Close the open file in step 3
> 
> I suspect the first causes the readdir cache revalidation to happen.
> 
> Is this intended behavior, or is there a better way to achieve
> consistency here without performing one of these actions?

Sounds like a bug to me, but I'm not sure where.  What filesystem are
you exporting?  How much time do you think passes between steps 1 and 4?
(I *think* it's possible you could hit a bug caused by low ctime
granularity if you could get from step 1 to step 4 in less than a
millisecond.)

Those kernel versions--are those the client (node A and B) versions, or
the server versions?

> Note that with an Isilon NFS server, instead of seeing stale content,
> I see "Stale file handle" errors indefinitely unless I perform one of
> the corrective steps.

You see "stale file handle" errors from the "cat test1.txt"?  That's
also weird.

--b.
