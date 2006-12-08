From: NeilBrown <neilb@suse.de>
Subject: [PATCH 012 of 18] knfsd: nfsd4: don't inline nfsd4 compound
	op functions
Date: Fri, 8 Dec 2006 12:14:25 +1100
Message-ID: <1061208011425.30701@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUJZ-0003Dw-CW
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:13 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUJZ-0001Er-V2
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:14 -0800
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


From: J.Bruce Fields <bfields@fieldses.org>

The inlining contributes to bloating the stack of nfsd4_compound, and
I want to change the compound op functions to function pointers anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |   43 ++++++++++++++++++-------------------------
 1 file changed, 18 insertions(+), 25 deletions(-)

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2006-12-08 12:09:27.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-12-08 12:09:29.000000000 +1100
@@ -33,13 +33,6 @@
  *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
- * Note: some routines in this file are just trivial wrappers
- * (e.g. nfsd4_lookup()) defined solely for the sake of consistent
- * naming.  Since all such routines have been declared "inline",
- * there shouldn't be any associated overhead.  At some point in
- * the future, I might inline these "by hand" to clean up a
- * little.
  */
 
 #include <linux/param.h>
@@ -161,7 +154,7 @@ do_open_fhandle(struct svc_rqst *rqstp, 
 }
 
 
-static inline __be32
+static __be32
 nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	   struct nfsd4_open *open)
 {
@@ -264,7 +257,7 @@ out:
 /*
  * filehandle-manipulating ops.
  */
-static inline __be32
+static __be32
 nfsd4_getfh(struct nfsd4_compound_state *cstate, struct svc_fh **getfh)
 {
 	if (!cstate->current_fh.fh_dentry)
@@ -274,7 +267,7 @@ nfsd4_getfh(struct nfsd4_compound_state 
 	return nfs_ok;
 }
 
-static inline __be32
+static __be32
 nfsd4_putfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_putfh *putfh)
 {
@@ -285,7 +278,7 @@ nfsd4_putfh(struct svc_rqst *rqstp, stru
 	return fh_verify(rqstp, &cstate->current_fh, 0, MAY_NOP);
 }
 
-static inline __be32
+static __be32
 nfsd4_putrootfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate)
 {
 	__be32 status;
@@ -296,7 +289,7 @@ nfsd4_putrootfh(struct svc_rqst *rqstp, 
 	return status;
 }
 
-static inline __be32
+static __be32
 nfsd4_restorefh(struct nfsd4_compound_state *cstate)
 {
 	if (!cstate->save_fh.fh_dentry)
@@ -306,7 +299,7 @@ nfsd4_restorefh(struct nfsd4_compound_st
 	return nfs_ok;
 }
 
-static inline __be32
+static __be32
 nfsd4_savefh(struct nfsd4_compound_state *cstate)
 {
 	if (!cstate->current_fh.fh_dentry)
@@ -319,7 +312,7 @@ nfsd4_savefh(struct nfsd4_compound_state
 /*
  * misc nfsv4 ops
  */
-static inline __be32
+static __be32
 nfsd4_access(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_access *access)
 {
@@ -331,7 +324,7 @@ nfsd4_access(struct svc_rqst *rqstp, str
 			   &access->ac_supported);
 }
 
-static inline __be32
+static __be32
 nfsd4_commit(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_commit *commit)
 {
@@ -434,7 +427,7 @@ nfsd4_create(struct svc_rqst *rqstp, str
 	return status;
 }
 
-static inline __be32
+static __be32
 nfsd4_getattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      struct nfsd4_getattr *getattr)
 {
@@ -454,7 +447,7 @@ nfsd4_getattr(struct svc_rqst *rqstp, st
 	return nfs_ok;
 }
 
-static inline __be32
+static __be32
 nfsd4_link(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	   struct nfsd4_link *link)
 {
@@ -488,7 +481,7 @@ nfsd4_lookupp(struct svc_rqst *rqstp, st
 			   "..", 2, &cstate->current_fh);
 }
 
-static inline __be32
+static __be32
 nfsd4_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_lookup *lookup)
 {
@@ -497,7 +490,7 @@ nfsd4_lookup(struct svc_rqst *rqstp, str
 			   &cstate->current_fh);
 }
 
-static inline __be32
+static __be32
 nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	   struct nfsd4_read *read)
 {
@@ -527,7 +520,7 @@ out:
 	return status;
 }
 
-static inline __be32
+static __be32
 nfsd4_readdir(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      struct nfsd4_readdir *readdir)
 {
@@ -551,7 +544,7 @@ nfsd4_readdir(struct svc_rqst *rqstp, st
 	return nfs_ok;
 }
 
-static inline __be32
+static __be32
 nfsd4_readlink(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	       struct nfsd4_readlink *readlink)
 {
@@ -560,7 +553,7 @@ nfsd4_readlink(struct svc_rqst *rqstp, s
 	return nfs_ok;
 }
 
-static inline __be32
+static __be32
 nfsd4_remove(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_remove *remove)
 {
@@ -579,7 +572,7 @@ nfsd4_remove(struct svc_rqst *rqstp, str
 	return status;
 }
 
-static inline __be32
+static __be32
 nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_rename *rename)
 {
@@ -612,7 +605,7 @@ nfsd4_rename(struct svc_rqst *rqstp, str
 	return status;
 }
 
-static inline __be32
+static __be32
 nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      struct nfsd4_setattr *setattr)
 {
@@ -639,7 +632,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 	return status;
 }
 
-static inline __be32
+static __be32
 nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_write *write)
 {

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
