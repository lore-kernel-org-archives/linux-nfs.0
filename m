Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail09.linbit.com ([212.69.161.110]:49603 "EHLO
	mail09.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab1JUX6V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2011 19:58:21 -0400
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
From: Andreas Gruenbacher <agruen@kernel.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Sat, 22 Oct 2011 01:58:18 +0200
In-Reply-To: <871uu65vzh.fsf@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20111019222021.GB1874@fieldses.org> <87k4805alx.fsf@linux.vnet.ibm.com>
	 <20111020091434.GC5444@fieldses.org> <20111020091946.GA23773@infradead.org>
	 <20111020102538.GG5444@fieldses.org>
	 <1319154390.2270.52.camel@schurl.linbit>
	 <874nz265tq.fsf@linux.vnet.ibm.com> <1319194331.5930.9.camel@schurl.linbit>
	 <871uu65vzh.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1319241499.5930.24.camel@schurl.linbit>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-10-21 at 18:42 +0530, Aneesh Kumar K.V wrote:
> diff --git a/fs/richacl_xattr.c b/fs/richacl_xattr.c
> index 02a7986..31e33b5 100644
> --- a/fs/richacl_xattr.c
> +++ b/fs/richacl_xattr.c
> @@ -58,19 +58,14 @@ richacl_from_xattr(const void *value, size_t size)
>  		goto fail_einval;
>  
>  	richacl_for_each_entry(ace, acl) {
> -		const char *who = (void *)(xattr_ace + 1), *end;
> -		ssize_t used = (void *)who - value;
>  
> -		if (used > size)
> -			goto fail_einval;
> -		end = memchr(who, 0, size - used);
> -		if (!end)
> +		if (((void *)xattr_ace + sizeof(*xattr_ace)) > (value + size))
>  			goto fail_einval;

This check can be moved out of the loop now.

Other than that, I'm happy with the patch; acked.

Thanks,
Andreas

