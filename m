From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] Access cache forgetting mode bits
Date: 28 Aug 2003 23:51:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1062107512.2121.25.camel@bree.suse.de>
References: <3F4E302F.5060409@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-utKkmKL8uN6HfZ9XFdt8"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sUe1-0004I1-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 14:49:29 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19sUe1-0006qf-1Z
	for nfs@lists.sourceforge.net; Thu, 28 Aug 2003 14:49:29 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3F4E302F.5060409@RedHat.com>
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


--=-utKkmKL8uN6HfZ9XFdt8
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

your idea idea is good, but the patch is incorrect in at least two ways:
(1) it merges the cached results of successful and unsuccessful
requests, (2) [access("file", R_OK) == 0] and [access("file", W_OK) ==
0] does not imply [access("file", R_OK | W_OK) == 0].

Luckily, [access("file", R_OK | W_OK) == 0] does imply both
[access("file", R_OK) == 0] and [access("file", W_OK) == 0] though. We
could take this to our advantage, and optimize for the common case. How
about the attached patch? In the worst case, with "weird" permissions
this will double the number of RPCs needed, but this will not happen on
"real" systems.


The NFS access cache has a problem if mounted file systems are accessed
by multiple users: The results of only a single user are cached. When
another user comes along, cache trashing similar to what Steve has
observed will occur.

Steve, you seem to be looking into the nfsacl extensions as well. ACLs
are not cached on the client side, so operations like `ls -l' (which
need to check which files have ACLs) also produce lots of RPCs. I don't
see this as a significant problem at this point.


On Thu, 2003-08-28 at 18:39, Steve Dickson wrote:
> While debugging something else, I notice that every time
> I did a ls on a nfs mounted directory a wto ACCESS rpc was
> *always* happening (with a  2.4.21 kernel). Taking a closer
> look it turns out the access cache  was dropping previous
> access bits. Here is the scenario...
> 
> nfs_permission is called with mode = MAY_EXEC
> the cached value is Zero so an ACCESS rpc is done.
> after the rpc, the cached value is _set_ to MAY_EXEC
> 
> then nfs_permission is called with mode = MAY_READ
> the cached value is MAY_EXEC, so an ACCESS rpc is done.
> after the rpc, the cache value is _set_ to MAY_READ
> 
> again, nfs_permission is called with mode = MAY_EXEC
> this time the cached value is MAY_READ so _again_ an RPC is done
> after the rpc, the cached value is _set_ to MAY_EXEC
> 
> Its a vicious cycle...
> 
> So this patch changes the setting of the masked value
> to the or-ing of the masked value. This cause the
> previous bits to be remembered thus cutting down on
> the number of otw rpcs...
> 
> 
> SteveD.
> 
> ______________________________________________________________________
> 
> --- linux-2.4.21/fs/nfs/dir.c.diff	2003-08-28 12:13:22.000000000 -0400
> +++ linux-2.4.21/fs/nfs/dir.c	2003-08-28 12:13:47.000000000 -0400
> @@ -1278,7 +1278,7 @@ nfs_permission(struct inode *inode, int 
>  		if (cache->cred)
>  			put_rpccred(cache->cred);
>  		cache->cred = cred;
> -		cache->mask = mask;
> +		cache->mask |= mask;
>  		cache->err = error;
>  		return error;
>  	}


Cheers,
-- 
Andreas Gruenbacher <agruen@suse.de>
SuSE Labs, SuSE Linux AG <http://www.suse.de/>


--=-utKkmKL8uN6HfZ9XFdt8
Content-Disposition: attachment; filename=nfsd-optimistic-caching.diff
Content-Type: text/plain; name=nfsd-optimistic-caching.diff; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Index: linux-2.4.21/fs/nfs/dir.c
===================================================================
--- linux-2.4.21.orig/fs/nfs/dir.c	2003-08-28 16:50:33.000000000 +0200
+++ linux-2.4.21/fs/nfs/dir.c	2003-08-28 23:19:27.000000000 +0200
@@ -1266,6 +1266,13 @@ nfs_permission(struct inode *inode, int 
 			/* Is the mask a subset of an accepted mask? */
 			if ((cache->mask & mask) == mask)
 				goto out_cached;
+			/* Try with expanded credentials. */
+			error = NFS_PROTO(inode)->access(inode, cred,
+							 mask | cache->mask);
+			if (!error || !cache->mask) {
+				mask |= cache->mask;
+				goto rpc_done;
+			}
 	       	} else {
 			/* ...or is it a superset of a rejected mask? */
 			if ((cache->mask & mask) == cache->mask)
@@ -1273,6 +1280,7 @@ nfs_permission(struct inode *inode, int 
 		}
 	}
 	error = NFS_PROTO(inode)->access(inode, cred, mask);
+rpc_done:
 	if (!error || error == -EACCES) {
 		cache->jiffies = jiffies;
 		if (cache->cred)

--=-utKkmKL8uN6HfZ9XFdt8--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
