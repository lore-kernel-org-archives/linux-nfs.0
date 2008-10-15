From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH/RFC]  Make nfs_file_cred more robust.
Date: Wed, 15 Oct 2008 18:44:58 -0400
Message-ID: <1224110698.7371.50.camel@localhost>
References: <18678.28273.285015.747371@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62857 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735AbYJOWpc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 18:45:32 -0400
In-Reply-To: <18678.28273.285015.747371-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-10-16 at 09:28 +1100, Neil Brown wrote:
> Hi Trond,
>  I wonder if you would consider including the following patch which
>  makes nfs_file_cred a little more robust.
> 
>  It isn't strictly needed with current mainline.  However we have a patch
>  set which (among other things) passes a 'struct file' down (via
>  ATTR_FILE) for a chmod call.
>  If chmod is called on e.g. a device special file, this will cause
>  nfs3_proc_setattr to call nfs_file_cred on a 'struct file' which does
>  not have an associated open context or credential.  That goes Oops.
> 
>  Thanks for your consideration,
> NeilBrown

Hi Neil,

Won't this still end up exploding in nfs4_proc_setattr?

Cheers
  Trond

> --------------
> 
> From: NeilBrown <neilb@suse.de>
> 
> As not all files have an associated open_context (e.g. device special
> files), it is safest to test for the existence of the open context
> before de-referencing it.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> 
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 78a5922..63bf8f0 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -372,8 +372,12 @@ static inline struct nfs_open_context *nfs_file_open_context(struct file *filp)
>  
>  static inline struct rpc_cred *nfs_file_cred(struct file *file)
>  {
> -	if (file != NULL)
> -		return nfs_file_open_context(file)->cred;
> +	if (file != NULL) {
> +		struct nfs_open_context *ctx =
> +			nfs_file_open_context(file);
> +		if (ctx)
> +			return ctx->cred;
> +	}
>  	return NULL;
>  }
>  
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
