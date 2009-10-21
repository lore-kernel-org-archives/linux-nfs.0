From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [PATCH] nfsd: Fix sort_pacl in fs/nfsd/nf4acl.c to actually sort
	groups
Date: Wed, 21 Oct 2009 16:45:02 -0700
Message-ID: <1256168703.31791.14.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank S Filz <ffilz@us.ibm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: NFS List <linux-nfs@vger.kernel.org>,
	NFS V4 Mailing List <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:51770 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897AbZJUXnn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2009 19:43:43 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9LNgJde008087
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2009 19:42:19 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9LNhl58255580
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2009 19:43:47 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9LNhk2Y016183
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2009 19:43:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have been doing some extensive testing of Linux support for ACLs on
NFDS v4. We have noticed that the server rejects ACLs where the groups
are out of order, for example, the following ACL is rejected:

A::OWNER@:rwaxtTcCy
A::user101@domain:rwaxtcy
A::GROUP@:rwaxtcy
A:g:group102@domain:rwaxtcy
A:g:group101@domain:rwaxtcy
A::EVERYONE@:rwaxtcy

Examining the server code, I found that after converting an NFS v4 ACL
to POSIX, sort_pacl is called to sort the user ACEs and group ACEs.
Unfortunately, a minor bug causes the group sort to be skipped.

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
---
 fs/nfsd/nfs4acl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 725d02f..6d9c6aa 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -389,7 +389,7 @@ sort_pacl(struct posix_acl *pacl)
 	sort_pacl_range(pacl, 1, i-1);
 
 	BUG_ON(pacl->a_entries[i].e_tag != ACL_GROUP_OBJ);
-	j = i++;
+	j = ++i;
 	while (pacl->a_entries[j].e_tag == ACL_GROUP)
 		j++;
 	sort_pacl_range(pacl, i, j-1);
-- 
1.5.2.2



