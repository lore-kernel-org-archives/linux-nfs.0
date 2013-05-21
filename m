Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44411 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983Ab3EUTXk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 May 2013 15:23:40 -0400
Date: Tue, 21 May 2013 15:23:38 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Don't give out read delegations on exclusive
 creates
Message-ID: <20130521192338.GC12114@fieldses.org>
References: <1368643909-8059-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368643909-8059-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 15, 2013 at 02:51:49PM -0400, Steve Dickson wrote:
> When an exclusive create is done with the mode bits
> set (aka open(testfile, O_CREAT | O_EXCL, 0777)) this

so implicitly O_RDONLY.  Is that common?  Maybe so, OK.

> causes a OPEN op followed by a SETATTR op. When a
> read delegation is given in the OPEN, it causes
> the SETATTR to delay with EAGAIN until the
> delegation is recalled.
> 
> This patch caused exclusive creates to give out
> a write delegation (which turn into no delegation)
> which allows the SETATTR seamlessly succeed.

OK.  May as well make it apply to all creates, though, I think?
Any create flag seems like a sign the file's likely to be modified soon,
hence isn't a good candidate for a read delegation.

I find it a little confusing the way we set this WRITE flag and then
depend on later code to turn that into no delegation, maybe we should
fix that.

--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfsd/nfs4state.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 316ec84..6b45d0e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3035,8 +3035,16 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
>  				goto out;
>  			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
>  				flag = NFS4_OPEN_DELEGATE_WRITE;
> -			else
> -				flag = NFS4_OPEN_DELEGATE_READ;
> +			else {
> +				switch(open->op_createmode) {
> +				case NFS4_CREATE_EXCLUSIVE:
> +				case NFS4_CREATE_EXCLUSIVE4_1:
> +					flag = NFS4_OPEN_DELEGATE_WRITE;
> +					break;
> +				default:
> +					flag = NFS4_OPEN_DELEGATE_READ;
> +				}
> +			}
>  			break;
>  		default:
>  			goto out;
> -- 
> 1.8.1.4
> 
