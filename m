Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga09.intel.com ([134.134.136.24]:29767 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751241Ab3AHD0O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jan 2013 22:26:14 -0500
Date: Tue, 08 Jan 2013 11:25:02 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [nfs:linux-next 1/1] net/sunrpc/xprt.c:1142:22: sparse: incorrect type in assignment (different address spaces)
Message-ID: <50eb918e.DgKsBe9tyaxzZIeK%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
head:   51b63a538c54cb9c3b83c4d62572cf18da165cba
commit: 51b63a538c54cb9c3b83c4d62572cf18da165cba [1/1] SUNRPC: Ensure we release the socket write lock if the rpc_task exits early


sparse warnings:

net/sunrpc/xprt.c:731:39: sparse: incorrect type in initializer (different address spaces)
net/sunrpc/xprt.c:731:39:    expected struct rpc_xprt *xprt
net/sunrpc/xprt.c:731:39:    got struct rpc_xprt [noderef] <asn:4>*cl_xprt
net/sunrpc/xprt.c:433:31: sparse: incorrect type in argument 1 (different address spaces)
net/sunrpc/xprt.c:433:31:    expected struct rpc_xprt *xprt
net/sunrpc/xprt.c:433:31:    got struct rpc_xprt [noderef] <asn:4>*cl_xprt
net/sunrpc/xprt.c:447:39: sparse: incorrect type in initializer (different address spaces)
net/sunrpc/xprt.c:447:39:    expected struct rpc_xprt *xprt
net/sunrpc/xprt.c:447:39:    got struct rpc_xprt [noderef] <asn:4>*cl_xprt
net/sunrpc/xprt.c:698:39: sparse: incorrect type in initializer (different address spaces)
net/sunrpc/xprt.c:698:39:    expected struct rpc_xprt *xprt
net/sunrpc/xprt.c:698:39:    got struct rpc_xprt [noderef] <asn:4>*cl_xprt
net/sunrpc/xprt.c:1094:39: sparse: incorrect type in initializer (different address spaces)
net/sunrpc/xprt.c:1094:39:    expected struct rpc_xprt *xprt
net/sunrpc/xprt.c:1094:39:    got struct rpc_xprt [noderef] <asn:4>*cl_xprt
+ net/sunrpc/xprt.c:1142:22: sparse: incorrect type in assignment (different address spaces)
net/sunrpc/xprt.c:1142:22:    expected struct rpc_xprt *xprt
net/sunrpc/xprt.c:1142:22:    got struct rpc_xprt [noderef] <asn:4>*cl_xprt

vim +1142 net/sunrpc/xprt.c

9903cd1c Chuck Lever     2005-08-11  1088   *
9903cd1c Chuck Lever     2005-08-11  1089   * If no more slots are available, place the task on the transport's
9903cd1c Chuck Lever     2005-08-11  1090   * backlog queue.
9903cd1c Chuck Lever     2005-08-11  1091   */
9903cd1c Chuck Lever     2005-08-11  1092  void xprt_reserve(struct rpc_task *task)
^1da177e Linus Torvalds  2005-04-16  1093  {
^1da177e Linus Torvalds  2005-04-16 @1094  	struct rpc_xprt	*xprt = task->tk_xprt;
^1da177e Linus Torvalds  2005-04-16  1095  
43cedbf0 Trond Myklebust 2011-07-17  1096  	task->tk_status = 0;
43cedbf0 Trond Myklebust 2011-07-17  1097  	if (task->tk_rqstp != NULL)
43cedbf0 Trond Myklebust 2011-07-17  1098  		return;
43cedbf0 Trond Myklebust 2011-07-17  1099  
43cedbf0 Trond Myklebust 2011-07-17  1100  	task->tk_timeout = 0;
43cedbf0 Trond Myklebust 2011-07-17  1101  	task->tk_status = -EAGAIN;
f39c1bfb Trond Myklebust 2012-09-07  1102  	xprt->ops->alloc_slot(xprt, task);
^1da177e Linus Torvalds  2005-04-16  1103  }
^1da177e Linus Torvalds  2005-04-16  1104  
d8ed029d Alexey Dobriyan 2006-09-26  1105  static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
^1da177e Linus Torvalds  2005-04-16  1106  {
0eae88f3 Eric Dumazet    2010-04-20  1107  	return (__force __be32)xprt->xid++;
^1da177e Linus Torvalds  2005-04-16  1108  }
^1da177e Linus Torvalds  2005-04-16  1109  
^1da177e Linus Torvalds  2005-04-16  1110  static inline void xprt_init_xid(struct rpc_xprt *xprt)
^1da177e Linus Torvalds  2005-04-16  1111  {
bf3fcf89 Chuck Lever     2006-05-25  1112  	xprt->xid = net_random();
^1da177e Linus Torvalds  2005-04-16  1113  }
^1da177e Linus Torvalds  2005-04-16  1114  
9903cd1c Chuck Lever     2005-08-11  1115  static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
^1da177e Linus Torvalds  2005-04-16  1116  {
^1da177e Linus Torvalds  2005-04-16  1117  	struct rpc_rqst	*req = task->tk_rqstp;
^1da177e Linus Torvalds  2005-04-16  1118  
d9ba131d Trond Myklebust 2011-07-17  1119  	INIT_LIST_HEAD(&req->rq_list);
ba7392bb Trond Myklebust 2007-12-20  1120  	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
^1da177e Linus Torvalds  2005-04-16  1121  	req->rq_task	= task;
^1da177e Linus Torvalds  2005-04-16  1122  	req->rq_xprt    = xprt;
02107148 Chuck Lever     2006-01-03  1123  	req->rq_buffer  = NULL;
^1da177e Linus Torvalds  2005-04-16  1124  	req->rq_xid     = xprt_alloc_xid(xprt);
ead5e1c2 J. Bruce Fields 2005-10-13  1125  	req->rq_release_snd_buf = NULL;
da45828e Trond Myklebust 2006-08-31  1126  	xprt_reset_majortimeo(req);
46121cf7 Chuck Lever     2007-01-31  1127  	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
^1da177e Linus Torvalds  2005-04-16  1128  			req, ntohl(req->rq_xid));
^1da177e Linus Torvalds  2005-04-16  1129  }
^1da177e Linus Torvalds  2005-04-16  1130  
9903cd1c Chuck Lever     2005-08-11  1131  /**
9903cd1c Chuck Lever     2005-08-11  1132   * xprt_release - release an RPC request slot
9903cd1c Chuck Lever     2005-08-11  1133   * @task: task which is finished with the slot
9903cd1c Chuck Lever     2005-08-11  1134   *
^1da177e Linus Torvalds  2005-04-16  1135   */
9903cd1c Chuck Lever     2005-08-11  1136  void xprt_release(struct rpc_task *task)
^1da177e Linus Torvalds  2005-04-16  1137  {
55ae1aab Ricardo Labiaga 2009-04-01  1138  	struct rpc_xprt	*xprt;
51b63a53 Trond Myklebust 2013-01-07  1139  	struct rpc_rqst	*req = task->tk_rqstp;
^1da177e Linus Torvalds  2005-04-16  1140  
51b63a53 Trond Myklebust 2013-01-07  1141  	if (req == NULL) {
51b63a53 Trond Myklebust 2013-01-07 @1142  		xprt = task->tk_xprt;
51b63a53 Trond Myklebust 2013-01-07  1143  		if (xprt->snd_task == task)
51b63a53 Trond Myklebust 2013-01-07  1144  			xprt_release_write(xprt, task);
^1da177e Linus Torvalds  2005-04-16  1145  		return;

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
