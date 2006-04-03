From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 16] knfsd: nfsd4: better nfs4acl errors
Date: Mon, 3 Apr 2006 15:18:18 +1000
Message-ID: <1060403051818.1757@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQHU0-0005Rm-Rt
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:08 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FQHTy-0008Gq-SH
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:08 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
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


We're returning -1 in a few places in the NFSv4<->POSIX acl translation
code where we could return a reasonable error.

Also allows some minor simplification elsewhere.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |    6 +++---
 ./fs/nfsd/nfs4xdr.c |    7 +++----
 2 files changed, 6 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4acl.c~current~ ./fs/nfsd/nfs4acl.c
--- ./fs/nfsd/nfs4acl.c~current~	2006-04-03 15:12:05.000000000 +1000
+++ ./fs/nfsd/nfs4acl.c	2006-04-03 15:12:06.000000000 +1000
@@ -710,9 +710,9 @@ calculate_posix_ace_count(struct nfs4_ac
 		/* Also, the remaining entries are for named users and
 		 * groups, and come in threes (mask, allow, deny): */
 		if (n4acl->naces < 7)
-			return -1;
+			return -EINVAL;
 		if ((n4acl->naces - 7) % 3)
-			return -1;
+			return -EINVAL;
 		return 4 + (n4acl->naces - 7)/3;
 	}
 }
@@ -866,7 +866,7 @@ nfs4_acl_add_ace(struct nfs4_acl *acl, u
 	struct nfs4_ace *ace;
 
 	if ((ace = kmalloc(sizeof(*ace), GFP_KERNEL)) == NULL)
-		return -1;
+		return -ENOMEM;
 
 	ace->type = type;
 	ace->flag = flag;

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2006-04-03 15:12:06.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2006-04-03 15:12:06.000000000 +1000
@@ -299,11 +299,10 @@ nfsd4_decode_fattr(struct nfsd4_compound
 						buf, dummy32, &ace.who);
 			if (status)
 				goto out_nfserr;
-			if (nfs4_acl_add_ace(*acl, ace.type, ace.flag,
-				 ace.access_mask, ace.whotype, ace.who) != 0) {
-				status = -ENOMEM;
+			status = nfs4_acl_add_ace(*acl, ace.type, ace.flag,
+				 ace.access_mask, ace.whotype, ace.who);
+			if (status)
 				goto out_nfserr;
-			}
 		}
 	} else
 		*acl = NULL;


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
