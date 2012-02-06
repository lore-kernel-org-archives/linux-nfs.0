Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:42104 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab2BFXZU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2012 18:25:20 -0500
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q16NPKmN000393
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 6 Feb 2012 15:25:20 -0800
Message-ID: <4F306160.8030901@candelatech.com>
Date: Mon, 06 Feb 2012 15:25:20 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Fwd: NFS related crash in net-next (3.3.0-rc1) and hacked 3.3.0-rc2
References: <4F305BB4.6020401@candelatech.com>
In-Reply-To: <4F305BB4.6020401@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Forgot to CC linux-nfs mailing list...


-------- Original Message --------
Subject: NFS related crash in net-next (3.3.0-rc1) and hacked 3.3.0-rc2
Date: Mon, 06 Feb 2012 15:01:08 -0800
From: Ben Greear <greearb@candelatech.com>
Organization: Candela Technologies
To: netdev <netdev@vger.kernel.org>

I see this on un-modified net-next (3.3.0-rc1+) from today.

A patched-by-me version of 3.3.0-rc2+ (synced with upstream from
a few days ago had similar issue).

The test case is just to copy a bunch of files over NFS, including
a few directories recursively.  Takes around 10 seconds when it's working
correctly, so it's not a huge number of files/data.

This is 100% reproducible for me.

Thanks,
Ben


ct922-61 login: BUG: unable to handle kernel NULL pointer dereference at   (null)
IP: [<c0499fcb>] page_address+0xb/0x8f
*pde = 00000000
Oops: 0000 [#1] SMP
Modules linked in: 8021q garp stp llc fuse macvlan pktgen iscsi_tcp libiscsi_tcp libiscsi scsi_transport_]

Pid: 2020, comm: cp Tainted: G        W    3.3.0-rc1+ #5    /Alviso
EIP: 0060:[<c0499fcb>] EFLAGS: 00010286 CPU: 0
EIP is at page_address+0xb/0x8f
EAX: 00000000 EBX: 00000000 ECX: f6f789e4 EDX: 00000038
ESI: f2dcfc54 EDI: 0000000e EBP: f2dcfc38 ESP: f2dcfc28
  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process cp (pid: 2020, ti=f2dce000 task=f2db1e60 task.ti=f2dce000)
Stack:
  f86049c2 f2dcfdd0 f2dcfc54 0000000e f2dcfc7c f8606e98 00000000 00001000
  f2dcfc54 f4ff1100 f2dcfc8c 00000000 00000002 f6f78874 00000000 00000000
  0000006e 00000000 f2dcfc8c f4ff1100 00000000 f2dcfcb4 f834d558 f835423f
Call Trace:
  [<f86049c2>] ? reserve_space+0x8/0x12 [nfs]
  [<f8606e98>] nfs4_xdr_enc_getacl+0x72/0x93 [nfs]
  [<f834d558>] rpcauth_wrap_req+0x72/0x7c [sunrpc]
  [<f835423f>] ? xdr_encode_opaque+0x12/0x15 [sunrpc]
  [<f8606e26>] ? nfs4_xdr_dec_read+0xc3/0xc3 [nfs]
  [<f8346c63>] call_transmit+0x178/0x1e2 [sunrpc]
  [<f834cafe>] __rpc_execute+0x60/0x1f2 [sunrpc]
  [<c043a39d>] ? wake_up_bit+0x57/0x5b
  [<f834ccc1>] rpc_execute+0x31/0x34 [sunrpc]
  [<f8347611>] rpc_run_task+0x5a/0x60 [sunrpc]
  [<f83476f6>] rpc_call_sync+0x3d/0x58 [sunrpc]
  [<f8600fa8>] _nfs4_call_sync+0x1e/0x20 [nfs]
  [<f8602f6d>] __nfs4_get_acl_uncached+0x16a/0x205 [nfs]
  [<f86030f8>] nfs4_xattr_get_nfs4_acl+0xf0/0x126 [nfs]
  [<c04d41cd>] generic_getxattr+0x69/0x6d
  [<c04d4164>] ? seq_read+0x31c/0x31c
  [<c04d4817>] vfs_getxattr+0x76/0x7f
  [<c04d4c05>] getxattr+0x84/0xce
  [<c04bf209>] ? put_filp+0x26/0x29
  [<c04c5a4d>] ? release_open_intent+0x1c/0x25
  [<c04c79a0>] ? path_openat+0x272/0x287
  [<c049d404>] ? handle_pte_fault+0x288/0x74d
  [<c04c7a5f>] ? do_filp_open+0x21/0x5d
  [<c07a46f4>] ? _raw_spin_unlock+0x8/0xa
  [<c04c66ad>] ? putname+0x25/0x2e
  [<c04c66ad>] ? putname+0x25/0x2e
  [<c04c5370>] ? path_put+0x15/0x18
  [<c047177f>] ? audit_free_names+0x77/0x91
  [<c04d4c80>] sys_fgetxattr+0x31/0x44
  [<c07a90d8>] sysenter_do_call+0x12/0x28
Code: 8d 58 f8 8d 4b 08 39 f1 75 9e 89 f8 e8 25 a7 30 00 83 c4 0c 5b 5e 5f 5d c3 0f 0b e9 f7 fe ff ff 55
EIP: [<c0499fcb>] page_address+0xb/0x8f SS:ESP 0068:f2dcfc28
CR2: 0000000000000000
---[ end trace e93713a9d40cd06e ]---

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
