Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35056 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933342AbdEOPo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 11:44:27 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 371CF80F9F
        for <linux-nfs@vger.kernel.org>; Mon, 15 May 2017 15:44:26 +0000 (UTC)
Date: Mon, 15 May 2017 11:44:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Eryu Guan <eguan@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [4.12-rc1 regression] failed to set posix acl on NFSv3 mount
Message-ID: <20170515154424.GC9697@parsley.fieldses.org>
References: <20170515112638.GU7250@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170515112638.GU7250@eguan.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 15, 2017 at 07:26:38PM +0800, Eryu Guan wrote:
> I found xfstests generic/053 generic/105 generic/307 and generic/319
> started to fail on NFSv3 mount against Linux server running v4.12-rc1
> kernel. They all try to set acl (xattr) on file/dir reside on NFSv3
> mount. And this is a regression, 4.11 Linux server worked fine. A simple
> reproducer would be:
> 
> mount linux-server:/export /mnt/nfs
> touch /mnt/nfs/testfile
> setfattr -n user.test -v helloworld /mnt/nfs/testfile
> 
> The last setfattr returned EACCES
> 
> setfattr: /mnt/nfs/testfile: Operation not supported
> 
> And I bisected this to commit 51f56777

Oh, yikes, very sorry about that, the patch should not have gone
upstream.

This was my original approach to the problem, but I abandoned it in part
because someone pointed out the problem you found.  And Neil suggested
the approach used in the better fix, which is upstream as e6838a29ecb
"nfsd: check for oversized NFSv2/v3 arguments".

But somehow the old version must have been left in the tree branch I
gave Linus to pull?

Apologies, I'll take another look to make sure I'm not still confused
about somethign, and then send a revert.  And I'll try to keep out an
eye for the stable backports to NAK those....

--b.

> 
> commit 51f567777799c9d85a778302b9eb61cf15214a98
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Apr 6 22:36:31 2017 -0400
> 
>     nfsd: check for oversized NFSv2/v3 arguments
> 
> And I only need to revert this hunk to "fix" the regression:
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index e770abe..6ef19cf 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -336,8 +336,7 @@ xdr_argsize_check(struct svc_rqst *rqstp, __be32 *p)
>  {
>         char *cp = (char *)p;
>         struct kvec *vec = &rqstp->rq_arg.head[0];
> -       return cp >= (char*)vec->iov_base
> -               && cp <= (char*)vec->iov_base + vec->iov_len;
> +       return cp == (char *)vec->iov_base + vec->iov_len;
>  }
>  
>  static inline int
> 
> Debug log printing out cp, iov_base and iov_base + iov_len confirmed
> that cp can be greater than iov_base but smaller than iov_base + iov_len
> 
> [10868.819939] xdr_argsize_check: cp == ffff88020ea6f094, iov_base == ffff88020ea6f068, iov_base + iov_len == ffff88020ea6f104
> 
> Please help take a look. If you need more info please let me know.
> 
> Thanks,
> Eryu
