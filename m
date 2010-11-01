From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/6] More fix-ups for nfs-utils-1.2.4
Date: Mon, 01 Nov 2010 08:13:26 -0400
Message-ID: <4CCEAEE6.8030609@RedHat.com>
References: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755651Ab0KAMN3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Nov 2010 08:13:29 -0400
In-Reply-To: <20101026155216.19184.36979.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/26/2010 11:57 AM, Chuck Lever wrote:
> Hi Steve-
> 
> Here are rather more final versions of the patches I posted here last
> week for review.  There are a couple of extra clean-ups here as well.
> I think these are ready to be considered for nfs-utils 1.2.4.
> 
> ---
> 
> Chuck Lever (6):
>       nfs(5): Document remount behavior
>       nfs(5): Grammar and style fixes
>       mount.nfs: mnt_freq and mnt_pass are always zero
>       mount.nfs: Fix memory leak in nfs_sys_mount()
>       mount: Fix compiler warning in nfs_parse_retry_option()
>       nfs-utils: Remove all uses of AI_ADDRCONFIG
The last five were committed..

steved.
> 
> 
>  support/export/hostname.c     |    6 --
>  tests/nsm_client/nsm_client.c |    2 -
>  utils/mount/mount.c           |   34 +++++++------
>  utils/mount/network.c         |    3 -
>  utils/mount/nfs.man           |  107 ++++++++++++++++++++++++++++++++---------
>  utils/mount/stropts.c         |   20 ++++----
>  utils/statd/hostname.c        |    4 --
>  utils/statd/sm-notify.c       |    5 --
>  8 files changed, 114 insertions(+), 67 deletions(-)
> 
