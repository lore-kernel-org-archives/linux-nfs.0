Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36540 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755449AbdE0KLO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 06:11:14 -0400
Received: by mail-qk0-f193.google.com with SMTP id y128so3831257qka.3
        for <linux-nfs@vger.kernel.org>; Sat, 27 May 2017 03:11:14 -0700 (PDT)
Message-ID: <1495879871.2881.6.camel@poochiereds.net>
Subject: Re: [PATCH 0/3] Fixups for l_pid
From: Jeff Layton <jlayton@poochiereds.net>
To: Benjamin Coddington <bcodding@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>, bfields@fieldses.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 27 May 2017 06:11:11 -0400
In-Reply-To: <cover.1495829587.git.bcodding@redhat.com>
References: <cover.1495829587.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-26 at 16:14 -0400, Benjamin Coddington wrote:
> LTP fcntl tests (fcntl11 fcntl14 fcntl17 fcntl19 fcntl20 fcntl21) have been
> failing for NFSv4 mounts due to an unexpected l_pid.  What follows are some
> fixups:
> 
> Benjamin Coddington (3):
>   fs/locks: Alloc file_lock where practical
>   fs/locks: Set fl_nspid at file_lock allocation
>   fs/locks: Use fs-specific l_pid for remote locks
> 
>  fs/locks.c         | 137 +++++++++++++++++++++++++++++++++--------------------
>  include/linux/fs.h |   1 +
>  2 files changed, 86 insertions(+), 52 deletions(-)
> 

Thanks Ben. These all look fine to me.

Could you rebase them on top of current linux-next? Christoph sent some
patches last week that are generating conflicts here and this doesn't
quite merge in correctly.

Thanks,
-- 
Jeff Layton <jlayton@poochiereds.net>
