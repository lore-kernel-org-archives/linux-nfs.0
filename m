Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:59828 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336Ab1AZPgr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jan 2011 10:36:47 -0500
Subject: Re: [PATCH] Fixed segfault in rpc.mountd
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1296046655-20246-1-git-send-email-steved@redhat.com>
Date: Wed, 26 Jan 2011 10:35:57 -0500
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <C6DF5374-6E97-459B-BED1-B044B456AAFE@oracle.com>
References: <1296046655-20246-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 26, 2011, at 7:57 AM, Steve Dickson wrote:

> A unallocated piece of memory, instead of a NULL point, was being
> used to initialize a ->next point in the mount link list which
> caused a segfault after a few remote accesses via the showmount
> command.

I thought there was a patch on the list just like this last week... in any event:

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> utils/mountd/rmtab.c |    1 +
> 1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
> index d339296..527377f 100644
> --- a/utils/mountd/rmtab.c
> +++ b/utils/mountd/rmtab.c
> @@ -205,6 +205,7 @@ mountlist_list(void)
> 	}
> 	if (stb.st_mtime != last_mtime) {
> 		mountlist_freeall(mlist);
> +		mlist = NULL;
> 		last_mtime = stb.st_mtime;
> 
> 		setrmtabent("r");

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




