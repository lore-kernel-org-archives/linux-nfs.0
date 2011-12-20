Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753096Ab1LSUXv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Dec 2011 15:23:51 -0500
Date: Tue, 20 Dec 2011 15:23:40 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Eric Paris <eparis@redhat.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: fix regression in handling of context= option in
 NFSv4
Message-ID: <20111220152340.1781369b@tlielax.poochiereds.net>
In-Reply-To: <1324325585.22363.16.camel@localhost>
References: <1324324223-9933-1-git-send-email-jlayton@redhat.com>
	<1324325585.22363.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 19 Dec 2011 15:13:05 -0500
Eric Paris <eparis@redhat.com> wrote:

> On Mon, 2011-12-19 at 14:50 -0500, Jeff Layton wrote:
> > Setting the security context of a NFSv4 mount via the context= mount
> > option is currently broken. The NFSv4 codepath allocates a parsed
> > options struct, and then parses the mount options to fill it. It
> > eventually calls nfs4_remote_mount which calls security_init_mnt_opts.
> > That clobbers the lsm_opts struct that was populated earlier. This bug
> > also looks like it causes a small memory leak on each v4 mount where
> > context= is used.
> > 
> > Fix this by moving the initialization of the lsm_opts into
> > nfs_alloc_parsed_mount_data, and the freeing of the same into the
> > functions that allocate the nfs_parsed_mount_data.
> 
> I think this is a good lifetime, but I don't think we have it quite
> right.
> 
> > @@ -2222,8 +2223,6 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
> >  	if (data == NULL || mntfh == NULL)
> >  		goto out_free_fh;
> 
> Lets assume we allocated data, but failed on mntfh.  We are going to
> have called security_init_mnt_opts() but never have called the
> corresponding destructor.  True, it'll be fine today with selinux, but I
> make no promises what the future holds...
> 
> I'm pretty sure the v4 code has the same issue.  Maybe you should write
> an explicit nfs_free_parsed_mount_data() function to handle all of the
> error paths in v3 and v4?  Just a suggestion....
> 
> 

That's a reasonable suggestion. I'll respin this with a destructor for
parsed_mount_data structs.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
