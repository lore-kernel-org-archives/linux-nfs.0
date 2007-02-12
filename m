From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 9] knfsd: NFSv4 ACL improvements and a couple
	of bug fixes.
Date: Tue, 13 Feb 2007 10:43:56 +1100
Message-ID: <20070213103941.28958.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGkqZ-0005Vw-DM
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:44:39 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HGkqZ-0000ft-V2
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:44:37 -0800
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

following are 9 patches from Bruce Fields for the NFSv4 server,
mostly ACL related.
Suitable for 2.6.21.

Thanks,
NeilBrown


 [PATCH 001 of 9] knfsd: nfsd4: fix non-terminated string
 [PATCH 002 of 9] knfsd: nfsd4: relax checking of ACL inheritance bits
 [PATCH 003 of 9] knfsd: nfsd4: simplify nfsv4->posix translation
 [PATCH 004 of 9] knfsd: nfsd4: represent nfsv4 acl with array instead of linked list
 [PATCH 005 of 9] knfsd: nfsd4: fix memory leak on kmalloc failure in savemem
 [PATCH 006 of 9] knfsd: nfsd4: fix error return on unsupported acl
 [PATCH 007 of 9] knfsd: nfsd4: acls: don't return explicit mask
 [PATCH 008 of 9] knfsd: nfsd4: acls: avoid unnecessary denies
 [PATCH 009 of 9] knfsd: nfsd4: fix handling of directories without default ACLs

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
