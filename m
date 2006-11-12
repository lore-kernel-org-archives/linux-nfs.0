From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC: 2.6 patch] include/linux/nfsd/nfsfh.h: fix a NULL
Date: Sun, 12 Nov 2006 10:58:47 -0500
Message-ID: <1163347127.6612.66.camel@lade.trondhjem.org>
References: <20061112131748.GI25057@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjHjr-00052B-FK
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 07:59:19 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1873r8uVdRIFAagFwmrnOY7LqbXa+EZMBw=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GjHjr-0005eB-F0
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 07:59:20 -0800
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061112131748.GI25057@stusta.de>
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

On Sun, 2006-11-12 at 14:17 +0100, Adrian Bunk wrote:
> dereference
> Reply-To: 
> Fcc: =sent-mail
> 
> When we know fhp->fh_dentry is NULL, a code path where it's being 
> dereferenced isn't a good choice.
> 
> Spotted by the coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> --- linux-2.6/include/linux/nfsd/nfsfh.h.old	2006-11-12 14:13:34.000000000 +0100
> +++ linux-2.6/include/linux/nfsd/nfsfh.h	2006-11-12 14:13:49.000000000 +0100
> @@ -330,8 +330,7 @@ fh_unlock(struct svc_fh *fhp)
>  {
>  	if (!fhp->fh_dentry)
>  		printk(KERN_ERR "fh_unlock: fh not verified!\n");
> -
> -	if (fhp->fh_locked) {
> +	else if (fhp->fh_locked) {
>  		fill_post_wcc(fhp);
>  		mutex_unlock(&fhp->fh_dentry->d_inode->i_mutex);
>  		fhp->fh_locked = 0;
> 

This issue has come up on lkml before. Please just convert that check
for fhp->fh_dentry into a BUG_ON().

Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
