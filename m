From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 012 of 20] knfsd: nfsd4: make readonly access
	depend on pseudoflavor
Date: Fri, 13 Jul 2007 10:54:13 +0100
Message-ID: <20070713095413.GC16304@infradead.org>
References: <20070710121949.12548.patches@notabene>
	<1070710022615.13375@suse.de>
	<20070713002704.2287f5a3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9Hr0-00085l-7O
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 02:54:26 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9Hr3-0002Pm-NX
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 02:54:30 -0700
In-Reply-To: <20070713002704.2287f5a3.akpm@linux-foundation.org>
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

On Fri, Jul 13, 2007 at 12:27:04AM -0700, Andrew Morton wrote:
> On Tue, 10 Jul 2007 12:26:15 +1000 NeilBrown <neilb@suse.de> wrote:
> 
> > +static inline int EX_RDONLY(struct svc_export *exp, struct svc_rqst *rqstp)
> > +{
> > +	struct exp_flavor_info *f;
> > +	struct exp_flavor_info *end = exp->ex_flavors + exp->ex_nflavors;
> > +
> > +	for (f = exp->ex_flavors; f < end; f++) {
> > +		if (f->pseudoflavor == rqstp->rq_flavor)
> > +			return f->flags & NFSEXP_READONLY;
> > +	}
> > +	return exp->ex_flags & NFSEXP_READONLY;
> > +}
> 
> It is fortunate that this inlined monster has only one callsite.
> 
> otoh, given that it has only one callsite, perhaps it should be private
> to fs/nfsd/vfs.c.

Absolutely.  Pluse a sane lower-case name and removing the inline qualifier
please.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
