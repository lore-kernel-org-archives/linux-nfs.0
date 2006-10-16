From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 5/8] knfsd: repcache: dynamically expand under load
Date: Mon, 16 Oct 2006 20:15:52 +1000
Message-ID: <17715.23512.3204.567488@cse.unsw.edu.au>
References: <1160566088.8530.15.camel@hole.melbourne.sgi.com>
	<17714.60137.447459.323573@cse.unsw.edu.au>
	<20061016100540.GC8568@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZPVn-000604-Bd
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 03:15:59 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZPVm-00056F-QI
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 03:16:00 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: message from Greg Banks on Monday October 16
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

On Monday October 16, gnb@sgi.com wrote:
> 
> How about this?
> 
>  	b->nhits++;
>  	if (b->last == 0) {
>  		b->last = now;
>  	} else if (time_after(now, b->last + CACHE_MAX_WAIT)) {
>  		b->last = now; /* too slow */
>  		b->nhits >>= 1;
>  		return 0;
>  	} else if (time_after(now, b->last + CACHE_RATE_JIFFIES) &&
>  		   b->nhits > (b->size >> 4)) {
>  		b->nhits = 0;
>  		b->last = now;
>  		return 1;
>  	}
>  	return 0;
>  
> It gives a damping factor without totally forgetting the past hits.
> Otherwise the case of a regular burst every 61 seconds fails to expand
> the repcache, which I think it should.

Works for me.  Definite improvement.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
