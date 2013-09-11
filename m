Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755433Ab3IKRIN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Sep 2013 13:08:13 -0400
From: Zach Brown <zab@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: [RFC] extending splice for copy offloading
Date: Wed, 11 Sep 2013 10:06:47 -0700
Message-Id: <1378919210-10372-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When I first started on this stuff I followed the lead of previous
work and added a new syscall for the copy operation:

https://lkml.org/lkml/2013/5/14/618

Towards the end of that thread Eric Wong asked why we didn't just
extend splice.  I immediately replied with some dumb dismissive
answer.  Once I sat down and looked at it, though, it does make a
lot of sense.  So good job, Eric.  +10 Dummie points for me.

Extending splice avoids all the noise of adding a new syscall and
naturally falls back to buffered copying as that's what the direct
splice path does for sendfile() today.

So that's what this patch series demonstrates.  It adds a flag that
lets splice get at the same direct splicing that sendfile() does.
We then add a file system file_operations method to accelerate the
copy which has access to both files.

Some things to talk about:
- I really don't care about the naming here.  If you do, holler.
- We might want different flags for file-to-file splicing and acceleration
- We might want flags to require or forbid acceleration
- We might want to provide all these flags to sendfile, too

Thoughts?  Objections?

Bryan, do you see any problems with wiring the NFS COPY RPC under this?

Martin, are we any closer to getting blk_() calls to kick off XCOPY
bios?

OCFS2 friends, is it a managable amount of work to implement an
ocfs2_splice_direct() that only modifies a region of the destination
file?

Finally, there's a slot in the plumbers schedule next week to talk
about this stuff. Come say hi if you're interested.

-z

