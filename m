From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: possible NULL pointer deref in
	nfs_sillyrename()
Date: Wed, 16 Aug 2006 20:16:41 -0400
Message-ID: <1155773801.6739.5.camel@localhost>
References: <200608170022.29168.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Rick Sladkey <jrs@world.std.com>, Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GDVZH-0007Od-Pw
	for nfs@lists.sourceforge.net; Wed, 16 Aug 2006 17:17:03 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GDVZG-0000i8-Ua
	for nfs@lists.sourceforge.net; Wed, 16 Aug 2006 17:17:04 -0700
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: <200608170022.29168.jesper.juhl@gmail.com>
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

On Thu, 2006-08-17 at 00:22 +0200, Jesper Juhl wrote:
> The coverity checker spotted this as bug #1013.
> 
> If we get a NULL dentry->d_inode, then regardless of 
> NFS_PARANOIA or no NFS_PARANOIA, then if 
>    if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
> turns out to be false we'll end up dereferencing 
> that NULL d_inode in two places below.
> 
> And since the check for "(!dentry->d_inode)" even exists
> (although inside #ifdef NFS_PARANOIA) I take that to mean
> that this is a possibility. 

Sorry, but it isn't possible. See the checks in may_delete() (which is
called before ->unlink()) and nfs_rename().

IOW: Feel free to kill the NFS_PARANOIA crap. It looks like legacy code
from a debugging session about a decade or so ago.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
