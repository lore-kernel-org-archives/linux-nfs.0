Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:45047 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905Ab0HATco (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Aug 2010 15:32:44 -0400
Date: Sun, 1 Aug 2010 21:32:05 +0200
From: Ingo Molnar <mingo@elte.hu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] NFS: Fix a typo in include/linux/nfs_fs.h
Message-ID: <20100801193205.GA22050@elte.hu>
References: <1280684100.4430.8.camel@heimdal.trondhjem.org>
 <1280684440-5763-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1280684440-5763-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


* Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> nfs_commit_inode() needs to be defined irrespectively of whether or not
> we are supporting NFSv3 and NFSv4.
> Allow the compiler to optimise away code in the NFSv2-only case by
> converting it into an inlined stub function.
> 
> Reported-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/write.c         |    5 -----
>  include/linux/nfs_fs.h |    6 ++++++
>  2 files changed, 6 insertions(+), 5 deletions(-)

I tested this patch too and it solves the problem (and doesnt introduce new 
problems).

Thanks,

	Ingo
