Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:45907 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab1KHEBU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 23:01:20 -0500
Subject: Re: [PATCH] mount.nfs: ensure AF priority when mounting
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAO_0yfP8XRH0+Gdn43QSncUFFPPmwbsxx2ZFdPpFTjKAQeuyAw@mail.gmail.com>
Date: Mon, 7 Nov 2011 23:01:09 -0500
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, steved@redhat.com, jlayton@redhat.com
Message-Id: <1617B125-3EFF-42EB-8F1B-A1D57E6ADC12@oracle.com>
References: <CAO_0yfP8XRH0+Gdn43QSncUFFPPmwbsxx2ZFdPpFTjKAQeuyAw@mail.gmail.com>
To: Hamo <hamo.by@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 7, 2011, at 10:14 PM, Hamo wrote:

> On different architectures, getaddrinfo() may return different
> orders of address families. This may confuse the users.
> This patch fixes this problem by ensuring that we first try
> through IPv6(if present), then through IPv4.
> Bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=750729

By the way, this bug isn't public (I can't access it, anyway).  If RH can't make it public, perhaps a copy of the relevant parts of the bug can be created in bugzilla.linux-nfs.org?  Otherwise, it's hard to tell what you are trying to fix so we can do a thorough patch review.

(Also, I'm not sure why you copied lkml and linux-fsdevel on this NFS-specific user space patch).

> Signed-off-by: Yang Bai <hamo.by@gmail.com>
> ---
> utils/mount/stropts.c |   41 +++++++++++++++++++++++++++++++++++++++++
> 1 files changed, 41 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 4032bf3..aa5ee86 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -654,7 +654,28 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
> 	struct addrinfo *ai;
> 	int ret = 0;
> 
> +	/* first, try IPv6 */
> 	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
> +		if (ai->ai_family != AF_INET6)
> +			continue;
> +		ret = nfs_do_mount_v3v2(mi, ai->ai_addr, ai->ai_addrlen);
> +		if (ret != 0)
> +			return ret;
> +
> +		switch (errno) {
> +		case ECONNREFUSED:
> +		case EOPNOTSUPP:
> +		case EHOSTUNREACH:
> +			continue;
> +		default:
> +			goto out;
> +		}
> +	}
> +
> +	/* then, try IPv4 */
> +	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
> +		if (ai->ai_family != AF_INET)
> +			continue;
> 		ret = nfs_do_mount_v3v2(mi, ai->ai_addr, ai->ai_addrlen);
> 		if (ret != 0)
> 			return ret;
> @@ -742,7 +763,27 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
> 	struct addrinfo *ai;
> 	int ret = 0;
> 
> +	/* first, try IPv6 */
> 	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
> +		if (ai->ai_family != AF_INET6)
> +			continue;
> +		ret = nfs_do_mount_v4(mi, ai->ai_addr, ai->ai_addrlen);
> +		if (ret != 0)
> +			return ret;
> +
> +		switch (errno) {
> +		case ECONNREFUSED:
> +		case EHOSTUNREACH:
> +			continue;
> +		default:
> +			goto out;
> +		}
> +	}
> +
> +	/* then, try IPv4 */
> +	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
> +		if (ai->ai_family != AF_INET)
> +			continue;
> 		ret = nfs_do_mount_v4(mi, ai->ai_addr, ai->ai_addrlen);
> 		if (ret != 0)
> 			return ret;
> -- 
> 1.7.1

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




