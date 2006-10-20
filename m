From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/2] VFS: Make d_materialise_unique() enforce
 directory uniqueness
Date: Thu, 19 Oct 2006 21:40:56 -0700
Message-ID: <20061019214056.6f82641b.akpm@osdl.org>
References: <1161291638.5506.9.camel@lade.trondhjem.org>
	<20061019210358.6797.64655.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linus Torvalds <torvalds@osdl.org>,
	Miklos Szeredi <miklos@szeredi.hu>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GamBn-0006z4-M7
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 21:40:59 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1GamBo-0003Cb-Gd
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 21:41:00 -0700
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20061019210358.6797.64655.stgit@lade.trondhjem.org>
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

On Thu, 19 Oct 2006 17:03:58 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> +static struct dentry *__d_unalias(struct dentry *dentry, struct dentry *alias)
> +{
> +	struct mutex *m1 = NULL, *m2 = NULL;
> +	struct dentry *ret;
> +
> +	/* If alias and dentry share a parent, then no extra locks required */
> +	if (alias->d_parent == dentry->d_parent)
> +		goto out_unalias;
> +
> +	/* Check for loops */
> +	ret = ERR_PTR(-ELOOP);
> +	if (d_isparent(alias, dentry))
> +		goto out_err;
> +
> +	/* See lock_rename() */
> +	ret = ERR_PTR(-EBUSY);
> +	if (!mutex_trylock(&dentry->d_sb->s_vfs_rename_mutex))
> +		goto out_err;
> +	m1 = &dentry->d_sb->s_vfs_rename_mutex;
> +	if (!mutex_trylock(&alias->d_parent->d_inode->i_mutex))
> +		goto out_err;
> +	m2 = &alias->d_parent->d_inode->i_mutex;
> +out_unalias:
> +	d_move_locked(alias, dentry);
> +	ret = alias;
> +out_err:
> +	spin_unlock(&dcache_lock);
> +	if (m2)
> +		mutex_unlock(m2);
> +	if (m1)
> +		mutex_unlock(m1);
> +	return ret;
> +}

The locking in there is, of course, gruesome.  There is no way in which it
can be made reliable?


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
