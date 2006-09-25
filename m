From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 009 of 11] knfsd: Allow max size of NFSd payload
	to be configured.
Date: Mon, 25 Sep 2006 17:24:57 -0400
Message-ID: <20060925212457.GK32762@fieldses.org>
References: <20060824162917.3600.patches@notabene> <1060824063716.5020@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GRxwp-0000gA-TQ
	for nfs@lists.sourceforge.net; Mon, 25 Sep 2006 14:25:08 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GRxwp-0002XW-H2
	for nfs@lists.sourceforge.net; Mon, 25 Sep 2006 14:25:08 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060824063716.5020@suse.de>
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

On Thu, Aug 24, 2006 at 04:37:16PM +1000, NeilBrown wrote:
> diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
> --- .prev/fs/nfsd/nfssvc.c	2006-08-24 16:26:10.000000000 +1000
> +++ ./fs/nfsd/nfssvc.c	2006-08-24 16:26:10.000000000 +1000
> @@ -198,9 +198,26 @@ int nfsd_create_serv(void)
>  		unlock_kernel();
>  		return 0;
>  	}
> +	if (nfsd_max_blksize == 0) {
> +		/* choose a suitable default */
> +		struct sysinfo i;
> +		si_meminfo(&i);
> +		/* Aim for 1/4096 of memory per thread
> +		 * This gives 1MB on 4Gig machines
> +		 * But only uses 32K on 128M machines.
> +		 * Bottom out at 8K on 32M and smaller.
> +		 * Of course, this is only a default.
> +		 */
> +		nfsd_max_blksize = NFSSVC_MAXBLKSIZE;
> +		i.totalram >>= 12;
> +		while (nfsd_max_blksize > i.totalram &&
> +		       nfsd_max_blksize >= 8*1024*2)
> +			nfsd_max_blksize /= 2;
> +	}

It looks to me like totalram is actually measured in pages.  So in
practice this gives almost everyone 8k here.  So that 12 should be
something like 12 - PAGE_CACHE_SHIFT?

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
