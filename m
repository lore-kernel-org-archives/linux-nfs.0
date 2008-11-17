From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 11/51] FIXME: nfsd41: reduce server lease time for
 nfs41
Date: Mon, 17 Nov 2008 15:59:44 +0200
Message-ID: <492178D0.5040301@panasas.com>
References: <491895A0.3040809@panasas.com> <1226349863-10506-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:5993 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752143AbYKQN7s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:59:48 -0500
In-Reply-To: <1226349863-10506-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

review 11-12: get rid of this patch (at least for submit),
can be set in run time.

On Nov. 10, 2008, 22:44 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> FIXME: bhalevy: find out why this is needed.  Is this only for debugging?
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0e1bc72..dcb075d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -59,8 +59,13 @@
>  #define NFSDDBG_FACILITY                NFSDDBG_PROC
>  
>  /* Globals */
> +#if defined(CONFIG_NFSD_V4_1)
> +static time_t lease_time = 20;     /* default lease time */
> +static time_t user_lease_time = 20;
> +#else /* CONFIG_NFSD_V4_1 */
>  static time_t lease_time = 90;     /* default lease time */
>  static time_t user_lease_time = 90;
> +#endif /* CONFIG_NFSD_V4_1 */
>  static time_t boot_time;
>  static u32 current_ownerid = 1;
>  static u32 current_fileid = 1;
