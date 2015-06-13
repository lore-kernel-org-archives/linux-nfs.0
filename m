Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36528 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbbFMMss (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2015 08:48:48 -0400
Received: by iecrd14 with SMTP id rd14so6955889iec.3
        for <linux-nfs@vger.kernel.org>; Sat, 13 Jun 2015 05:48:47 -0700 (PDT)
Date: Sat, 13 Jun 2015 08:48:39 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Quentin Barnes <qbarnes@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Adding file handle support to NFS client code
Message-ID: <20150613084839.2854b977@tlielax.poochiereds.net>
In-Reply-To: <20150613004718.GA26293@gmail.com>
References: <20150613004718.GA26293@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 12 Jun 2015 19:47:18 -0500
Quentin Barnes <qbarnes@gmail.com> wrote:

> I'm thinking of adding support to the NFS client code so that the
> open_by_handle_at(2) and name_to_handle_at(2) services would work
> on NFS mounted file systems.  As far as I can tell, this support
> currently doesn't exist in mainline, correct?
> 

Correct.

> 
> Many years ago I created and still maintain (unreleased) code for
> RHEL4-RHEL6 kernels that provide open-by-file-handle services for
> NFS clients.  The approach was loosely based on Robert Love's ext3
> open-by-inode patch of long ago.
> 
> We have used the modified NFS client code as a significant
> performance boost in accessing mostly read-only files from NFS file
> servers.  The files number in the many 10s of millions in trees
> spread across many hundreds of thousands of nested directories.
> (Come to think of it, that was several years ago.  I'm sure since
> then the numbers have grown by at least an order of magnitude or
> two.)  With the sheer numbers of files and directories, attempting
> to use even openat(2) with all those directories would still be
> overwhelming to the servers' inode cache.  Also, just doing all the
> constant tree-walks down to the files kill performance and stresses
> the dentry cache, let alone all the network traffic and load on our
> filers that would generate.  So that's why an open-by-file-handle
> hack was added to our kernels.
> 
> Now the time has come for that functionality to be ported to a
> RHEL7-based kernel.  Seems to me the best approach would be not to
> port my old work forward but to complete the fhandle callbacks for
> NFS clients.  However, before I begin my journey down that path, I'd
> like to hear if anyone has tried it before, or if there's a good
> reason not to choose this approach.  Any comments?
> 
> 
> If the NFS client fhandle support is the right way to go, since
> it wouldn't be a hackfest like my previous effort, I'd attempt
> contribute it upstream in case anyone else would ever find it
> useful.
> 
> Quentin

I think it makes sense to use the standard syscalls instead of ioctls
or something, and having this support sounds at least moderately useful.

The big stumbling block is that open_by_handle_at (and to some degree
name_to_handle_at) rely on the filesystem being exportable via knfsd,
and the NFS client is (intentionally) not. So, you'll have some work to
do there...

Also, how do you intend to present the filehandles here in (e.g.)
name_to_handle_at? Are you planning to generate synthetic filehandles
based on the inode number that the NFS client generates or are you
going to try to pass them through (opaquely) as-is from the actual
server?

-- 
Jeff Layton <jlayton@poochiereds.net>
