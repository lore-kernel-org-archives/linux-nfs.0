Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:42320 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbbGAFUJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jul 2015 01:20:09 -0400
Date: Wed, 1 Jul 2015 06:20:07 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/8] nfs: Use remove_proc_subtree() instead
 remove_proc_entry()
Message-ID: <20150701052007.GA17109@ZenIV.linux.org.uk>
References: <5593648D.7020804@gmail.com>
 <559364E9.1070808@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <559364E9.1070808@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 01, 2015 at 11:56:25AM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfs/client.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index a13fada..52488ec 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1447,13 +1447,11 @@ int __init nfs_fs_proc_init(void)
>  	/* a file of volumes that we have mounted */
>  	p = proc_symlink("volumes", proc_fs_nfs, "../../net/nfsfs/volumes");

Why not make that
	if (!proc_symlink("fs/nfs/volumes", NULL, "../../net/nfsfs/volumes"))
instead, and kill proc_fs_nfs completely?
