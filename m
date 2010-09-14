From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/2] Two more fixes for mount.nfs
Date: Tue, 14 Sep 2010 15:49:57 -0400
Message-ID: <20100914154957.1986f449@tlielax.poochiereds.net>
References: <20100913171100.18926.77712.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59464 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753599Ab0INTuC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Sep 2010 15:50:02 -0400
In-Reply-To: <20100913171100.18926.77712.stgit-x+BlCsqV7M/wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 13 Sep 2010 13:17:25 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Here are a couple of bug fixes for mount.nfs.
> 
> The second patch in this series makes remount work again, but there is
> a lingering problem with it (and maybe some other corner cases, not
> related to "remount"). 
> 
> It turns out that "remount" mounts (even legacy remount, AFAICT) have
> always completely wiped the mount options in /etc/mtab, and replaced
> them with "remount,foo".  This breaks umount.nfs, which relies on
> the contents of /etc/mtab to know how to perform the unmount request.
> 
> I'm working on a solution, but it will still be some time.  I felt
> that the remount fix here was important enough to send now.
> 
> ---
> 
> Chuck Lever (2):
>       mount.nfs: Don't do anything fancy if this is a remount
>       mount.nfs: Refactor mount version and protocol autonegotiation
> 
> 
>  utils/mount/stropts.c |   95 ++++++++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 81 insertions(+), 14 deletions(-)
> 

Looks good. Ack on the set...

-- 
Jeff Layton <jlayton@redhat.com>
