Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:42184 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347Ab2EaO3N convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2012 10:29:13 -0400
Subject: Re: [PATCH] mount.nfs: try the next address after mount fails with ETIMEDOUT
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1338469436-5411-1-git-send-email-jlayton@redhat.com>
Date: Thu, 31 May 2012 10:28:49 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <C16A9517-8334-4B2D-BFB1-D2C02AD66972@oracle.com>
References: <1338469436-5411-1-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 31, 2012, at 9:03 AM, Jeff Layton wrote:

> If a NFS mount attempt fails with an ETIMEDOUT error, the mount.nfs code
> doesn't currently attempt the next address in the list. For a NFSv4 mount
> the initial mount() call almost always ends up going over
> NFS_DEF_FG_TIMEOUT_MINUTES and the mount is never retried.
> 
> For a v3 mount, it ends up continually retrying against the same IPv6
> address, and never tries the IPv4 address. Eventually it gives up once
> it hits the NFS_DEF_FG_TIMEOUT_MINUTES timeout.
> 
> It's possible that a server is just unreachable via IPv6 (due to a
> routing misconfiguration for instance), or is dropping IPv6 frames on
> the floor. In that situation, it might still be reachable via IPv4 and
> trying the next address could have allowed the mount to succeed.
> 
> Fix this by treating ETIMEDOUT in a similar fashion to ECONNREFUSED.
> Have the client try the next address in the list before giving up and
> returning an error.

Bzzzzt.  AF fallback is only legal to do if the admin did not specify a netid.

Can you demonstrate that your patch works correctly if an IPv6 netid is specified?  "Correctly" here means that no fallback occurs.

> Our QA folks noticed this after a routing problem in one of our test
> labs. I was able to reproduce it by having the server drop incoming
> IPv6 frames from the client's address.
> 
> With this patch, the mount eventually succeeds over IPv4 instead of
> returning an error.
> 
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> utils/mount/stropts.c |    2 ++
> 1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index e09aa7c..0aa9a75 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -665,6 +665,7 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
> 		case ECONNREFUSED:
> 		case EOPNOTSUPP:
> 		case EHOSTUNREACH:
> +		case ETIMEDOUT:
> 			continue;
> 		default:
> 			goto out;
> @@ -752,6 +753,7 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
> 		switch (errno) {
> 		case ECONNREFUSED:
> 		case EHOSTUNREACH:
> +		case ETIMEDOUT:
> 			continue;
> 		default:
> 			goto out;
> -- 
> 1.7.1
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




