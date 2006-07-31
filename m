From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 007 of 11] knfsd: add svc_get
Date: Mon, 31 Jul 2006 14:16:38 +1000
Message-ID: <17613.33830.510025.59046@cse.unsw.edu.au>
References: <20060731103458.29040.patches@notabene>
	<1060731004219.29255@suse.de>
	<20060730210507.12e33f56.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7PCx-0004Dh-0q
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:16:47 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7PCw-00071Q-WC
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:16:47 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: message from Andrew Morton on Sunday July 30
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

On Sunday July 30, akpm@osdl.org wrote:
> On Mon, 31 Jul 2006 10:42:19 +1000
> NeilBrown <neilb@suse.de> wrote:
> 
> >  /*
> > + * We use sv_nrthreads as a reference count.  svc_destroy() drops
> > + * this refcount, so we need to bump it up around operations that
> > + * change the number of threads.  Horrible, but there it is.
> > + * Should be called with the BKL held.
> > + */
> > +static inline void svc_get(struct svc_serv *serv)
> > +{
> > +	serv->sv_nrthreads++;
> > +}
> 
> It's a bit odd for a numa-scalability patch to be increasing our dependency
> upon lock_kernel()...

It just looks odd.
This patch doesn't change generated code - it just puts a
post-increment into an inline function so that it can be documented
and well understood.

We don't change the number of threads very often (mainly at bootup and
shutdown) so having that under the BKL isn't a big cost.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
