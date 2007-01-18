From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/14] NLM: Shrink the maximum request size of NLM4
	requests
Date: Thu, 18 Jan 2007 18:30:56 -0500
Message-ID: <20070118233056.23310.1289.stgit@localhost.localdomain>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7gin-0002tl-Cb
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:31:05 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7gio-0004XD-Sa
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:31:07 -0800
To: trond.myklybust@fys.uio.no
In-Reply-To: <20070118232356.23310.6705.stgit@localhost.localdomain>
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
while XDR encoding NLM4 arguments..

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/xdr.c  |   13 +++++++++----
 fs/lockd/xdr4.c |   16 +++++++++++-----
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 75dd023..55796c3 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -510,17 +510,22 @@ nlmclt_decode_res(struct rpc_rqst *req, 
 	return 0;
 }
 
+#ifndef MIN
+# define MIN(a, b)	(((a) < (b)) ? (a) : (b))
+#endif
+
 /*
  * Buffer requirements for NLM
  */
 #define NLM_void_sz		0
 #define NLM_cookie_sz		1+XDR_QUADLEN(NLM_MAXCOOKIELEN)
 #define NLM_caller_sz		1+XDR_QUADLEN(sizeof(utsname()->nodename))
-#define NLM_netobj_sz		1+XDR_QUADLEN(XDR_MAX_NETOBJ)
-/* #define NLM_owner_sz		1+XDR_QUADLEN(NLM_MAXOWNER) */
+/* #define NLM_netobj_sz		1+XDR_QUADLEN(XDR_MAX_NETOBJ) */
+#define NLM_owner_sz		1+XDR_QUADLEN(MIN((XDR_MAX_NETOBJ), \
+					NLMCLNT_OHSIZE))
 #define NLM_fhandle_sz		1+XDR_QUADLEN(NFS2_FHSIZE)
-#define NLM_lock_sz		3+NLM_caller_sz+NLM_netobj_sz+NLM_fhandle_sz
-#define NLM_holder_sz		4+NLM_netobj_sz
+#define NLM_lock_sz		3+NLM_caller_sz+NLM_owner_sz+NLM_fhandle_sz
+#define NLM_holder_sz		4+NLM_owner_sz
 
 #define NLM_testargs_sz		NLM_cookie_sz+1+NLM_lock_sz
 #define NLM_lockargs_sz		NLM_cookie_sz+4+NLM_lock_sz
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index d354f3f..88c18a8 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -516,17 +516,23 @@ nlm4clt_decode_res(struct rpc_rqst *req,
 	return 0;
 }
 
+#ifndef MIN
+# define MIN(a, b)	(((a) < (b)) ? (a) : (b))
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
+#define NLM4_caller_sz		1+XDR_QUADLEN(MIN((NLM_MAXSTRLEN), \
+					NLMCLNT_OHSIZE))
+/* #define NLM4_netobj_sz		1+XDR_QUADLEN(XDR_MAX_NETOBJ) */
+#define NLM4_owner_sz		1+XDR_QUADLEN(MIN((XDR_MAX_NETOBJ), \
+					NLMCLNT_OHSIZE))
 #define NLM4_fhandle_sz		1+XDR_QUADLEN(NFS3_FHSIZE)
-#define NLM4_lock_sz		5+NLM4_caller_sz+NLM4_netobj_sz+NLM4_fhandle_sz
-#define NLM4_holder_sz		6+NLM4_netobj_sz
+#define NLM4_lock_sz		5+NLM4_caller_sz+NLM4_owner_sz+NLM4_fhandle_sz
+#define NLM4_holder_sz		6+NLM4_owner_sz
 
 #define NLM4_testargs_sz	NLM4_cookie_sz+1+NLM4_lock_sz
 #define NLM4_lockargs_sz	NLM4_cookie_sz+4+NLM4_lock_sz

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
