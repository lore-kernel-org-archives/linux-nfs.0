From: Mike Waychison <michael.waychison@sun.com>
Subject: [PATCH 1/2] Make get rootfh calls soft + intr
Date: Thu, 9 Dec 2004 16:23:06 -0500
Message-ID: <1102627386571@sun.com>
References: <11026273562@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcVkq-0008Jd-Iv
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 13:23:16 -0800
Received: from ip22-176.tor.istop.com
	([66.11.176.22] helo=crlf.tor.istop.com ident=postfix)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcVkq-00055k-0u
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 13:23:16 -0800
Received: from localhost (belle.christiehouse.net [127.0.0.1])
	by crlf.tor.istop.com (Postfix) with ESMTP id 818A7D379
	for <nfs@lists.sourceforge.net>; Thu,  9 Dec 2004 16:33:39 -0500 (EST)
Received: from crlf.tor.istop.com ([127.0.0.1])
	by localhost (belle [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 23560-02 for <nfs@lists.sourceforge.net>;
	Thu, 9 Dec 2004 16:33:34 -0500 (EST)
Received: from lapdance (unknown [192.168.4.103])
	by crlf.tor.istop.com (Postfix) with SMTP id CAD72D36A
	for <nfs@lists.sourceforge.net>; Thu,  9 Dec 2004 16:33:34 -0500 (EST)
In-Reply-To: <11026273562@sun.com>
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

This patch add a new rpc task flag, RPC_TASK_FORCEINTR, which makes the task in
question run intr even if nointr is specified.  This is used by the get root fh
functions so that mounting becomes interuptible.

As well, this patch also modifies the get root calls to run RPC_TASK_SOFT so
that a bogus mount will eventually time out.  This makes bogus mounts like
'mount -o nfsport=10000 host:/export /tmp/foo' eventually timeout instead of
leaving a super_block hung for eternity.

Signed-off-by: Mike Waychison <michael.waychison@sun.com>
Index: linux-2.6.9-quilt/fs/nfs/nfs3proc.c
===================================================================
--- linux-2.6.9-quilt.orig/fs/nfs/nfs3proc.c	2004-11-11 16:51:45.691151928 -0800
+++ linux-2.6.9-quilt/fs/nfs/nfs3proc.c	2004-11-11 16:52:22.279589640 -0800
@@ -79,10 +79,14 @@ nfs3_proc_get_root(struct nfs_server *se
 
 	dprintk("%s: call  fsinfo\n", __FUNCTION__);
 	info->fattr->valid = 0;
-	status = rpc_call(server->client_sys, NFS3PROC_FSINFO, fhandle, info, 0);
+	/*
+	 * We force mount setup to be soft,intr regardless of true mount options
+	 * so that we don't end up with a hung system on a bad initial mount 
+	 */
+	status = rpc_call(server->client_sys, NFS3PROC_FSINFO, fhandle, info, RPC_TASK_SOFT | RPC_TASK_FORCEINTR);
 	dprintk("%s: reply fsinfo %d\n", __FUNCTION__, status);
 	if (!(info->fattr->valid & NFS_ATTR_FATTR)) {
-		status = rpc_call(server->client_sys, NFS3PROC_GETATTR, fhandle, info->fattr, 0);
+		status = rpc_call(server->client_sys, NFS3PROC_GETATTR, fhandle, info->fattr, RPC_TASK_SOFT | RPC_TASK_FORCEINTR);
 		dprintk("%s: reply getattr %d\n", __FUNCTION__, status);
 	}
 	return status;
Index: linux-2.6.9-quilt/fs/nfs/proc.c
===================================================================
--- linux-2.6.9-quilt.orig/fs/nfs/proc.c	2004-11-11 16:51:45.696151168 -0800
+++ linux-2.6.9-quilt/fs/nfs/proc.c	2004-11-11 16:52:22.281589336 -0800
@@ -62,12 +62,18 @@ nfs_proc_get_root(struct nfs_server *ser
 
 	dprintk("%s: call getattr\n", __FUNCTION__);
 	fattr->valid = 0;
-	status = rpc_call(server->client_sys, NFSPROC_GETATTR, fhandle, fattr, 0);
+	/*
+	 * We force mount setup to be soft,intr regardless of true mount options
+	 * so that we don't end up with a hung system on a bad initial mount 
+	 */
+	status = rpc_call(server->client_sys, NFSPROC_GETATTR, fhandle, fattr,
+			RPC_TASK_SOFT | RPC_TASK_FORCEINTR);
 	dprintk("%s: reply getattr %d\n", __FUNCTION__, status);
 	if (status)
 		return status;
 	dprintk("%s: call statfs\n", __FUNCTION__);
-	status = rpc_call(server->client_sys, NFSPROC_STATFS, fhandle, &fsinfo, 0);
+	status = rpc_call(server->client_sys, NFSPROC_STATFS, fhandle, &fsinfo,
+			RPC_TASK_SOFT | RPC_TASK_FORCEINTR);
 	dprintk("%s: reply statfs %d\n", __FUNCTION__, status);
 	if (status)
 		return status;
Index: linux-2.6.9-quilt/include/linux/sunrpc/sched.h
===================================================================
--- linux-2.6.9-quilt.orig/include/linux/sunrpc/sched.h	2004-11-11 16:51:45.697151016 -0800
+++ linux-2.6.9-quilt/include/linux/sunrpc/sched.h	2004-11-11 16:52:22.282589184 -0800
@@ -114,6 +114,7 @@ typedef void			(*rpc_action)(struct rpc_
 #define RPC_TASK_KILLED		0x0100		/* task was killed */
 #define RPC_TASK_SOFT		0x0200		/* Use soft timeouts */
 #define RPC_TASK_NOINTR		0x0400		/* uninterruptible task */
+#define RPC_TASK_FORCEINTR	0x0800		/* force intr even if nointr */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SETUID(t)	((t)->tk_flags & RPC_TASK_SETUID)
@@ -124,7 +125,7 @@ typedef void			(*rpc_action)(struct rpc_
 #define RPC_IS_ACTIVATED(t)	((t)->tk_active)
 #define RPC_DO_CALLBACK(t)	((t)->tk_callback != NULL)
 #define RPC_IS_SOFT(t)		((t)->tk_flags & RPC_TASK_SOFT)
-#define RPC_TASK_UNINTERRUPTIBLE(t) ((t)->tk_flags & RPC_TASK_NOINTR)
+#define RPC_TASK_UNINTERRUPTIBLE(t) (((t)->tk_flags & (RPC_TASK_NOINTR | RPC_TASK_FORCEINTR)) == RPC_TASK_NOINTR)
 
 #define RPC_TASK_SLEEPING	0
 #define RPC_TASK_RUNNING	1



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
