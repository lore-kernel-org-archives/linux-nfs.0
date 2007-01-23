From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 5] knfsd: Don't mess with the 'mode' when
	storing a exclusive-create cookie.
Date: Tue, 23 Jan 2007 11:22:31 +1100
Message-ID: <1070123002231.27868@suse.de>
References: <20070123111558.27683.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H99RA-0007Rl-FH
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 16:22:56 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H99RB-0002Gi-Fu
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 16:22:58 -0800
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


From: Peter Staubach <staubach@redhat.com>

NFS V3 (and V4) support exclusive create by passing a 'cookie' which
can get stored with the file.  If the file exists but has exactly the
right cookie stored, then we assume this is a retransmit and the
exclusive create was successful.

The cookie is 64bits and is traditionally stored in the mtime and
atime fields.  This causes a problem with Solaris7 as negative mtime
or atime confuse it.  So we moved two bits into the mode word instead.

But inherited ACLs sometimes overwrite the mode word on create, so
this is a problem.

So we give up and just store 62 of the 64 bits and assume that is
close enough.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/vfs.c |   21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2007-01-23 11:14:54.000000000 +1100
+++ ./fs/nfsd/vfs.c	2007-01-23 11:15:06.000000000 +1100
@@ -1249,7 +1249,6 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 	__be32		err;
 	int		host_err;
 	__u32		v_mtime=0, v_atime=0;
-	int		v_mode=0;
 
 	err = nfserr_perm;
 	if (!flen)
@@ -1286,16 +1285,11 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		goto out;
 
 	if (createmode == NFS3_CREATE_EXCLUSIVE) {
-		/* while the verifier would fit in mtime+atime,
-		 * solaris7 gets confused (bugid 4218508) if these have
-		 * the high bit set, so we use the mode as well
+		/* solaris7 gets confused (bugid 4218508) if these have
+		 * the high bit set, so just clear the high bits.
 		 */
 		v_mtime = verifier[0]&0x7fffffff;
 		v_atime = verifier[1]&0x7fffffff;
-		v_mode  = S_IFREG
-			| ((verifier[0]&0x80000000) >> (32-7)) /* u+x */
-			| ((verifier[1]&0x80000000) >> (32-9)) /* u+r */
-			;
 	}
 	
 	if (dchild->d_inode) {
@@ -1323,7 +1317,6 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		case NFS3_CREATE_EXCLUSIVE:
 			if (   dchild->d_inode->i_mtime.tv_sec == v_mtime
 			    && dchild->d_inode->i_atime.tv_sec == v_atime
-			    && dchild->d_inode->i_mode  == v_mode
 			    && dchild->d_inode->i_size  == 0 )
 				break;
 			 /* fallthru */
@@ -1345,26 +1338,22 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 	}
 
 	if (createmode == NFS3_CREATE_EXCLUSIVE) {
-		/* Cram the verifier into atime/mtime/mode */
+		/* Cram the verifier into atime/mtime */
 		iap->ia_valid = ATTR_MTIME|ATTR_ATIME
-			| ATTR_MTIME_SET|ATTR_ATIME_SET
-			| ATTR_MODE;
+			| ATTR_MTIME_SET|ATTR_ATIME_SET;
 		/* XXX someone who knows this better please fix it for nsec */ 
 		iap->ia_mtime.tv_sec = v_mtime;
 		iap->ia_atime.tv_sec = v_atime;
 		iap->ia_mtime.tv_nsec = 0;
 		iap->ia_atime.tv_nsec = 0;
-		iap->ia_mode  = v_mode;
 	}
 
 	/* Set file attributes.
-	 * Mode has already been set but we might need to reset it
-	 * for CREATE_EXCLUSIVE
 	 * Irix appears to send along the gid when it tries to
 	 * implement setgid directories via NFS. Clear out all that cruft.
 	 */
  set_attr:
-	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID)) != 0) {
+	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID|ATTR_MODE)) != 0) {
  		__be32 err2 = nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
 		if (err2)
 			err = err2;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
