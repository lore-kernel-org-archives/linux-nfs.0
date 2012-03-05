Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:58590 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752797Ab2CEP7n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 10:59:43 -0500
Date: Mon, 5 Mar 2012 10:59:39 -0500
From: "Ted Ts'o" <tytso@mit.edu>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Fan Yong <yong.fan@whamcloud.com>,
        bfields@redhat.com, sandeen@redhat.com,
        Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [PATCH 5 2/4] Return 32/64-bit dir name hash according to
 usage type
Message-ID: <20120305155939.GE21356@thunk.org>
References: <20120109132137.2616029.76288.stgit@localhost.localdomain>
 <20120109132148.2616029.68798.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120109132148.2616029.68798.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 09, 2012 at 02:21:48PM +0100, Bernd Schubert wrote:
> diff --git a/fs/ext4/hash.c b/fs/ext4/hash.c
> index ac8f168..fa8e491 100644
> --- a/fs/ext4/hash.c
> +++ b/fs/ext4/hash.c
> @@ -200,8 +200,8 @@ int ext4fs_dirhash(const char *name, int len, struct dx_hash_info *hinfo)
>  		return -1;
>  	}
>  	hash = hash & ~1;
> -	if (hash == (EXT4_HTREE_EOF << 1))
> -		hash = (EXT4_HTREE_EOF-1) << 1;
> +	if (hash == (EXT4_HTREE_EOF_32BIT << 1))
> +		hash = (EXT4_HTREE_EOF_32BIT - 1) << 1;
>  	hinfo->hash = hash;
>  	hinfo->minor_hash = minor_hash;
>  	return 0;

Is there a reason why we don't need to avoid the collsion with the
64-bit EOF value as well?  i.e., I think we also need to add:

	if (hash == (EXT4_HTREE_EOF_64BIT << 1))
		hash = (EXT4_HTREE_EOF_64BIT - 1) << 1;

		       			       	  - Ted
