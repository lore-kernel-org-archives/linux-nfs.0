From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [GIT] NFS client updates for 2.6.22...
Date: Tue, 8 May 2007 11:37:26 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0705081133110.20168@pademelon.sonytel.be>
References: <1178117571.5435.10.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-584337861-980738872-1178617046=:20168"
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934641AbXEHJhh@vger.kernel.org>
In-Reply-To: <1178117571.5435.10.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---584337861-980738872-1178617046=:20168
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Wed, 2 May 2007, Trond Myklebust wrote:
> commit c5a4dd8b7c15927a8fbff83171b57cad675a79b9
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Thu Mar 29 16:47:58 2007 -0400
> 
>     SUNRPC: Eliminate side effects from rpc_malloc
>     
>     Currently rpc_malloc sets req->rq_buffer internally.  Make this a more
>     generic interface:  return a pointer to the new buffer (or NULL) and
>     make the caller set req->rq_buffer and req->rq_bufsize.  This looks much
>     more like kmalloc and eliminates the side effects.
>     
>     To fix a potential deadlock, this patch also replaces GFP_NOFS with
>     GFP_NOWAIT in rpc_malloc.  This prevents async RPCs from sleeping outside
>     the RPC's task scheduler while allocating their buffer.
>     
>     Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

This patch introduced the following compiler warnings:

net/sunrpc/sched.c:766: warning: format ‘%u’ expects type ‘unsigned int’, but argument 3 has type ‘size_t’
net/sunrpc/sched.c:785: warning: format ‘%u’ expects type ‘unsigned int’, but argument 2 has type ‘size_t’

  - Use %zu to format size_t
  - Kill 2 useless casts

Signed-off-by: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>

--- ps3-linux-2.6.21.orig/net/sunrpc/sched.c
+++ ps3-linux-2.6.21/net/sunrpc/sched.c
@@ -763,9 +763,9 @@ void *rpc_malloc(struct rpc_task *task, 
 	else
 		buf = kmalloc(size, gfp);
 	*buf = size;
-	dprintk("RPC: %5u allocated buffer of size %u at %p\n",
+	dprintk("RPC: %5u allocated buffer of size %zu at %p\n",
 			task->tk_pid, size, buf);
-	return (void *) ++buf;
+	return ++buf;
 }
 
 /**
@@ -775,14 +775,14 @@ void *rpc_malloc(struct rpc_task *task, 
  */
 void rpc_free(void *buffer)
 {
-	size_t size, *buf = (size_t *) buffer;
+	size_t size, *buf = buffer;
 
 	if (!buffer)
 		return;
 	size = *buf;
 	buf--;
 
-	dprintk("RPC:       freeing buffer of size %u at %p\n",
+	dprintk("RPC:       freeing buffer of size %zu at %p\n",
 			size, buf);
 	if (size <= RPC_BUFFER_MAXSIZE)
 		mempool_free(buf, rpc_buffer_mempool);

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- Sony Network and Software Technology Center Europe (NSCE)
Geert.Uytterhoeven@sonycom.com ------- The Corporate Village, Da Vincilaan 7-D1
Voice +32-2-7008453 Fax +32-2-7008622 ---------------- B-1935 Zaventem, Belgium
---584337861-980738872-1178617046=:20168--
