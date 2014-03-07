Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f42.google.com ([209.85.220.42]:58577 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbaCGP0I convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2014 10:26:08 -0500
Received: by mail-pa0-f42.google.com with SMTP id fb1so4320867pad.29
        for <linux-nfs@vger.kernel.org>; Fri, 07 Mar 2014 07:26:07 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] NFSv4: Don't retry server trunking discovery on timeouts
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1394204563-1166-2-git-send-email-steved@redhat.com>
Date: Fri, 7 Mar 2014 10:26:04 -0500
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <D80E339C-9F29-4FE5-AF98-D4A469ADEE13@primarydata.com>
References: <1394204563-1166-1-git-send-email-steved@redhat.com> <1394204563-1166-2-git-send-email-steved@redhat.com>
To: Dickson Steve <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 7, 2014, at 10:02, Steve Dickson <steved@redhat.com> wrote:

> To allow background mounts to process into background,
> server trunking discovery needs to return the -ETIMEDOUT
> error to the mount command instead of endless retrying in
> the kernel.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> fs/nfs/nfs4state.c |    1 +
> 1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index e1a4721..be4b33f 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2085,6 +2085,7 @@ again:
> 		break;
> 	case -NFS4ERR_DELAY:
> 	case -ETIMEDOUT:
> +		break;
> 	case -EAGAIN:
> 		ssleep(1);
> 	case -NFS4ERR_STALE_CLIENTID:
> -- 
> 1.7.1
> 

This will cause NFS4ERR_DELAY to interrupt the mount as well. We don’t want that...
_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

