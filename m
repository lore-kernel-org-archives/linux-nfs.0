From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 002 of 9] knfsd: knfsd: Remove an
	unused	variable	from e_show().
Date: Tue, 25 Jul 2006 14:36:13 +1000
Message-ID: <17605.40893.875871.653357@cse.unsw.edu.au>
References: <20060725114207.21779.patches@notabene>
	<1060725015432.21921@suse.de>
	<20060725041059.GA13294@filer.fsl.cs.sunysb.edu>
	<17605.39934.963857.665398@cse.unsw.edu.au>
	<1153801950.1547.657.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Josef Sipek <jsipek@fsl.cs.sunysb.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5EfC-0000iV-SJ
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 21:36:58 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5EfB-0004cW-HR
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 21:36:59 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Tuesday July 25
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

On Tuesday July 25, gnb@melbourne.sgi.com wrote:
> On Tue, 2006-07-25 at 14:20, Neil Brown wrote:
> > On Tuesday July 25, jsipek@fsl.cs.sunysb.edu wrote:
> > > On Tue, Jul 25, 2006 at 11:54:32AM +1000, NeilBrown wrote:
> > > ...
> > 
> > Probably.  We just need a pointer value that is definitely not a
> > pointer to a valid cache_head object, and is not NULL.
> > (void*)1 seems a reasonable choice, but maybe #defineing something
> > would help.
> > 
> > Patches welcome.
> 
> This trivial patch compiles.

Cool... you learn something new every day!
> --
> 
> knfsd: Use SEQ_START_TOKEN instead of hardcoded magic (void*)1.
> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Acked-by: NeilBrown <neilb@suse.de>

NeilBrown


> ---
> 
>  fs/nfsd/export.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> Index: linux/fs/nfsd/export.c
> ===================================================================
> --- linux.orig/fs/nfsd/export.c	2006-07-25 14:28:03.000000000 +1000
> +++ linux/fs/nfsd/export.c	2006-07-25 14:29:14.526574385 +1000
> @@ -1086,7 +1086,7 @@ static void *e_start(struct seq_file *m,
>  	exp_readlock();
>  	read_lock(&svc_export_cache.hash_lock);
>  	if (!n--)
> -		return (void*)1;
> +		return SEQ_START_TOKEN;
>  	hash = n >> 32;
>  	export = n & ((1LL<<32) - 1);
>  
> @@ -1110,7 +1110,7 @@ static void *e_next(struct seq_file *m, 
>  	struct cache_head *ch = p;
>  	int hash = (*pos >> 32);
>  
> -	if (p == (void*)1)
> +	if (p == SEQ_START_TOKEN)
>  		hash = 0;
>  	else if (ch->next == NULL) {
>  		hash++;
> @@ -1180,7 +1180,7 @@ static int e_show(struct seq_file *m, vo
>  	struct svc_export *exp = container_of(cp, struct svc_export, h);
>  	svc_client *clp;
>  
> -	if (p == (void*)1) {
> +	if (p == SEQ_START_TOKEN) {
>  		seq_puts(m, "# Version 1.1\n");
>  		seq_puts(m, "# Path Client(Flags) # IPs\n");
>  		return 0;
> 
> 
> 
> Greg.
> -- 
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.
> 
> 
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys -- and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
