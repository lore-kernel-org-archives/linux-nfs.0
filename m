From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: ACL on NFS, how make it work?
Date: Thu, 9 Mar 2006 12:20:13 +0100
Message-ID: <200603091220.13561.agruen@suse.de>
References: <20060303103806.GB8038@sv.lnf.it> <20060308170425.GS8060@sv.lnf.it> <20060309014955.GA8089@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Marco Gaiarin <gaio@sv.lnf.it>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, nfs@lists.sourceforge.net,
	Gopal Santhanam <gopal@nerur.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHJBt-0001Wt-Vy
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 03:20:21 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHJBs-0008VP-IT
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 03:20:21 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060309014955.GA8089@fieldses.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

the patch looks good.

On Thursday 09 March 2006 02:49, J. Bruce Fields wrote:
> nfsd4: fix acl xattr length return
Actually all versions, not only v4.
>
> We should be using the length from the second vfs_getxattr, in case it
> changed.  (Note: there's still a small race here; we could end up returning
> -ENOMEM if the length increased between the first and second call.  Oh
> well; I'm not sure it's worth spending a lot of effort to fix that.)
>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
> ---
>
>  fs/nfsd/vfs.c |    6 +-----
>  1 files changed, 1 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 5320e5a..ac3a8e4 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -371,7 +371,6 @@ out_nfserr:
>  static ssize_t nfsd_getxattr(struct dentry *dentry, char *key, void **buf)
>  {
>  	ssize_t buflen;
> -	int error;
>
>  	buflen = vfs_getxattr(dentry, key, NULL, 0);
>  	if (buflen <= 0)
> @@ -381,10 +380,7 @@ static ssize_t nfsd_getxattr(struct dent
>  	if (!*buf)
>  		return -ENOMEM;
>
> -	error = vfs_getxattr(dentry, key, *buf, buflen);
> -	if (error < 0)
> -		return error;
> -	return buflen;
> +	return vfs_getxattr(dentry, key, *buf, buflen);
>  }
>  #endif

Thanks,
Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
SUSE Labs, SUSE LINUX Products GmbH / Novell Inc.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
