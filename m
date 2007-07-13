From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 012 of 20] knfsd: nfsd4: make readonly access
 depend on pseudoflavor
Date: Fri, 13 Jul 2007 00:27:04 -0700
Message-ID: <20070713002704.2287f5a3.akpm@linux-foundation.org>
References: <20070710121949.12548.patches@notabene>
	<1070710022615.13375@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9FYa-00007u-AU
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 00:27:16 -0700
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9FYc-0004iG-Qb
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 00:27:20 -0700
In-Reply-To: <1070710022615.13375@suse.de>
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

On Tue, 10 Jul 2007 12:26:15 +1000 NeilBrown <neilb@suse.de> wrote:

> +static inline int EX_RDONLY(struct svc_export *exp, struct svc_rqst *rqstp)
> +{
> +	struct exp_flavor_info *f;
> +	struct exp_flavor_info *end = exp->ex_flavors + exp->ex_nflavors;
> +
> +	for (f = exp->ex_flavors; f < end; f++) {
> +		if (f->pseudoflavor == rqstp->rq_flavor)
> +			return f->flags & NFSEXP_READONLY;
> +	}
> +	return exp->ex_flags & NFSEXP_READONLY;
> +}

It is fortunate that this inlined monster has only one callsite.

otoh, given that it has only one callsite, perhaps it should be private
to fs/nfsd/vfs.c.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
