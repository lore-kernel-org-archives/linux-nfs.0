From: Jeff Moyer <jmoyer@redhat.com>
Subject: list corruption in locks_start_grace with 2.6.28-rc3
Date: Wed, 12 Nov 2008 11:15:23 -0500
Message-ID: <x498wrokjj8.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45531 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755050AbYKLQPZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Nov 2008 11:15:25 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mACGFPQ6031455
	for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2008 11:15:25 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mACGFOmt006898
	for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2008 11:15:25 -0500
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.16.60.26])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mACGFOQF030485
	for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2008 11:15:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm doing some testing which involves roughly the following:

o mount a file system on the server
o start the nfs service
- mount the nfs-exported file system from a client
- perform a dd from the client
- umount the nfs-exported file system from a client
o stop the nfs service
o unmount the file system on the server

After several iterations of this, varying the number of nfsd threads
started, I get the attached backtrace.  I've reproduced it twice, now.

Let me know if I can be of further help.

Cheers,

Jeff

------------[ cut here ]------------
WARNING: at lib/list_debug.c:26 __list_add+0x42/0x87()
list_add corruption. next->prev should be prev (ffffffffa044fcc0), but was fffff
fffa0494b50. (next=ffffffffa0494b50).
Modules linked in: nfsd lockd nfs_acl auth_rpcgss exportfs bridge stp bnep rfcom
m l2cap bluetooth sunrpc iptable_filter ip_tables ip6table_filter ip6_tables x_t
ables ipv6 loop dm_round_robin dm_multipath sg sd_mod crc_t10dif qla2xxx ipmi_si
 ide_cd_mod pcspkr ipmi_msghandler bnx2 cdrom scsi_transport_fc serio_raw shpchp
 button cciss scsi_mod dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mo
d ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
Pid: 7076, comm: rpc.nfsd Tainted: G        W  2.6.28-rc3 #51
Call Trace:
 [<ffffffff8023ca74>] warn_slowpath+0xae/0xd5
 [<ffffffff802b036e>] ? kfree_debugcheck+0x11/0x2c
 [<ffffffff802b036e>] ? kfree_debugcheck+0x11/0x2c
 [<ffffffff802b036e>] ? kfree_debugcheck+0x11/0x2c
 [<ffffffff802b040a>] ? cache_free_debugcheck+0x81/0x238
 [<ffffffffa0058ee1>] ? ext3_htree_free_dir_info+0x19/0x1d [ext3]
 [<ffffffff8032c2b4>] ? selinux_file_free_security+0x1e/0x20
 [<ffffffff802b903d>] ? __fput+0x19e/0x1ab
 [<ffffffff803638e3>] __list_add+0x42/0x87
 [<ffffffffa0446629>] locks_start_grace+0x2e/0x41 [lockd]
 [<ffffffffa04764d7>] nfs4_state_start+0x94/0x106 [nfsd]
 [<ffffffffa045e5df>] nfsd_svc+0x6a/0x111 [nfsd]
 [<ffffffffa045f2d9>] ? write_threads+0x0/0xb4 [nfsd]
 [<ffffffffa045f343>] write_threads+0x6a/0xb4 [nfsd]
 [<ffffffff804e30b5>] ? _spin_unlock+0x30/0x4b
 [<ffffffff802d12d1>] ? simple_transaction_get+0x53/0xbf
 [<ffffffff802d1320>] ? simple_transaction_get+0xa2/0xbf
 [<ffffffffa045ea0c>] nfsctl_transaction_write+0x4c/0x7e [nfsd]
 [<ffffffff802b6362>] ? fd_install+0x30/0x5f
 [<ffffffff802b85b4>] vfs_write+0xae/0x137
 [<ffffffff802b8701>] sys_write+0x47/0x70
 [<ffffffff8020c00b>] system_call_fastpath+0x16/0x1b
---[ end trace 4eaa2a86a8e2da22 ]---
