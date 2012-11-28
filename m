Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp103.biz.mail.ne1.yahoo.com ([98.138.207.10]:33821 "HELO
	smtp103.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755725Ab2K1S44 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Nov 2012 13:56:56 -0500
Message-ID: <50B65E7E.4030607@schaufler-ca.com>
Date: Wed, 28 Nov 2012 10:57:02 -0800
From: Casey Schaufler <casey@schaufler-ca.com>
MIME-Version: 1.0
To: Dave Quigley <dpquigl@davequigley.com>
CC: bfields@fieldses.org, trond.myklebust@netapp.com, sds@tycho.nsa.gov,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Labeled NFS [v5]
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <50ABF1A5.2010406@schaufler-ca.com> <50AC1A74.7080105@davequigley.com> <50AC2117.801@schaufler-ca.com> <50AC224D.3080108@davequigley.com> <50AC41DC.5070607@schaufler-ca.com> <50AC4A7A.6010208@davequigley.com>
In-Reply-To: <50AC4A7A.6010208@davequigley.com>
Content-Type: multipart/mixed;
 boundary="------------060008000900030309010000"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060008000900030309010000
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 11/20/2012 7:28 PM, Dave Quigley wrote:
> On 11/20/2012 9:52 PM, Casey Schaufler wrote:
>> On 11/20/2012 4:37 PM, Dave Quigley wrote:
>>> ...
>>>
>>>
>>> Or I could just give you this link and you should be good to go ;)
>>>
>>> http://www.selinuxproject.org/~dpquigl/nfs-utils-rpms/
>>>
>>> I haven't tried it but it should work. If it doesn't let me know and
>>> i'll try to fix it on my end. I'd imagine you might need to yum remove
>>> nfs-utils first before adding this new one or you could also try an
>>> rpm with the upgrade flag for this instead. Good luck.
>>
...


I've tried on Fedora17 and Ubuntu12.04, and I'm getting the
attached stack trace on mount. After mounting I'm getting
denials when I should, but also when I shouldn't.

I've tried tracking down the issue, but there's a lot going on
that I don't find obvious. I added a dentry_init hook just for
grins, but it's not getting called.

.



--------------060008000900030309010000
Content-Type: text/plain; charset=windows-1252;
 name="nfs-trace-20121128"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs-trace-20121128"

[ 1318.360964] decode_attr_security_label(): NULL label.
[ 1318.360968] Pid: 2141, comm: mount.nfs4 Not tainted 3.7.0-rc5-nfs-cbs #7
[ 1318.360970] Call Trace:
[ 1318.360985]  [<f877ec53>] decode_getfattr_attrs+0xbb3/0xca0 [nfsv4]
[ 1318.360995]  [<f8778455>] ? decode_attr_length+0x35/0x50 [nfsv4]
[ 1318.361005]  [<f877edc1>] decode_getfattr_generic.constprop.104+0x81/0xb0 [nfsv4]
[ 1318.361033]  [<f877ee9d>] decode_getfattr+0x1d/0x30 [nfsv4]
[ 1318.361044]  [<f877f34a>] nfs4_xdr_dec_access+0x7a/0x80 [nfsv4]
[ 1318.361051]  [<c103cd98>] ? default_spin_lock_flags+0x8/0x10
[ 1318.361060]  [<f877f2d0>] ? nfs4_xdr_dec_getattr+0x60/0x60 [nfsv4]
[ 1318.361079]  [<f86eddbd>] rpcauth_unwrap_resp+0x5d/0x70 [sunrpc]
[ 1318.361084]  [<c15c2993>] ? schedule+0x23/0x60
[ 1318.361094]  [<f877f2d0>] ? nfs4_xdr_dec_getattr+0x60/0x60 [nfsv4]
[ 1318.361106]  [<f86e48e2>] call_decode+0x2c2/0x3b0 [sunrpc]
[ 1318.361116]  [<f877f2d0>] ? nfs4_xdr_dec_getattr+0x60/0x60 [nfsv4]
[ 1318.361129]  [<f86ec727>] __rpc_execute+0x57/0x250 [sunrpc]
[ 1318.361141]  [<f86e4620>] ? call_bc_transmit+0xf0/0xf0 [sunrpc]
[ 1318.361152]  [<f86e4620>] ? call_bc_transmit+0xf0/0xf0 [sunrpc]
[ 1318.361157]  [<c106a5b3>] ? wake_up_bit+0x23/0x30
[ 1318.361170]  [<f86ece84>] rpc_execute+0x34/0x80 [sunrpc]
[ 1318.361174]  [<c15c358d>] ? _raw_spin_lock+0xd/0x10
[ 1318.361186]  [<f86e5f5d>] ? rpc_task_set_client+0x5d/0x90 [sunrpc]
[ 1318.361197]  [<f86e5fe9>] rpc_run_task+0x59/0x70 [sunrpc]
[ 1318.361209]  [<f86e60fc>] rpc_call_sync+0x3c/0x60 [sunrpc]
[ 1318.361218]  [<f876e713>] _nfs4_call_sync+0x33/0x40 [nfsv4]
[ 1318.361226]  [<f87711f3>] nfs4_proc_access+0x123/0x1c0 [nfsv4]
[ 1318.361238]  [<f8717ba3>] nfs_do_access+0x163/0x200 [nfs]
[ 1318.361252]  [<f86ee522>] ? generic_lookup_cred+0x12/0x20 [sunrpc]
[ 1318.361267]  [<f86edc8e>] ? rpcauth_lookupcred+0x4e/0x70 [sunrpc]
[ 1318.361277]  [<f8717cea>] nfs_permission+0xaa/0x160 [nfs]
[ 1318.361283]  [<c1157a04>] __inode_permission+0x64/0xb0
[ 1318.361293]  [<f871aed2>] ? nfs_get_root+0xe2/0x1b0 [nfs]
[ 1318.361302]  [<f8718010>] ? nfs_instantiate+0x170/0x170 [nfs]
[ 1318.361306]  [<c1157a66>] inode_permission+0x16/0x50
[ 1318.361316]  [<f8718010>] ? nfs_instantiate+0x170/0x170 [nfs]
[ 1318.361320]  [<c115842c>] path_init+0x10c/0x3b0
[ 1318.361324]  [<c1158701>] path_lookupat+0x31/0x6a0
[ 1318.361330]  [<c125598b>] ? security_sb_set_mnt_opts+0x1b/0x30
[ 1318.361341]  [<f871fc00>] ? nfs_set_sb_security+0x40/0x70 [nfs]
[ 1318.361346]  [<c1158d9e>] filename_lookup+0x2e/0xc0
[ 1318.361350]  [<c1158ec1>] do_path_lookup+0x31/0x40
[ 1318.361354]  [<c1159071>] vfs_path_lookup+0x31/0x50
[ 1318.361358]  [<c11434ba>] ? kmem_cache_alloc_trace+0x7a/0x140
[ 1318.361361]  [<c11512f2>] ? mount_fs+0xa2/0x180
[ 1318.361366]  [<c1167641>] ? alloc_mnt_ns+0x21/0x80
[ 1318.361370]  [<c116766f>] ? alloc_mnt_ns+0x4f/0x80
[ 1318.361373]  [<c11683f8>] ? create_mnt_ns+0x18/0x60
[ 1318.361377]  [<c116a43f>] mount_subtree+0x3f/0x80
[ 1318.361388]  [<f8782f37>] ? nfs_follow_remote_path+0xc7/0x1a0 [nfsv4]
[ 1318.361398]  [<f8782f49>] nfs_follow_remote_path+0xd9/0x1a0 [nfsv4]
[ 1318.361408]  [<f87830a6>] nfs4_try_mount+0x46/0x50 [nfsv4]
[ 1318.361420]  [<f872073d>] nfs_fs_mount+0x49d/0x920 [nfs]
[ 1318.361431]  [<f8720090>] ? nfs_clone_super+0x160/0x160 [nfs]
[ 1318.361442]  [<f871fbc0>] ? nfs_compare_super+0x1b0/0x1b0 [nfs]
[ 1318.361446]  [<c1151286>] mount_fs+0x36/0x180
[ 1318.361451]  [<c112172f>] ? __alloc_percpu+0xf/0x20
[ 1318.361455]  [<c1167bce>] ? alloc_vfsmnt+0xae/0x130
[ 1318.361458]  [<c1167ce1>] vfs_kern_mount+0x51/0xc0
[ 1318.361462]  [<c116833e>] do_kern_mount+0x3e/0xe0
[ 1318.361466]  [<c11699b9>] do_mount+0x169/0x760
[ 1318.361470]  [<c116a01b>] sys_mount+0x6b/0xa0
[ 1318.361474]  [<c15c3a87>] syscall_call+0x7/0xb

--------------060008000900030309010000--
