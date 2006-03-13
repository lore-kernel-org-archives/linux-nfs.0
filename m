From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] nfs4: fix segfult on errors returned that are < -1000
Date: Mon, 13 Mar 2006 11:05:03 -0500
Message-ID: <20060313160503.GA27685@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, nhorman@tuxdriver.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FIpXq-0006Gq-9T
	for nfs@lists.sourceforge.net; Mon, 13 Mar 2006 08:05:18 -0800
Received: from ra.tuxdriver.com ([24.172.12.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FIpXo-0006Vr-T8
	for nfs@lists.sourceforge.net; Mon, 13 Mar 2006 08:05:18 -0800
To: nfs@lists.sourceforge.net
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

Hey all-
	This was reported to me last week.  If you attempt to mount an nfsv4
share, and the mount syscall for that filesystem returns an error code that is
less than -1000 (of which NFS4 has many), The IS_ERR macro function will
erroniously return false, and do_kern_mount will pass the error code to called
functions as though it were a valid pointer.  This patch fixes up the missed
point in nfs4_get_sb that allows such an error to propogate to do_kern_mount.

Regards
Neil


Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 inode.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)



diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a77ee95..0eb1c57 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2000,7 +2000,7 @@ static struct super_block *nfs4_get_sb(s
 	if (error) {
 		up_write(&s->s_umount);
 		deactivate_super(s);
-		return ERR_PTR(error);
+		return ERR_PTR(nfs4_map_errors(error));
 	}
 	s->s_flags |= MS_ACTIVE;
 	return s;
-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
