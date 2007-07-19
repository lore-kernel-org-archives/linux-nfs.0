From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 5/5] knfsd: clean up EX_RDONLY
Date: Thu, 19 Jul 2007 09:29:51 +0100
Message-ID: <20070719082951.GB2507@infradead.org>
References: <2ac9f179334dc7894bb58b1c2fb62837a07fbbdf.1184798679.git.bfields@citi.umich.edu>
	<986bf36dcb843bf352799fad5c20f1764748ce22.1184798679.git.bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-kernel@vger.kernel.org, andros@citi.umich.edu,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBROU-0002aj-4d
	for nfs@lists.sourceforge.net; Thu, 19 Jul 2007 01:29:54 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBROX-0005pS-MA
	for nfs@lists.sourceforge.net; Thu, 19 Jul 2007 01:29:58 -0700
In-Reply-To: <986bf36dcb843bf352799fad5c20f1764748ce22.1184798679.git.bfields@citi.umich.edu>
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

On Wed, Jul 18, 2007 at 06:57:30PM -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> Share a little common code, reverse the arguments for consistency, drop
> the unnecessary "inline", and lowercase the name.

Ah, sorry - didn't notice this was a separate patch.

> @@ -1845,7 +1838,7 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
>  	 */
>  	if (!(acc & MAY_LOCAL_ACCESS))
>  		if (acc & (MAY_WRITE | MAY_SATTR | MAY_TRUNC)) {
> -			if (EX_RDONLY(exp, rqstp) || IS_RDONLY(inode))
> +			if (exp_rdonly(rqstp, exp) || IS_RDONLY(inode))

In fact with just a singler caller left and reduced to a one-liner we
could kill this function completely..

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
