From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 07/11] NFS: fix minor bug in new NFS symlink code
Date: Thu, 19 Oct 2006 21:25:41 -0700
Message-ID: <20061019212541.b2adc4b2.akpm@osdl.org>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
	<20061019170432.8171.49033.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linus Torvalds <torvalds@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Galx3-0005kR-IV
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 21:25:45 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1Galx3-0007JQ-A8
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 21:25:46 -0700
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20061019170432.8171.49033.stgit@lade.trondhjem.org>
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

On Thu, 19 Oct 2006 13:04:32 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 58d4405..c86a1ea 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1519,8 +1519,8 @@ static int nfs_symlink(struct inode *dir
>  	pagevec_init(&lru_pvec, 0);
>  	if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
>  							GFP_KERNEL)) {
> -		if (!pagevec_add(&lru_pvec, page))
> -			__pagevec_lru_add(&lru_pvec);
> +		pagevec_add(&lru_pvec, page);
> +		pagevec_lru_add(&lru_pvec);
>  		SetPageUptodate(page);
>  		unlock_page(page);
>  	} else

One could export add_to_page_cache_lru() to modules..

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
