From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] Access cache forgetting mode bits
Date: Thu, 28 Aug 2003 12:39:11 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F4E302F.5060409@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040805050108050401080104"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sPmj-0003aB-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 09:38:09 -0700
Received: from pix-525-pool.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19sPmj-00056X-4x
	for nfs@lists.sourceforge.net; Thu, 28 Aug 2003 09:38:09 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h7SGc6K00310
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 12:38:06 -0400
To: nfs@lists.sourceforge.net
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

This is a multi-part message in MIME format.
--------------040805050108050401080104
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

While debugging something else, I notice that every time
I did a ls on a nfs mounted directory a wto ACCESS rpc was
*always* happening (with a  2.4.21 kernel). Taking a closer
look it turns out the access cache  was dropping previous
access bits. Here is the scenario...

nfs_permission is called with mode = MAY_EXEC
the cached value is Zero so an ACCESS rpc is done.
after the rpc, the cached value is _set_ to MAY_EXEC

then nfs_permission is called with mode = MAY_READ
the cached value is MAY_EXEC, so an ACCESS rpc is done.
after the rpc, the cache value is _set_ to MAY_READ

again, nfs_permission is called with mode = MAY_EXEC
this time the cached value is MAY_READ so _again_ an RPC is done
after the rpc, the cached value is _set_ to MAY_EXEC

Its a vicious cycle...

So this patch changes the setting of the masked value
to the or-ing of the masked value. This cause the
previous bits to be remembered thus cutting down on
the number of otw rpcs...


SteveD.

--------------040805050108050401080104
Content-Type: text/plain;
 name="linux-2.4.21-nfs-accesscache.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-accesscache.patch"

--- linux-2.4.21/fs/nfs/dir.c.diff	2003-08-28 12:13:22.000000000 -0400
+++ linux-2.4.21/fs/nfs/dir.c	2003-08-28 12:13:47.000000000 -0400
@@ -1278,7 +1278,7 @@ nfs_permission(struct inode *inode, int 
 		if (cache->cred)
 			put_rpccred(cache->cred);
 		cache->cred = cred;
-		cache->mask = mask;
+		cache->mask |= mask;
 		cache->err = error;
 		return error;
 	}

--------------040805050108050401080104--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
