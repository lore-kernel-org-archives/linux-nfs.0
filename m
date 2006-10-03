From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 008 of 11] knfsd: Prepare knfsd for support
	of	rsize/wsize of up to 1MB, over TCP.
Date: Tue, 3 Oct 2006 18:02:02 +1000
Message-ID: <20061003080202.GM28796@sgi.com>
References: <20060824162917.3600.patches@notabene> <1060824063711.5008@suse.de>
	<20060925154316.GA17465@fieldses.org>
	<17697.48800.933642.581926@cse.unsw.edu.au>
	<20061003021304.GB12867@fieldses.org>
	<17697.63511.32591.797058@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GUfEy-0007Lx-7t
	for nfs@lists.sourceforge.net; Tue, 03 Oct 2006 01:03:00 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GUfEy-0007Z2-LA
	for nfs@lists.sourceforge.net; Tue, 03 Oct 2006 01:03:01 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17697.63511.32591.797058@cse.unsw.edu.au>
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

On Tue, Oct 03, 2006 at 03:41:43PM +1000, Neil Brown wrote:
> Comments on the below?

Looks ok, except...

> @@ -57,7 +57,8 @@ struct svc_serv {
>  	struct svc_stat *	sv_stats;	/* RPC statistics */
>  	spinlock_t		sv_lock;
>  	unsigned int		sv_nrthreads;	/* # of server threads */
> -	unsigned int		sv_bufsz;	/* datagram buffer size */
> +	unsigned int		sv_max_payload;	/* datagram payload size */
> +	unsigned int		sv_max_mesg;	/* bufsz + 1 page for overheads */

Presumably the comment should read "max_payload + 1 page..." ?

> @@ -414,9 +415,11 @@ svc_init_buffer(struct svc_rqst *rqstp, 
>  	int pages;
>  	int arghi;
>  	
> -	if (size > RPCSVC_MAXPAYLOAD)
> -		size = RPCSVC_MAXPAYLOAD;
> -	pages = 2 + (size+ PAGE_SIZE -1) / PAGE_SIZE;
> +	if (size > RPCSVC_MAXPAYLOAD + PAGE_SIZE)
> +		size = RPCSVC_MAXPAYLOAD + PAGE_SIZE;
> +	pages = size + PAGE_SIZE; /* extra page as we hold both request and reply.
> +				   * We assume one is at most one page
> +				   */

Isn't there a divide by PAGE_SIZE missing here?  Looks
like we'll be allocating a *lot* of pages ;-)

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
