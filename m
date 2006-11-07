From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS4  fix for recursive locking problem.
Date: Mon, 6 Nov 2006 19:26:57 -0500
Message-ID: <20061107002657.GN12372@fieldses.org>
References: <454755B0.5020103@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@osdl.org, neilb@suse.de, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, andros@citi.umich.edu
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhEnz-0006kv-3e
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 16:27:07 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GhEny-0003Ci-VR
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 16:27:08 -0800
To: Srinivasa Ds <srinivasa@in.ibm.com>
In-Reply-To: <454755B0.5020103@in.ibm.com>
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

On Tue, Oct 31, 2006 at 07:24:56PM +0530, Srinivasa Ds wrote:
> When I was performing some operations on NFS, I got below error on server 
> side.
> 
> ===========================================================
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 2.6.19-prep #1
...
> So I have developed the patch to overcome this problem. Please let me know 
> your comments on this.

Looks right, thanks!

--b.

> Signed-off-by: Srinivasa DS <srinivasa@in.ibm.com>
> 
> 
> 

>  nfs4recover.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.19-rc3/fs/nfsd/nfs4recover.c
> ===================================================================
> --- linux-2.6.19-rc3.orig/fs/nfsd/nfs4recover.c	2006-10-24 04:32:02.000000000 +0530
> +++ linux-2.6.19-rc3/fs/nfsd/nfs4recover.c	2006-10-31 18:27:30.000000000 +0530
> @@ -274,7 +274,7 @@
>  	 * any regular files anyway, just in case the directory was created by
>  	 * a kernel from the future.... */
>  	nfsd4_list_rec_dir(dentry, nfsd4_remove_clid_file);
> -	mutex_lock(&dir->d_inode->i_mutex);
> +	mutex_lock_nested(&dir->d_inode->i_mutex, I_MUTEX_PARENT);
>  	status = vfs_rmdir(dir->d_inode, dentry);
>  	mutex_unlock(&dir->d_inode->i_mutex);
>  	return status;


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
