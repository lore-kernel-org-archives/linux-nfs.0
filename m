From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] Two more fixes for mount.nfs
Date: Thu, 16 Sep 2010 08:00:52 -0400
Message-ID: <4C9206F4.8080106@RedHat.com>
References: <20100913171100.18926.77712.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753856Ab0IPMA5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 08:00:57 -0400
In-Reply-To: <20100913171100.18926.77712.stgit-x+BlCsqV7M/wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/13/2010 01:17 PM, Chuck Lever wrote:
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
Both Committed...

steved.
