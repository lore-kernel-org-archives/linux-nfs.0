From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/15] NLM: Shrink the maximum request size of NLM4
	requests
Date: Wed, 24 Jan 2007 14:20:23 -0500
Message-ID: <20070124192023.31133.95257.stgit@localhost.localdomain>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9nhB-0001G9-HP
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:22:09 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9nhB-0004YJ-R0
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:22:11 -0800
In-Reply-To: <20070124191704.31133.12713.stgit@localhost.localdomain>
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

NLM version 4 requests estimate the call and reply header sizes rather
conservatively, using the very maximum size allowed in the protocol even
though Linux always uses only a small fraction of the allowable space.

Reduce the size of caller and lock arguments to conserve RPC buffer space
while XDR encoding NLM4 arguments.  Add compile-time checks to ensure the
hostname string won't overflow NLM protocol maximums.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/xdr.c              |   13 ++++++++-----
 fs/lockd/xdr4.c             |   17 ++++++++++++-----
 include/linux/lockd/lockd.h |    2 +-
 3 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 75dd023..1644248 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -510,17 +510,20 @@ nlmclt_decode_res(struct rpc_rqst *req, 
 	return 0;
 }
 
+#if (NLMCLNT_OHSIZE > XDR_MAX_NETOBJ)
+#  error "NLM host name can be larger than XDR_MAX_NETOBJ!"
+#endif
+
 /*
  * Buffer requirements for NLM
  */
 #define NLM_void_sz		0
 #define NLM_cookie_sz		1+XDR_QUADLEN(NLM_MAXCOOKIELEN)
-#define NLM_caller_sz		1+XDR_QUADLEN(sizeof(utsname()->nodename))
-#define NLM_netobj_sz		1+XDR_QUADLEN(XDR_MAX_NETOBJ)
-/* #define NLM_owner_sz		1+XDR_QUADLEN(NLM_MAXOWNER) */
+#define NLM_caller_sz		1+XDR_QUADLEN(NLMCLNT_OHSIZE)
+#define NLM_owner_sz		1+XDR_QUADLEN(NLMCLNT_OHSIZE)
 #define NLM_fhandle_sz		1+XDR_QUADLEN(NFS2_FHSIZE)
-#define NLM_lock_sz		3+NLM_caller_sz+NLM_netobj_sz+NLM_fhandle_sz
-#define NLM_holder_sz		4+NLM_netobj_sz
+#define NLM_lock_sz		3+NLM_caller_sz+NLM_owner_sz+NLM_fhandle_sz
+#define NLM_holder_sz		4+NLM_owner_sz
 
 #define NLM_testargs_sz		NLM_cookie_sz+1+NLM_lock_sz
 #define NLM_lockargs_sz		NLM_cookie_sz+4+NLM_lock_sz
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index d354f3f..3d7baa6 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -516,17 +516,24 @@ nlm4clt_decode_res(struct rpc_rqst *req,
 	return 0;
 }
 
+#if (NLMCLNT_OHSIZE > XDR_MAX_NETOBJ)
+#  error "NLM host name can be larger than XDR_MAX_NETOBJ!"
+#endif
+
+#if (NLMCLNT_OHSIZE > NLM_MAXSTRLEN)
+#  error "NLM host name can be larger than NLM's maximum string length!"
+#endif
+
 /*
  * Buffer requirements for NLM
  */
 #define NLM4_void_sz		0
 #define NLM4_cookie_sz		1+XDR_QUADLEN(NLM_MAXCOOKIELEN)
-#define NLM4_caller_sz		1+XDR_QUADLEN(NLM_MAXSTRLEN)
-#define NLM4_netobj_sz		1+XDR_QUADLEN(XDR_MAX_NETOBJ)
-/* #define NLM4_owner_sz		1+XDR_QUADLEN(NLM4_MAXOWNER) */
+#define NLM4_caller_sz		1+XDR_QUADLEN(NLMCLNT_OHSIZE)
+#define NLM4_owner_sz		1+XDR_QUADLEN(NLMCLNT_OHSIZE)
 #define NLM4_fhandle_sz		1+XDR_QUADLEN(NFS3_FHSIZE)
-#define NLM4_lock_sz		5+NLM4_caller_sz+NLM4_netobj_sz+NLM4_fhandle_sz
-#define NLM4_holder_sz		6+NLM4_netobj_sz
+#define NLM4_lock_sz		5+NLM4_caller_sz+NLM4_owner_sz+NLM4_fhandle_sz
+#define NLM4_holder_sz		6+NLM4_owner_sz
 
 #define NLM4_testargs_sz	NLM4_cookie_sz+1+NLM4_lock_sz
 #define NLM4_lockargs_sz	NLM4_cookie_sz+4+NLM4_lock_sz
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index ac25b56..f6a81e0 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -88,7 +88,7 @@ struct nlm_wait;
 /*
  * Memory chunk for NLM client RPC request.
  */
-#define NLMCLNT_OHSIZE		(sizeof(utsname()->nodename)+10)
+#define NLMCLNT_OHSIZE		((__NEW_UTS_LEN) + 10u)
 struct nlm_rqst {
 	unsigned int		a_flags;	/* initial RPC task flags */
 	struct nlm_host *	a_host;		/* host handle */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
