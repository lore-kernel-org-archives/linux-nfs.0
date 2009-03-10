From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] Replace NFS4ERR_NOTEMPY with NFS4ERR_EXIST
Date: Tue, 10 Mar 2009 16:22:47 +0800
Message-ID: <49B62357.3080604@cn.fujitsu.com>
References: <49B622D1.6060602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Cc: linux-nfs@vger.kernel.org
To: Ni Wenjuan <niwj@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52320 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753096AbZCJIXz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Mar 2009 04:23:55 -0400
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id 0682317012F
	for <linux-nfs@vger.kernel.org>; Tue, 10 Mar 2009 16:46:15 +0800 (CST)
Received: from fnst.cn.fujitsu.com (localhost.localdomain [127.0.0.1])
	by tang.cn.fujitsu.com (8.13.1/8.13.1) with ESMTP id n2A8OsPT026835
	for <linux-nfs@vger.kernel.org>; Tue, 10 Mar 2009 16:24:54 +0800
In-Reply-To: <49B622D1.6060602@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ni Wenjuan wrote:
> Fix a test in rename operation. rename dir1 into existing,nonempty dir2 should
> return  NFS4ERR_EXIST instead got NFS4ERR_NOTEMPY. RFC says if the target is a
> directory but not empty, the server will return the error, NFS4ERR_EXIST.
> 

SOF && please use git to generate patch.

> ------
> fs/nfsd/nfs4proc.c | 2 +-
> 1 files changed, 1 insertion(+) ,1 deletion (-)
> 
> diff -Nurp fs/nfsd/nfs4proc_orig.c fs/nfsd/nfs4proc.c
> --- fs/nfsd/nfs4proc_orig.c	2009-02-23 20:28:56.000000000 +0800
> +++ fs/nfsd/nfs4proc.c	2009-03-05 16:56:56.000000000 +0800
> 
> @@ -585,10 +586,11 @@ nfsd4_rename(struct svc_rqst *rqstp, str
>    	status = nfsd_rename(rqstp, save_fh, rename->rn_sname,
>   			     rename->rn_snamelen, current_fh,
>   			     rename->rn_tname, rename->rn_tnamelen);
> 
>   	/* the underlying filesystem returns different error's than required
>   	 * by NFSv4. both save_fh and current_fh have been verified.. */
>     -	if (status == nfserr_isdir)
>     +	if (status == nfserr_isdir || status == nfserr_notempty)
>   		status = nfserr_exist;
>   	else if ((status == nfserr_notdir) &&
>                     (S_ISDIR(save_fh->fh_dentry->d_inode->i_mode) &&
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


-- 
Regards
Yang Hongyang
