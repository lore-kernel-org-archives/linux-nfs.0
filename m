Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mercury.cora.nwra.com ([4.28.99.165]:42082 "EHLO
	mail.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab2LSWYz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2012 17:24:55 -0500
Message-ID: <50D236A4.6060906@cora.nwra.com>
Date: Wed, 19 Dec 2012 14:50:28 -0700
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: umount(,MNT_DETACH) for nfsv4 hangs when using sec=krb5 and network
 is down
References: <loom.20121219T214634-616@post.gmane.org> <4FA345DA4F4AE44899BD2B03EEEC2FA91196AE42@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91196AE42@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/19/2012 02:08 PM, Myklebust, Trond wrote:
> On Wed, 2012-12-19 at 20:47 +0000, Orion Poplawski wrote:
>>
>> However, we need someway to be able to drop mounts after the network connection
>> has been removed.  This behavior is causing sever problems for our laptop and
>> vpn users.
>>
>> Tested with:
>>
>> 3.6.11-3.fc18
>> nfs-utils-1.2.7-2.fc18
>>
>> I've also filed https://bugzilla.redhat.com/show_bug.cgi?id=888942
> 
> No. What you need is a way to unmount _before_ you kill the network.
> Once the network is gone, you are in severe data loss territory, and you
> are entirely on your own dealing with that problem...
> 
> Maybe one day we will get round to supporting offline mounts, but that's
> not the case today.
> 

I agree (see https://bugzilla.gnome.org/show_bug.cgi?id=387832 for example),
however it happens (and, because of lack of support as indicated by the bug,
hard to prevent) and it seems unfortunate to then subject the user to hanging
mounts (which will effectively lock up the desktop).  It currently is possible
for sec=sys mounts, so I thought it would be worth while making it work for
sec=krb5 mounts.  The same data loss issues are present for both.

We have put work in the past into making umount work for offline nfs mounts
(https://bugzilla.redhat.com/show_bug.cgi?id=820707).  In fact that looks
remarkably familiar :).

[  131.832005] umount.nfs4     D f1585bc8     0  1959   1958 0x00000080
[  131.832005]  f1585c34 00000086 0000ea8a f1585bc8 c045a297 f705f110 644b6440
0000001c
[  131.832005]  f1585bd8 c0cd5080 c0cd5080 00000282 f1585c00 f7591080 f3a27110
f1585c24
[  131.832005]  00000000 c0d2e280 00000282 00000246 f1585c00 c097a273 f1585c2c
f7ee11c5
[  131.832005] Call Trace:
[  131.832005]  [<c045a297>] ? __internal_add_timer+0x77/0xc0
[  131.832005]  [<c097a273>] ? _raw_spin_unlock_bh+0x13/0x20
[  131.832005]  [<f7ee11c5>] ? rpc_wake_up_first+0x65/0x180 [sunrpc]
[  131.832005]  [<f7eda240>] ? rpc_show_tasks+0x1b0/0x1b0 [sunrpc]
[  131.832005]  [<c09794d3>] schedule+0x23/0x60
[  131.832005]  [<f7ee064d>] rpc_wait_bit_killable+0x2d/0x70 [sunrpc]
[  131.832005]  [<c0977fc1>] __wait_on_bit+0x51/0x70
[  131.832005]  [<f7ee0620>] ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
[  131.832005]  [<f7ee0620>] ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
[  131.832005]  [<c0978041>] out_of_line_wait_on_bit+0x61/0x70
[  131.832005]  [<c046c100>] ? autoremove_wake_function+0x50/0x50
[  131.832005]  [<f7ee198f>] __rpc_execute+0x11f/0x340 [sunrpc]
[  131.832005]  [<c0507774>] ? mempool_alloc+0x44/0x120
[  131.832005]  [<f7ed8a50>] ? call_connect+0x90/0x90 [sunrpc]
[  131.832005]  [<f7ed8a50>] ? call_connect+0x90/0x90 [sunrpc]
[  131.832005]  [<c046c0a3>] ? wake_up_bit+0x23/0x30
[  131.832005]  [<f7ee1ec8>] rpc_execute+0x48/0x80 [sunrpc]
[  131.832005]  [<f7ed9929>] rpc_run_task+0x59/0x70 [sunrpc]
[  131.832005]  [<f7ed9a3c>] rpc_call_sync+0x3c/0x60 [sunrpc]
[  131.832005]  [<f8a402fc>] _nfs4_call_sync+0x3c/0x50 [nfsv4]
[  131.832005]  [<f8a403d5>] _nfs4_proc_getattr+0x95/0xa0 [nfsv4]
[  131.832005]  [<f8a41bab>] nfs4_proc_getattr+0x3b/0x60 [nfsv4]
[  131.832005]  [<f897f891>] __nfs_revalidate_inode+0x81/0x210 [nfs]
[  131.832005]  [<f897fbd2>] nfs_revalidate_inode+0x62/0x90 [nfs]
[  131.832005]  [<f89793ef>] nfs_check_verifier+0x4f/0x80 [nfs]
[  131.832005]  [<f897b4da>] nfs_lookup_revalidate+0x2ba/0x440 [nfs]
[  131.832005]  [<c055f8cb>] ? follow_managed+0x19b/0x200
[  131.832005]  [<c0560000>] ? unlazy_walk+0xf0/0x1a0
[  131.832005]  [<f897c184>] nfs4_lookup_revalidate+0x34/0xe0 [nfs]
[  131.832005]  [<c055fedc>] complete_walk+0x8c/0xc0
[  131.832005]  [<c05611b3>] path_lookupat+0x63/0x650
[  131.832005]  [<c05617ca>] do_path_lookup+0x2a/0xb0
[  131.832005]  [<c0563df6>] user_path_at_empty+0x46/0x80
[  131.832005]  [<c097d440>] ? vmalloc_fault+0x176/0x176
[  131.832005]  [<c097d5f7>] ? do_page_fault+0x1b7/0x450
[  131.832005]  [<c0563e4f>] user_path_at+0x1f/0x30
[  131.832005]  [<c05707b1>] sys_umount+0x41/0x340
[  131.832005]  [<c04bd59c>] ? __audit_syscall_entry+0xbc/0x290
[  131.832005]  [<c04bdac6>] ? __audit_syscall_exit+0x356/0x3b0
[  131.832005]  [<c0980fdf>] sysenter_do_call+0x12/0x28

I wonder if it never did get fixed for krb5 mounts then...

Bah.

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
