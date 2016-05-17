Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48554 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317AbcEQPAR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2016 11:00:17 -0400
Date: Tue, 17 May 2016 16:59:47 +0200
From: David Sterba <dsterba@suse.cz>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fs: Add MODULE_SOFTDEP declarations for hard-coded
 crypto drivers
Message-ID: <20160517145947.GT511@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <20160517133631.GF7555@decadent.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160517133631.GF7555@decadent.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 17, 2016 at 02:36:31PM +0100, Ben Hutchings wrote:
> This helps initramfs builders and other tools to find the full
> dependencies of a module.
> 
> References: https://bugs.debian.org/819725
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> --- a/fs/btrfs/super.c
> +++ b/fs/btrfs/super.c
> @@ -2456,3 +2456,4 @@ late_initcall(init_btrfs_fs);
>  module_exit(exit_btrfs_fs)
>  
>  MODULE_LICENSE("GPL");
> +MODULE_SOFTDEP("pre: crypto-crc32c");

Acked-by: David Sterba <dsterba@suse.com>
