Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f173.google.com ([209.85.214.173]:42944 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400Ab3EWIMZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 May 2013 04:12:25 -0400
Received: by mail-ob0-f173.google.com with SMTP id eh20so3514810obb.4
        for <linux-nfs@vger.kernel.org>; Thu, 23 May 2013 01:12:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CDC2ABAC.3341C%andreas.dilger@intel.com>
References: <CDC2ABAC.3341C%andreas.dilger@intel.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 23 May 2013 16:12:04 +0800
Message-ID: <CA+a=Yy4CQ7zG48dGOVjh8YBv0e+X1Gk4RxpDzdR4vM8JmqossQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: support 64-bit root inode number in NFS FSID
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Yong, Fan" <fan.yong@intel.com>, Steve Dickson <steved@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[nfs-utils patch needs to be sent to Steve Dickson (CC'ed)]

On Thu, May 23, 2013 at 7:06 AM, Dilger, Andreas
<andreas.dilger@intel.com> wrote:
> When exporting a filesystem via NFS, it can generate several kinds
> of NFS filesystem IDs. For most of cases, it uses a 32-bit inode
> number in the NFS FSID, but this does not work on a filesystem
> using a 64-bit root inode number.
>
> In kernel space, NFS can generate/use NFS FSID with a 64-bit inode
> number for the "FSID_UUID16_INUM" type. Unfortunately, while the
> user space nfs-utils decode the 64-bit inode number from the FSID
> correctly, it is truncated when storing it in "struct parsed_fsid".
> Expand the "struct parsed_fsid" inode field to store the full 64-bit
> root inode number.
>
> Intel-bug-id: LU-2904
> Signed-off-by: Fan Yong <fan.yong@intel.com>
> Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
> ---
>  utils/mountd/cache.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 517aa62..a7212e7 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -388,7 +388,7 @@ struct parsed_fsid {
>         int fsidtype;
>         /* We could use a union for this, but it would be more
>          * complicated; why bother? */
> -       unsigned int inode;
> +       unsigned long long inode; /* We need 64-bits ino# */
>         unsigned int minor;
>         unsigned int major;
>         unsigned int fsidnum;
> --1.7.1
>
> Patch is also attached separately, since it will likely be butchered
> by this email client.
>
>
> Cheers, Andreas
> --
> Andreas Dilger
>
> Lustre Software Architect
> Intel High Performance Data Division
>
>
