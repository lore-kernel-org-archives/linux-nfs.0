From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 0 of 9] Introduction
Date: Fri, 03 Sep 2004 12:34:25 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040903122815.15453.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C33uO-000056-4k
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:36 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C33uN-0007KR-CA
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
To: Andrew Morton <akpm@osdl.org>
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


9 patches for knfsd in 2.6.9-rc1-mm2

The first three affect all versions.  The remaining are v4 specific.

1 - Add O_NONBLOCK to calls to break_lease so the nfs server doesn't block
    pointlessly.  Return nfserr_jukebox for v3, or just drop the reques for
    v2 if we get a EWOULDBLOCK.

2 - Change a return of "ESTALE" or "EACCES" in a situation where ACCES is 
    argueable the more correct error, and real people have had real problems
    that were really fixed.

3 - Fix some indentation.

4 - Check is filesystem supports acls before returning "acl supported" attribute

5-9 assorted v4 locking changes.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
