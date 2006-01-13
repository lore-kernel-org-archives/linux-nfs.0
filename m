From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 025 of 26] NFSERR_SERVERFAULT returned host-endian
Date: Fri, 13 Jan 2006 12:01:07 +1100
Message-ID: <1060113010107.23228@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJc-0002b8-QQ
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:16 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJc-00057H-Bz
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:16 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:12 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:08 +1100
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


From: Al Viro <viro@zeniv.linux.org.uk>
Date: 1135492936 -0500

->rp_status is network-endian and nobody byteswaps it before sending to
client; putting NFSERR_SERVERFAULT instead of nfserr_serverfault in there
is not nice...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:51:10.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:10.000000000 +1100
@@ -1088,7 +1088,7 @@ alloc_init_open_stateowner(unsigned int 
 	sop->so_seqid = open->op_seqid;
 	sop->so_confirmed = 0;
 	rp = &sop->so_replay;
-	rp->rp_status = NFSERR_SERVERFAULT;
+	rp->rp_status = nfserr_serverfault;
 	rp->rp_buflen = 0;
 	rp->rp_buf = rp->rp_ibuf;
 	return sop;
@@ -2583,7 +2583,7 @@ alloc_init_lock_stateowner(unsigned int 
 	sop->so_seqid = lock->lk_new_lock_seqid + 1;
 	sop->so_confirmed = 1;
 	rp = &sop->so_replay;
-	rp->rp_status = NFSERR_SERVERFAULT;
+	rp->rp_status = nfserr_serverfault;
 	rp->rp_buflen = 0;
 	rp->rp_buf = rp->rp_ibuf;
 	return sop;


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
