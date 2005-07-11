From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH kNFSd 1 of 4] Fixed possibly xdr parsing error if write size exceed 2^31
Date: Mon, 11 Jul 2005 11:50:16 +0200
Message-ID: <20050711095015.GA9650@suse.de>
References: <20040816135256.9819.patches@notabene> <E1BwYdv-0002Zf-5L@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Druve-00010N-HY
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 02:50:22 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Druvd-0001Ib-FZ
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 02:50:23 -0700
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <E1BwYdv-0002Zf-5L@notabene.cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi all,

what happened to this patch? It never seems to have made it
upstream.

Olaf

On Mon, Aug 16, 2004 at 01:58:43PM +1000, NeilBrown wrote:
> 
> xdr_argsize_check needs to cope with the possibility that the
> pointer has wrapped and could be below buf->base.
> 
> Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>
> 
> ### Diffstat output
>  ./fs/nfsd/nfs3xdr.c         |    2 +-
>  ./include/linux/nfsd/xdr3.h |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
> --- ./fs/nfsd/nfs3xdr.c~current~	2004-08-14 13:21:52.000000000 +1000
> +++ ./fs/nfsd/nfs3xdr.c	2004-08-14 13:23:06.000000000 +1000
> @@ -273,7 +273,7 @@ xdr_argsize_check(struct svc_rqst *rqstp
>  {
>  	struct svc_buf	*buf = &rqstp->rq_argbuf;
>  
> -	return p - buf->base <= buf->buflen;
> +	return p >= buf->base && p <= buf->base + buf->buflen ;
>  }
>  
>  static inline int
> 
> diff ./include/linux/nfsd/xdr3.h~current~ ./include/linux/nfsd/xdr3.h
> --- ./include/linux/nfsd/xdr3.h~current~	2004-08-14 13:17:07.000000000 +1000
> +++ ./include/linux/nfsd/xdr3.h	2004-08-16 09:48:43.000000000 +1000
> @@ -41,7 +41,7 @@ struct nfsd3_writeargs {
>  	__u32			count;
>  	int			stable;
>  	__u8 *			data;
> -	int			len;
> +	__u32			len;
>  };
>  
>  struct nfsd3_createargs {
> 
> 
> -------------------------------------------------------
> SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
> 100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
> Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
> http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
