From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 5/8] knfsd: repcache: dynamically expand under load
Date: Mon, 16 Oct 2006 12:14:01 +1000
Message-ID: <17714.60137.447459.323573@cse.unsw.edu.au>
References: <1160566088.8530.15.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZHzU-0006YA-6s
	for nfs@lists.sourceforge.net; Sun, 15 Oct 2006 19:14:08 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZHzU-0001Bu-Kg
	for nfs@lists.sourceforge.net; Sun, 15 Oct 2006 19:14:09 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Wednesday October 11
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

On Wednesday October 11, gnb@melbourne.sgi.com wrote:
>  /*
> + * Decide whether it is time to expand the cache.  Returns 1 iff
> + * the cache is to be expanded.  Called with bucket lock held.
> + */
> +static int
> +nfsd_cache_expand_ratelimit(struct svc_cache_bucket *b)
> +{
> +	unsigned long now = jiffies;
> +
> +	b->nhits++;
> +	if (b->last == 0) {
> +		b->last = now;
> +	} else if ((now - b->last) > CACHE_RATE_JIFFIES &&
> +		   b->nhits > (b->size >> 4)) {
> +		b->nhits = 0;
> +		b->last = now;
> +		return 1;
> +	}
> +	return 0;
> +}

I'm wondering a bit about this function.
Firstly (and this is very minor) I expected to see "time_before" or
similar when comparing times.  The code you have is correct, but maybe
it will also be obvious if it read
           if (time_after(now, b->last + CACHE_RATE_JIFFIES))
??

Also, nhits is only reset when we return 1, and hence grow the bucket.
So if we only occasionally had large bursts which included
CACHE_BUCKET_MAX_SIZE requests in CACHE_THRESH_AGE jiffies, we would
still eventually grow the bucket to it's max size.
I think I would like to have something like


	b->nhits++;
	if (b->last == 0) {
		b->last = now;
	} else if (time_after(now, b->last + CACHE_MAX_WAIT)) {
		b->last = now; /* too slow, forget it */
		b->nhits = 0;
		return 0;
	} else if (time_after(now, b->last + CACHE_RATE_JIFFIES) &&
		   b->nhits > (b->size >> 4)) {
		b->nhits = 0;
		b->last = now;
		return 1;
	}
	return 0;

with CACHE_MAX_WAIT maybe 60*HZ.

Make sense?

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
