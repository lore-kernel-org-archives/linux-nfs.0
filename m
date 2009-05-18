From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] Address three recently reported bugs
Date: Mon, 18 May 2009 11:15:59 -0400
Message-ID: <4A117BAF.3030902@RedHat.com>
References: <20090428213453.16098.33168.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42217 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961AbZERPS6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 11:18:58 -0400
In-Reply-To: <20090428213453.16098.33168.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> Some bug fixes for sm-notify and mount.nfs.  Please consider these for
> nfs-utils 1.1.7.
> 
> ---
> 
> Chuck Lever (3):
>       mount: remove legacy version of nfs_name_to_address()
>       sm-notify: Failed DNS lookups should be retried
>       sm-notify: Don't orphan addrinfo structs
> 
> 
>  utils/mount/network.c   |   88 ++++++++++++-----------------------------------
>  utils/mount/network.h   |    3 +-
>  utils/mount/nfsumount.c |    2 +
>  utils/mount/stropts.c   |   16 ++-------
>  utils/statd/sm-notify.c |   73 ++++++++++++++++++++++++++-------------
>  5 files changed, 76 insertions(+), 106 deletions(-)
> 
Committed....

steved.

