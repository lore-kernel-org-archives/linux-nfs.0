From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: [PATCH] Access cache forgetting mode bits
Date: Fri, 29 Aug 2003 09:14:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F4F51C4.10605@RedHat.com>
References: <3F4E302F.5060409@RedHat.com> <1062107512.2121.25.camel@bree.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sj6d-0000B5-00
	for <nfs@lists.sourceforge.net>; Fri, 29 Aug 2003 06:15:59 -0700
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19sj6c-00036K-78
	for nfs@lists.sourceforge.net; Fri, 29 Aug 2003 06:15:58 -0700
To: Andreas Gruenbacher <agruen@suse.de>
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

Andreas Gruenbacher wrote:

>your idea idea is good, but the patch is incorrect in at least two ways:
>(1) it merges the cached results of successful and unsuccessful
>requests, (2) [access("file", R_OK) == 0] and [access("file", W_OK) ==
>0] does not imply [access("file", R_OK | W_OK) == 0].
>
Good point!

>[....] How about the attached patch? In the worst case, with "weird" permissions
>this will double the number of RPCs needed, but this will not happen on
>"real" systems.
>
Yes... your patch does seem to work with "normal" cases.... which is 
probably the
best we can hope for...

>The NFS access cache has a problem if mounted file systems are accessed
>by multiple users: The results of only a single user are cached. When
>another user comes along, cache trashing similar to what Steve has
>observed will occur.
>  
>
True... its too bad the cred cache doesn't use uids and gids....

>Steve, you seem to be looking into the nfsacl extensions as well. ACLs
>are not cached on the client side, so operations like `ls -l' (which
>need to check which files have ACLs) also produce lots of RPCs. I don't
>see this as a significant problem at this point.
>
Caches are always a good idea wrt to NFS... but I guess only time will 
tell wrt nfsacls...

SteveD.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
