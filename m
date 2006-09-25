From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 008 of 11] knfsd: Prepare knfsd for support of
	rsize/wsize of up to 1MB, over TCP.
Date: Mon, 25 Sep 2006 11:43:16 -0400
Message-ID: <20060925154316.GA17465@fieldses.org>
References: <20060824162917.3600.patches@notabene> <1060824063711.5008@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GRsch-0002BJ-H0
	for nfs@lists.sourceforge.net; Mon, 25 Sep 2006 08:43:59 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GRsch-0005ZI-6F
	for nfs@lists.sourceforge.net; Mon, 25 Sep 2006 08:44:00 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060824063711.5008@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Aug 24, 2006 at 04:37:11PM +1000, NeilBrown wrote:
> The limit over UDP remains at 32K.  Also, make some of
> the apparently arbitrary sizing constants clearer.
> 
> The biggest change here involves replacing NFSSVC_MAXBLKSIZE
> by a function of the rqstp.  This allows it to be different
> for different protocols (udp/tcp) and also allows it
> to depend on the servers declared sv_bufsiz.
> 
> Note that we don't actually increase sv_bufsz for nfs yet.
> That comes next.

This patch has some problems.  (Apologies for being so slow to look at
them!)

We're reporting svc_max_payload(rqstp) as the server's maximum
read/write block size:

> @@ -538,15 +539,16 @@ nfsd3_proc_fsinfo(struct svc_rqst * rqst
>  					   struct nfsd3_fsinfores *resp)
>  {
>  	int	nfserr;
> +	u32	max_blocksize = svc_max_payload(rqstp);
>  
>  	dprintk("nfsd: FSINFO(3)   %s\n",
>  				SVCFH_fmt(&argp->fh));
>  
> -	resp->f_rtmax  = NFSSVC_MAXBLKSIZE;
> -	resp->f_rtpref = NFSSVC_MAXBLKSIZE;
> +	resp->f_rtmax  = max_blocksize;
> +	resp->f_rtpref = max_blocksize;
>  	resp->f_rtmult = PAGE_SIZE;
> -	resp->f_wtmax  = NFSSVC_MAXBLKSIZE;
> -	resp->f_wtpref = NFSSVC_MAXBLKSIZE;
> +	resp->f_wtmax  = max_blocksize;
> +	resp->f_wtpref = max_blocksize;
>  	resp->f_wtmult = PAGE_SIZE;
>  	resp->f_dtpref = PAGE_SIZE;
>  	resp->f_maxfilesize = ~(u32) 0;

But svc_max_payload() usually returns sv_bufsz in the TCP case:

> +u32 svc_max_payload(const struct svc_rqst *rqstp)
> +{
> +	int max = RPCSVC_MAXPAYLOAD_TCP;
> +
> +	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
> +		max = RPCSVC_MAXPAYLOAD_UDP;
> +	if (rqstp->rq_server->sv_bufsz < max)
> +		max = rqstp->rq_server->sv_bufsz;
> +	return max;
> +}


That's the *total* size of the buffer for holding requests and replies.

If a client actually tries to send a write of that size, the entire
request will of course exceed sv_bufsz, so we'll drop it.  (We've seen
this happen with the Solaris v4 client.)

> -#define NFSD_BUFSIZE		(1024 + NFSSVC_MAXBLKSIZE)
> +/*
> + * Largest number of bytes we need to allocate for an NFS
> + * call or reply.  Used to control buffer sizes.  We use
> + * the length of v3 WRITE, READDIR and READDIR replies
> + * which are an RPC header, up to 26 XDR units of reply
> + * data, and some page data.
> + *
> + * Note that accuracy here doesn't matter too much as the
> + * size is rounded up to a page size when allocating space.
> + */

Is the rounding up *always* going to increase the size?  And if not,
then why doesn't accuracy matter?

> +#define NFSD_BUFSIZE		((RPC_MAX_HEADER_WITH_AUTH+26)*XDR_UNIT + NFSSVC_MAXBLKSIZE)

I think this results in 80 less bytes less than before, I think.

No doubt we have lots of wiggle room here, but I'd rather we didn't
decrease that size without seeing a careful analysis.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
