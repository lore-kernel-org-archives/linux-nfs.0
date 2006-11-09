From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: fix spurious error return from nfsd_create
	in async case
Date: Thu, 9 Nov 2006 12:29:24 +1100
Message-ID: <17746.33908.348544.679986@cse.unsw.edu.au>
References: <20061101021647.GA4203@schwan.zoo>
	<20061108234515.GD16390@fieldses.org>
	<20061109004909.GA30367@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, aime.le-rouzic@bull.net,
	nfs@lists.sourceforge.net, Al Viro <viro@zeniv.linux.org.uk>,
	Ingo Saitz <Ingo.Saitz@stud.uni-hannover.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhyjY-00025T-09
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 17:29:36 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GhyjU-0003bG-Qv
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 17:29:37 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Wednesday November 8
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

On Wednesday November 8, bfields@fieldses.org wrote:
> Commit 6264d69d7df654ca64f625e9409189a0e50734e9 modified the
> nfsd_create() error handling in such a way that nfsd_create will usually
> return nfserr_perm even when succesful, if the export has the async
> export option.
>     
> This introduced a regression that could cause mkdir() to always return a
> permissions error, even though the directory in question was actually
> succesfully created.
>     
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

Acked-by: NeilBrown <neilb@suse.de>

Thanks Bruce.  I checked the rest of that commit and I don't think the
same problem occurs anywhere else.

There is an 'err = nfserr_acces' in nfsd_lookup which is now dead
code... but I guess it already was before the patch.

That "err = " that you fixed was dead code before the patch, but
became a live problem.....

Thanks.
NeilBrown

> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 1a7ad8c..bb4d926 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1177,7 +1177,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
>  	/*
>  	 * Get the dir op function pointer.
>  	 */
> -	err = nfserr_perm;
> +	err = 0;
>  	switch (type) {
>  	case S_IFREG:
>  		host_err = vfs_create(dirp, dchild, iap->ia_mode, NULL);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
