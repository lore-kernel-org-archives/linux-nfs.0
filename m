From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 8] knfsd: Assorted bugfixes for 2.6.22
Date: Mon, 7 May 2007 10:35:09 +1000
Message-ID: <20070507103211.23855.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HkrCO-00050U-ET
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:35:32 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HkrCP-0002bM-MT
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:35:35 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Following are 8 patches for knfsd and related code that are suitable for
2.6.22.

First two are suitable for -stable: they can cause an oops.
(8 can also cause an oops, but you really need buggy userspace code 
running as root, and it is a larger patch than I like to send to -stable).

Other 6 are less significant bug fixes and cleanups.

Thanks,
NeilBrown


 [PATCH 001 of 8] knfsd: Avoid use of unitialised variables on error path when nfs exports.
 [PATCH 002 of 8] knfsd: rpc: fix server-side wrapping of krb5i replies
 [PATCH 003 of 8] knfsd: Fix resource leak resulting in module refcount leak for	rpcsec_gss_krb5.ko
 [PATCH 004 of 8] knfsd: rpcgss : RPC_GSS_PROC_ DESTROY request will get a bad rpc
 [PATCH 005 of 8] knfsd: Simplify a 'while' condition in svcsock.c
 [PATCH 006 of 8] knfsd: Trivial makefile cleanup
 [PATCH 007 of 8] knfsd: Various nfsd xdr cleanups.
 [PATCH 008 of 8] knfsd: Avoid Oops if buggy userspace performs confusing filehandle->dentry mapping.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
