From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] Access cache forgetting mode bits
Date: 01 Sep 2003 01:25:17 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1062372316.2341.16.camel@bree.suse.de>
References: <3F4E302F.5060409@RedHat.com>
	 <1062107512.2121.25.camel@bree.suse.de>  <3F525BA8.9020904@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-jckWpWOS3IcQhajBjVq8"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19tbWR-0003o0-00
	for <nfs@lists.sourceforge.net>; Sun, 31 Aug 2003 16:22:15 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19tbWQ-00077u-HY
	for nfs@lists.sourceforge.net; Sun, 31 Aug 2003 16:22:14 -0700
To: Steve Dickson <SteveD@RedHat.com>
In-Reply-To: <3F525BA8.9020904@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-jckWpWOS3IcQhajBjVq8
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2003-08-31 at 22:33, Steve Dickson wrote:
> Hello,
> 
> I'm thinking there might even be a better way to cache these bits...
> 
> It seems the OS calls nfs_permission() to test each permission

Individually you mean? That's not at all the case in general.

> [...] even with Andreas patch's there are at least two rpcs for one access call....

No, two different, consecutice permission checks will result in two
RPCs.

It is possible to optimize another common case: Directory accesses are
seldom denied, and users are usually granted both r and x at once. The
attached patch optimizes that; it's the same pattern as in my first
patch. I'm in doubt whether this optimization is worth it, though.

For non-directories, I don't think a common enough case exists that
would deserve optimization.

> what if on the first access call, we get *all* of the access bits 
> from the
> server and cache them locally (i.e. in cache->mask). That way when 
> nfs_permission()
> is called again, all if the needed info is there... The attached patch 
> does just that
> and it really seems to cut down on the amount access rpc needed...
>
> Thoughts?

You have again attached your first, buggy patch.


Cheers,
-- 
Andreas Gruenbacher <agruen@suse.de>
SuSE Labs, SuSE Linux AG <http://www.suse.de/>


--=-jckWpWOS3IcQhajBjVq8
Content-Disposition: attachment; filename=nfs-more-optimistic.diff
Content-Type: text/plain; name=nfs-more-optimistic.diff; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Index: linux-2.4.21/fs/nfs/dir.c
===================================================================
--- linux-2.4.21.orig/fs/nfs/dir.c	2003-09-01 00:46:26.000000000 +0200
+++ linux-2.4.21/fs/nfs/dir.c	2003-09-01 01:09:27.000000000 +0200
@@ -1278,6 +1278,13 @@ nfs_permission(struct inode *inode, int 
 			if ((cache->mask & mask) == cache->mask)
 				goto out_cached;
 		}
+	} else if (S_ISDIR(mode)) {
+		int try_mask = mask | S_IROTH | S_IXOTH;
+		error = NFS_PROTO(inode)->access(inode, cred, try_mask);
+		if (!error || mask == try_mask) {
+			mask = try_mask;
+			goto rpc_done;
+		}
 	}
 	error = NFS_PROTO(inode)->access(inode, cred, mask);
 rpc_done:

--=-jckWpWOS3IcQhajBjVq8--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
