Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:46220 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbbBLWFB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2015 17:05:01 -0500
MIME-Version: 1.0
In-Reply-To: <20150212203832.GA24835@kernel.dk>
References: <20150212203832.GA24835@kernel.dk>
Date: Thu, 12 Feb 2015 14:05:00 -0800
Message-ID: <CA+55aFxnisiCLB0pHWU7dmzXWBG16gPB9cEycGRUgB+RcbJGnA@mail.gmail.com>
Subject: Re: [GIT PULL] Backing device changes for 3.20
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Jens Axboe <axboe@fb.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 12, 2015 at 12:38 PM, Jens Axboe <axboe@fb.com> wrote:
>
> This pull request contains a cleanup of how the backing device is
> handled, in preparation for a rework of the life time rules. In this
> part, the most important change is to split the unrelated nommu mmap
> flags from it, but also removing a backing_dev_info pointer from the
> address_space (and inode), and a cleanup of other various minor bits.

Ugh, so this has a semantic conflict with the NFS client, that has
this particular code:

        if (!cinfo->dreq) {
                inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-               inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
+
inc_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
                             BDI_RECLAIMABLE);
                __mark_inode_dirty(req->wb_context->dentry->d_inode,
                                   I_DIRTY_DATASYNC);
        }

duplicated several times, and now one more time in the new
fs/nfs/flexfilelayout/flexfilelayout.c file.

I fixed it the same way it was fixed everywhere else, but while fixing
and looking at the cases, I *really* feel like the nfs code needs some
cleaning up.

That insane complicated and unexplained code exists three times: in
filelayout/filelayout.c, flexfilelayout/flexfilelayout.c and in
write.c.

The "reverse" case (which does the decrements, and doesn't mark the
inode dirty) exists a few more times.

Could we make that a helper function, with a few comments. For
example, looking at it, I wonder if

 - page_file_mapping(req->wb_page)->host
 - req->wb_context->dentry->d_inode

are the same inode?

Hmm?

                          Linus
