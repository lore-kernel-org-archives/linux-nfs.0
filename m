From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/5] knfsd: move EX_RDONLY out of header
Date: Thu, 19 Jul 2007 09:28:38 +0100
Message-ID: <20070719082838.GA2507@infradead.org>
References: <2ac9f179334dc7894bb58b1c2fb62837a07fbbdf.1184798679.git.bfields@citi.umich.edu>
	<fbbdd23e675df0288cf80243fdcd5e211fff855b.1184798679.git.bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-kernel@vger.kernel.org, andros@citi.umich.edu,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBRNP-0002TR-CU
	for nfs@lists.sourceforge.net; Thu, 19 Jul 2007 01:28:47 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBRNS-0001Zx-U2
	for nfs@lists.sourceforge.net; Thu, 19 Jul 2007 01:28:51 -0700
In-Reply-To: <fbbdd23e675df0288cf80243fdcd5e211fff855b.1184798679.git.bfields@citi.umich.edu>
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

On Wed, Jul 18, 2007 at 06:57:29PM -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> EX_RDONLY is only called in one place; just put it there.
> 
> Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
> ---
>  fs/nfsd/vfs.c               |   12 ++++++++++++
>  include/linux/nfsd/export.h |   12 ------------
>  2 files changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 5c97d0e..f2684e5 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1797,6 +1797,18 @@ nfsd_statfs(struct svc_rqst *rqstp, struct svc_fh *fhp, struct kstatfs *stat)
>  	return err;
>  }
>  
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

As mentioned last time lease remove the inline qualifier and give it a
lower-case name.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
