From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Replace NFS4ERR_NOTEMPY with NFS4ERR_EXIST
Date: Wed, 11 Mar 2009 19:46:13 -0400
Message-ID: <20090311234613.GA21273@fieldses.org>
References: <49B622D1.6060602@cn.fujitsu.com> <49B62357.3080604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ni Wenjuan <niwj@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42049 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbZCKXqP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 19:46:15 -0400
In-Reply-To: <49B62357.3080604@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 10, 2009 at 04:22:47PM +0800, Yang Hongyang wrote:
> Ni Wenjuan wrote:
> > Fix a test in rename operation. rename dir1 into existing,nonempty dir2 should
> > return  NFS4ERR_EXIST instead got NFS4ERR_NOTEMPY. RFC says if the target is a
> > directory but not empty, the server will return the error, NFS4ERR_EXIST.
> > 
> 
> SOF && please use git to generate patch.

Also, when you resend--could send any server patches to me (in addition
to the linux-nfs list)?  

The content of the patch looks ok, thanks.

--b.

> 
> > ------
> > fs/nfsd/nfs4proc.c | 2 +-
> > 1 files changed, 1 insertion(+) ,1 deletion (-)
> > 
> > diff -Nurp fs/nfsd/nfs4proc_orig.c fs/nfsd/nfs4proc.c
> > --- fs/nfsd/nfs4proc_orig.c	2009-02-23 20:28:56.000000000 +0800
> > +++ fs/nfsd/nfs4proc.c	2009-03-05 16:56:56.000000000 +0800
> > 
> > @@ -585,10 +586,11 @@ nfsd4_rename(struct svc_rqst *rqstp, str
> >    	status = nfsd_rename(rqstp, save_fh, rename->rn_sname,
> >   			     rename->rn_snamelen, current_fh,
> >   			     rename->rn_tname, rename->rn_tnamelen);
> > 
> >   	/* the underlying filesystem returns different error's than required
> >   	 * by NFSv4. both save_fh and current_fh have been verified.. */
> >     -	if (status == nfserr_isdir)
> >     +	if (status == nfserr_isdir || status == nfserr_notempty)
> >   		status = nfserr_exist;
> >   	else if ((status == nfserr_notdir) &&
> >                     (S_ISDIR(save_fh->fh_dentry->d_inode->i_mode) &&
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> 
> 
> -- 
> Regards
> Yang Hongyang
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
