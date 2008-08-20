From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/4] nfs: prepare to share nfs_set_port
Date: Wed, 20 Aug 2008 16:23:23 -0400
Message-ID: <76bd70e30808201323h32debdeaj31577cd19b87612e@mail.gmail.com>
References: <20080820200827.GC21226@fieldses.org>
	 <1219263023-22592-1-git-send-email-bfields@citi.umich.edu>
	 <1219263023-22592-2-git-send-email-bfields@citi.umich.edu>
	 <1219263023-22592-3-git-send-email-bfields@citi.umich.edu>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:5030 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754272AbYHTUXZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2008 16:23:25 -0400
Received: by mu-out-0910.google.com with SMTP id w8so807353mue.1
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2008 13:23:23 -0700 (PDT)
In-Reply-To: <1219263023-22592-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2008 at 4:10 PM, J. Bruce Fields <bfields@citi.umich.edu> wrote:
> We plan to use this function elsewhere.
>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfs/internal.h |   20 ++++++++++++++++++++
>  fs/nfs/super.c    |   19 -------------------
>  2 files changed, 20 insertions(+), 19 deletions(-)
>
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 24241fc..0b30f24 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -276,3 +276,23 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
>                PAGE_SIZE - 1) >> PAGE_SHIFT;
>  }
>
> +

Extra blank line here.

> +/*
> + * Set the port number in an address.  Be agnostic about the address
> + * family.
> + */
> +static inline void nfs_set_port(struct sockaddr *sap, unsigned short port)
> +{
> +       switch (sap->sa_family) {
> +       case AF_INET: {
> +             struct sockaddr_in *ap = (struct sockaddr_in *)sap;
> +             ap->sin_port = htons(port);
> +             break;
> +       }
> +       case AF_INET6: {
> +              struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
> +              ap->sin6_port = htons(port);
> +              break;
> +       }
> +       }
> +}

Before Trond sees this and busts a blood vessel... you should refactor
the switch statement to get rid of the double braces.

-- 
Chuck Lever
