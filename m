From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 007 of 11] knfsd: add svc_get
Date: Sun, 30 Jul 2006 21:05:07 -0700
Message-ID: <20060730210507.12e33f56.akpm@osdl.org>
References: <20060731103458.29040.patches@notabene>
	<1060731004219.29255@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7P1l-0003Kp-Qj
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:05:13 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1G7P1l-0004sv-3G
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:05:14 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060731004219.29255@suse.de>
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

On Mon, 31 Jul 2006 10:42:19 +1000
NeilBrown <neilb@suse.de> wrote:

>  /*
> + * We use sv_nrthreads as a reference count.  svc_destroy() drops
> + * this refcount, so we need to bump it up around operations that
> + * change the number of threads.  Horrible, but there it is.
> + * Should be called with the BKL held.
> + */
> +static inline void svc_get(struct svc_serv *serv)
> +{
> +	serv->sv_nrthreads++;
> +}

It's a bit odd for a numa-scalability patch to be increasing our dependency
upon lock_kernel()...


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
