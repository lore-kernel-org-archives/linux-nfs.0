Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4477 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752934Ab1LSUNH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Dec 2011 15:13:07 -0500
Message-ID: <1324325585.22363.16.camel@localhost>
Subject: Re: [PATCH] nfs: fix regression in handling of context= option in
 NFSv4
From: Eric Paris <eparis@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Date: Mon, 19 Dec 2011 15:13:05 -0500
In-Reply-To: <1324324223-9933-1-git-send-email-jlayton@redhat.com>
References: <1324324223-9933-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-12-19 at 14:50 -0500, Jeff Layton wrote:
> Setting the security context of a NFSv4 mount via the context= mount
> option is currently broken. The NFSv4 codepath allocates a parsed
> options struct, and then parses the mount options to fill it. It
> eventually calls nfs4_remote_mount which calls security_init_mnt_opts.
> That clobbers the lsm_opts struct that was populated earlier. This bug
> also looks like it causes a small memory leak on each v4 mount where
> context= is used.
> 
> Fix this by moving the initialization of the lsm_opts into
> nfs_alloc_parsed_mount_data, and the freeing of the same into the
> functions that allocate the nfs_parsed_mount_data.

I think this is a good lifetime, but I don't think we have it quite
right.

> @@ -2222,8 +2223,6 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
>  	if (data == NULL || mntfh == NULL)
>  		goto out_free_fh;

Lets assume we allocated data, but failed on mntfh.  We are going to
have called security_init_mnt_opts() but never have called the
corresponding destructor.  True, it'll be fine today with selinux, but I
make no promises what the future holds...

I'm pretty sure the v4 code has the same issue.  Maybe you should write
an explicit nfs_free_parsed_mount_data() function to handle all of the
error paths in v3 and v4?  Just a suggestion....


