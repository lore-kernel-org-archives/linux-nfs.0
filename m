From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 008 of 28] nfsd4: rename nfs4_state_init
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006i4-El@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3R-0005xa-N9
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:17 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3Q-0002Rs-II
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:17 -0700
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


Somewhat gratuitous rename to simplify following patch.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c       |    6 +++---
 ./fs/nfsd/nfssvc.c          |    4 ++--
 ./include/linux/nfsd/nfsd.h |    4 ++--
 3 files changed, 7 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:20:59.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:00.000000000 +1000
@@ -3185,7 +3185,7 @@ nfs4_check_open_reclaim(clientid_t *clid
  */
 
 static void
-__nfs4_state_init(void)
+__nfs4_state_start(void)
 {
 	int i;
 	time_t grace_time;
@@ -3235,7 +3235,7 @@ __nfs4_state_init(void)
 }
 
 int
-nfs4_state_init(void)
+nfs4_state_start(void)
 {
 	int status;
 
@@ -3244,7 +3244,7 @@ nfs4_state_init(void)
 	status = nfsd4_init_slabs();
 	if (status)
 		return status;
-	__nfs4_state_init();
+	__nfs4_state_start();
 	nfs4_init = 1;
 	return 0;
 }

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2005-05-31 14:21:00.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2005-05-31 14:21:00.000000000 +1000
@@ -92,10 +92,10 @@ nfsd_svc(unsigned short port, int nrserv
 		nrservs = NFSD_MAXSERVS;
 	
 	/* Readahead param cache - will no-op if it already exists */
- 	error =	nfsd_racache_init(2*nrservs);
+	error =	nfsd_racache_init(2*nrservs);
 	if (error<0)
 		goto out;
-	error = nfs4_state_init();
+	error = nfs4_state_start();
 	if (error<0)
 		goto out;
 	if (!nfsd_serv) {

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2005-05-31 14:21:00.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2005-05-31 14:21:00.000000000 +1000
@@ -145,12 +145,12 @@ int nfsd_set_posix_acl(struct svc_fh *, 
  * NFSv4 State
  */
 #ifdef CONFIG_NFSD_V4
-int nfs4_state_init(void);
+int nfs4_state_start(void);
 void nfs4_state_shutdown(void);
 time_t nfs4_lease_time(void);
 void nfs4_reset_lease(time_t leasetime);
 #else
-static inline int nfs4_state_init(void){return 0;}
+static inline int nfs4_state_start(void){return 0;}
 static inline void nfs4_state_shutdown(void){}
 static inline time_t nfs4_lease_time(void){return 0;}
 static inline void nfs4_reset_lease(time_t leasetime){}


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
