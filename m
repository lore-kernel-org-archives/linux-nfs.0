Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36317 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755226Ab1C1U75 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Mar 2011 16:59:57 -0400
Message-ID: <4D90F6CB.4060407@netapp.com>
Date: Mon, 28 Mar 2011 16:59:55 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Dan Carpenter <error27@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: smatch stuff: returning signed values in nfs_negotiate_security()
References: <20110328082220.GH1885@bicker>
In-Reply-To: <20110328082220.GH1885@bicker>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/28/2011 04:22 AM, Dan Carpenter wrote:
> Hi Brian,
> 
> 7ebb931598 "NFS: use secinfo when crossing mountpoints" has a signed vs
> unsigned bug.

Thanks for pointing this out.  I'll fix this up.

-Bryan

> 
> fs/nfs/namespace.c +189 nfs_lookup_with_sec(10)
> 	warn: unsigned 'flavor' is never less than zero.
> 
>    161                  page = alloc_page(GFP_KERNEL);
>    162                  if (!page) {
>    163                          status = -ENOMEM;
> 				^^^^^^^^^^^^^^^^
> 	Btw. this gets over written after we goto out.
> 
>    164                          goto out;
>    165                  }
>    166                  flavors = page_address(page);
>    167                  status = secinfo(parent->d_inode, &dentry->d_name, flavors);
>    168                  flavor = nfs_find_best_sec(flavors, dentry->d_inode);
>    169                  put_page(page);
>    170          }
>    171
>    172          return flavor;
>    173
>    174  out:
>    175          status = -ENOMEM;
> 		^^^^^^^^^^^^^^^^
> 	Here.
> 
> More importantly, the caller is expecting an unsigned return value.  The
> check for negative returns in nfs_lookup_with_sec() doesn't work.
> 
>    176          return status;
> 
> regards,
> dan carpenter

