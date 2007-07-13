From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] nfsd: fix possible read-ahead cache and export
	table corruption
Date: Fri, 13 Jul 2007 14:10:19 +1000
Message-ID: <20070713041019.GB20430@sgi.com>
References: <20070713024420.GA31364@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9CTz-0005C5-QN
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 21:10:20 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1I9CU2-0007GR-9Y
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 21:10:23 -0700
In-Reply-To: <20070713024420.GA31364@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Jul 12, 2007 at 10:44:20PM -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> The value of nperbucket calculated here is too small--we should be
> [...]
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 7e50da0..dd3604e 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1885,7 +1885,7 @@ nfsd_racache_init(int cache_size)
>  		raparm_hash[i].pb_head = NULL;
>  		spin_lock_init(&raparm_hash[i].pb_lock);
>  	}
> -	nperbucket = cache_size >> RAPARM_HASH_BITS;
> +	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
>  	for (i = 0; i < cache_size - 1; i++) {
>  		if (i % nperbucket == 0)
>  			raparm_hash[j++].pb_head = raparml + i;
> -- 
> 1.5.3.rc0.63.gc956

My bad.  The code I added really only works properly if the number
of nfsd threads at startup is a multiple of 8, so that cache_size
is a multiple of 16 and the shift doesn't lose any nonzero bits.
As we use 128 threads in our product, I'd never noticed the bug :-(
Sorry for the trouble, Bruce.

There's a couple of other problems with that code, for which I'll send
patches shortly.  But I think the raparams cache needs a more thorough
renovation than that.  I have a mostly-working patch which rips it out
entirely and replaces it with a cache of open struct files, an idea
of Neil's.  This approach fixes a whole bunch of separate problems
at once, and will be really useful...if I can ever find enough time
between super-urgent dramas to work on it ;-)

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
