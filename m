Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59328 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753983AbdHUVVk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 21 Aug 2017 17:21:40 -0400
Date: Mon, 21 Aug 2017 17:21:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 1/3] nfsd: Limit end of page list when decoding NFSv4
 WRITE
Message-ID: <20170821212140.GB14949@fieldses.org>
References: <20170818150957.26571.12169.stgit@klimt.1015granger.net>
 <20170818151219.26571.31977.stgit@klimt.1015granger.net>
 <20170821211359.GA14949@fieldses.org>
 <BC15F5B8-7B61-4A0C-8F80-2513FB6C12EF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BC15F5B8-7B61-4A0C-8F80-2513FB6C12EF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 21, 2017 at 05:15:38PM -0400, Chuck Lever wrote:
> 
> > On Aug 21, 2017, at 5:13 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Fri, Aug 18, 2017 at 11:12:19AM -0400, Chuck Lever wrote:
> >> When processing an NFSv4 WRITE operation, argp->end should never
> >> point past the end of the data in the final page of the page list.
> >> Otherwise, nfsd4_decode_compound can walk into uninitialized memory.
> >> 
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> fs/nfsd/nfs4xdr.c |    6 ++----
> >> 1 file changed, 2 insertions(+), 4 deletions(-)
> >> 
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index 51e729a..7c48d68 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -144,7 +144,7 @@ static void next_decode_page(struct nfsd4_compoundargs *argp)
> >> 	argp->p = page_address(argp->pagelist[0]);
> >> 	argp->pagelist++;
> >> 	if (argp->pagelen < PAGE_SIZE) {
> >> -		argp->end = argp->p + (argp->pagelen>>2);
> >> +		argp->end = argp->p + XDR_QUADLEN(argp->pagelen);
> >> 		argp->pagelen = 0;
> >> 	} else {
> >> 		argp->end = argp->p + (PAGE_SIZE>>2);
> >> @@ -1279,9 +1279,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
> >> 		argp->pagelen -= pages * PAGE_SIZE;
> >> 		len -= pages * PAGE_SIZE;
> >> 
> >> -		argp->p = (__be32 *)page_address(argp->pagelist[0]);
> >> -		argp->pagelist++;
> >> -		argp->end = argp->p + XDR_QUADLEN(PAGE_SIZE);
> >> +		next_decode_page(argp);
> > 
> > I think there's no change in behavior here *except* for adding a new
> > argp->pagelen=0 (or argp->pagelen -= PAGE_SIZE).
> 
> The code around this change is currently working correctly,
> so there is no change in behavior AFAICT. This is a defensive
> change, but it also replaces duplicate code.

I don't understand.  I'm saying that by calling next_decode_page() there
you've added a new argp->pagelen assignment.  I don't understand how
that can't change behavior, unless there's another bug in our bounds
checking someplace.

Most likely it could cause subsequent op parsers to believe there's less
space in the argument buffer than there really is, so it might fail to
parse a compound with a write plus some other ops, if that puts the
total call close to the maximum size?

--b.

> 
> 
> > --b.
> > 
> >> 	}
> >> 	argp->p += XDR_QUADLEN(len);
> >> 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
