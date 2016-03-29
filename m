Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36088 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbcC2TRK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2016 15:17:10 -0400
Received: by mail-wm0-f41.google.com with SMTP id 127so71429400wmu.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Mar 2016 12:17:09 -0700 (PDT)
Subject: Re: [REGRESSION 4.6-rc1] NFS mounts (using autofs) failing
To: Al Viro <viro@ZenIV.linux.org.uk>
References: <56FA62FB.1080506@broadcom.com>
 <20160329140244.GV17997@ZenIV.linux.org.uk>
Cc: Junichi Nomura <j-nomura@ce.jp.nec.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Arend van Spriel <arend.vanspriel@broadcom.com>
Message-ID: <56FAD4B4.3070508@broadcom.com>
Date: Tue, 29 Mar 2016 21:17:08 +0200
MIME-Version: 1.0
In-Reply-To: <20160329140244.GV17997@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 29-03-16 16:02, Al Viro wrote:
> On Tue, Mar 29, 2016 at 01:11:55PM +0200, Arend Van Spriel wrote:
>> Hi Al,
>>
>> Moved to 4.6-rc1 and found NFS mounts were failing moving to the new
>> kernel. The NFS mounts are done using autofs. Below is the bisect log
>> and attached the kernel .config file. Let me know if you need any other
>> information.
> 
> AFAICS, it's the same one that got reported yesterday by Junichi Nomura.
> Folks, could you check if the delta below fixes it?

Works for me so you may add

Tested-by: Arend van Spriel <arend@broadcom.com>

Regards,
Arend

> diff --git a/fs/namei.c b/fs/namei.c
> index 3498d53..0d80c72 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -1740,15 +1740,17 @@ static int walk_component(struct nameidata *nd, int flags)
>  					  nd->flags);
>  		if (IS_ERR(path.dentry))
>  			return PTR_ERR(path.dentry);
> -		if (unlikely(d_is_negative(path.dentry))) {
> -			dput(path.dentry);
> -			return -ENOENT;
> -		}
> +
>  		path.mnt = nd->path.mnt;
>  		err = follow_managed(&path, nd);
>  		if (unlikely(err < 0))
>  			return err;
>  
> +		if (unlikely(d_is_negative(path.dentry))) {
> +			path_to_nameidata(&path, nd);
> +			return -ENOENT;
> +		}
> +
>  		seq = 0;	/* we are already out of RCU mode */
>  		inode = d_backing_inode(path.dentry);
>  	}
> 
