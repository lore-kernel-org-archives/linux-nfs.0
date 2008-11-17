From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 12/51] nfsd41: provide support for minor version
 1 at	rpc level
Date: Mon, 17 Nov 2008 16:00:18 +0200
Message-ID: <492178F2.3050307@panasas.com>
References: <491895A0.3040809@panasas.com> <1226349883-10543-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:11080 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751439AbYKQOAV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:00:21 -0500
In-Reply-To: <1226349883-10543-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:44 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-12: move down the patchset for bisectability

> ---
>  include/linux/nfsd/nfsd.h |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
> index 9703540..ffb7897 100644
> --- a/include/linux/nfsd/nfsd.h
> +++ b/include/linux/nfsd/nfsd.h
> @@ -24,7 +24,11 @@
>   * nfsd version
>   */
>  #define NFSD_VERSION		"0.5"

review 11-12: send a patch to remove NFSD_VERSION

> +#if defined(CONFIG_NFSD_V4_1)
> +#define NFSD_SUPPORTED_MINOR_VERSION	1
> +#else /* CONFIG_NFSD_V4_1 */
>  #define NFSD_SUPPORTED_MINOR_VERSION	0
> +#endif /* CONFIG_NFSD_V4_1 */
>  
>  /*
>   * Flags for nfsd_permission
