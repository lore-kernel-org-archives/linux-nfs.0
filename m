Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:36171 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934Ab2LACjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2012 21:39:17 -0500
Date: Fri, 30 Nov 2012 18:18:17 -0800
From: Simon Kirby <sim@hostway.ca>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Patrick McLean <patrick@cim.mcgill.ca>,
        Patrick McLean <patrickm@gaikai.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Regression with initramfs and nfsroot (appears to be in the
 dcache)
Message-ID: <20121201021817.GA11921@hostway.ca>
References: <CAE2NFgWCnmgSCsw7MzRkqBLTHgRDG-FvKKcbTHN6UqePK6Ef+Q@mail.gmail.com>
 <20121129222109.GW4939@ZenIV.linux.org.uk>
 <50B7E759.9070007@gaikai.com>
 <20121129234326.GX4939@ZenIV.linux.org.uk>
 <50B7FBA7.2030300@gaikai.com>
 <20121130003502.GY4939@ZenIV.linux.org.uk>
 <50B8046F.7030308@cim.mcgill.ca>
 <20121130013628.GZ4939@ZenIV.linux.org.uk>
 <50B811BA.6070503@cim.mcgill.ca>
 <20121130020047.GA4939@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121130020047.GA4939@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 30, 2012 at 02:00:48AM +0000, Al Viro wrote:

> OK, that settles it.  WARN_ON() and printks in the area can be dropped;
> the right fix is below.  However, there's a similar place in cifs that
> also needs to be dealt with and I really, really wonder why the hell do
> we do d_drop() in nfs_revalidate_lookup().  It's not relevant in this
> bug, but I would like to understand what's wrong with simply returning
> 0 from ->d_revalidate() and letting the caller (in fs/namei.c) take care
> of unhashing, etc. itself.  Would make have_submounts() in there pointless
> as well - we could just return 0 and let d_invalidate() take care of the
> checks...  Trond?
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -450,7 +450,8 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
>  			nfs_refresh_inode(dentry->d_inode, entry->fattr);
>  			goto out;
>  		} else {
> -			d_drop(dentry);
> +			if (d_invalidate(dentry) != 0)
> +				goto out;
>  			dput(dentry);
>  		}
>  	}

Hello,

With your previous patch (with the WARN_ON), I hit the WARN_ON() in the
test case described here: https://patchwork.kernel.org/patch/1446851/ .
The __d_move()ing mountpoint case no longer hits, and there is no longer
an EBUSY, so this seems to work for me (in 3.6, where it broke).

Simon-
