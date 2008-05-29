From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] nfsd: make nfs4xdr WRITEMEM safe against zero count
Date: Thu, 29 May 2008 12:24:58 -0400
Message-ID: <3C91B431-664C-4D9C-B85A-4152B4624168@oracle.com>
References: <483E7DB8.1050705@panasas.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:50489 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260AbYE2Q1S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2008 12:27:18 -0400
In-Reply-To: <483E7DB8.1050705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 29, 2008, at 5:56 AM, Benny Halevy wrote:
> WRITEMEM zeroes the last word in the destination buffer
> for padding purposes, but this must not be done if
> no bytes are to be copied, as it would result
> in zeroing of the word right before the array.
>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>
> --
> The current implementation works since it's always called
> with non zero nbytes or it follows an encoding of the
> string (or opaque) length which, if equal to zero,
> can be overwritten with zero.
>
> Another way of implementing that is the way it's done in
> fs/nfsd/nfs4callback.c:
>
> static inline __be32 *
> xdr_writemem(__be32 *p, const void *ptr, int nbytes)
> {
> 	int tmp = XDR_QUADLEN(nbytes);
> 	if (!tmp)
> 		return p;
> 	p[tmp-1] = 0;
> 	memcpy(p, ptr, nbytes);
> 	return p + tmp;
> }
>
> #define WRITEMEM(ptr,nbytes)     do {                           \
> 	p = xdr_writemem(p, ptr, nbytes);                       \
> } while (0)
>
> Also, is there any plan to clean up the xdr encoding definition
> any time and define a cleaner static inline API?
> I'd be happy to take a stab at it and come up with a
> written and tested proposal.

By the way, here is a pointer to the old work:

   http://git.linux-nfs.org/?p=cel/ 
cel-2.6.git;a=shortlog;h=drop-20070423

The work in this snapshot is only partially complete.

There are many many issues to fix up.  One of the bigger ones is that  
the RPC layer still takes the BKL during XDR encoding and decoding.   
But I wanted to create something that could be fully or partially  
shared by the client and server implementations, and that would be  
more rigorous about static and dynamic type checking.

In addition, the NFSv4 routines use a new style of managing the RPC  
buffer that I wanted to adopt for the other in-kernel XDR routines,  
then convert the RPC client to use only the new style when invoking  
XDR routines.  I never got that far, but I still think it's a  
reasonable goal.

> git diff --stat -p
> fs/nfsd/nfs4xdr.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index e8e27fb..588c9f6 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1712,7 +1712,7 @@ nfsd4_decode_compound(struct  
> nfsd4_compoundargs *argp)
> 	*p++ = htonl((u32)((n) >> 32));				\
> 	*p++ = htonl((u32)(n));					\
> } while (0)
> -#define WRITEMEM(ptr,nbytes)     do {				\
> +#define WRITEMEM(ptr,nbytes)     do if (nbytes > 0) {		\
> 	*(p + XDR_QUADLEN(nbytes) -1) = 0;                      \
> 	memcpy(p, ptr, nbytes);					\
> 	p += XDR_QUADLEN(nbytes);				\
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



