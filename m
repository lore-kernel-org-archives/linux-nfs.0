From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd ] Make sure nfsd doesn't hog a cpu forever.
Date: Tue, 15 Nov 2005 12:54:29 +1100
Message-ID: <1051115015429.9307@cse.unsw.edu.au>
References: <20051115125307.9288.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ebq1v-0008FR-Fv
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 17:54:39 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ebq1u-0005d6-Au
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 17:54:39 -0800
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

Against 2.6.14-mm2, or 2.6.15-rc1
### Comments for Changeset

Being kernel-threads, nfsd servers don't get pre-empted (depending on
CONIG).  If there is a steady stream of NFS requests that can be
served from cache, an nfsd thread may hold on to a cpu indefinitely ,
which isn't very friendly.

So it is good to have a cond_resched in there (just before looking for
a new request to serve), to make sure we play nice.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |    1 +
 1 file changed, 1 insertion(+)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2005-11-15 10:24:52.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2005-11-15 10:24:52.000000000 +1100
@@ -1181,6 +1181,7 @@ svc_recv(struct svc_serv *serv, struct s
 	arg->tail[0].iov_len = 0;
 
 	try_to_freeze();
+	cond_resched();
 	if (signalled())
 		return -EINTR;
 


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
