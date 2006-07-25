From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Tue, 25 Jul 2006 19:03:57 +1000
Message-ID: <1153818237.21040.160.camel@hole.melbourne.sgi.com>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
	<17605.53272.237011.603771@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5Ipi-0005u2-9e
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 02:04:06 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5Iph-0005C6-EH
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 02:04:06 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17605.53272.237011.603771@cse.unsw.edu.au>
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

On Tue, 2006-07-25 at 18:02, Neil Brown wrote:
> On Tuesday July 25, neilb@suse.de wrote:
> > 
> > Thanks.  I now have all those patches applied.
> > 
> > I'll post the interesting revisions in a little while.
> 
> You can see them all at 
>   http://cgi.cse.unsw.edu.au/~neilb/patches/linux-devel/2.6/2006-07-25-07/
> 
> The following patch removes some of the #if's.
> Do you agree with it?

Yep.

>  
>  struct svc_pool_map svc_pool_map = { .mode = -1, .init = 0 };
> @@ -54,7 +53,6 @@ svc_pool_map_init(void)
>  		 * Detect best pool mapping mode heuristically.
>  		 */
>  		m->mode = 0;	/* default: one global pool */
> -#ifdef CONFIG_NUMA
>  		if (num_online_nodes() > 1) {
>  			/*
>  			 * Actually have multiple NUMA nodes,
> @@ -73,14 +71,6 @@ svc_pool_map_init(void)
>  				m->mode = 1;
>  			}
>  		}
> -#else
> -		if (num_online_cpus() > 1) {
> -			/*
> -			 * Plain SMP with multiple CPUs online.
> -			 */
> -			m->mode = 1;
> -		}
> -#endif
>  	}

This hunk actually changes the logic slightly, but not
detrimentally (the threshold for using mode `1' is
changed from 1 to 2 cpus in the !NUMA case).  It shouldn't
matter.
 
The rest looks fine.

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
