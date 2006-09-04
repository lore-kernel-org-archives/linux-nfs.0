From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 9] knfsd: minor gss/v4 cleanups and major ACL
	surgery.
Date: Tue, 5 Sep 2006 09:15:21 +1000
Message-ID: <20060905090617.21303.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKNf9-0000K5-EA
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:15:31 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKNfB-0005Mu-P7
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:15:35 -0700
To: Andrew Morton <akpm@osdl.org>
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

Following are 9 patches for nfsd from Bruce Fields.  First 5 are minor
cleanups around gss code and elsewhere.  Last 4 make substantial
changes to ACL handling, particularly for mapping between Posix draft
ACLs and NFSv4 ACLs.

Thanks,
NeilBrown


 [PATCH 001 of 9] knfsd: svcrpc: gss: factor out some common wrapping code
 [PATCH 002 of 9] knfsd: svcrpc: gss: fix failure on SVC_DENIED in integrity case
 [PATCH 003 of 9] knfsd: svcrpc: use consistent variable name for the reply state
 [PATCH 004 of 9] knfsd: nfsd4: refactor exp_pseudoroot
 [PATCH 005 of 9] knfsd: nfsd4: clean up exp_pseudoroot
 [PATCH 006 of 9] knfsd: nfsd4: acls: relax the nfsv4->posix mapping
 [PATCH 007 of 9] knfsd: nfsd4: acls: fix inheritance
 [PATCH 008 of 9] knfsd: nfsd4: acls: simplify nfs4_acl_nfsv4_to_posix interface
 [PATCH 009 of 9] knfsd: nfsd4: acls: fix handling of zero-length acls

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
