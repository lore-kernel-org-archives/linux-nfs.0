Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690Ab3A2W3q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2013 17:29:46 -0500
Date: Tue, 29 Jan 2013 17:29:45 -0500
From: bfields <bfields@fieldses.org>
To: majianpeng <majianpeng@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfsd: Fix memleak.
Message-ID: <20130129222945.GB6219@fieldses.org>
References: <201301291315544246751@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201301291315544246751@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 29, 2013 at 01:16:01PM +0800, majianpeng wrote:
> In func svc_export_parse,the uuid which used kmemdup to alloc will be
> changed in func export_update.So the later kfree don't free this memory.
> And it can't be free in func svc_export_parse because other place still
> used.So put this operation in func svc_export_put.

Applying, thanks.--b.

> 
> Signed-off-by: Jianpeng Ma <majianpeng@gmail.com>
> ---
>  fs/nfsd/export.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index a3946cf..45159ee 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -315,6 +315,7 @@ static void svc_export_put(struct kref *ref)
>  	path_put(&exp->ex_path);
>  	auth_domain_put(exp->ex_client);
>  	nfsd4_fslocs_free(&exp->ex_fslocs);
> +	kfree(exp->ex_uuid);
>  	kfree(exp);
>  }
>  
> -- 
> 1.7.9.5
