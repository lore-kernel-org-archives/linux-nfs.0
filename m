Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:37093 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757483Ab2CETh7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 14:37:59 -0500
Subject: Re: [PATCH 0/1] Normalized path names on umounts (take 2)
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1330976165-19849-1-git-send-email-steved@redhat.com>
Date: Mon, 5 Mar 2012 14:37:54 -0500
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <5C0B4422-2BF3-4534-817C-0480B1A21D34@oracle.com>
References: <1330976165-19849-1-git-send-email-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 5, 2012, at 2:36 PM, Steve Dickson wrote:

> There is a second attempted at making paths in the
> device names that have multiple slashes or no slash
> at all unmount-able, without breaking any APIs.
> 
> Due to the way entries are written to both the /etc/mtab
> and /proc/mounts, multiple slash have to be stripped and
> leading slash have to be added (when they don't exist) 
> on v4 mounts.

I thought a pathname without a leading slash was allowed for NFSv4, for mounting OSD devices?  Not really sure.

> With v3 mounts this normalization can 
> not occur since those entries are always in the same format.
> 
> Finally, this normalization only needs to happen
> when the mtab and /proc/mounts are not the same file.
> 
> Steve Dickson (1):
>  umount.nfs: normalize path names during umounts.
> 
> utils/mount/nfsumount.c |   64 +++++++++++++++++++++++++++++++++++++++++++++-
> 1 files changed, 62 insertions(+), 2 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




