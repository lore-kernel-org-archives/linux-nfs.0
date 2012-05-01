Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17299 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756870Ab2EAPwT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 11:52:19 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q41FqJuU006668
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 1 May 2012 11:52:19 -0400
Date: Tue, 1 May 2012 11:53:22 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/6] nfsd4: preserve __user annotation on cld downcall
 msg
Message-ID: <20120501115322.0f8f45a9@corrin.poochiereds.net>
In-Reply-To: <1335887149-30420-4-git-send-email-bfields@redhat.com>
References: <1335887149-30420-1-git-send-email-bfields@redhat.com>
	<1335887149-30420-4-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue,  1 May 2012 11:45:46 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Cc: Jeff Layton <jlayton@redhat.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4recover.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 2b8e9a9..260d8c8 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -570,7 +570,7 @@ static ssize_t
>  cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
>  {
>  	struct cld_upcall *tmp, *cup;
> -	struct cld_msg *cmsg = (struct cld_msg *)src;
> +	struct cld_msg __user *cmsg = (struct cld_msg __user *)src;
>  	uint32_t xid;
>  	struct nfsd_net *nn = net_generic(filp->f_dentry->d_sb->s_fs_info,
>  						nfsd_net_id);

Good catch...

Reviewed-by: Jeff Layton <jlayton@redhat.com>
