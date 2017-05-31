Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:36842 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdEaRQ4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 May 2017 13:16:56 -0400
Received: by mail-qt0-f171.google.com with SMTP id f55so17434917qta.3
        for <linux-nfs@vger.kernel.org>; Wed, 31 May 2017 10:16:55 -0700 (PDT)
Message-ID: <1496251011.2984.2.camel@redhat.com>
Subject: Re: [PATCH v2 0/3] Fixups for l_pid
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>, bfields@fieldses.org
Cc: Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 31 May 2017 13:16:51 -0400
In-Reply-To: <cover.1496161312.git.bcodding@redhat.com>
References: <cover.1496161312.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-05-30 at 12:31 -0400, Benjamin Coddington wrote:
> LTP fcntl tests (fcntl11 fcntl14 fcntl17 fcntl19 fcntl20 fcntl21) have been
> failing for NFSv4 mounts due to an unexpected l_pid.  What follows are some
> fixups:
> 
> on v2:
> 	- Rebase onto linux-next
> 	- Revert back to using the stack in locks_mandatory_area(), and fixup
> 	patch description for 1/3
> 	- Add a comment to 3/3 explaining the seemingly-redundant fl_pid and
> 	fl_nspid
> 
> These three patches can be pulled from the branch named "fixups_for_l_pid"
> here: git://bcodding.com/~bcodding/linux
> 
> Benjamin Coddington (3):
>   fs/locks: Use allocation rather than the stack in fcntl_getlk()
>   fs/locks: Set fl_nspid at file_lock allocation
>   fs/locks: Use fs-specific l_pid for remote locks
> 
>  fs/locks.c         | 100 ++++++++++++++++++++++++++++++++++-------------------
>  include/linux/fs.h |   7 ++++
>  2 files changed, 72 insertions(+), 35 deletions(-)
> 

This all looks good to me. Nice work!

I've gone ahead and merged it into my linux-next branch, and it should
make v4.13 (barring any problems).

Thanks!
-- 
Jeff Layton <jlayton@redhat.com>
