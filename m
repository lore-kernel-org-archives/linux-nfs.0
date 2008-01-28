From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 003/100] Fix incorrect assignment
Date: Mon, 28 Jan 2008 12:40:33 -0500
Message-ID: <6BE49033-E0B1-48CF-866C-030F5E28B10D@oracle.com>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu> <1201303040-7779-2-git-send-email-bfields@citi.umich.edu> <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org, Prasad P <pvp@us.ibm.com>,
	Steve French <smfltc@us.ibm.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:19059 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbYA1R7U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 12:59:20 -0500
In-Reply-To: <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 25, 2008, at 6:15 PM, J. Bruce Fields wrote:
> From: Prasad P <pvp@us.ibm.com>
>
> Dereferenced pointer "dentry" without checking and assigned to inode
> in the declaration.
>
> (We could just delete the NULL checks that follow instead, as we never
> get to the encode function in this particular case.  But it takes a
> little detective work to verify that fact, so it's probably safer to
> leave the checks in place.)

I think adding a comment to this effect before the "dentry == NULL"  
check would be beneficial.

> Cc: Steve French <smfltc@us.ibm.com>
> Signed-off-by: Prasad V Potluri <pvp@us.ibm.com>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs2acl.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
> index 0e5fa11..d5fca59 100644
> --- a/fs/nfsd/nfs2acl.c
> +++ b/fs/nfsd/nfs2acl.c
> @@ -221,7 +221,7 @@ static int nfsaclsvc_encode_getaclres(struct  
> svc_rqst *rqstp, __be32 *p,
>  		struct nfsd3_getaclres *resp)
>  {
>  	struct dentry *dentry = resp->fh.fh_dentry;
> -	struct inode *inode = dentry->d_inode;
> +	struct inode *inode;
>  	struct kvec *head = rqstp->rq_res.head;
>  	unsigned int base;
>  	int n;
> -- 
> 1.5.4.rc2.60.gb2e62
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux- 
> nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



