Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38945 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758AbbDUU0s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Apr 2015 16:26:48 -0400
Date: Tue, 21 Apr 2015 16:26:47 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <Anna.Schumaker@Netapp.com>,
        stable@vger.kernel.org
Subject: Re: [PATCH 2/3] nfsd4: disallow SEEK with special stateids
Message-ID: <20150421202647.GC13782@fieldses.org>
References: <1429647735-15512-1-git-send-email-bfields@redhat.com>
 <1429647735-15512-3-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1429647735-15512-3-git-send-email-bfields@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 21, 2015 at 04:22:14PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> If the client uses a special stateid then we'll pass a NULL file to
> vfs_llseek.

By the way, Christoph has also pointed out that it's probably worth
fixing nfsd4_preprocess_stateid_op() to do a temporary open itself in
the special stateid case.

If we wanted to get nfsd4_preprocess_stateid_op() to the point where it
also returned a file (if requested) on success, then there'd also be the
possible NULL returns from find_{read|write}able_file() to handle.

I haven't figured that out yet.

--b.

> 
> Fixes: 24bab491220f " NFSD: Implement SEEK"
> Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>
> Cc: stable@vger.kernel.org
> Reported-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4proc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index d0848fc6529e..4a8314f08a0e 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1071,6 +1071,8 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		dprintk("NFSD: nfsd4_seek: couldn't process stateid!\n");
>  		return status;
>  	}
> +	if (!file)
> +		return nfserr_bad_stateid;
>  
>  	switch (seek->seek_whence) {
>  	case NFS4_CONTENT_DATA:
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
