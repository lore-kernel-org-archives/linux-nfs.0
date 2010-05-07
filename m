Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:32906 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755039Ab0EGPim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 May 2010 11:38:42 -0400
Date: Fri, 7 May 2010 17:39:20 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Cc: salvet@ics.muni.cz
Subject: Deadlock in NFSv4 in all kernels
Message-ID: <20100507153920.GP28167@ics.muni.cz>
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I encountered the following problem. We use short expiration time for
kerberos contexts created by rpc.gssd (some patches were included in mainline
nfs-utils). In particular, we use 120secs expiration time.

Now, I run application that eats 80% of available RAM. Then I run 10 parallel
dd processes that write data into NFS4 volume with sec=krb5.

As soon as the kerberos context expires (i.e., up to 120 secs), the whole
system gets stuck in do_page_fault and succesive functions. It is because
there is no free memory in kernel, all free memory is used as cache for NFS4
(due to dd traffic), kernel ask NFS to write back its pages but NFS cannot do
anything as it is missing valid context. NFS contacts rpc.gssd to provide
a renewed context, the rpc.gssd does not provide the context as it needs some memory
to scan /tmp for a ticket. I.e., it deadlocks.

Longer context expiration time is no real solution as it only makes the
deadlock less often. 

Any ideas what can be done here? (Please cc me.) We could preallocate some
memory in rpc.gssd and use mlockall but not sure whether this proctects also
kernel malloc for things related to rpc.gssd and context creation (new file
descriptors and so on). 

This is seen in 2.6.32 kernel but most probably this is related to all kernel
versions.

rpc.gssd and all dd processes are stuck in:

May  6 15:33:10 skirit20 kernel: [84087.788019] rpc.gssd      D 6758d881     0 26864      1 0x00000000
May  6 15:33:10 skirit20 kernel: [84087.788019]  c280594c 00000086 f94c3d6c 6758d881 00004c5a 0f3e1c27 c1d868c0 c1c068dc
May  6 15:33:10 skirit20 kernel: [84087.788019]  c07d8880 c07d8880 f6752130 f67523d4 c1c06880 00000000 c1c06880 00000000
May  6 15:33:10 skirit20 kernel: [84087.788019]  f6d7c8f0 f67523d4 f6752130 c1c06cd4 c1c06880 c2805960 c052101f 00000000
May  6 15:33:10 skirit20 kernel: [84087.788019] Call Trace:
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c052101f>] io_schedule+0x6f/0xc0
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<f88d8af5>] nfs_wait_bit_uninterruptible+0x5/0x10 [nfs]
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c05215a7>] __wait_on_bit+0x47/0x70
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c0521683>] out_of_line_wait_on_bit+0xb3/0xd0
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<f88d8ae3>] nfs_wait_on_request+0x23/0x30 [nfs]
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<f88ddb4a>] nfs_sync_mapping_wait+0xea/0x200 [nfs]
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<f88ddd0e>] nfs_wb_page_priority+0xae/0x170 [nfs]
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<f88cdfec>] nfs_release_page+0x5c/0x70 [nfs]
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c029620b>] try_to_release_page+0x2b/0x40
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02a25af>] shrink_page_list+0x37f/0x4b0
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02a29ae>] shrink_inactive_list+0x2ce/0x6c0
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02a34c8>] shrink_zone+0x1c8/0x260
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02a35ae>] shrink_zones+0x4e/0xe0
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02a43b5>] do_try_to_free_pages+0x75/0x2e0
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02a4756>] try_to_free_pages+0x86/0xa0
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c029cda4>] __alloc_pages_slowpath+0x164/0x470
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c029d1c8>] __alloc_pages_nodemask+0x118/0x120
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02acce0>] do_anonymous_page+0x100/0x240
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02b072a>] handle_mm_fault+0x34a/0x3d0
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c0524c54>] do_page_fault+0x174/0x370
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c0522cb6>] error_code+0x66/0x70
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c0296ac2>] file_read_actor+0x32/0xf0
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c029815f>] do_generic_file_read+0x3af/0x4c0
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c0298a01>] generic_file_aio_read+0xb1/0x210
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02cdc05>] do_sync_read+0xd5/0x120
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02ce3bb>] vfs_read+0x9b/0x110
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c02ce501>] sys_read+0x41/0x80
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<c0203150>] sysenter_do_call+0x12/0x22
May  6 15:33:10 skirit20 kernel: [84087.788019]  [<ffffe430>] 0xffffe430

-- 
Luká¹ Hejtmánek
