Return-Path: <SRS0=31iP=RZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAB17C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Mar 2019 15:23:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 830632083D
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Mar 2019 15:23:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726817AbfCVPXk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Mar 2019 11:23:40 -0400
Received: from fieldses.org ([173.255.197.46]:52468 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726440AbfCVPXk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Mar 2019 11:23:40 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id C9B011B90; Fri, 22 Mar 2019 11:23:39 -0400 (EDT)
Date:   Fri, 22 Mar 2019 11:23:39 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Arnd Bergmann <arnd@arndb.de>
Cc:     Jeff Layton <jlayton@kernel.org>,
        clang-built-linux@googlegroups.com,
        Nick Desaulniers <ndesaulniers@google.com>,
        Nathan Chancellor <natechancellor@gmail.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: avoid uninitialized variable warning
Message-ID: <20190322152339.GA7692@fieldses.org>
References: <20190322140726.251521-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322140726.251521-1-arnd@arndb.de>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Mar 22, 2019 at 03:07:11PM +0100, Arnd Bergmann wrote:
> clang warns that 'contextlen' may be accessed without an initialization:
> 
> fs/nfsd/nfs4xdr.c:2911:9: error: variable 'contextlen' is uninitialized when used here [-Werror,-Wuninitialized]
>                                                                 contextlen);
>                                                                 ^~~~~~~~~~
> fs/nfsd/nfs4xdr.c:2424:16: note: initialize the variable 'contextlen' to silence this warning
>         int contextlen;
>                       ^
>                        = 0
> 
> Presumably this cannot happen, as FATTR4_WORD2_SECURITY_LABEL is
> set if CONFIG_NFSD_V4_SECURITY_LABEL is enabled.
> Adding another #ifdef like the other two in this function
> avoids the warning.

Thanks, applied.--b.

> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  fs/nfsd/nfs4xdr.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 3de42a729093..a3a3455826aa 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2420,8 +2420,10 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  	__be32 status;
>  	int err;
>  	struct nfs4_acl *acl = NULL;
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>  	void *context = NULL;
>  	int contextlen;
> +#endif
>  	bool contextsupport = false;
>  	struct nfsd4_compoundres *resp = rqstp->rq_resp;
>  	u32 minorversion = resp->cstate.minorversion;
> @@ -2906,12 +2908,14 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  			*p++ = cpu_to_be32(NFS4_CHANGE_TYPE_IS_TIME_METADATA);
>  	}
>  
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>  	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
>  		status = nfsd4_encode_security_label(xdr, rqstp, context,
>  								contextlen);
>  		if (status)
>  			goto out;
>  	}
> +#endif
>  
>  	attrlen = htonl(xdr->buf->len - attrlen_offset - 4);
>  	write_bytes_to_xdr_buf(xdr->buf, attrlen_offset, &attrlen, 4);
> -- 
> 2.20.0
