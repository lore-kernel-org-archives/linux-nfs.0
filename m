From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 7 of 12] lockd: don't try to match callback requests against export table
Date: Tue, 08 Feb 2005 14:06:54 +1100
Message-ID: <E1CyLiI-0006Va-Az@notabene.cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLis-0006vE-0q
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:30 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLir-0004Fs-Gq
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:29 -0800
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



On lockd callbacks, we're a client, and the source address is that of a server,
so we shouldn't be trying to match the source address of the callback request
against our export table.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/lockd/svc.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+)

diff ./fs/lockd/svc.c~current~ ./fs/lockd/svc.c
--- ./fs/lockd/svc.c~current~	2005-02-07 15:04:35.000000000 +1100
+++ ./fs/lockd/svc.c	2005-02-07 15:04:54.000000000 +1100
@@ -403,6 +403,18 @@ static int param_set_##name(const char *
 	return 0;							\
 }
 
+static inline int is_callback(u32 proc)
+{
+	return proc == NLMPROC_GRANTED
+		|| proc == NLMPROC_GRANTED_MSG
+		|| proc == NLMPROC_TEST_RES
+		|| proc == NLMPROC_LOCK_RES
+		|| proc == NLMPROC_CANCEL_RES
+		|| proc == NLMPROC_UNLOCK_RES
+		|| proc == NLMPROC_NSM_NOTIFY;
+}
+
+
 static int lockd_authenticate(struct svc_rqst *rqstp)
 {
 	rqstp->rq_client = NULL;
@@ -411,6 +423,12 @@ static int lockd_authenticate(struct svc
 		case RPC_AUTH_UNIX:
 			if (rqstp->rq_proc == 0)
 				return SVC_OK;
+			if (is_callback(rqstp->rq_proc)) {
+				/* Leave it to individual procedures to
+				 * call nlmsvc_lookup_host(rqstp)
+				 */
+				return SVC_OK;
+			}
 			return svc_set_client(rqstp);
 	}
 	return SVC_DENIED;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
