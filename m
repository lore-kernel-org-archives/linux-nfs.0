Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59902 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179Ab1FWW31 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 18:29:27 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p5NMTRCx014567
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jun 2011 15:29:27 -0700
Message-ID: <4E03BE46.2040405@candelatech.com>
Date: Thu, 23 Jun 2011 15:29:26 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Subject: Use-after-free in hacked 2.6.38.8 kernel.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2.6.38.8 kernel, with our NFS bind-source-IP patches and some other
stuff, including a tainting module (though that module isn't
active in this test).

I'm also running the patch I posted a few days ago that explicitly
un-links the xpt_ready list:

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index ab86b79..178716f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -901,6 +901,7 @@ void svc_delete_xprt(struct svc_xprt *xprt)
  	spin_lock_bh(&serv->sv_lock);
  	if (!test_and_set_bit(XPT_DETACHED, &xprt->xpt_flags))
  		list_del_init(&xprt->xpt_list);
+	list_del_init(&xprt->xpt_ready);
  	/*
  	 * We used to delete the transport from whichever list
  	 * it's sk_xprt.xpt_ready node was on, but we don't actually

Test is to create 200 unique mounts (using unique srcaddr)
and mount/run-file-io-traffic/unmount them every 15 seconds.

It hit this bug after about 5 hours.

I'm going to try to figure this out, but any help is appreciated!


=============================================================================
BUG kmalloc-64: Poison overwritten
-----------------------------------------------------------------------------

INFO: 0xffff8800c6da9dd0-0xffff8800c6da9e03. First byte 0x48 instead of 0x6b
INFO: Allocated in nfs_get_lock_context+0xa4/0x179 [nfs] age=60 cpu=2 pid=9218
INFO: Freed in nfs_put_lock_context+0x3f/0x44 [nfs] age=70 cpu=0 pid=8543
INFO: Slab 0xffffea0002b7fcf8 objects=30 used=26 fp=0xffff8800c6da9dd0
flags=0x200000000000c1
INFO: Object 0xffff8800c6da9dd0 @offset=3536 fp=0xffff8800c6da9d48

Bytes b4 0xffff8800c6da9dc0:  fe b7 0f 01 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a
??......ZZZZZZZZ
   Object 0xffff8800c6da9dd0:  48 90 b9 b3 00 88 ff ff 6b 6b 6b 6b 6b 6b 6b 6b
H.??..??kkkkkkkk
   Object 0xffff8800c6da9de0:  06 00 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
......kkkkkkkkkk
   Object 0xffff8800c6da9df0:  00 00 00 00 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b
........kkkkkkkk
   Object 0xffff8800c6da9e00:  f3 ff ff ff 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5
????kkkkkkkkkkk?
  Redzone 0xffff8800c6da9e10:  bb bb bb bb bb bb bb bb
????????
  Padding 0xffff8800c6da9e50:  5a 5a 5a 5a 5a 5a 5a 5a
ZZZZZZZZ
Pid: 9019, comm: btserver Tainted: P            2.6.38.8+ #9
Call Trace:
  [<ffffffff81100aee>] ? print_trailer+0x12e/0x137
  [<ffffffff81100fb7>] ? check_bytes_and_report+0xb9/0xfd
  [<ffffffffa030ddbb>] ? nfs_get_lock_context+0x94/0x179 [nfs]
  [<ffffffff811010b0>] ? check_object+0xb5/0x192
  [<ffffffffa030ddcb>] ? nfs_get_lock_context+0xa4/0x179 [nfs]
  [<ffffffff811014d1>] ? alloc_debug_processing+0x79/0xf2
  [<ffffffff81102bff>] ? __slab_alloc+0x337/0x375
  [<ffffffffa030ddcb>] ? nfs_get_lock_context+0xa4/0x179 [nfs]
  [<ffffffffa030dd4f>] ? nfs_get_lock_context+0x28/0x179 [nfs]
  [<ffffffffa030ddcb>] ? nfs_get_lock_context+0xa4/0x179 [nfs]
  [<ffffffff81103d87>] ? kmem_cache_alloc_trace+0x76/0xef
  [<ffffffff81465d62>] ? sub_preempt_count+0x92/0xa6
  [<ffffffffa030ddcb>] ? nfs_get_lock_context+0xa4/0x179 [nfs]
  [<ffffffffa0313c32>] ? nfs_file_direct_write+0x1ab/0x752 [nfs]
  [<ffffffff81122b25>] ? pollwake+0x0/0x4f
  [<ffffffff810423db>] ? get_parent_ip+0x11/0x41
  [<ffffffff811026f5>] ? __slab_free+0x86/0xf1
  [<ffffffff811429cf>] ? fsnotify_put_event+0x63/0x67
  [<ffffffff81077d44>] ? trace_hardirqs_on+0xd/0xf
  [<ffffffffa030bd9b>] ? nfs_file_write+0x5d/0x169 [nfs]
  [<ffffffff811134c8>] ? do_sync_write+0xc6/0x103
  [<ffffffff811df2b4>] ? security_file_permission+0x29/0x2e
  [<ffffffff81113e58>] ? vfs_write+0xa9/0x105
  [<ffffffff811145f5>] ? fget_light+0x35/0x94
  [<ffffffff81113f6d>] ? sys_write+0x45/0x6c
  [<ffffffff8100aa92>] ? system_call_fastpath+0x16/0x1b
FIX kmalloc-64: Restoring 0xffff8800c6da9dd0-0xffff8800c6da9e03=0x6b

FIX kmalloc-64: Marking all objects used
=============================================================================
BUG kmalloc-64: Redzone overwritten
-----------------------------------------------------------------------------

INFO: 0xffff8800c6da9e10-0xffff8800c6da9e17. First byte 0xbb instead of 0xcc
INFO: Allocated in nfs_get_lock_context+0xa4/0x179 [nfs] age=173 cpu=2 pid=9218
INFO: Freed in nfs_put_lock_context+0x3f/0x44 [nfs] age=172 cpu=0 pid=8543
INFO: Slab 0xffffea0002b7fcf8 objects=30 used=30 fp=0x          (null)
flags=0x20000000000081
INFO: Object 0xffff8800c6da9dd0 @offset=3536 fp=0xffff8800c6da9d48

Bytes b4 0xffff8800c6da9dc0:  fe b7 0f 01 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a
??......ZZZZZZZZ
   Object 0xffff8800c6da9dd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
   Object 0xffff8800c6da9de0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
   Object 0xffff8800c6da9df0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
   Object 0xffff8800c6da9e00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5
kkkkkkkkkkkkkkk?
  Redzone 0xffff8800c6da9e10:  bb bb bb bb bb bb bb bb
????????
  Padding 0xffff8800c6da9e50:  5a 5a 5a 5a 5a 5a 5a 5a
ZZZZZZZZ
Pid: 13574, comm: mount.nfs Tainted: P            2.6.38.8+ #9
Call Trace:
  [<ffffffff81100aee>] ? print_trailer+0x12e/0x137
  [<ffffffff81100fb7>] ? check_bytes_and_report+0xb9/0xfd
  [<ffffffffa028a9cc>] ? rpcb_create_local+0x6a/0x112 [sunrpc]
  [<ffffffffa028a95d>] ? rpcb_map_release+0x3f/0x44 [sunrpc]
  [<ffffffff81101044>] ? check_object+0x49/0x192
  [<ffffffffa028a95d>] ? rpcb_map_release+0x3f/0x44 [sunrpc]
  [<ffffffff81101efd>] ? free_debug_processing+0x7a/0x18e
  [<ffffffffa028a95d>] ? rpcb_map_release+0x3f/0x44 [sunrpc]
  [<ffffffff8110274b>] ? __slab_free+0xdc/0xf1
  [<ffffffffa028a95d>] ? rpcb_map_release+0x3f/0x44 [sunrpc]
  [<ffffffff811031ad>] ? kfree+0x12e/0x166
  [<ffffffffa028a95d>] ? rpcb_map_release+0x3f/0x44 [sunrpc]
  [<ffffffffa0281eae>] ? rpc_release_calldata+0x12/0x14 [sunrpc]
  [<ffffffffa0282080>] ? rpc_free_task+0x59/0x61 [sunrpc]
  [<ffffffffa028210a>] ? rpc_final_put_task+0x82/0x8a [sunrpc]
  [<ffffffffa028213d>] ? rpc_do_put_task+0x2b/0x32 [sunrpc]
  [<ffffffffa028215e>] ? rpc_put_task+0xb/0xd [sunrpc]
  [<ffffffffa028a8dd>] ? rpcb_getport_async+0x564/0x5a5 [sunrpc]
  [<ffffffff810423db>] ? get_parent_ip+0x11/0x41
  [<ffffffffa027b349>] ? call_bind+0x70/0x75 [sunrpc]
  [<ffffffffa0282911>] ? __rpc_execute+0x78/0x24b [sunrpc]
  [<ffffffff8106750e>] ? wake_up_bit+0x20/0x25
  [<ffffffffa0282b21>] ? rpc_execute+0x3d/0x42 [sunrpc]
  [<ffffffffa027ca9f>] ? rpc_run_task+0xe3/0xef [sunrpc]
  [<ffffffffa027cb89>] ? rpc_call_sync+0x3f/0x60 [sunrpc]
  [<ffffffffa027cbec>] ? rpc_ping+0x42/0x58 [sunrpc]
  [<ffffffff8146275b>] ? _raw_spin_unlock+0x45/0x52
  [<ffffffffa027d4d5>] ? rpc_create+0x493/0x50e [sunrpc]
  [<ffffffffa0307077>] ? nfs_get_client+0x50/0x536 [nfs]
  [<ffffffffa030698e>] ? nfs_create_rpc_client+0xb1/0xf6 [nfs]
  [<ffffffffa0307f92>] ? nfs_create_server+0x170/0x48e [nfs]
  [<ffffffff81077d44>] ? trace_hardirqs_on+0xd/0xf
  [<ffffffffa0312486>] ? nfs_get_sb+0x4e8/0x742 [nfs]
  [<ffffffff81115eb7>] ? vfs_kern_mount+0xea/0x1f6
  [<ffffffff81116021>] ? do_kern_mount+0x48/0xd8
  [<ffffffff8112da55>] ? do_mount+0x708/0x770
  [<ffffffff810f9723>] ? alloc_pages_current+0xaa/0xcd
  [<ffffffff8112db40>] ? sys_mount+0x83/0xbd
  [<ffffffff8100aa92>] ? system_call_fastpath+0x16/0x1b
FIX kmalloc-64: Restoring 0xffff8800c6da9e10-0xffff8800c6da9e17=0xcc
-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

