Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49452 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755707Ab2C1OTP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 10:19:15 -0400
Date: Wed, 28 Mar 2012 10:19:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfsd4: memory corruption in numeric_name_to_id()
Message-ID: <20120328141914.GB7779@fieldses.org>
References: <20120328104459.GA29022@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120328104459.GA29022@elgon.mountain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2012 at 01:44:59PM +0300, Dan Carpenter wrote:
> "id" is type is a uid_t (32 bits) but on 64 bit systems strict_strtoul()
> modifies 64 bits of data.  We should use kstrtouint() instead.

Whoops--thanks, applied!

--b.

> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
> index 69ca9c5..322d11c 100644
> --- a/fs/nfsd/nfs4idmap.c
> +++ b/fs/nfsd/nfs4idmap.c
> @@ -581,7 +581,7 @@ numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namel
>  	/* Just to make sure it's null-terminated: */
>  	memcpy(buf, name, namelen);
>  	buf[namelen] = '\0';
> -	ret = strict_strtoul(name, 10, (unsigned long *)id);
> +	ret = kstrtouint(name, 10, id);
>  	return ret == 0;
>  }
>  
