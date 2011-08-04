Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:36239 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752305Ab1HDMOq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 08:14:46 -0400
Date: Thu, 4 Aug 2011 14:14:44 +0200
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: 2.6.39.3: rpcb_getport_done() BUG trying to deref 0x6b6b6b6f
Message-ID: <20110804121444.GA14024@janus>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

While testing NLM I saw this once (reformatted a bit because logged
over netconsole):

 BUG: unable to handle kernel paging request at 6b6b6b6f
 IP: [<c174ffa2>] rpcb_getport_done+0x32/0xc0
 *pdpt = 000000003547c001
 *pde = 0000000000000000
 Oops: 0000 [#1]
 PREEMPT SMP 
 Pid: 1512, comm: kworker/0:2 Not tainted 2.6.39.3-x260 #1
 EIP: 0060:[<c174ffa2>] EFLAGS: 00010286 CPU: 0
 EIP is at rpcb_getport_done+0x32/0xc0
 EAX: 00009712 EBX: 00000000 ECX: c174ff70 EDX: f5434c40
 ESI: 6b6b6b6b EDI: f5434c40 EBP: f5fa9ef8 ESP: f5fa9ed8
  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
 Process kworker/0:2 (pid: 1512, ti=f5fa8000 task=f65008a0 task.ti=f5fa8000)
 Call Trace:
  [<c1741ded>] ? call_decode+0x13d/0x200
  [<c174835e>] rpc_exit_task+0x1e/0x50
  [<c17488f8>] __rpc_execute+0x68/0x1b0
  [<c1746694>] ? xs_udp_setup_socket+0x34/0x180
  [<c1748a8b>] rpc_async_schedule+0xb/0x10
  [<c1084400>] process_one_work+0x110/0x360
  [<c1748a80>] ? rpc_execute+0x40/0x40
  [<c1084977>] worker_thread+0x137/0x370
  [<c1084840>] ? manage_workers+0x110/0x110
  [<c1089d84>] kthread+0x74/0x80
  [<c1089d10>] ? __init_kthread_worker+0x30/0x30
  [<c17871b6>] kernel_thread_helper+0x6/0xd


I think it's here:
00000000 <rpcb_getport_done>:
   0:   55                      push   %ebp
   1:   89 e5                   mov    %esp,%ebp
   3:   83 ec 20                sub    $0x20,%esp
   6:   89 7d fc                mov    %edi,-0x4(%ebp)
   9:   89 d7                   mov    %edx,%edi
   b:   89 5d f4                mov    %ebx,-0xc(%ebp)
   e:   89 75 f8                mov    %esi,-0x8(%ebp)
  11:   8b 58 6c                mov    0x6c(%eax),%ebx
  14:   89 45 f0                mov    %eax,-0x10(%ebp)
  17:   8b 32                   mov    (%edx),%esi
  19:   83 fb fb                cmp    $0xfffffffb,%ebx
  1c:   74 62                   je     80 <rpcb_getport_done+0x80>
  1e:   83 fb a3                cmp    $0xffffffa3,%ebx
  21:   74 5d                   je     80 <rpcb_getport_done+0x80>
  23:   85 db                   test   %ebx,%ebx
  25:   78 65                   js     8c <rpcb_getport_done+0x8c>
  27:   0f b7 52 10             movzwl 0x10(%edx),%edx
  2b:   66 85 d2                test   %dx,%dx
  2e:   74 38                   je     68 <rpcb_getport_done+0x68>
=>30:   8b 4e 04                mov    0x4(%esi),%ecx
  33:   0f b7 d2                movzwl %dx,%edx
  36:   89 f0                   mov    %esi,%eax
  38:   ff 51 10                call   *0x10(%ecx)
  3b:   f0 0f ba ae bc 02 00    lock btsl $0x4,0x2bc(%esi)

static void rpcb_getport_done(struct rpc_task *child, void *data)
{
        struct rpcbind_args *map = data;
        struct rpc_xprt *xprt = map->r_xprt;
        int status = child->tk_status;

        /* Garbage reply: retry with a lesser rpcbind version */
        if (status == -EIO)
                status = -EPROTONOSUPPORT;

        /* rpcbind server doesn't support this rpcbind protocol version */
        if (status == -EPROTONOSUPPORT)
                xprt->bind_index++;

        if (status < 0) {
                /* rpcbind server not available on remote host? */
                xprt->ops->set_port(xprt, 0);
        } else if (map->r_port == 0) {
                /* Requested RPC service wasn't registered on remote host */
                xprt->ops->set_port(xprt, 0);
                status = -EACCES;
        } else {
                /* Succeeded */
                xprt->ops->set_port(xprt, map->r_port);
                    ^

-- 
Frank
