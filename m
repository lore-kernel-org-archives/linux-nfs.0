From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] Two minor nfs-utils bug fixes
Date: Tue, 28 Sep 2010 08:08:41 -0400
Message-ID: <4CA1DAC9.4000004@RedHat.com>
References: <20100920153714.2604.50581.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440Ab0I1MIo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 08:08:44 -0400
In-Reply-To: <20100920153714.2604.50581.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/20/2010 11:39 AM, Chuck Lever wrote:
> Hi Steve-
> 
> A couple of minor clean up patches.  I'm still working on the
> "remount" issue.
> 
> ---
> 
> Chuck Lever (2):
>       nfs-utils: Fix source code character encoding
>       libnfs.a: Remove support/nfs/fstab.c
> 
> 
>  support/include/conffile.h |    2 
>  support/nfs/conffile.c     |    2 
>  support/nfs/fstab.c        |  554 --------------------------------------------
>  support/nfs/nfs_mntent.c   |    2 
>  support/nfs/xcommon.c      |    2 
>  utils/mount/fstab.c        |    2 
>  utils/mount/nfsmount.c     |    2 
>  7 files changed, 6 insertions(+), 560 deletions(-)
>  delete mode 100644 support/nfs/fstab.c
> 
Committed...

steved.
