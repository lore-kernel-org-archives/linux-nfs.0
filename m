From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 007 of 9] knfsd: Separate out some parts of
 nfsd_svc, which start nfs servers.
Date: Tue, 25 Jul 2006 23:42:02 -0700
Message-ID: <20060725234202.078ecb48.akpm@osdl.org>
References: <20060725114207.21779.patches@notabene>
	<1060725015457.21981@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5d5r-00037J-2I
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 23:42:07 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1G5d5q-00058I-9u
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 23:42:07 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060725015457.21981@suse.de>
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

On Tue, 25 Jul 2006 11:54:57 +1000
NeilBrown <neilb@suse.de> wrote:

> 
> Separate out the code for creating a new service, and for creating
> initial sockets.
> 
> Some of these new functions will have multiple callers soon.

In which case they shouldn't be inlined, hmm?

> +static inline int nfsd_create_serv(void)
> +{
> +	int err = 0;
> +	lock_kernel();
> +	if (nfsd_serv) {
> +		nfsd_serv->sv_nrthreads++;
> +		unlock_kernel();
> +		return 0;
> +	}
> +
> +	atomic_set(&nfsd_busy, 0);
> +	nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE,
> +			       nfsd_last_thread);
> +	if (nfsd_serv == NULL)
> +		err = -ENOMEM;
> +	else
> +		nfsd_serv->sv_nrthreads++;
> +	unlock_kernel();
> +	do_gettimeofday(&nfssvc_boot);		/* record boot time */
> +	return err;
> +}
> +


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
