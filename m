Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24339 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1749667Ab2DTUEs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 16:04:48 -0400
Message-ID: <4F91C15B.6070200@redhat.com>
Date: Fri, 20 Apr 2012 15:04:43 -0500
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Fan Yong <yong.fan@whamcloud.com>,
        bfields@redhat.com, Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [PATCH 5 2/4] Return 32/64-bit dir name hash according to usage
 type
References: <20120109132137.2616029.76288.stgit@localhost.localdomain> <20120109132148.2616029.68798.stgit@localhost.localdomain>
In-Reply-To: <20120109132148.2616029.68798.stgit@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/9/12 7:21 AM, Bernd Schubert wrote:
> From: Fan Yong <yong.fan@whamcloud.com>
> 
> Traditionally ext2/3/4 has returned a 32-bit hash value from llseek()
> to appease NFSv2, which can only handle a 32-bit cookie for seekdir()
> and telldir().  However, this causes problems if there are 32-bit hash
> collisions, since the NFSv2 server can get stuck resending the same
> entries from the directory repeatedly.
> 
> Allow ext4 to return a full 64-bit hash (both major and minor) for
> telldir to decrease the chance of hash collisions.  This still needs
> integration on the NFS side.
> 
> Patch-updated-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
> (blame me if something is not correct)

Bernd, I've merged this to ext3.  Bruce thought maybe you were working
on the same.  Should I send mine?

Also...

> +/*
> + * ext4_dir_llseek() based on generic_file_llseek() to handle both
> + * non-htree and htree directories, where the "offset" is in terms
> + * of the filename hash value instead of the byte offset.
> + *
> + * NOTE: offsets obtained *before* ext4_set_inode_flag(dir, EXT4_INODE_INDEX)
> + *       will be invalid once the directory was converted into a dx directory
> + */
> +loff_t ext4_dir_llseek(struct file *file, loff_t offset, int origin)

ext4_llseek() worries about max offset for direct/indirect vs. extent-mapped
files.  Do we need to worry about the same thing in this function?

-Eric
