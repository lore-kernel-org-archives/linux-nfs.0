Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758538Ab3ENVQC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:16:02 -0400
From: Zach Brown <zab@redhat.com>
To: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [RFC v0 0/4] sys_copy_range() rough draft
Date: Tue, 14 May 2013 14:15:22 -0700
Message-Id: <1368566126-17610-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've been talking about implementing some form of bulk data copy
offloading for a while now.  BTRFS and OCFS2 implement forms of copy
offloading with ioctls, NFS 4.2 will include a byte-granular COPY
operation, and the SCSI XCOPY command is being implemented now that
Windows can issue it.

In the past we've discussed promoting the ocfs2 reflink ioctl into a
system call that would create a new file and implicitly copy the
source data into the new file:
https://lkml.org/lkml/2009/9/14/481

These draft patches take the simpler approach of only copying data
between existing files.  The patches 1) make a system call out of the
btrfs CLONE_RANGE ioctl, 2) implement the btrfs .copy_range method with
the ioctl's guts, 3) implement the nfs .copy_range by sending a COPY
op, and 4) serve the COPY op in nfsd by calling the .copy_range method
again.

The nfs patch is an untested hack.  I'm happy to beat it in to shape
but I'll need some guidance.

I'd like strong review feedback on the interfaces, here are some
possible topics:

a) Hopefully being able to specify a portion of the data to copy will
avoid *huge* syscall latencies and the motivation for new async
semantics.

b) The BTRFS ioctl and nfs COPY let you specify a count of 0 to copy
from the start offset to the end of the file.  Does anyone have a
strong feeling about this?  I'm leaning towards not bothering with it
in the syscall interface.

c) I chose to return partial progess in the ssize_t return code.  This
limits the length of the range and the size_t count argument can be too
large and return errors, much like other io syscalls.  This seemed
less awful than some extra argument with a pointer to a status value.

d) I'm dreading mentioning a vector of ranges to copy in one syscall
because I don't want to think about overlaping ranges and file systems
that use range locks -- xfs for now, but more if Jan gets his way.
I'd rather that we get some experience with this simpler syscall before
taking on that headache.

I'm sure I'm forgetting some other details.

I'm going to keep hacking away at this.  My next step is to get ext4
supporting .copy_range, probably with a quick hack to copy the
contents of bios.  Hopefully that'll give enough time to also integrate
review feedback.

Thoughts?

- z
