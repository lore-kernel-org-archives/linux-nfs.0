Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:54138 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927AbcFFDUp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jun 2016 23:20:45 -0400
From: Oleg Drokin <green@linuxhacker.ru>
Content-Type: text/plain; charset=us-ascii
Subject: nfs4 infinite loop in rpc_clnt_iterate_for_each_xprt without multipath
Date: Sun, 5 Jun 2016 23:20:35 -0400
Message-Id: <8C211C23-0DBA-4702-96BC-405E6ECDC10F@linuxhacker.ru>
Cc: linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

   I am hitting a strange problem with 4.7.0-rc1, basically eventually my NFS4 client
   enters a state where it's stuck in an infinite loop in
   rpc_clnt_iterate_for_each_xprt() called from nfs4_proc_bind_conn_to_session_callback

   The whole backtrace looks like this:
(gdb) bt
#0  xprt_iter_next_entry_multiple (xpi=0xffff880058cf3d80, 
    find_next=0xffffffff81865de0 <xprt_switch_find_next_entry>)
    at /home/green/bk/linux/net/sunrpc/xprtmultipath.c:276
#1  0xffffffff81866085 in xprt_iter_next_entry_all (xpi=<optimized out>)
    at /home/green/bk/linux/net/sunrpc/xprtmultipath.c:306
#2  0xffffffff81865e56 in xprt_iter_get_helper (xpi=0xffff880058cf3d80, 
    fn=0xffffffff81866070 <xprt_iter_next_entry_all>)
    at /home/green/bk/linux/net/sunrpc/xprtmultipath.c:411
#3  0xffffffff818668e6 in xprt_iter_get_next (xpi=0xffff880058cf3d80)
    at /home/green/bk/linux/net/sunrpc/xprtmultipath.c:448
#4  0xffffffff8183ebc2 in rpc_clnt_iterate_for_each_xprt (
    clnt=0xffff88005e313e00, 
    fn=0xffffffff8139d8f0 <nfs4_proc_bind_conn_to_session_callback>, 
    data=0xffff880058cf3dd8) at /home/green/bk/linux/net/sunrpc/clnt.c:776
#5  0xffffffff813adfdb in nfs4_proc_bind_conn_to_session (clp=<optimized out>, 
    cred=<optimized out>) at /home/green/bk/linux/fs/nfs/nfs4proc.c:6917
#6  0xffffffff813bea11 in nfs4_bind_conn_to_session (clp=<optimized out>)
    at /home/green/bk/linux/fs/nfs/nfs4state.c:2311
#7  nfs4_state_manager (clp=<optimized out>)
    at /home/green/bk/linux/fs/nfs/nfs4state.c:2376
#8  nfs4_run_state_manager (ptr=0xffff88003c39d800)
    at /home/green/bk/linux/fs/nfs/nfs4state.c:2457
#9  0xffffffff810af3a1 in kthread (_create=0xffff8800509c62c0)
    at /home/green/bk/linux/kernel/kthread.c:209


   if I enable nfs debug, I also see a very tight loop like:
[ 4563.114185] --> nfs4_proc_bind_one_conn_to_session
[ 4563.114690] <-- nfs4_proc_bind_one_conn_to_session status= 0
[ 4563.114691] --> nfs4_proc_bind_one_conn_to_session
[ 4563.115177] <-- nfs4_proc_bind_one_conn_to_session status= 0
. . .
   the NFSD side also gets a lot of these back to back requests.
   Everytthign using this nfs export is stuck in D state.

   So I looked around and I guess I am confused how is this all supposed to work.

   The loop in rpc_clnt_iterate_for_each_xprt() supposedly iterates over all connections
   for the "import". Now looking into the xprt_iter_next_entry_multiple, we can see that
        if (xps->xps_nxprts < 2)
                return xprt_switch_find_first_entry(head);

   This is my case:
$15 = {xps_lock = {{rlock = {raw_lock = {val = {counter = 0}}, 
        magic = 3735899821, owner_cpu = 4294967295, owner = 0xffffffffffffffff, 
        dep_map = {key = 0xffffffff8357e4b0 <__key.23771>, class_cache = {
            0x0 <irq_stack_union>, 0x0 <irq_stack_union>}, 
          name = 0xffffffff81cf96e6 "&(&xps->xps_lock)->rlock", cpu = 4, 
          ip = 6510615555426900570}}, {
        __padding = "\000\000\000\000\255N\255\336\377\377\377\377ZZZZ\377\377\377\377\377\377\377\377", dep_map = {key = 0xffffffff8357e4b0 <__key.23771>, 
          class_cache = {0x0 <irq_stack_union>, 0x0 <irq_stack_union>}, 
          name = 0xffffffff81cf96e6 "&(&xps->xps_lock)->rlock", cpu = 4, 
          ip = 6510615555426900570}}}}, xps_kref = {refcount = {counter = 3}}, 
  xps_nxprts = 1, xps_xprt_list = {next = 0xffff88004f5835e0, 
    prev = 0xffff88004f5835e0}, xps_net = 0xffffffff81f790c0 <init_net>, 
  xps_iter_ops = 0xffffffff81adfb20 <rpc_xprt_iter_singular>, xps_rcu = {
    next = 0x5a5a5a5a5a5a5a5a, func = 0xa55a5a5a5a5a5a5a}}


   So the loop in rpc_clnt_iterate_for_each_xprt(), that terminates on when the next
   element returned is NULL never gets that for when there are no failover links
   and happily keeps looping forever? Am I reading this right?

   This seems to be a somewhat new code landing on Linus' tree only on Mar 22,
   so I imagine if it was indeed an eternal loop like that, there would be a lot
   more reports already but in fact I don't hit this all the time myself, so I
   wonder if there's something else in play?

   Thanks.

Bye,
    Oleg