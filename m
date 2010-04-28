From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfsd4: fix filehandle comment
Date: Wed, 28 Apr 2010 17:34:32 -0400
Message-ID: <4BD8A9E8.8060608@oracle.com>
References: <20100428213107.GA23474@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54906 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011Ab0D1Vf0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Apr 2010 17:35:26 -0400
In-Reply-To: <20100428213107.GA23474@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/28/2010 05:31 PM, J. Bruce Fields wrote:
> From: J. Bruce Fields<bfields@citi.umich.edu>
>
> Minor typos.
>
> Signed-off-by: J. Bruce Fields<bfields@citi.umich.edu>
> ---
>   include/linux/nfsd/nfsfh.h |    4 ++--
>   1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
> index 65e333a..45bb5a8 100644
> --- a/include/linux/nfsd/nfsfh.h
> +++ b/include/linux/nfsd/nfsfh.h
> @@ -40,8 +40,8 @@ struct nfs_fhbase_old {
>    * This is the new flexible, extensible style NFSv2/v3 file handle.
>    * by Neil Brown<neilb-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>  - March 2000
>    *
> - * The file handle is seens as a list of 4byte words.
> - * The first word contains a version number (1) and four descriptor bytes
> + * The file handle is seens as a list of four-byte words.

seens?  seen?  sent?

> + * The first word contains a version number (1) and three descriptor bytes
>    * that tell how the remaining 3 variable length fields should be handled.
>    * These three bytes are auth_type, fsid_type and fileid_type.
>    *


-- 
chuck[dot]lever[at]oracle[dot]com
