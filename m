Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753195Ab2DWWX1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 18:23:27 -0400
Message-ID: <4F95D65A.8070608@redhat.com>
Date: Mon, 23 Apr 2012 17:23:22 -0500
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Fan Yong <yong.fan@whamcloud.com>,
        bfields@redhat.com, Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [PATCH 5 2/4] Return 32/64-bit dir name hash according to usage
 type
References: <20120109132137.2616029.76288.stgit@localhost.localdomain> <20120109132148.2616029.68798.stgit@localhost.localdomain> <4F91C15B.6070200@redhat.com> <4F93FED6.6090505@itwm.fraunhofer.de> <4F95BD72.6090200@redhat.com> <4F95C109.1030401@itwm.fraunhofer.de>
In-Reply-To: <4F95C109.1030401@itwm.fraunhofer.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/23/12 3:52 PM, Bernd Schubert wrote:
> On 04/23/2012 10:37 PM, Eric Sandeen wrote:

...

> diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
> index b867862..3a4988e2 100644
> --- a/fs/ext4/dir.c
> +++ b/fs/ext4/dir.c
> @@ -363,7 +363,7 @@ loff_t ext4_dir_llseek(struct file *file, loff_t
> offset, int origin)
>  		goto out_err;
> 
>  	if (!dx_dir) {
> -		if (offset > inode->i_sb->s_maxbytes)
> +		if (offset > i_size_read(inode))
>  			goto out_err;
>  	} else if (offset > ext4_get_htree_eof(file))
>  		goto out_err;

I'm curious about the above as well as:

        case SEEK_END:
                if (unlikely(offset > 0))
                        goto out_err; /* not supported for directories */

The previous .llseek handler, and the generic handler for other filesystems, allow seeking past the end of the dir AFAICT.  (not sure why you'd want to, but I don't see that you'd get an error back).

Is there a reason to uniquely exclude it in ext4?  Does that line up with POSIX?

-Eric

