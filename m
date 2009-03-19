From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] NFSD: do not return nfserr_symlink for the LINK operation
Date: Thu, 19 Mar 2009 14:59:39 +0800
Message-ID: <49C1ED5B.6040000@cn.fujitsu.com>
References: <49AF9C28.8030603@cn.fujitsu.com> <49AFA4E4.50207@panasas.com> <20090306213234.GB1779@fieldses.org> <49B2C404.3060907@panasas.com> <20090309180643.GB9408@fieldses.org> <49BA15B3.2040904@cn.fujitsu.com> <20090318230621.GK18894@fieldses.org> <49C1EB55.8060700@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Ni Wenjuan <niwj@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50997 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753081AbZCSHAd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2009 03:00:33 -0400
In-Reply-To: <49C1EB55.8060700@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny Halevy wrote:
> As reported by Ni Wenjuan <niwj@cn.fujitsu.com> on 2009-03-05:
>> the result of newpynfs test case of  LINK4a .  if you link with target directoty
>> is a symbole file,it should get NFS4ERR_NOTDIR ,instead got NFS4ERR_SYMLINK.
> 
> THE LINK operation doesn't list NFS4ERR_SYMLINK as a valid error in the spec.
> Although NFS4ERR_SYMLINK seems like a reasonable error and even though
> it was added for LINK in NFSv4.1 we should still return NFSERR_NOTDIR for
> nfsv[234].

HI,Benny:
There are other places that have the same problem,i'm preparing a all-in-one
patch.^!^

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/vfs.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 6e50aaa..9165b1f 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1637,6 +1637,9 @@ out_dput:
>  out_unlock:
>  	fh_unlock(ffhp);
>  out:
> +	/* nfserr_symlink returned from fh_verify is inappropriate for LINK */
> +	if (err == nfserr_symlink)
> +		err = nfserr_notdir;
>  	return err;
>  
>  out_nfserr:
> 
> 


-- 
Regards
Yang Hongyang
