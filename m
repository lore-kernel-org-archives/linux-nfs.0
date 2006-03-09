From: Gopal Santhanam <gopal@nerur.com>
Subject: Re: Re: ACL on NFS, how make it work?
Date: Thu, 9 Mar 2006 00:56:30 -0800
Message-ID: <200603090056.31041.gopal@nerur.com>
References: <20060303103806.GB8038@sv.lnf.it> <20060308170425.GS8060@sv.lnf.it> <20060309014955.GA8089@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Marco Gaiarin <gaio@sv.lnf.it>, Andreas Gruenbacher <agruen@suse.de>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHGx1-0004Bs-Kr
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 00:56:51 -0800
Received: from smtp3.stanford.edu ([171.67.16.138])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FHGx0-0000od-Hw
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 00:56:51 -0800
To: nfs@lists.sourceforge.net
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

It seems to work for me.  Thanks!

Why does the return value of vfs_getxattr change between the two 
calls though?  Can you explain?

Thanks again,
Gopal


On Wednesday 08 March 2006 17:49, J. Bruce Fields wrote:
> On Wed, Mar 08, 2006 at 06:04:25PM +0100, Marco Gaiarin wrote:
> > Mandi! J. Bruce Fields
> >   In chel di` si favelave...
> >
> > > Actually I got one other NFS/XFS ACL complaint recently,
> > > and confirmed that with current kernels I'm able to get
> > > and set ext3 ACL's over NFS, and get and set XFS ACL's
> > > locally, but I can't use XFS ACL's over NFS. Which is
> > > odd--on a first glance it looks like the two filesystems
> > > export posix acl's through the same interface, etc.  I
> > > haven't had the chance to figure out what's going on
> > > yet....
> >
> > If i can do something to debug that, say me.
>
> Could you try the following patch?  Fixes the problem for me.
>
> --b.
>
> nfsd4: fix acl xattr length return
>
> We should be using the length from the second vfs_getxattr, in
> case it changed.  (Note: there's still a small race here; we
> could end up returning -ENOMEM if the length increased between
> the first and second call.  Oh well; I'm not sure it's worth
> spending a lot of effort to fix that.)
>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
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
>  static ssize_t nfsd_getxattr(struct dentry *dentry, char
> *key, void **buf) {
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
>
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by xPML, a groundbreaking
> scripting language that extends applications into web and
> mobile media. Attend the live webcast and join the prime
> developer group breaking into this new coding territory!
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&
>dat=121642 _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
