From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [RFC Patch 07/09] NFS/RDMA client - core rpcrdma transport
 implementation
Date: Wed, 11 Jul 2007 17:07:54 -0400
Message-ID: <EXNANE01pH71yEXUIEA00000c66@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8jSC-0002Hf-6q
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:10:32 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I8jSF-0007YO-NJ
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:10:35 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l6BLATQK022624
	for <nfs@lists.sourceforge.net>; Wed, 11 Jul 2007 14:10:29 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

RPCRDMA: rpc rdma transport switch

This implements the configuration and building of the core transport
switch implementation of the rpcrdma transport. Stubs are provided for
the rpcrdma protocol handling, and the infiniband/iwarp verbs interface.
These are provided in other patches. 

Signed-off-by: Tom Talpey <talpey@netapp.com>

---

Index: linux-2.6.22/fs/Kconfig
===================================================================
--- linux-2.6.22.orig/fs/Kconfig
+++ linux-2.6.22/fs/Kconfig
@@ -1730,6 +1730,14 @@ config SUNRPC
 config SUNRPC_GSS
        tristate
 
+config SUNRPC_XPRT_RDMA
+       tristate "RDMA transport for sunrpc (EXPERIMENTAL)"
+       depends on NFS_FS && INFINIBAND && EXPERIMENTAL
+       default m
+       help
+         Adds a client RPC transport for supporting kernel NFS over RDMA
+         mounts, including Infiniband and iWARP. Experimental.
+
 config SUNRPC_BIND34
        bool "Support for rpcbind versions 3 & 4 (EXPERIMENTAL)"
        depends on SUNRPC && EXPERIMENTAL
Index: linux-2.6.22/net/sunrpc/Makefile
===================================================================
--- linux-2.6.22.orig/net/sunrpc/Makefile
+++ linux-2.6.22/net/sunrpc/Makefile
@@ -5,6 +5,7 @@
 
 obj-$(CONFIG_SUNRPC) += sunrpc.o
 obj-$(CONFIG_SUNRPC_GSS) += auth_gss/
+obj-$(CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma/
 
 sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
            auth.o auth_null.o auth_unix.o \
Index: linux-2.6.22/net/sunrpc/xprtrdma/Makefile
===================================================================
--- /dev/null
+++ linux-2.6.22/net/sunrpc/xprtrdma/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma.o
+
+xprtrdma-y := transport.o rpc_rdma.o verbs.o
Index: linux-2.6.22/include/linux/sunrpc/debug.h
===================================================================
--- linux-2.6.22.orig/include/linux/sunrpc/debug.h
+++ linux-2.6.22/include/linux/sunrpc/debug.h
@@ -88,6 +88,11 @@ enum {
        CTL_SLOTTABLE_TCP,
        CTL_MIN_RESVPORT,
        CTL_MAX_RESVPORT,
+       CTL_SLOTTABLE_RDMA,
+       CTL_RDMA_MAXINLINEREAD,
+       CTL_RDMA_MAXINLINEWRITE,
+       CTL_RDMA_WRITEPADDING,
+       CTL_RDMA_MEMREG,
 };
 
 #endif /* _LINUX_SUNRPC_DEBUG_H_ */
Index: linux-2.6.22/net/sunrpc/xprtrdma/xprt_rdma.h
===================================================================
--- /dev/null
+++ linux-2.6.22/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -0,0 +1,358 @@
+/*
+ * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the BSD-type
+ * license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *      Redistributions of source code must retain the above copyright
+ *      notice, this list of conditions and the following disclaimer.
+ *
+ *      Redistributions in binary form must reproduce the above
+ *      copyright notice, this list of conditions and the following
+ *      disclaimer in the documentation and/or other materials provided
+ *      with the distribution.
+ *
+ *      Neither the name of the Network Appliance, Inc. nor the names of
+ *      its contributors may be used to endorse or promote products
+ *      derived from this software without specific prior written
+ *      permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _LINUX_SUNRPC_XPRT_RDMA_H
+#define _LINUX_SUNRPC_XPRT_RDMA_H
+
+#include <linux/wait.h>                /* wait_queue_head_t, etc */
+#include <linux/spinlock.h>            /* spinlock_t, etc */
+#include <asm/atomic.h>                        /* atomic_t, etc */
+
+#include <rdma/rdma_cm.h>              /* RDMA connection api */
+#include <rdma/ib_verbs.h>             /* RDMA verbs api */
+
+#include <linux/sunrpc/clnt.h>                 /* rpc_xprt */
+#include <linux/sunrpc/rpc_rdma.h>     /* RPC/RDMA protocol */
+
+#define RPCRDMA_PERSISTENT_REGISTRATION (1)
+
+/*
+ * Constants. Max RPC/NFS header is big enough to account for
+ * additional marshaling buffers passed down by Linux client.
+ *
+ * RDMA header is currently fixed max size, and is big enough for a
+ * fully-chunked NFS message (read chunks are the largest). Note only
+ * a single chunk type per message is supported currently.
+ */
+#define RPCRDMA_MIN_SLOT_TABLE (2U)
+#define RPCRDMA_DEF_SLOT_TABLE (32U)
+#define RPCRDMA_MAX_SLOT_TABLE (256U)
+
+#define RPCRDMA_DEF_INLINE  (1024)     /* default inline max */
+
+#define RPCRDMA_INLINE_PAD_THRESH  (512)/* payload threshold to pad (bytes) */
+
+#define RDMA_RESOLVE_TIMEOUT   (5*HZ)  /* TBD 5 seconds */
+#define RDMA_CONNECT_RETRY_MAX (2)     /* retries if no listener backlog */
+
+/* temporary static scatter/gather max */
+#define RPCRDMA_MAX_DATA_SEGS  (8)     /* max scatter/gather */
+#define RPCRDMA_MAX_SEGS       (RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
+#define MAX_RPCRDMAHDR (       /* max supported RPC/RDMA header */ \
+       sizeof (struct rpcrdma_msg) + (2 * sizeof (u32)) + \
+       (sizeof (struct rpcrdma_read_chunk) * RPCRDMA_MAX_SEGS) + sizeof (u32))
+
+enum rpcrdma_memreg {
+       RPCRDMA_BOUNCEBUFFERS = 0,
+       RPCRDMA_REGISTER,
+       RPCRDMA_MEMWINDOWS,
+       RPCRDMA_MEMWINDOWS_ASYNC,
+       RPCRDMA_MTHCAFMR,
+       RPCRDMA_ALLPHYSICAL,
+       RPCRDMA_LAST
+};
+
+/*
+ * Interface Adapter -- one per transport instance
+ */
+struct rpcrdma_ia {
+       struct rdma_cm_id       *ri_id;
+       struct ib_pd            *ri_pd;
+       struct ib_mr            *ri_bind_mem;
+       struct completion       ri_done;
+       int                     ri_async_rc;
+       enum rpcrdma_memreg     ri_memreg_strategy;
+};
+
+/*
+ * RDMA Endpoint -- one per transport instance
+ */
+
+struct rpcrdma_ep {
+       atomic_t                rep_cqcount;
+       int                     rep_cqinit;
+       int                     rep_connected;
+       struct rpcrdma_ia       *rep_ia;
+       struct ib_cq            *rep_cq;
+       struct ib_qp_init_attr  rep_attr;
+       wait_queue_head_t       rep_connect_wait;
+       struct ib_sge           rep_pad;        /* holds zeroed pad */
+       struct ib_mr            *rep_pad_mr;    /* holds zeroed pad */
+       void                    (*rep_func)(struct rpcrdma_ep *);
+       struct rpc_xprt         *rep_xprt;      /* for rep_func */
+       struct rdma_conn_param  rep_remote_cma;
+       struct sockaddr_storage rep_remote_addr;
+};
+
+#define INIT_CQCOUNT(ep) atomic_set(&(ep)->rep_cqcount, (ep)->rep_cqinit)
+#define DECR_CQCOUNT(ep) atomic_sub_return(1, &(ep)->rep_cqcount)
+
+/*
+ * struct rpcrdma_rep -- this structure encapsulates state required to recv
+ * and complete a reply, asychronously. It needs several pieces of
+ * state:
+ *   o recv buffer (posted to provider)
+ *   o ib_sge (also donated to provider)
+ *   o status of reply (length, success or not)
+ *   o bookkeeping state to get run by tasklet (list, etc)
+ *
+ * These are allocated during initialization, per-transport instance;
+ * however, the tasklet execution list itself is global, as it should
+ * always be pretty short.
+ *
+ * N of these are associated with a transport instance, and stored in
+ * struct rpcrdma_buffer. N is the max number of outstanding requests.
+ */
+
+struct rpcrdma_buffer;
+
+struct rpcrdma_rep {
+       unsigned int    rr_len;         /* actual received reply length */
+       struct rpcrdma_buffer *rr_buffer; /* home base for this structure */
+       struct rpc_xprt *rr_xprt;       /* needed for request/reply matching */
+       void (*rr_func)(struct rpcrdma_rep *); /* called by tasklet in softint */
+       struct list_head rr_list;       /* tasklet list */
+       wait_queue_head_t rr_unbind;    /* optional unbind wait */
+       struct ib_sge   rr_iov;         /* for posting */
+       struct ib_mr    *rr_handle;     /* handle for mem in rr_iov */
+       char    rr_base[MAX_RPCRDMAHDR]; /* minimal inline receive buffer */
+};
+
+/*
+ * struct rpcrdma_req -- structure central to the request/reply sequence.
+ *
+ * N of these are associated with a transport instance, and stored in
+ * struct rpcrdma_buffer. N is the max number of outstanding requests.
+ *
+ * It includes pre-registered buffer memory for send AND recv.
+ * The recv buffer, however, is not owned by this structure, and
+ * is "donated" to the hardware when a recv is posted. When a
+ * reply is handled, the recv buffer used is given back to the
+ * struct rpcrdma_req associated with the request.
+ *
+ * In addition to the basic memory, this structure includes an array
+ * of iovs for send operations. The reason is that the iovs passed to
+ * ib_post_{send,recv} must not be modified until the work request
+ * completes.
+ *
+ * NOTES:
+ *   o RPCRDMA_MAX_SEGS is the max number of addressible chunk elements we
+ *     marshal. The number needed varies depending on the iov lists that
+ *     are passed to us, the memory registration mode we are in, and if
+ *     physical addressing is used, the layout.
+ */
+
+struct rpcrdma_mr_seg {                /* chunk descriptors */
+       union {                         /* chunk memory handles */
+               struct ib_mr    *rl_mr;         /* if registered directly */
+               struct rpcrdma_mw {             /* if registered from region */
+                       union {
+                               struct ib_mw    *mw;
+                               struct ib_fmr   *fmr;
+                       } r;
+                       struct list_head mw_list;
+               } *rl_mw;
+       } mr_chunk;
+       u64             mr_base;        /* registration result */
+       u32             mr_rkey;        /* registration result */
+       u32             mr_len;         /* length of chunk or segment */
+       int             mr_nsegs;       /* number of segments in chunk or 0 */
+       enum dma_data_direction mr_dir; /* segment mapping direction */
+       dma_addr_t      mr_dma;         /* segment mapping address */
+       size_t          mr_dmalen;      /* segment mapping length */
+       struct page     *mr_page;       /* owning page, if any */
+       char            *mr_offset;     /* kva if no page, else offset */
+};
+
+struct rpcrdma_req {
+       size_t          rl_size;        /* actual length of buffer */
+       unsigned int    rl_niovs;       /* 0, 2 or 4 */
+       unsigned int    rl_nchunks;     /* non-zero if chunks */
+       struct rpcrdma_buffer *rl_buffer; /* home base for this structure */
+       struct rpcrdma_rep      *rl_reply;/* holder for reply buffer */
+       struct rpcrdma_mr_seg rl_segments[RPCRDMA_MAX_SEGS];/* chunk segments */
+       struct ib_sge   rl_send_iov[4]; /* for active requests */
+       struct ib_sge   rl_iov;         /* for posting */
+       struct ib_mr    *rl_handle;     /* handle for mem in rl_iov */
+       char            rl_base[MAX_RPCRDMAHDR]; /* start of actual buffer */
+       __u32           rl_xdr_buf[0];  /* start of returned rpc rq_buffer */
+};
+#define rpcr_to_rdmar(r) container_of((r)->rq_buffer, struct rpcrdma_req, rl_xdr_buf[0])
+
+/*
+ * struct rpcrdma_buffer -- holds list/queue of pre-registered memory for
+ * inline requests/replies, and client/server credits.
+ *
+ * One of these is associated with a transport instance
+ */
+struct rpcrdma_buffer {
+       spinlock_t      rb_lock;        /* protects indexes */
+       atomic_t        rb_credits;     /* most recent server credits */
+       unsigned long   rb_cwndscale;   /* cached framework rpc_cwndscale */
+       int             rb_max_requests;/* client max requests */
+       struct list_head rb_mws;        /* optional memory windows/fmrs */
+       int             rb_send_index;
+       struct rpcrdma_req      **rb_send_bufs;
+       int             rb_recv_index;
+       struct rpcrdma_rep      **rb_recv_bufs;
+       char            *rb_pool;
+};
+#define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
+
+/*
+ * Internal structure for transport instance creation. This
+ * exists primarily for modularity.
+ *
+ * This data should be set with mount options
+ */
+struct rpcrdma_create_data_internal {
+       struct sockaddr_storage addr;   /* RDMA server address */
+       unsigned int    max_requests;   /* max requests (slots) in flight */
+       unsigned int    rsize;          /* mount rsize - max read hdr+data */
+       unsigned int    wsize;          /* mount wsize - max write hdr+data */
+       unsigned int    inline_rsize;   /* max non-rdma read data payload */
+       unsigned int    inline_wsize;   /* max non-rdma write data payload */
+       unsigned int    padding;        /* non-rdma write header padding */
+};
+
+#define RPCRDMA_INLINE_READ_THRESHOLD(rq) \
+       (rpcx_to_rdmad(rq->rq_task->tk_xprt).inline_rsize)
+
+#define RPCRDMA_INLINE_WRITE_THRESHOLD(rq)\
+       (rpcx_to_rdmad(rq->rq_task->tk_xprt).inline_wsize)
+
+#define RPCRDMA_INLINE_PAD_VALUE(rq)\
+       rpcx_to_rdmad(rq->rq_task->tk_xprt).padding
+
+/*
+ * Statistics for RPCRDMA
+ */
+struct rpcrdma_stats {
+       unsigned long           read_chunk_count;
+       unsigned long           write_chunk_count;
+       unsigned long           reply_chunk_count;
+
+       unsigned long long      total_rdma_request;
+       unsigned long long      total_rdma_reply;
+
+       unsigned long long      pullup_copy_count;
+       unsigned long long      fixup_copy_count;
+       unsigned long           hardway_register_count;
+       unsigned long           failed_marshal_count;
+       unsigned long           bad_reply_count;
+};
+
+/*
+ * RPCRDMA transport -- encapsulates the structures above for
+ * integration with RPC.
+ *
+ * The contained structures are embedded, not pointers,
+ * for convenience. This structure need not be visible externally.
+ *
+ * It is allocated and initialized during mount, and released
+ * during unmount.
+ */
+struct rpcrdma_xprt {
+       struct rpc_xprt         xprt;
+       struct rpcrdma_ia       rx_ia;
+       struct rpcrdma_ep       rx_ep;
+       struct rpcrdma_buffer   rx_buf;
+       struct rpcrdma_create_data_internal rx_data;
+       struct delayed_work     rdma_connect;
+       struct rpcrdma_stats    rx_stats;
+};
+
+#define rpcx_to_rdmax(x) container_of(x, struct rpcrdma_xprt, xprt)
+#define rpcx_to_rdmad(x) (rpcx_to_rdmax(x)->rx_data)
+
+/*
+ * Interface Adapter calls - xprtrdma/verbs.c
+ */
+int rpcrdma_ia_open(struct rpcrdma_xprt *, struct sockaddr *, int);
+void rpcrdma_ia_close(struct rpcrdma_ia *);
+
+/*
+ * Endpoint calls - xprtrdma/verbs.c
+ */
+int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
+                               struct rpcrdma_create_data_internal *);
+int rpcrdma_ep_destroy(struct rpcrdma_ep *, struct rpcrdma_ia *);
+int rpcrdma_ep_connect(struct rpcrdma_ep *, struct rpcrdma_ia *);
+int rpcrdma_ep_disconnect(struct rpcrdma_ep *, struct rpcrdma_ia *);
+
+int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
+                               struct rpcrdma_req *);
+int rpcrdma_ep_post_recv(struct rpcrdma_ia *, struct rpcrdma_ep *,
+                               struct rpcrdma_rep *);
+
+/*
+ * Buffer calls - xprtrdma/verbs.c
+ */
+int rpcrdma_buffer_create(struct rpcrdma_buffer *, struct rpcrdma_ep *,
+                               struct rpcrdma_ia *,
+                               struct rpcrdma_create_data_internal *);
+void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
+
+struct rpcrdma_req *rpcrdma_buffer_get(struct rpcrdma_buffer *);
+void rpcrdma_buffer_put(struct rpcrdma_req *);
+void rpcrdma_recv_buffer_get(struct rpcrdma_req *);
+void rpcrdma_recv_buffer_put(struct rpcrdma_rep *);
+
+int rpcrdma_register_internal(struct rpcrdma_ia *, void *, int,
+                               struct ib_mr **, struct ib_sge *);
+int rpcrdma_deregister_internal(struct rpcrdma_ia *,
+                               struct ib_mr *, struct ib_sge *);
+
+int rpcrdma_register_external(struct rpcrdma_mr_seg *,
+                               int, int, struct rpcrdma_xprt *);
+int rpcrdma_deregister_external(struct rpcrdma_mr_seg *,
+                               struct rpcrdma_xprt *, void *);
+
+/*
+ * RPC/RDMA connection management calls - xprtrdma/rpc_rdma.c
+ */
+void rpcrdma_conn_func(struct rpcrdma_ep *);
+void rpcrdma_reply_handler(struct rpcrdma_rep *);
+
+/*
+ * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c
+ */
+int rpcrdma_marshal_req(struct rpc_rqst *);
+
+#endif                         /* _LINUX_SUNRPC_XPRT_RDMA_H */
Index: linux-2.6.22/net/sunrpc/xprtrdma/transport.c
===================================================================
--- /dev/null
+++ linux-2.6.22/net/sunrpc/xprtrdma/transport.c
@@ -0,0 +1,823 @@
+/*
+ * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the BSD-type
+ * license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *      Redistributions of source code must retain the above copyright
+ *      notice, this list of conditions and the following disclaimer.
+ *
+ *      Redistributions in binary form must reproduce the above
+ *      copyright notice, this list of conditions and the following
+ *      disclaimer in the documentation and/or other materials provided
+ *      with the distribution.
+ *
+ *      Neither the name of the Network Appliance, Inc. nor the names of
+ *      its contributors may be used to endorse or promote products
+ *      derived from this software without specific prior written
+ *      permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+/*
+ * transport.c
+ *
+ * This file contains the top-level implementation of an RPC RDMA
+ * transport.
+ *
+ * Naming convention: functions beginning with xprt_ are part of the
+ * transport switch. All others are RPC RDMA internal.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/seq_file.h>
+
+#include "xprt_rdma.h"
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY       RPCDBG_TRANS
+#endif
+
+MODULE_LICENSE("Dual BSD/GPL");
+
+MODULE_DESCRIPTION("RPC/RDMA Transport for Linux kernel NFS");
+MODULE_AUTHOR("Network Appliance, Inc.");
+
+/*
+ * tunables
+ */
+
+unsigned int xprt_rdma_slot_table_entries = RPCRDMA_DEF_SLOT_TABLE;
+unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
+unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
+unsigned int xprt_rdma_inline_write_padding = 0;
+#if !RPCRDMA_PERSISTENT_REGISTRATION
+unsigned int xprt_rdma_memreg_strategy = RPCRDMA_REGISTER;     /* FMR? */
+#else
+unsigned int xprt_rdma_memreg_strategy = RPCRDMA_ALLPHYSICAL;
+#endif
+
+#ifdef RPC_DEBUG
+
+static unsigned int min_slot_table_size = RPCRDMA_MIN_SLOT_TABLE;
+static unsigned int max_slot_table_size = RPCRDMA_MAX_SLOT_TABLE;
+static unsigned int zero = 0;
+static unsigned int max_padding = PAGE_SIZE;
+static unsigned int min_memreg = RPCRDMA_BOUNCEBUFFERS;
+static unsigned int max_memreg = RPCRDMA_LAST - 1;
+
+static struct ctl_table_header *sunrpc_table_header;
+
+static ctl_table xr_tunables_table[] = {
+       {
+               .ctl_name       = CTL_SLOTTABLE_RDMA,
+               .procname       = "rdma_slot_table_entries",
+               .data           = &xprt_rdma_slot_table_entries,
+               .maxlen         = sizeof(unsigned int),
+               .mode           = 0644,
+               .proc_handler   = &proc_dointvec_minmax,
+               .strategy       = &sysctl_intvec,
+               .extra1         = &min_slot_table_size,
+               .extra2         = &max_slot_table_size
+       },
+       {
+               .ctl_name       = CTL_RDMA_MAXINLINEREAD,
+               .procname       = "rdma_max_inline_read",
+               .data           = &xprt_rdma_max_inline_read,
+               .maxlen         = sizeof(unsigned int),
+               .mode           = 0644,
+               .proc_handler   = &proc_dointvec,
+               .strategy       = &sysctl_intvec,
+       },
+       {
+               .ctl_name       = CTL_RDMA_MAXINLINEWRITE,
+               .procname       = "rdma_max_inline_write",
+               .data           = &xprt_rdma_max_inline_write,
+               .maxlen         = sizeof(unsigned int),
+               .mode           = 0644,
+               .proc_handler   = &proc_dointvec,
+               .strategy       = &sysctl_intvec,
+       },
+       {
+               .ctl_name       = CTL_RDMA_WRITEPADDING,
+               .procname       = "rdma_inline_write_padding",
+               .data           = &xprt_rdma_inline_write_padding,
+               .maxlen         = sizeof(unsigned int),
+               .mode           = 0644,
+               .proc_handler   = &proc_dointvec_minmax,
+               .strategy       = &sysctl_intvec,
+               .extra1         = &zero,
+               .extra2         = &max_padding,
+       },
+       {
+               .ctl_name       = CTL_RDMA_MEMREG,
+               .procname       = "rdma_memreg_strategy",
+               .data           = &xprt_rdma_memreg_strategy,
+               .maxlen         = sizeof(unsigned int),
+               .mode           = 0644,
+               .proc_handler   = &proc_dointvec_minmax,
+               .strategy       = &sysctl_intvec,
+               .extra1         = &min_memreg,
+               .extra2         = &max_memreg,
+       },
+       {
+               .ctl_name = 0,
+       },
+};
+
+static ctl_table sunrpc_table[] = {
+       {
+               .ctl_name       = CTL_SUNRPC,
+               .procname       = "sunrpc",
+               .mode           = 0555,
+               .child          = xr_tunables_table
+       },
+       {
+               .ctl_name = 0,
+       },
+};
+
+#endif
+
+static struct rpc_xprt_ops xprt_rdma_procs;    /* forward reference */
+
+static void
+xprt_rdma_format_addresses(struct rpc_xprt *xprt)
+{
+        struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
+        char *buf;
+
+        buf = kzalloc(20, GFP_KERNEL);
+        if (buf) {
+                snprintf(buf, 20, "%u.%u.%u.%u",
+                                NIPQUAD(addr->sin_addr.s_addr));
+        }
+        xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
+
+        buf = kzalloc(8, GFP_KERNEL);
+        if (buf) {
+                snprintf(buf, 8, "%u",
+                                ntohs(addr->sin_port));
+        }
+        xprt->address_strings[RPC_DISPLAY_PORT] = buf;
+
+       xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
+
+        buf = kzalloc(48, GFP_KERNEL);
+        if (buf) {
+                snprintf(buf, 48, "addr=%u.%u.%u.%u port=%u proto=%s",
+                        NIPQUAD(addr->sin_addr.s_addr),
+                        ntohs(addr->sin_port),
+                        "rdma");
+        }
+        xprt->address_strings[RPC_DISPLAY_ALL] = buf;
+}
+
+static void
+xprt_rdma_free_addresses(struct rpc_xprt *xprt)
+{
+        kfree(xprt->address_strings[RPC_DISPLAY_ADDR]);
+        kfree(xprt->address_strings[RPC_DISPLAY_PORT]);
+        kfree(xprt->address_strings[RPC_DISPLAY_ALL]);
+}
+
+static void
+xprt_rdma_connect_worker(struct work_struct *work)
+{
+       struct rpcrdma_xprt *r_xprt =
+               container_of(work, struct rpcrdma_xprt, rdma_connect.work);
+       struct rpc_xprt *xprt = &r_xprt->xprt;
+       int rc = 0;
+
+       if (!xprt->shutdown) {
+               xprt_clear_connected(xprt);
+
+               dprintk("RPC:       %s: %sconnect\n", __func__,
+                               r_xprt->rx_ep.rep_connected != 0 ? "re" : "");
+               rc = rpcrdma_ep_connect(&r_xprt->rx_ep, &r_xprt->rx_ia);
+               if (rc)
+                       goto out;
+       }
+       goto out_clear;
+
+out:
+       xprt_wake_pending_tasks(xprt, rc);
+
+out_clear:
+       dprintk("RPC:       %s: exit\n", __func__);
+       xprt_clear_connecting(xprt);
+}
+
+/*
+ * xprt_rdma_destroy
+ *
+ * Destroy the xprt.
+ * Free all memory associated with the object, including its own.
+ * NOTE: none of the *destroy methods free memory for their top-level
+ * objects, even though they may have allocated it (they do free
+ * private memory). It's up to the caller to handle it. In this
+ * case (RDMA transport), all structure memory is inlined with the
+ * struct rpcrdma_xprt.
+ */
+static void
+xprt_rdma_destroy(struct rpc_xprt *xprt)
+{
+       struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+       int rc;
+
+       dprintk("RPC:       %s: called\n", __func__);
+
+       cancel_delayed_work(&r_xprt->rdma_connect);
+       flush_scheduled_work();
+
+       xprt_clear_connected(xprt);
+
+       rpcrdma_buffer_destroy(&r_xprt->rx_buf);
+       rc = rpcrdma_ep_destroy(&r_xprt->rx_ep, &r_xprt->rx_ia);
+       if (rc)
+               dprintk("RPC:       %s: rpcrdma_ep_destroy returned %i\n",
+                       __func__, rc);
+       rpcrdma_ia_close(&r_xprt->rx_ia);
+
+       xprt_rdma_free_addresses(xprt);
+
+       kfree(xprt->slot);
+       xprt->slot = NULL;
+       kfree(xprt);
+
+       dprintk("RPC:       %s: returning\n", __func__);
+
+       module_put(THIS_MODULE);
+}
+
+/**
+ * xprt_setup_rdma - Set up transport to use RDMA
+ *
+ * @addr: address of remote server
+ * @addrlen: length of address in bytes
+ * @to:   timeout parameters
+ *
+ * Note: at present this is the only way to set the remote peer address
+ *       for an RPC transport.
+ */
+static struct rpc_xprt *
+xprt_setup_rdma(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
+{
+       struct rpcrdma_create_data_internal cdata;
+       struct rpc_xprt *xprt;
+       struct rpcrdma_xprt *new_xprt;
+       struct rpcrdma_ep *new_ep;
+       int rc;
+
+       if (addrlen > sizeof(xprt->addr)) {
+               dprintk("RPC:       %s: address too large\n", __func__);
+               return ERR_PTR(-EBADF);
+       }
+
+       xprt = kzalloc(sizeof(struct rpcrdma_xprt), GFP_KERNEL);
+       if (xprt == NULL) {
+               dprintk("RPC:       %s: couldn't allocate rpcrdma_xprt\n", __func__);
+               return ERR_PTR(-ENOMEM);
+       }
+
+       xprt->max_reqs = xprt_rdma_slot_table_entries;
+       xprt->slot = kcalloc(xprt->max_reqs, sizeof(struct rpc_rqst), GFP_KERNEL);
+       if (xprt->slot == NULL) {
+               kfree(xprt);
+               dprintk("RPC:       %s: couldn't allocate %d slots\n", __func__, xprt->max_reqs);
+               return ERR_PTR(-ENOMEM);
+       }
+
+       /* 60 second timeout, no retries */
+       xprt_set_timeout(&xprt->timeout, 0, 60UL * HZ);
+       xprt->bind_timeout = (60U * HZ);
+       xprt->connect_timeout = (60U * HZ);
+       xprt->reestablish_timeout = (5U * HZ);
+       xprt->idle_timeout = (5U * 60 * HZ);
+
+       xprt->prot = IPPROTO_TCP;       /* kinda :-) */
+       xprt->resvport = 0;             /* privileged port not needed */
+       xprt->tsh_size = 0;             /* RPC-RDMA handles framing */
+       xprt->max_payload = RPCRDMA_MAX_DATA_SEGS * PAGE_SIZE;
+       xprt->ops = &xprt_rdma_procs;
+
+       memcpy(&xprt->addr, addr, addrlen);
+       xprt->addrlen = addrlen;
+
+       xprt_set_bound(xprt);
+
+/* [Temporary trick until NFS has its new mount API] */
+       {
+               struct sockaddr_in *sin = (struct sockaddr_in *)&xprt->addr;
+               sin->sin_family = AF_INET;      /* undo the family=255 */
+               if (sin->sin_port == 0)
+                       sin->sin_port = htons(2050);
+
+               memcpy(&cdata.addr, sin, sizeof *sin);
+
+               if (*((unsigned short *)&(sin->sin_zero[0])) == 9999) {
+                       struct sockaddr *caddr = (struct sockaddr *) &cdata.addr;
+                       memcpy(&caddr->sa_data[2], &(sin->sin_zero[2]), 4);
+                       /*
+                       * zero out the 9999 trick, lest clients like NLM come
+                       * back with it. We only support the initial mount
+                       * doing this.
+                       */
+                       memset(&(sin->sin_zero), 0, sizeof(sin->sin_zero));
+               }
+#ifdef RPC_DEBUG
+               sin = (struct sockaddr_in *)&cdata.addr;
+               printk("RPC:       %s: %u.%u.%u.%u:%u\n", __func__,
+                       NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+#endif
+       }
+/* [end trick] */
+
+       /*
+       * Set up RDMA-specific connect data.
+       */
+
+       /* Set max requests */
+       cdata.max_requests = xprt->max_reqs;
+
+       /* Set some length limits */
+       cdata.rsize = RPCRDMA_MAX_SEGS * PAGE_SIZE; /* RDMA write max */
+       cdata.wsize = RPCRDMA_MAX_SEGS * PAGE_SIZE; /* RDMA read max */
+
+       cdata.inline_wsize = xprt_rdma_max_inline_write;
+       if (cdata.inline_wsize > cdata.wsize)
+               cdata.inline_wsize = cdata.wsize;
+
+       cdata.inline_rsize = xprt_rdma_max_inline_read;
+       if (cdata.inline_rsize > cdata.rsize)
+               cdata.inline_rsize = cdata.rsize;
+
+       cdata.padding = xprt_rdma_inline_write_padding;
+
+       /*
+       * Create new transport instance, which includes initialized
+       *  o ia
+       *  o endpoint
+       *  o buffers
+       */
+
+       new_xprt = rpcx_to_rdmax(xprt);
+
+       rc = rpcrdma_ia_open(new_xprt, (struct sockaddr *) &cdata.addr,
+                               xprt_rdma_memreg_strategy);
+       if (rc)
+               goto out1;
+
+       /*
+       * initialize and create ep
+       */
+       new_xprt->rx_data = cdata;
+       new_ep = &new_xprt->rx_ep;
+       new_ep->rep_remote_addr = cdata.addr;
+
+       rc = rpcrdma_ep_create(&new_xprt->rx_ep, &new_xprt->rx_ia, &new_xprt->rx_data);
+       if (rc)
+               goto out2;
+
+       /*
+       * Allocate pre-registered send and receive buffers for headers and
+       * any inline data. Also specify any padding which will be provided
+       * from a preregistered zero buffer.
+       */
+       rc = rpcrdma_buffer_create(&new_xprt->rx_buf, new_ep, &new_xprt->rx_ia,
+                               &new_xprt->rx_data);
+       if (rc)
+               goto out3;
+
+       /*
+       * Register a callback for connection events. This is necessary because
+       * connection loss notification is async. We also catch connection loss
+       * when reaping receives.
+       */
+       INIT_DELAYED_WORK(&new_xprt->rdma_connect, xprt_rdma_connect_worker);
+       new_ep->rep_func = rpcrdma_conn_func;
+       new_ep->rep_xprt = xprt;
+
+       xprt_rdma_format_addresses(xprt);
+
+       if (!try_module_get(THIS_MODULE))
+               goto out4;
+
+       return xprt;
+
+out4:
+       xprt_rdma_free_addresses(xprt);
+       rc = -EINVAL;
+out3:
+       (void) rpcrdma_ep_destroy(new_ep, &new_xprt->rx_ia);
+out2:
+       rpcrdma_ia_close(&new_xprt->rx_ia);
+out1:
+       kfree(xprt->slot);
+       kfree(xprt);
+       return ERR_PTR(rc);
+}
+
+/*
+ * Close a connection, during shutdown or timeout/reconnect
+ */
+static void
+xprt_rdma_close(struct rpc_xprt *xprt)
+{
+       struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+
+       dprintk("RPC:       %s: closing\n", __func__);
+       xprt_disconnect(xprt);
+       (void) rpcrdma_ep_disconnect(&r_xprt->rx_ep, &r_xprt->rx_ia);
+}
+
+static void
+xprt_rdma_set_buffer_size(struct rpc_xprt *xprt, size_t ss, size_t rs)
+{
+       /* Nothing to do. The inline size is negotiated (administratively set).
+       * Any outsized request is transfered via RDMA. */
+}
+
+static void
+xprt_rdma_set_port(struct rpc_xprt *xprt, u16 port)
+{
+       struct sockaddr_in *sap = (struct sockaddr_in *)&xprt->addr;
+       sap->sin_port = htons(port);
+       dprintk("RPC:       %s: %u\n", __func__, port);
+}
+
+static void
+xprt_rdma_connect(struct rpc_task *task)
+{
+       struct rpc_xprt *xprt = (struct rpc_xprt *)task->tk_xprt;
+       struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+
+       if (!xprt_test_and_set_connecting(xprt)) {
+               if (r_xprt->rx_ep.rep_connected != 0) {
+                       /* Reconnect */
+                       schedule_delayed_work(&r_xprt->rdma_connect,
+                               xprt->reestablish_timeout);
+               } else {
+                       schedule_delayed_work(&r_xprt->rdma_connect, 0);
+                       if (!RPC_IS_ASYNC(task))
+                               flush_scheduled_work();
+               }
+       }
+}
+
+static int
+xprt_rdma_reserve_xprt(struct rpc_task *task)
+{
+       struct rpc_xprt *xprt = task->tk_xprt;
+       struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+       int credits = atomic_read(&r_xprt->rx_buf.rb_credits);
+
+       /* == RPC_CWNDSCALE @ init, but *after* setup */
+       if (r_xprt->rx_buf.rb_cwndscale == 0UL) {
+               r_xprt->rx_buf.rb_cwndscale = xprt->cwnd;
+               dprintk("RPC:       %s: cwndscale %lu\n", __func__,
+                       r_xprt->rx_buf.rb_cwndscale);
+               BUG_ON(r_xprt->rx_buf.rb_cwndscale <= 0);
+       }
+       xprt->cwnd = credits * r_xprt->rx_buf.rb_cwndscale;
+       return xprt_reserve_xprt_cong(task);
+}
+
+static void
+xprt_rdma_timer(struct rpc_task *task)
+{
+       /* nothing to do */
+}
+
+static void
+xprt_rdma_bind(struct rpc_task *task)
+{
+       struct rpc_clnt *clnt = task->tk_client;
+       struct sockaddr_in *addr = (struct sockaddr_in *)&(clnt->cl_xprt->addr);
+
+/* NFS/RDMA uses static port for now...
+ * this will use rpcbind, once the rpc/rdma transport id is assigned
+       struct rpc_portmap *map = &clnt->cl_xprt->pmap;
+       if (map->pm_port != 0)
+               addr->sin_port = htons(map->pm_port);
+       else
+*/
+               addr->sin_port = htons(2050);
+       dprintk("RPC:       %s: %u\n", __func__, ntohs(addr->sin_port));
+}
+
+/*
+ * The RDMA allocate/free functions need the task structure as a place
+ * to hide the struct rpcrdma_req, which is necessary for the actual send/recv
+ * sequence. For this reason, the recv buffers are attached to send
+ * buffers for portions of the RPC. Note that the RPC layer allocates
+ * both send and receive buffers in the same call. We may register
+ * the receive buffer portion when using reply chunks.
+ */
+static void *
+xprt_rdma_allocate(struct rpc_task *task, size_t size)
+{
+       struct rpc_xprt *xprt = task->tk_xprt;
+       struct rpcrdma_req *req, *nreq;
+
+       req = rpcrdma_buffer_get(&rpcx_to_rdmax(xprt)->rx_buf);
+       BUG_ON(0 == req);
+
+       if (size > req->rl_size) {
+               dprintk("RPC:       %s: size %zd too large for buffer[%zd]: "
+                       "prog %d vers %d proc %d\n",
+                       __func__, size, req->rl_size,
+                       task->tk_client->cl_prog, task->tk_client->cl_vers,
+                       task->tk_msg.rpc_proc->p_proc);
+               /*
+               * Outgoing length shortage. Our inline write max must have
+               * been configured to perform direct i/o.
+               *
+               * This is therefore a large metadata operation, and the
+               * allocate call was made on the maximum possible message,
+               * e.g. containing long filename(s) or symlink data. In
+               * fact, while these metadata operations *might* carry
+               * large outgoing payloads, they rarely *do*. However, we
+               * have to commit to the request here, so reallocate and
+               * register it now. The data path will never require this
+               * reallocation.
+               *
+               * If the allocation or registration fails, the RPC framework
+               * will (doggedly) retry.
+               */
+               if (rpcx_to_rdmax(xprt)->rx_ia.ri_memreg_strategy == RPCRDMA_BOUNCEBUFFERS) {
+                       /* forced to "pure inline" */
+                       dprintk("RPC:       %s: too much data (%zd) for inline "
+                                       "(r/w max %d/%d)\n", __func__, size,
+                                       rpcx_to_rdmad(xprt).inline_rsize,
+                                       rpcx_to_rdmad(xprt).inline_wsize);
+                       size = req->rl_size;
+                       rpc_exit(task, -EIO);           /* fail the operation */
+                       rpcx_to_rdmax(xprt)->rx_stats.failed_marshal_count++;
+                       goto out;
+               }
+               if (task->tk_flags & RPC_TASK_SWAPPER)
+                       nreq = kmalloc(sizeof *req + size, GFP_ATOMIC);
+               else
+                       nreq = kmalloc(sizeof *req + size, GFP_NOFS);
+               if (nreq == NULL)
+                       goto outfail;
+
+               if (rpcrdma_register_internal(&rpcx_to_rdmax(xprt)->rx_ia,
+                               nreq->rl_base, size + sizeof (struct rpcrdma_req)
+                               - offsetof(struct rpcrdma_req, rl_base),
+                               &nreq->rl_handle, &nreq->rl_iov)) {
+                       kfree(nreq);
+                       goto outfail;
+               }
+               rpcx_to_rdmax(xprt)->rx_stats.hardway_register_count += size;
+               nreq->rl_size = size;
+               nreq->rl_niovs = 0;
+               nreq->rl_nchunks = 0;
+               nreq->rl_buffer = (struct rpcrdma_buffer *)req;
+               nreq->rl_reply = req->rl_reply;
+               memcpy(nreq->rl_segments, req->rl_segments, sizeof nreq->rl_segments);
+               /* flag the swap with an unused field */
+               nreq->rl_iov.length = 0;
+               req->rl_reply = NULL;
+               req = nreq;
+       }
+       dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
+out:
+       return req->rl_xdr_buf;
+
+outfail:
+       rpcrdma_buffer_put(req);
+       rpcx_to_rdmax(xprt)->rx_stats.failed_marshal_count++;
+       return NULL;
+}
+
+/*
+ * This function returns all RDMA resources to the pool.
+ */
+static void
+xprt_rdma_free(void *buffer)
+{
+       struct rpcrdma_req *req;
+       struct rpcrdma_xprt *r_xprt;
+       struct rpcrdma_rep *rep;
+       int i;
+
+       if (buffer == NULL)
+               return;
+
+       req = container_of(buffer, struct rpcrdma_req, rl_xdr_buf[0]);
+       r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
+       rep = req->rl_reply;
+
+       dprintk("RPC:       %s: called on 0x%p%s\n",
+               __func__, rep, (rep && rep->rr_func) ? " (with waiter)" : "");
+
+       /*
+       * Finish the deregistration. When using mw bind, this was
+       * begun in rpcrdma_reply_handler(). In all other modes, we
+       * do it here, in thread context. The process is considered
+       * complete when the rr_func vector becomes NULL - this
+       * was put in place during rpcrdma_reply_handler() - the wait
+       * call below will not block if the dereg is "done". If
+       * interrupted, our framework will clean up.
+       */
+       for (i = 0; req->rl_nchunks; ) {
+               --req->rl_nchunks;
+               i += rpcrdma_deregister_external(
+                       &req->rl_segments[i], r_xprt, NULL);
+       }
+
+       if (rep && wait_event_interruptible(rep->rr_unbind, !rep->rr_func)) {
+               rep->rr_func = NULL;    /* abandon the callback */
+               req->rl_reply = NULL;
+       }
+
+       if (req->rl_iov.length == 0) {  /* see allocate above */
+               struct rpcrdma_req *oreq = (struct rpcrdma_req *)req->rl_buffer;
+               oreq->rl_reply = req->rl_reply;
+               (void) rpcrdma_deregister_internal(&r_xprt->rx_ia, req->rl_handle, &req->rl_iov);
+               kfree(req);
+               req = oreq;
+       }
+
+       /* Put back request+reply buffers */
+       rpcrdma_buffer_put(req);
+}
+
+/*
+ * send_request invokes the meat of RPC RDMA. It must do the following:
+ *  1.  Marshal the RPC request into an RPC RDMA request, which means
+ *     putting a header in front of data, and creating IOVs for RDMA
+ *     from those in the request.
+ *  2.  In marshaling, detect opportunities for RDMA, and use them.
+ *  3.  Post a recv message to set up asynch completion, then send
+ *     the request (rpcrdma_ep_post).
+ *  4.  No partial sends are possible in the RPC-RDMA protocol (as in UDP).
+ */
+
+static int
+xprt_rdma_send_request(struct rpc_task *task)
+{
+       struct rpc_rqst *rqst = task->tk_rqstp;
+       struct rpc_xprt *xprt = task->tk_xprt;
+       struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
+       struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+
+       /* marshal the send itself */
+       if (req->rl_niovs == 0 && rpcrdma_marshal_req(rqst) != 0) {
+               r_xprt->rx_stats.failed_marshal_count++;
+               dprintk("RPC:       %s: rpcrdma_marshal_req failed\n",__func__);
+               return -EIO;
+       }
+
+       if (req->rl_reply == NULL)              /* e.g. reconnection */
+               rpcrdma_recv_buffer_get(req);
+
+       if (req->rl_reply) {
+               req->rl_reply->rr_func = rpcrdma_reply_handler;
+               /* this need only be done once, but... */
+               req->rl_reply->rr_xprt = xprt;
+       }
+
+       if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req)) {
+               xprt_disconnect(xprt);
+               return -ENOTCONN;       /* implies disconnect */
+       }
+
+       rqst->rq_bytes_sent = 0;
+       return 0;
+}
+
+static void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
+{
+       struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+       long idle_time = 0;
+
+       if (xprt_connected(xprt))
+               idle_time = (long)(jiffies - xprt->last_used) / HZ;
+
+       seq_printf(seq,
+         "\txprt:\trdma %u %lu %lu %lu %ld %lu %lu %lu %Lu %Lu "
+         "%lu %lu %lu %Lu %Lu %Lu %Lu %lu %lu %lu\n",
+
+          0,   /* need a local port? */
+          xprt->stat.bind_count,
+          xprt->stat.connect_count,
+          xprt->stat.connect_time,
+          idle_time,
+          xprt->stat.sends,
+          xprt->stat.recvs,
+          xprt->stat.bad_xids,
+          xprt->stat.req_u,
+          xprt->stat.bklog_u,
+
+          r_xprt->rx_stats.read_chunk_count,
+          r_xprt->rx_stats.write_chunk_count,
+          r_xprt->rx_stats.reply_chunk_count,
+          r_xprt->rx_stats.total_rdma_request,
+          r_xprt->rx_stats.total_rdma_reply,
+          r_xprt->rx_stats.pullup_copy_count,
+          r_xprt->rx_stats.fixup_copy_count,
+          r_xprt->rx_stats.hardway_register_count,
+          r_xprt->rx_stats.failed_marshal_count,
+          r_xprt->rx_stats.bad_reply_count);
+}
+
+/*
+ * Plumbing for rpc transport switch and kernel module
+ */
+
+static struct rpc_xprt_ops xprt_rdma_procs = {
+       .set_buffer_size        = xprt_rdma_set_buffer_size,
+       .reserve_xprt           = xprt_rdma_reserve_xprt,
+       .release_xprt           = xprt_release_xprt_cong,       /* sunrpc/xprt.c */
+       .rpcbind                = xprt_rdma_bind,
+       .set_port               = xprt_rdma_set_port,
+       .connect                = xprt_rdma_connect,
+       .buf_alloc              = xprt_rdma_allocate,
+       .buf_free               = xprt_rdma_free,
+       .send_request           = xprt_rdma_send_request,
+       .set_retrans_timeout    = xprt_set_retrans_timeout_def, /* ditto */
+       .timer                  = xprt_rdma_timer,
+       .release_request        = xprt_release_rqst_cong,       /* ditto */
+       .close                  = xprt_rdma_close,
+       .destroy                = xprt_rdma_destroy,
+       .print_stats            = xprt_rdma_print_stats
+};
+
+static struct xprt_class xprt_rdma = {
+       .list                   = LIST_HEAD_INIT(xprt_rdma.list),
+       .name                   = "rdma",
+       .owner                  = THIS_MODULE,
+       .family                 = 0xFF,         /* TBD: family 255 */
+       .protocol               = 0,
+       .setup                  = xprt_setup_rdma,
+};
+
+static void __exit xprt_rdma_cleanup(void)
+{
+       int rc;
+
+#ifdef RPC_DEBUG
+       printk("RPCRDMA Module Removed, deregister RPC RDMA transport\n");
+#endif
+#ifdef RPC_DEBUG
+       if (sunrpc_table_header) {
+               unregister_sysctl_table(sunrpc_table_header);
+               sunrpc_table_header = NULL;
+       }
+#endif
+       rc = xprt_unregister_transport(&xprt_rdma);
+       if (rc)
+               dprintk("RPC:       %s: xprt_unregister returned %i\n", __func__, rc);
+}
+
+static int __init xprt_rdma_init(void)
+{
+       int rc;
+
+       rc = xprt_register_transport(&xprt_rdma);
+
+       if (rc) {
+               return rc;
+       }
+
+#ifdef RPC_DEBUG
+       printk("RPCRDMA Module Init, register RPC RDMA transport\n");
+
+       printk("Defaults:\n");
+       printk("\tSlots %d\n"
+               "\tMaxInlineRead %d\n\tMaxInlineWrite %d\n",
+               xprt_rdma_slot_table_entries,
+               xprt_rdma_max_inline_read, xprt_rdma_max_inline_write);
+       printk("\tPadding %d\n\tMemreg %d\n",
+               xprt_rdma_inline_write_padding, xprt_rdma_memreg_strategy);
+
+       if (!sunrpc_table_header)
+               sunrpc_table_header = register_sysctl_table(sunrpc_table);
+#endif
+       return 0;
+}
+
+module_init(xprt_rdma_init);
+module_exit(xprt_rdma_cleanup);
Index: linux-2.6.22/net/sunrpc/xprtrdma/rpc_rdma.c
===================================================================
--- /dev/null
+++ linux-2.6.22/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -0,0 +1,9 @@
+/*
+ * Placeholders for subsequent patches
+ */
+
+#include "xprt_rdma.h"
+
+void rpcrdma_conn_func(struct rpcrdma_ep *a) { }
+void rpcrdma_reply_handler(struct rpcrdma_rep *a) { }
+int rpcrdma_marshal_req(struct rpc_rqst *a) { return EINVAL; }
Index: linux-2.6.22/net/sunrpc/xprtrdma/verbs.c
===================================================================
--- /dev/null
+++ linux-2.6.22/net/sunrpc/xprtrdma/verbs.c
@@ -0,0 +1,24 @@
+/*
+ * Placeholders for subsequent patches
+ */
+
+#include "xprt_rdma.h"
+
+int rpcrdma_ia_open(struct rpcrdma_xprt *a, struct sockaddr *b, int c) { return EINVAL; }
+void rpcrdma_ia_close(struct rpcrdma_ia *a) { }
+int rpcrdma_ep_create(struct rpcrdma_ep *a, struct rpcrdma_ia *b, struct rpcrdma_create_data_internal *c) { return EINVAL; }
+int rpcrdma_ep_destroy(struct rpcrdma_ep *a, struct rpcrdma_ia *b) { return EINVAL; }
+int rpcrdma_ep_connect(struct rpcrdma_ep *a, struct rpcrdma_ia *b) { return EINVAL; }
+int rpcrdma_ep_disconnect(struct rpcrdma_ep *a, struct rpcrdma_ia *b) { return EINVAL; }
+int rpcrdma_ep_post(struct rpcrdma_ia *a, struct rpcrdma_ep *b, struct rpcrdma_req *c) { return EINVAL; }
+int rpcrdma_ep_post_recv(struct rpcrdma_ia *a, struct rpcrdma_ep *b, struct rpcrdma_rep *c) { return EINVAL; }
+int rpcrdma_buffer_create(struct rpcrdma_buffer *a, struct rpcrdma_ep *b, struct rpcrdma_ia *c, struct rpcrdma_create_data_internal *d) { return EINVAL; }
+void rpcrdma_buffer_destroy(struct rpcrdma_buffer *a) { }
+struct rpcrdma_req *rpcrdma_buffer_get(struct rpcrdma_buffer *a) { return NULL; }
+void rpcrdma_buffer_put(struct rpcrdma_req *a) { }
+void rpcrdma_recv_buffer_get(struct rpcrdma_req *a) { }
+void rpcrdma_recv_buffer_put(struct rpcrdma_rep *a) { }
+int rpcrdma_register_internal(struct rpcrdma_ia *a, void *b, int c, struct ib_mr **d, struct ib_sge *e) { return EINVAL; }
+int rpcrdma_deregister_internal(struct rpcrdma_ia *a, struct ib_mr *b, struct ib_sge *c) { return EINVAL; }
+int rpcrdma_register_external(struct rpcrdma_mr_seg *a, int b, int c, struct rpcrdma_xprt *d) { return EINVAL; }
+int rpcrdma_deregister_external(struct rpcrdma_mr_seg *a, struct rpcrdma_xprt *b, void *c) { return EINVAL; }


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
