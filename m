From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: [PATCH] Access cache forgetting mode bits
Date: Sun, 31 Aug 2003 16:33:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F525BA8.9020904@RedHat.com>
References: <3F4E302F.5060409@RedHat.com> <1062107512.2121.25.camel@bree.suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000907050205090208020506"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19tYuB-0001Dj-00
	for <nfs@lists.sourceforge.net>; Sun, 31 Aug 2003 13:34:35 -0700
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19tYuA-0002WT-P8
	for nfs@lists.sourceforge.net; Sun, 31 Aug 2003 13:34:34 -0700
To: Andreas Gruenbacher <agruen@suse.de>,
   Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1062107512.2121.25.camel@bree.suse.de>
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
--------------000907050205090208020506
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

I'm thinking there might even be a better way to cache these bits...

It seems the OS calls nfs_permission() to test each permission bit which 
in turn
causes an otw access rpc for every call (assuming the same person and same
bit is *not* asked for ) and even with Andreas patch's there are at 
least two
rpcs for one access call....

Now what if on the first access call, we get *all* of the access bits 
from the
server and cache them locally (i.e. in cache->mask). That way when 
nfs_permission()
is called again, all if the needed info is there... The attached patch 
does just that
and it really seems to cut down on the amount access rpc needed...

Thoughts?

SteveD.


--------------000907050205090208020506
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

--------------000907050205090208020506--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
