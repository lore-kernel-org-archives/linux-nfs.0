Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37174 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S944900AbdEZU0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 May 2017 16:26:31 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@poochiereds.net>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org, "Alexander Viro" <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 0/3] Fixups for l_pid
Date: Fri, 26 May 2017 16:26:29 -0400
Message-ID: <256FA719-93CB-44E3-9A12-165237DA0A0F@redhat.com>
In-Reply-To: <cover.1495829587.git.bcodding@redhat.com>
References: <cover.1495829587.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 26 May 2017, at 16:14, Benjamin Coddington wrote:

> LTP fcntl tests (fcntl11 fcntl14 fcntl17 fcntl19 fcntl20 fcntl21) have 
> been
> failing for NFSv4 mounts due to an unexpected l_pid.  What follows are 
> some
> fixups:
>
> Benjamin Coddington (3):
>   fs/locks: Alloc file_lock where practical
>   fs/locks: Set fl_nspid at file_lock allocation
>   fs/locks: Use fs-specific l_pid for remote locks
>
>  fs/locks.c         | 137 
> +++++++++++++++++++++++++++++++++--------------------
>  include/linux/fs.h |   1 +
>  2 files changed, 86 insertions(+), 52 deletions(-)

Ah, Jeff, I just saw your other email asking to add comments documenting 
the behavior for the four cases.  Would you like another patch for 
those, or should I send another version rolling them into one of these?

Ben
