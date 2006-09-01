From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 018 of 19] knfsd: lockd: fix use of h_nextrebind
Date: Fri, 01 Sep 2006 12:05:51 -0400
Message-ID: <1157126751.5632.54.camel@localhost>
References: <20060901141639.27206.patches@notabene>
	<1060901043943.27665@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, Olaf Kirch <okir@suse.de>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJBX6-0008C1-Gu
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:06:16 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJBX5-0002LH-9G
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:06:17 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060901043943.27665@suse.de>
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

On Fri, 2006-09-01 at 14:39 +1000, NeilBrown wrote:
> From: Olaf Kirch <okir@suse.de>
> 
>   nlmclnt_recovery would try to force a portmap rebind by setting
>   host->h_nextrebind to 0. The right thing to do here is to set it
>   to the current time.

Could we instead just add a routine nlm_force_rebind_host() into host.c?

> Signed-off-by: okir@suse.de
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./fs/lockd/clntlock.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff .prev/fs/lockd/clntlock.c ./fs/lockd/clntlock.c
> --- .prev/fs/lockd/clntlock.c	2006-08-31 17:02:23.000000000 +1000
> +++ ./fs/lockd/clntlock.c	2006-09-01 12:19:55.000000000 +1000
> @@ -184,7 +184,7 @@ restart:
>  	/* Force a portmap getport - the peer's lockd will
>  	 * most likely end up on a different port.
>  	 */
> -	host->h_nextrebind = 0;
> +	host->h_nextrebind = jiffies;
>  	nlm_rebind_host(host);
>  
>  	/* First, reclaim all locks that have been granted. */
> 
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
