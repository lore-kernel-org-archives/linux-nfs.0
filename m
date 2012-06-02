From: ethan zhao <ethan.kernel@gmail.com>
Subject: Re: BUG in __key_instantiate_and_link(): unable to handle kernel
 paging request at 0000632e6472616f
Date: Sat, 2 Jun 2012 10:25:59 +0800
Message-ID: <CABawtvPCmfjqDB91Mwa6vGQDf6C9yuOjAarP4VON8bxSCk8LRg@mail.gmail.com>
References: <20120601034114.GA9248@localhost>
	<20120601143420.GA11869@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Howells <dhowells@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120601143420.GA11869@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David,

Maybe related to the big change of nfs/idmap.c in 3.4

Is it a good way to add some valid code before do a

ret =3D key->type->instantiate(key, data, datalen);

call ?

Thanks,
Ethan


On Fri, Jun 1, 2012 at 10:34 PM, Fengguang Wu <fengguang.wu@intel.com> =
wrote:
> [add CC to NFS list, as the bug is related to idmap]
>
> On Fri, Jun 01, 2012 at 11:41:14AM +0800, Fengguang Wu wrote:
>> Hi David,
>>
>> It's the second time the machine oops in __key_instantiate_and_link(=
) on
>> 3.4 kernel. =A0This bug only happens after several days of run. Do y=
ou
>> have any advices or debug patches? For now I can try older (or newer=
)
>> kernels and see if it's any better.
>
> I'll run v3.3 for several days and try to narrow things down.
>
> Up to now, Ethan and David posted some diagnoses:
>
> Ethan:
>
> =A0 =A0 =A0 =A0The following code of __key_instantiate_and_link() tri=
ed to request a
> =A0 =A0 =A0 =A0invalid function pointer ?
>
> =A0 =A0 =A0 =A0<ff> 50 18 =A0callq =A0*0x18(%rax)
> =A0 =A0 =A0 =A0ret =3D key->type->instantiate(key, data, datalen);
>
> =A0 =A0 =A0 =A0So may be the key/type =A0is not initialized or freed.=
 not found the
> =A0 =A0 =A0 =A0same code in 3.3. should be bug with 3.4 only.
>
> David:
>
> =A0 =A0 =A0 =A0> 0000632e6472616f
>
> =A0 =A0 =A0 =A0That looks suspiciously like text.
>
> =A0 =A0 =A0 =A000 \0
> =A0 =A0 =A0 =A000 \0
> =A0 =A0 =A0 =A063 c
> =A0 =A0 =A0 =A02e .
> =A0 =A0 =A0 =A064 d
> =A0 =A0 =A0 =A072 t
> =A0 =A0 =A0 =A061 a
> =A0 =A0 =A0 =A06f f
>
> Thanks,
> Fengguang
>
>> Thanks,
>> Fengguang
>> ---
>>
>> [53056.100019] BUG: unable to handle kernel paging request at 000063=
2e6472616f
>> [53056.108072] IP: [<0000632e6472616f>] 0x632e6472616e
>> [53056.113702] PGD 0
>> [53056.116119] Oops: 0010 [#1] SMP
>> [53056.119982] CPU 0
>> [53056.122111] Modules linked in:
>> [53056.125969]
>> [53056.127713] Pid: 3502, comm: rpc.idmapd Not tainted 3.4.0 #130 In=
tel Corporation S2600CP/S2600CP
>> [53056.137880] RIP: 0010:[<0000632e6472616f>] =A0[<0000632e6472616f>=
] 0x632e6472616e
>> [53056.146228] RSP: 0018:ffff880421d2fd30 =A0EFLAGS: 00010246
>> [53056.152249] RAX: ffff8803bef69100 RBX: ffff8803bef690d0 RCX: ffff=
ffff81f0f440
>> [53056.160309] RDX: 0000000000000005 RSI: ffff880421d2fe8d RDI: ffff=
8803bef690d0
>> [53056.168371] RBP: ffff880421d2fd88 R08: ffff880421d2fcd8 R09: 0000=
000000000000
>> [53056.176435] R10: ffffffff81f0f468 R11: ffffffff813bbdbf R12: ffff=
880421d2fe8d
>> [53056.184504] R13: ffff8805c9957b00 R14: ffff8804287b9c00 R15: 0000=
000000000000
>> [53056.192564] FS: =A000007f87fbce5700(0000) GS:ffff88042fa00000(000=
0) knlGS:0000000000000000
>> [53056.202451] CS: =A00010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [53056.209343] CR2: 0000632e6472616f CR3: 000000042951a000 CR4: 0000=
0000000407f0
>> [53056.217784] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
>> [53056.226226] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
>> [53056.234675] Process rpc.idmapd (pid: 3502, threadinfo ffff880421d=
2e000, task ffff880427865e20)
>> [53056.245144] Stack:
>> [53056.247841] =A0ffffffff813bbde2 ffff880416c54820 0000000000000005=
 ffff880421d2fdb0
>> [53056.257281] =A0fffffff0287b9c28 ffff8803bef690b0 ffff8803bef690d0=
 ffff8804287b9c00
>> [53056.266725] =A00000000000000005 ffff880421d2fe8d 00007f87fbaea800=
 ffff880421d2fdd8
>> [53056.276172] Call Trace:
>> [53056.279363] =A0[<ffffffff813bbde2>] ? __key_instantiate_and_link+=
0x5e/0xe4
>> [53056.287316] =A0[<ffffffff813bbec5>] key_instantiate_and_link+0x5d=
/0x85
>> [53056.294888] =A0[<ffffffff81262c29>] idmap_pipe_downcall+0x14a/0x1=
8f
>> [53056.302176] =A0[<ffffffff81958071>] rpc_pipe_write+0x5d/0x77
>> [53056.308782] =A0[<ffffffff8114bfbd>] vfs_write+0xb2/0x142
>> [53056.315000] =A0[<ffffffff8114c247>] sys_write+0x4a/0x71
>> [53056.321108] =A0[<ffffffff819bc329>] system_call_fastpath+0x16/0x1=
b
>> [53056.328278] Code: =A0Bad RIP value.
>> [53056.332599] RIP =A0[<0000632e6472616f>] 0x632e6472616e
>> [53056.338687] =A0RSP <ffff880421d2fd30>
>> [53056.343035] CR2: 0000632e6472616f
>> [53056.347640] ---[ end trace ee5d4100fdd3e1d2 ]---
>>
>>
>> [293850.014215] general protection fault: 0000 [#1] SMP
>> [293850.020521] CPU 0
>> [293850.022749] Modules linked in:
>> [293850.027564]
>> [293850.029790] Pid: 3487, comm: rpc.idmapd Not tainted 3.4.0 #130 I=
ntel Corporation S2600CP/S2600CP
>> [293850.040833] RIP: 0010:[<ffffffff813bbddf>] =A0[<ffffffff813bbddf=
>] __key_instantiate_and_link+0x5b/0xe4
>> [293850.052196] RSP: 0018:ffff880421d3bd38 =A0EFLAGS: 00010246
>> [293850.058696] RAX: ffff8803044aac10 RBX: ffff8803044aac00 RCX: fff=
fffff81f0f440
>> [293850.067637] RDX: 0000000000000005 RSI: ffff880421d3be8d RDI: fff=
f8803044aac00
>> [293850.076670] RBP: ffff880421d3bd88 R08: ffff880421d3bcd8 R09: 000=
0000000000000
>> [293850.085601] R10: ffffffff81f0f468 R11: ffffffff813bbdbf R12: fff=
f880421d3be8d
>> [293850.094538] R13: ffff88036cc14d00 R14: ffff88042816dc00 R15: 000=
0000000000000
>> [293850.103477] FS: =A000007f0954695700(0000) GS:ffff88042fa00000(00=
00) knlGS:0000000000000000
>> [293850.113492] CS: =A00010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [293850.120494] CR2: 00007f09546b8000 CR3: 0000000421d55000 CR4: 000=
00000000407f0
>> [293850.129431] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
>> [293850.138376] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
>> [293850.147324] Process rpc.idmapd (pid: 3487, threadinfo ffff880421=
d3a000, task ffff880421cdbec0)
>> [293850.157919] Stack:
>> [293850.160740] =A0ffff880540d037a0 0000000000000005 ffff880421d3bdb=
0 fffffff02816dc28
>> [293850.170396] =A0ffff8803044aacf0 ffff8803044aac00 ffff88042816dc0=
0 0000000000000005
>> [293850.179978] =A0ffff880421d3be8d 00007f095449a800 ffff880421d3bdd=
8 ffffffff813bbec5
>> [293850.189571] Call Trace:
>> [293850.192880] =A0[<ffffffff813bbec5>] key_instantiate_and_link+0x5=
d/0x85
>> [293850.200559] =A0[<ffffffff81262c29>] idmap_pipe_downcall+0x14a/0x=
18f
>> [293850.207951] =A0[<ffffffff81958071>] rpc_pipe_write+0x5d/0x77
>> [293850.214668] =A0[<ffffffff8114bfbd>] vfs_write+0xb2/0x142
>> [293850.221001] =A0[<ffffffff8114c247>] sys_write+0x4a/0x71
>> [293850.227225] =A0[<ffffffff819bc329>] system_call_fastpath+0x16/0x=
1b
>> [293850.234517] Code: 89 c5 4c 89 4d c0 e8 bc 70 5f 00 48 8b 83 c0 0=
0 00 00 c7 45 cc f0 ff ff ff 48 8b 55 b8 a8 01 75 5f 48 8b 43 20 4c 89 =
e6 48 89 df <ff> 50 18 85 c0 89 45 cc 75 4b 48 8b 83 98 00 00 00 f0 ff =
80 e0
>> [293850.262891] RIP =A0[<ffffffff813bbddf>] __key_instantiate_and_li=
nk+0x5b/0xe4
>> [293850.271249] =A0RSP <ffff880421d3bd38>
>> [293850.276003] ---[ end trace 5e5f70d6ba42fdc4 ]---
>>
>> After the oops, lots of tasks get stuck:
>>
>> [302954.158127] SysRq : Show Blocked State
>> [302954.164055] =A0 task =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0PC stack =A0 pid father
>> [302954.171284] rpc.idmapd =A0 =A0 =A0D 0000000000000000 =A03912 =A0=
3487 =A0 =A0 =A01 0x00000000
>> [302954.179917] =A0ffff880421d3b938 0000000000000046 ffff880421cdbec=
0 ffff880421d3bfd8
>> [302954.189481] =A0ffff880421d3bfd8 0000000000012f00 ffff88080e40000=
0 ffff880421cdbec0
>> [302954.199053] =A0ffffffff8117fe4c 0000000000000000 ffff880421cdbec=
0 0000000000000000
>> [302954.208615] Call Trace:
>> [302954.211916] =A0[<ffffffff8117fe4c>] ? fsnotify_clear_marks_by_in=
ode+0x31/0xd4
>> [302954.220272] =A0[<ffffffff81958b73>] ? rpc_pipe_release+0x2d/0x15=
5
>> [302954.227456] =A0[<ffffffff819b4393>] schedule+0x64/0x66
>> [302954.233567] =A0[<ffffffff819b4618>] schedule_preempt_disabled+0x=
e/0x10
>> [302954.241236] =A0[<ffffffff819b3006>] mutex_lock_nested+0x18b/0x2c=
9
>> [302954.248415] =A0[<ffffffff81958b73>] ? rpc_pipe_release+0x2d/0x15=
5
>> [302954.255595] =A0[<ffffffff81958b73>] rpc_pipe_release+0x2d/0x155
>> [302954.262587] =A0[<ffffffff8114d7f1>] fput+0x10e/0x25b
>> [302954.268506] =A0[<ffffffff8114a4b3>] filp_close+0x6e/0x7a
>> [302954.274816] =A0[<ffffffff81067dac>] put_files_struct+0xb0/0x142
>> [302954.281802] =A0[<ffffffff81067d23>] ? put_files_struct+0x27/0x14=
2
>> [302954.288980] =A0[<ffffffff81067ed9>] exit_files+0x49/0x51
>> [302954.295286] =A0[<ffffffff81068431>] do_exit+0x27a/0x7e5
>> [302954.301497] =A0[<ffffffff81066440>] ? kmsg_dump+0x116/0x126
>> [302954.308091] =A0[<ffffffff810663c5>] ? kmsg_dump+0x9b/0x126
>> [302954.314591] =A0[<ffffffff819b6655>] oops_end+0xbd/0xc6
>> [302954.320704] =A0[<ffffffff81038de9>] die+0x5a/0x65
>> [302954.326328] =A0[<ffffffff819b620f>] do_general_protection+0x138/=
0x140
>> [302954.333897] =A0[<ffffffff819b5b15>] general_protection+0x25/0x30
>> [302954.340983] =A0[<ffffffff813bbdbf>] ? __key_instantiate_and_link=
+0x3b/0xe4
>> [302954.349040] =A0[<ffffffff813bbddf>] ? __key_instantiate_and_link=
+0x5b/0xe4
>> [302954.357096] =A0[<ffffffff813bbde2>] ? __key_instantiate_and_link=
+0x5e/0xe4
>> [302954.365151] =A0[<ffffffff813bbec5>] key_instantiate_and_link+0x5=
d/0x85
>> [302954.382213] =A0[<ffffffff81262c29>] idmap_pipe_downcall+0x14a/0x=
18f
>> [302954.389590] =A0[<ffffffff81958071>] rpc_pipe_write+0x5d/0x77
>> [302954.396282] =A0[<ffffffff8114bfbd>] vfs_write+0xb2/0x142
>> [302954.402585] =A0[<ffffffff8114c247>] sys_write+0x4a/0x71
>> [302954.408787] =A0[<ffffffff819bc329>] system_call_fastpath+0x16/0x=
1b
>> [302954.416067] zsh =A0 =A0 =A0 =A0 =A0 =A0 D 0000000000000000 =A037=
28 =A04242 =A0 4239 0x00000000
>> [302954.424689] =A0ffff8804296ab458 0000000000000046 ffff8804253a800=
0 ffff8804296abfd8
>> [302954.434255] =A0ffff8804296abfd8 0000000000012f00 ffffffff81ea302=
0 ffff8804253a8000
>> [302954.443819] =A00000000100000000 ffff8804280b6900 000000000000000=
1 fffffffffffffff5
>> [302954.453389] Call Trace:
>> [302954.456688] =A0[<ffffffff813c06ae>] ? request_key_and_link+0x103=
/0x39b
>> [302954.464354] =A0[<ffffffff813bc185>] ? key_user_lookup+0x3c/0x18c
>> [302954.471439] =A0[<ffffffff819b4393>] schedule+0x64/0x66
>> [302954.477548] =A0[<ffffffff819b4618>] schedule_preempt_disabled+0x=
e/0x10
>> [302954.485215] =A0[<ffffffff819b3006>] mutex_lock_nested+0x18b/0x2c=
9
>> [302954.492509] =A0[<ffffffff813c06ae>] ? request_key_and_link+0x103=
/0x39b
>> [302954.500176] =A0[<ffffffff813c06ae>] request_key_and_link+0x103/0=
x39b
>> [302954.507646] =A0[<ffffffff813c0a1a>] request_key+0x41/0x73
>> [302954.514046] =A0[<ffffffff8126287d>] nfs_idmap_request_key+0xea/0=
x1bf
>> [302954.521519] =A0[<ffffffff810983b7>] ? idle_balance+0x12c/0x157
>> [302954.528410] =A0[<ffffffff8108e121>] ? finish_task_switch+0x4c/0x=
f6
>> [302954.535686] =A0[<ffffffff81262a42>] nfs_idmap_lookup_id+0x4c/0xa=
c
>> [302954.542867] =A0[<ffffffff819b54c5>] ? _raw_spin_unlock_irq+0x2e/=
0x3a
>> [302954.550337] =A0[<ffffffff81262c96>] ? nfs_map_string_to_numeric+=
0x28/0x76
>> [302954.558292] =A0[<ffffffff8108e15d>] ? finish_task_switch+0x88/0x=
f6
>> [302954.565568] =A0[<ffffffff8108e121>] ? finish_task_switch+0x4c/0x=
f6
>> [302954.572836] =A0[<ffffffff8126325f>] nfs_map_name_to_uid+0x58/0x6=
1
>> [302954.580020] =A0[<ffffffff8125b17f>] decode_getfattr_attrs+0x51f/=
0x985
>> [302954.587589] =A0[<ffffffff8125e5e7>] decode_getfattr_generic.cons=
tprop.60+0x8c/0xbe
>> [302954.596800] =A0[<ffffffff8125ea93>] ? nfs4_xdr_dec_lookup+0x6e/0=
x6e
>> [302954.604173] =A0[<ffffffff8125e62c>] decode_getfattr+0x13/0x15
>> [302954.610966] =A0[<ffffffff8125ead6>] nfs4_xdr_dec_getattr+0x43/0x=
4c
>> [302954.618244] =A0[<ffffffff8125ea93>] ? nfs4_xdr_dec_lookup+0x6e/0=
x6e
>> [302954.625619] =A0[<ffffffff8194d701>] rpcauth_unwrap_resp+0x57/0x6=
0
>> [302954.632790] =A0[<ffffffff8194490f>] call_decode+0x34c/0x3a9
>> [302954.639388] =A0[<ffffffff81084d42>] ? autoremove_wake_function+0=
x3d/0x3d
>> [302954.647246] =A0[<ffffffff819445c3>] ? call_transmit_status+0x8f/=
0x8f
>> [302954.654714] =A0[<ffffffff8194c78c>] __rpc_execute+0x9b/0x204
>> [302954.661407] =A0[<ffffffff81084a68>] ? wake_up_bit+0x25/0x2a
>> [302954.668001] =A0[<ffffffff8194c98a>] rpc_execute+0x67/0x70
>> [302954.674402] =A0[<ffffffff81945e6c>] rpc_run_task+0x7e/0x86
>> [302954.680899] =A0[<ffffffff81945f61>] rpc_call_sync+0x45/0x66
>> [302954.687501] =A0[<ffffffff81253e96>] _nfs4_call_sync+0x13/0x15
>> [302954.694292] =A0[<ffffffff81254c29>] _nfs4_proc_getattr+0x9f/0xad
>> [302954.701375] =A0[<ffffffff81257e9f>] nfs4_proc_getattr+0x36/0x55
>> [302954.708350] =A0[<ffffffff81244cc0>] __nfs_revalidate_inode+0x8b/=
0xef
>> [302954.715817] =A0[<ffffffff81244e26>] nfs_revalidate_inode+0x4a/0x=
51
>> [302954.723095] =A0[<ffffffff81240999>] nfs_check_verifier+0x51/0x77
>> [302954.730175] =A0[<ffffffff81240ab1>] nfs_lookup_revalidate+0xf2/0=
x32c
>> [302954.737643] =A0[<ffffffff8124220f>] nfs_open_revalidate+0x225/0x=
238
>> [302954.745019] =A0[<ffffffff81155c8f>] ? inode_permission+0x78/0xd5
>> [302954.752101] =A0[<ffffffff81156ecb>] ? link_path_walk+0x7e/0x74a
>> [302954.759089] =A0[<ffffffff81155171>] complete_walk+0xfa/0x124
>> [302954.765781] =A0[<ffffffff81157bb2>] path_lookupat+0x55e/0x5d4
>> [302954.772574] =A0[<ffffffff8113f9cc>] ? kmem_cache_alloc+0x39/0x12=
4
>> [302954.779754] =A0[<ffffffff81157c50>] do_path_lookup+0x28/0xa3
>> [302954.786447] =A0[<ffffffff811590c7>] user_path_at_empty+0x53/0x92
>> [302954.793530] =A0[<ffffffff810889ea>] ? up_read+0x20/0x37
>> [302954.799736] =A0[<ffffffff819b8be0>] ? do_page_fault+0x3d3/0x42a
>> [302954.806719] =A0[<ffffffff81159117>] user_path_at+0x11/0x13
>> [302954.813216] =A0[<ffffffff811500e7>] vfs_fstatat+0x3a/0x64
>> [302954.819613] =A0[<ffffffff8115014c>] vfs_stat+0x1b/0x1d
>> [302954.825722] =A0[<ffffffff8115024b>] sys_newstat+0x1a/0x33
>> [302954.832127] =A0[<ffffffff813fdffe>] ? trace_hardirqs_on_thunk+0x=
3a/0x3f
>> [302954.839893] =A0[<ffffffff819bc329>] system_call_fastpath+0x16/0x=
1b
>> [302954.847176] kworker/11:5 =A0 =A0D 000000000000000b =A04528 61345=
 =A0 =A0 =A02 0x00000000
>> [302954.855802] =A0ffff880679387c00 0000000000000046 ffff8807eb0a5e2=
0 ffff880679387fd8
>> [302954.865365] =A0ffff880679387fd8 0000000000012f00 ffff880429b71f6=
0 ffff8807eb0a5e20
>> [302954.874904] =A00000000000000000 0000000000000000 ffff8807eb0a5e2=
0 0000000000000000
>> [302954.884461] Call Trace:
>> [302954.887751] =A0[<ffffffff819b4dd1>] ? rwsem_down_failed_common+0=
x41/0x103
>> [302954.895707] =A0[<ffffffff819b4393>] schedule+0x64/0x66
>> [302954.901816] =A0[<ffffffff819b4e63>] rwsem_down_failed_common+0xd=
3/0x103
>> [302954.909579] =A0[<ffffffff819b4ea6>] rwsem_down_write_failed+0x13=
/0x15
>> [302954.917146] =A0[<ffffffff813fdf63>] call_rwsem_down_write_failed=
+0x13/0x20
>> [302954.925201] =A0[<ffffffff813bda11>] ? keyring_gc+0x28/0x1b3
>> [302954.931794] =A0[<ffffffff819b3515>] ? down_write+0x52/0x59
>> [302954.938296] =A0[<ffffffff813bda11>] ? keyring_gc+0x28/0x1b3
>> [302954.944892] =A0[<ffffffff813bb9a4>] ? key_garbage_collector+0x2a=
0/0x3b1
>> [302954.952656] =A0[<ffffffff813bda11>] keyring_gc+0x28/0x1b3
>> [302954.959061] =A0[<ffffffff813bba49>] key_garbage_collector+0x345/=
0x3b1
>> [302954.966628] =A0[<ffffffff813bb9a4>] ? key_garbage_collector+0x2a=
0/0x3b1
>> [302954.974392] =A0[<ffffffff8107ce74>] process_one_work+0x220/0x3e5
>> [302954.981474] =A0[<ffffffff8107cde5>] ? process_one_work+0x191/0x3=
e5
>> [302954.988743] =A0[<ffffffff813bb704>] ? key_schedule_gc+0x83/0x83
>> [302954.995719] =A0[<ffffffff8107d4bf>] worker_thread+0x15a/0x21b
>> [302955.002512] =A0[<ffffffff8107d365>] ? manage_workers.isra.22+0x1=
70/0x170
>> [302955.010372] =A0[<ffffffff810845d5>] kthread+0x8b/0x93
>> [302955.016387] =A0[<ffffffff819bd774>] kernel_thread_helper+0x4/0x1=
0
>> [302955.023564] =A0[<ffffffff819b5930>] ? retint_restore_args+0x13/0=
x13
>> [302955.030929] =A0[<ffffffff8108454a>] ? __init_kthread_worker+0x5a=
/0x5a
>> [302955.038495] =A0[<ffffffff819bd770>] ? gs_change+0x13/0x13
>> [302955.044936] make =A0 =A0 =A0 =A0 =A0 =A0D 000000000000000e =A038=
00 46865 =A040708 0x00000000
>> [302955.053556] =A0ffff88048f489518 0000000000000046 ffff880678129f6=
0 ffff88048f489fd8
>> [302955.063125] =A0ffff88048f489fd8 0000000000012f00 ffff880475701f6=
0 ffff880678129f60
>> [302955.072700] =A00000000000000286 0000000000000000 000000000000000=
0 0000000000000000
>> [302955.082254] Call Trace:
>> [302955.085548] =A0[<ffffffff81084b9d>] ? prepare_to_wait+0x25/0x79
>> [302955.092535] =A0[<ffffffff813c00d1>] ? wait_for_key_construction+=
0x6d/0x6d
>> [302955.100495] =A0[<ffffffff819b4393>] schedule+0x64/0x66
>> [302955.106599] =A0[<ffffffff813c00df>] key_wait_bit+0xe/0x12
>> [302955.113004] =A0[<ffffffff819b2201>] __wait_on_bit+0x48/0x7b
>> [302955.119603] =A0[<ffffffff819b22a6>] out_of_line_wait_on_bit+0x72=
/0x7d
>> [302955.127169] =A0[<ffffffff813c00d1>] ? wait_for_key_construction+=
0x6d/0x6d
>> [302955.135126] =A0[<ffffffff81084d42>] ? autoremove_wake_function+0=
x3d/0x3d
>> [302955.142988] =A0[<ffffffff813c00ae>] wait_for_key_construction+0x=
4a/0x6d
>> [302955.150761] =A0[<ffffffff813c09bc>] request_key_with_auxdata+0x3=
5/0x52
>> [302955.158429] =A0[<ffffffff81262865>] nfs_idmap_request_key+0xd2/0=
x1bf
>> [302955.165903] =A0[<ffffffff814014be>] ? _kstrtoull+0x2c/0x66
>> [302955.172401] =A0[<ffffffff8140150c>] ? kstrtoull+0x14/0x16
>> [302955.178803] =A0[<ffffffff81262a6d>] nfs_idmap_lookup_id+0x77/0xa=
c
>> [302955.185985] =A0[<ffffffff819b54c5>] ? _raw_spin_unlock_irq+0x2e/=
0x3a
>> [302955.193455] =A0[<ffffffff81262c96>] ? nfs_map_string_to_numeric+=
0x28/0x76
>> [302955.201416] =A0[<ffffffff8108e121>] ? finish_task_switch+0x4c/0x=
f6
>> [302955.208827] =A0[<ffffffff812632c0>] nfs_map_group_to_gid+0x58/0x=
60
>> [302955.216106] =A0[<ffffffff8125b246>] decode_getfattr_attrs+0x5e6/=
0x985
>> [302955.223665] =A0[<ffffffff8125e5e7>] decode_getfattr_generic.cons=
tprop.60+0x8c/0xbe
>> [302955.232886] =A0[<ffffffff8125ea93>] ? nfs4_xdr_dec_lookup+0x6e/0=
x6e
>> [302955.240263] =A0[<ffffffff8125e62c>] decode_getfattr+0x13/0x15
>> [302955.247053] =A0[<ffffffff8125ead6>] nfs4_xdr_dec_getattr+0x43/0x=
4c
>> [302955.254327] =A0[<ffffffff8125ea93>] ? nfs4_xdr_dec_lookup+0x6e/0=
x6e
>> [302955.261698] =A0[<ffffffff8194d701>] rpcauth_unwrap_resp+0x57/0x6=
0
>> [302955.268880] =A0[<ffffffff8194490f>] call_decode+0x34c/0x3a9
>> [302955.275476] =A0[<ffffffff81084d42>] ? autoremove_wake_function+0=
x3d/0x3d
>> [302955.283336] =A0[<ffffffff819445c3>] ? call_transmit_status+0x8f/=
0x8f
>> [302955.290803] =A0[<ffffffff8194c78c>] __rpc_execute+0x9b/0x204
>> [302955.297496] =A0[<ffffffff81084a68>] ? wake_up_bit+0x25/0x2a
>> [302955.304091] =A0[<ffffffff8194c98a>] rpc_execute+0x67/0x70
>> [302955.310494] =A0[<ffffffff81945e6c>] rpc_run_task+0x7e/0x86
>> [302955.316993] =A0[<ffffffff81945f61>] rpc_call_sync+0x45/0x66
>> [302955.323589] =A0[<ffffffff81253e96>] _nfs4_call_sync+0x13/0x15
>> [302955.330378] =A0[<ffffffff81254c29>] _nfs4_proc_getattr+0x9f/0xad
>> [302955.337460] =A0[<ffffffff81257e9f>] nfs4_proc_getattr+0x36/0x55
>> [302955.344445] =A0[<ffffffff81244cc0>] __nfs_revalidate_inode+0x8b/=
0xef
>> [302955.351916] =A0[<ffffffff81240b1a>] nfs_lookup_revalidate+0x15b/=
0x32c
>> [302955.359486] =A0[<ffffffff8124220f>] nfs_open_revalidate+0x225/0x=
238
>> [302955.366867] =A0[<ffffffff8115f764>] ? __d_lookup+0x177/0x189
>> [302955.373555] =A0[<ffffffff8115f5ed>] ? __d_lookup_rcu+0x160/0x160
>> [302955.380639] =A0[<ffffffff81156d5d>] do_lookup+0x1b5/0x2a5
>> [302955.387042] =A0[<ffffffff81156ecb>] ? link_path_walk+0x7e/0x74a
>> [302955.394026] =A0[<ffffffff81158041>] do_last+0x14b/0x773
>> [302955.400232] =A0[<ffffffff81158dd3>] path_openat+0xd0/0x351
>> [302955.406728] =A0[<ffffffff81159151>] do_filp_open+0x38/0x86
>> [302955.413229] =A0[<ffffffff819b5493>] ? _raw_spin_unlock+0x28/0x2c
>> [302955.420302] =A0[<ffffffff81163666>] ? alloc_fd+0xec/0xfe
>> [302955.426606] =A0[<ffffffff8114b5b1>] do_sys_open+0x105/0x197
>> [302955.433197] =A0[<ffffffff81163eab>] ? vfsmount_lock_local_lock_c=
pu+0x66/0x66
>> [302955.441442] =A0[<ffffffff8114b664>] sys_open+0x21/0x23
>> [302955.447555] =A0[<ffffffff819bc329>] system_call_fastpath+0x16/0x=
1b
>> [302955.454824] make =A0 =A0 =A0 =A0 =A0 =A0D 0000000000000009 =A038=
56 47064 =A040708 0x00000000
>> [302955.463444] =A0ffff88080bb87518 0000000000000046 ffff880672393ec=
0 ffff88080bb87fd8
>> [302955.473003] =A0ffff88080bb87fd8 0000000000012f00 ffff88048f663ec=
0 ffff880672393ec0
>> [302955.482558] =A00000000000000286 0000000000000000 000000000000000=
0 0000000000000000
>> [302955.492119] Call Trace:
>> [302955.495410] =A0[<ffffffff81084b9d>] ? prepare_to_wait+0x25/0x79
>> [302955.502392] =A0[<ffffffff813c00d1>] ? wait_for_key_construction+=
0x6d/0x6d
>> [302955.510353] =A0[<ffffffff819b4393>] schedule+0x64/0x66
>> [302955.516464] =A0[<ffffffff813c00df>] key_wait_bit+0xe/0x12
>> [302955.522867] =A0[<ffffffff819b2201>] __wait_on_bit+0x48/0x7b
>> [302955.529464] =A0[<ffffffff8184f881>] ? release_sock+0x15e/0x17d
>> [302955.536352] =A0[<ffffffff819b22a6>] out_of_line_wait_on_bit+0x72=
/0x7d
>> [302955.543920] =A0[<ffffffff813c00d1>] ? wait_for_key_construction+=
0x6d/0x6d
>> [302955.551874] =A0[<ffffffff81084d42>] ? autoremove_wake_function+0=
x3d/0x3d
>> [302955.559734] =A0[<ffffffff813c00ae>] wait_for_key_construction+0x=
4a/0x6d
>> [302955.567496] =A0[<ffffffff813c09bc>] request_key_with_auxdata+0x3=
5/0x52
>> [302955.575162] =A0[<ffffffff81262865>] nfs_idmap_request_key+0xd2/0=
x1bf
>> [302955.592031] =A0[<ffffffff814014be>] ? _kstrtoull+0x2c/0x66
>> [302955.598530] =A0[<ffffffff8140150c>] ? kstrtoull+0x14/0x16
>> [302955.604932] =A0[<ffffffff81262a6d>] nfs_idmap_lookup_id+0x77/0xa=
c
>> [302955.612102] =A0[<ffffffff819b54c5>] ? _raw_spin_unlock_irq+0x2e/=
0x3a
>> [302955.619574] =A0[<ffffffff81262c96>] ? nfs_map_string_to_numeric+=
0x28/0x76
>> [302955.627530] =A0[<ffffffff8108e121>] ? finish_task_switch+0x4c/0x=
f6
>> [302955.634808] =A0[<ffffffff812632c0>] nfs_map_group_to_gid+0x58/0x=
60
>> [302955.642085] =A0[<ffffffff8125b246>] decode_getfattr_attrs+0x5e6/=
0x985
>> [302955.649653] =A0[<ffffffff8125e5e7>] decode_getfattr_generic.cons=
tprop.60+0x8c/0xbe
>> [302955.658862] =A0[<ffffffff8125ea93>] ? nfs4_xdr_dec_lookup+0x6e/0=
x6e
>> [302955.666231] =A0[<ffffffff8125e62c>] decode_getfattr+0x13/0x15
>> [302955.673020] =A0[<ffffffff8125ead6>] nfs4_xdr_dec_getattr+0x43/0x=
4c
>> [302955.680295] =A0[<ffffffff8125ea93>] ? nfs4_xdr_dec_lookup+0x6e/0=
x6e
>> [302955.687667] =A0[<ffffffff8194d701>] rpcauth_unwrap_resp+0x57/0x6=
0
>> [302955.694843] =A0[<ffffffff8194490f>] call_decode+0x34c/0x3a9
>> [302955.701436] =A0[<ffffffff81084d42>] ? autoremove_wake_function+0=
x3d/0x3d
>> [302955.709302] =A0[<ffffffff819445c3>] ? call_transmit_status+0x8f/=
0x8f
>> [302955.716773] =A0[<ffffffff8194c78c>] __rpc_execute+0x9b/0x204
>> [302955.723464] =A0[<ffffffff81084a68>] ? wake_up_bit+0x25/0x2a
>> [302955.730058] =A0[<ffffffff8194c98a>] rpc_execute+0x67/0x70
>> [302955.736455] =A0[<ffffffff81945e6c>] rpc_run_task+0x7e/0x86
>> [302955.742953] =A0[<ffffffff81945f61>] rpc_call_sync+0x45/0x66
>> [302955.749546] =A0[<ffffffff81253e96>] _nfs4_call_sync+0x13/0x15
>> [302955.756336] =A0[<ffffffff81254c29>] _nfs4_proc_getattr+0x9f/0xad
>> [302955.763419] =A0[<ffffffff81257e9f>] nfs4_proc_getattr+0x36/0x55
>> [302955.770402] =A0[<ffffffff81244cc0>] __nfs_revalidate_inode+0x8b/=
0xef
>> [302955.777872] =A0[<ffffffff81240b1a>] nfs_lookup_revalidate+0x15b/=
0x32c
>> [302955.785438] =A0[<ffffffff8124220f>] nfs_open_revalidate+0x225/0x=
238
>> [302955.792811] =A0[<ffffffff8115f764>] ? __d_lookup+0x177/0x189
>> [302955.799499] =A0[<ffffffff8115f5ed>] ? __d_lookup_rcu+0x160/0x160
>> [302955.806582] =A0[<ffffffff81156d5d>] do_lookup+0x1b5/0x2a5
>> [302955.812983] =A0[<ffffffff81156ecb>] ? link_path_walk+0x7e/0x74a
>> [302955.819966] =A0[<ffffffff81158041>] do_last+0x14b/0x773
>> [302955.826172] =A0[<ffffffff81158dd3>] path_openat+0xd0/0x351
>> [302955.832670] =A0[<ffffffff81159151>] do_filp_open+0x38/0x86
>> [302955.839168] =A0[<ffffffff819b5493>] ? _raw_spin_unlock+0x28/0x2c
>> [302955.846250] =A0[<ffffffff81163666>] ? alloc_fd+0xec/0xfe
>> [302955.852555] =A0[<ffffffff8114b5b1>] do_sys_open+0x105/0x197
>> [302955.859155] =A0[<ffffffff81163eab>] ? vfsmount_lock_local_lock_c=
pu+0x66/0x66
>> [302955.867403] =A0[<ffffffff8114b664>] sys_open+0x21/0x23
>> [302955.873514] =A0[<ffffffff819bc329>] system_call_fastpath+0x16/0x=
1b
>> [302955.880791] make =A0 =A0 =A0 =A0 =A0 =A0D 000000000000000c =A038=
56 47169 =A042128 0x00000000
>> [302955.889411] =A0ffff880824bbd518 0000000000000046 ffff880672389f6=
0 ffff880824bbdfd8
>> [302955.898968] =A0ffff880824bbdfd8 0000000000012f00 ffff88048ffbde2=
0 ffff880672389f60
>> [302955.908525] =A00000000000000286 0000000000000000 000000000000000=
0 0000000000000000
>> [302955.918078] Call Trace:
>> [302955.921368] =A0[<ffffffff81084b9d>] ? prepare_to_wait+0x25/0x79
>> [302955.928354] =A0[<ffffffff813c00d1>] ? wait_for_key_construction+=
0x6d/0x6d
>> [302955.936311] =A0[<ffffffff819b4393>] schedule+0x64/0x66
>> [302955.942420] =A0[<ffffffff813c00df>] key_wait_bit+0xe/0x12
>> [302955.948821] =A0[<ffffffff819b2201>] __wait_on_bit+0x48/0x7b
>> [302955.955416] =A0[<ffffffff8184f881>] ? release_sock+0x15e/0x17d
>> [302955.962303] =A0[<ffffffff819b22a6>] out_of_line_wait_on_bit+0x72=
/0x7d
>> [302955.969868] =A0[<ffffffff813c00d1>] ? wait_for_key_construction+=
0x6d/0x6d
>> [302955.977824] =A0[<ffffffff81084d42>] ? autoremove_wake_function+0=
x3d/0x3d
>> [302955.985680] =A0[<ffffffff813c00ae>] wait_for_key_construction+0x=
4a/0x6d
>> [302955.993432] =A0[<ffffffff813c09bc>] request_key_with_auxdata+0x3=
5/0x52
>> [302956.001099] =A0[<ffffffff81262865>] nfs_idmap_request_key+0xd2/0=
x1bf
>> [302956.008571] =A0[<ffffffff814014be>] ? _kstrtoull+0x2c/0x66
>> [302956.015066] =A0[<ffffffff8140150c>] ? kstrtoull+0x14/0x16
>> [302956.021468] =A0[<ffffffff81262a6d>] nfs_idmap_lookup_id+0x77/0xa=
c
>> [302956.028648] =A0[<ffffffff819b54c5>] ? _raw_spin_unlock_irq+0x2e/=
0x3a
>> [302956.036117] =A0[<ffffffff81262c96>] ? nfs_map_string_to_numeric+=
0x28/0x76
>> [302956.044074] =A0[<ffffffff8108e121>] ? finish_task_switch+0x4c/0x=
f6
>> [302956.051349] =A0[<ffffffff812632c0>] nfs_map_group_to_gid+0x58/0x=
60
>> [302956.058636] =A0[<ffffffff8125b246>] decode_getfattr_attrs+0x5e6/=
0x985
>> [302956.066202] =A0[<ffffffff8125e5e7>] decode_getfattr_generic.cons=
tprop.60+0x8c/0xbe
>> [302956.075420] =A0[<ffffffff8125ea93>] ? nfs4_xdr_dec_lookup+0x6e/0=
x6e
>> [302956.082794] =A0[<ffffffff8125e62c>] decode_getfattr+0x13/0x15
>> [302956.089586] =A0[<ffffffff8125ead6>] nfs4_xdr_dec_getattr+0x43/0x=
4c
>> [302956.096864] =A0[<ffffffff8125ea93>] ? nfs4_xdr_dec_lookup+0x6e/0=
x6e
>> [302956.104237] =A0[<ffffffff8194d701>] rpcauth_unwrap_resp+0x57/0x6=
0
>> [302956.111421] =A0[<ffffffff8194490f>] call_decode+0x34c/0x3a9
>> [302956.118020] =A0[<ffffffff81084d42>] ? autoremove_wake_function+0=
x3d/0x3d
>> [302956.125877] =A0[<ffffffff819445c3>] ? call_transmit_status+0x8f/=
0x8f
>> [302956.133346] =A0[<ffffffff8194c78c>] __rpc_execute+0x9b/0x204
>> [302956.140032] =A0[<ffffffff81084a68>] ? wake_up_bit+0x25/0x2a
>> [302956.146629] =A0[<ffffffff8194c98a>] rpc_execute+0x67/0x70
>> [302956.153029] =A0[<ffffffff81945e6c>] rpc_run_task+0x7e/0x86
>> [302956.159527] =A0[<ffffffff81945f61>] rpc_call_sync+0x45/0x66
>> [302956.166121] =A0[<ffffffff81253e96>] _nfs4_call_sync+0x13/0x15
>> [302956.172902] =A0[<ffffffff81254c29>] _nfs4_proc_getattr+0x9f/0xad
>> [302956.179985] =A0[<ffffffff81257e9f>] nfs4_proc_getattr+0x36/0x55
>> [302956.186969] =A0[<ffffffff81244cc0>] __nfs_revalidate_inode+0x8b/=
0xef
>> [302956.194439] =A0[<ffffffff81240b1a>] nfs_lookup_revalidate+0x15b/=
0x32c
>> [302956.202007] =A0[<ffffffff8124220f>] nfs_open_revalidate+0x225/0x=
238
>> [302956.209382] =A0[<ffffffff8115f764>] ? __d_lookup+0x177/0x189
>> [302956.216074] =A0[<ffffffff8115f5ed>] ? __d_lookup_rcu+0x160/0x160
>> [302956.223157] =A0[<ffffffff81156d5d>] do_lookup+0x1b5/0x2a5
>> [302956.229562] =A0[<ffffffff81156ecb>] ? link_path_walk+0x7e/0x74a
>> [302956.236550] =A0[<ffffffff81158041>] do_last+0x14b/0x773
>> [302956.242756] =A0[<ffffffff81158dd3>] path_openat+0xd0/0x351
>> [302956.249255] =A0[<ffffffff81159151>] do_filp_open+0x38/0x86
>> [302956.255753] =A0[<ffffffff819b5493>] ? _raw_spin_unlock+0x28/0x2c
>> [302956.262835] =A0[<ffffffff81163666>] ? alloc_fd+0xec/0xfe
>> [302956.269137] =A0[<ffffffff8114b5b1>] do_sys_open+0x105/0x197
>> [302956.275726] =A0[<ffffffff81163eab>] ? vfsmount_lock_local_lock_c=
pu+0x66/0x66
>> [302956.283979] =A0[<ffffffff8114b664>] sys_open+0x21/0x23
>> [302956.290089] =A0[<ffffffff819bc329>] system_call_fastpath+0x16/0x=
1b
>>
>
>> #
>> # Automatically generated file; DO NOT EDIT.
>> # Linux/x86_64 3.4.0 Kernel Configuration
>> #
>> CONFIG_64BIT=3Dy
>> # CONFIG_X86_32 is not set
>> CONFIG_X86_64=3Dy
>> CONFIG_X86=3Dy
>> CONFIG_INSTRUCTION_DECODER=3Dy
>> CONFIG_OUTPUT_FORMAT=3D"elf64-x86-64"
>> CONFIG_ARCH_DEFCONFIG=3D"arch/x86/configs/x86_64_defconfig"
>> CONFIG_GENERIC_CMOS_UPDATE=3Dy
>> CONFIG_CLOCKSOURCE_WATCHDOG=3Dy
>> CONFIG_GENERIC_CLOCKEVENTS=3Dy
>> CONFIG_ARCH_CLOCKSOURCE_DATA=3Dy
>> CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=3Dy
>> CONFIG_LOCKDEP_SUPPORT=3Dy
>> CONFIG_STACKTRACE_SUPPORT=3Dy
>> CONFIG_HAVE_LATENCYTOP_SUPPORT=3Dy
>> CONFIG_MMU=3Dy
>> CONFIG_NEED_DMA_MAP_STATE=3Dy
>> CONFIG_NEED_SG_DMA_LENGTH=3Dy
>> CONFIG_GENERIC_ISA_DMA=3Dy
>> CONFIG_GENERIC_BUG=3Dy
>> CONFIG_GENERIC_BUG_RELATIVE_POINTERS=3Dy
>> CONFIG_GENERIC_HWEIGHT=3Dy
>> CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
>> # CONFIG_RWSEM_GENERIC_SPINLOCK is not set
>> CONFIG_RWSEM_XCHGADD_ALGORITHM=3Dy
>> CONFIG_ARCH_HAS_CPU_IDLE_WAIT=3Dy
>> CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
>> CONFIG_GENERIC_TIME_VSYSCALL=3Dy
>> CONFIG_ARCH_HAS_CPU_RELAX=3Dy
>> CONFIG_ARCH_HAS_DEFAULT_IDLE=3Dy
>> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=3Dy
>> CONFIG_ARCH_HAS_CPU_AUTOPROBE=3Dy
>> CONFIG_HAVE_SETUP_PER_CPU_AREA=3Dy
>> CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=3Dy
>> CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=3Dy
>> CONFIG_ARCH_HIBERNATION_POSSIBLE=3Dy
>> CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy
>> CONFIG_ZONE_DMA32=3Dy
>> CONFIG_AUDIT_ARCH=3Dy
>> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=3Dy
>> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=3Dy
>> CONFIG_X86_64_SMP=3Dy
>> CONFIG_X86_HT=3Dy
>> CONFIG_ARCH_HWEIGHT_CFLAGS=3D"-fcall-saved-rdi -fcall-saved-rsi -fca=
ll-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-sa=
ved-r10 -fcall-saved-r11"
>> # CONFIG_KTIME_SCALAR is not set
>> CONFIG_ARCH_CPU_PROBE_RELEASE=3Dy
>> CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"
>> CONFIG_HAVE_IRQ_WORK=3Dy
>> CONFIG_IRQ_WORK=3Dy
>>
>> #
>> # General setup
>> #
>> CONFIG_EXPERIMENTAL=3Dy
>> CONFIG_INIT_ENV_ARG_LIMIT=3D32
>> CONFIG_CROSS_COMPILE=3D""
>> CONFIG_LOCALVERSION=3D""
>> # CONFIG_LOCALVERSION_AUTO is not set
>> CONFIG_HAVE_KERNEL_GZIP=3Dy
>> CONFIG_HAVE_KERNEL_BZIP2=3Dy
>> CONFIG_HAVE_KERNEL_LZMA=3Dy
>> CONFIG_HAVE_KERNEL_XZ=3Dy
>> CONFIG_HAVE_KERNEL_LZO=3Dy
>> CONFIG_KERNEL_GZIP=3Dy
>> # CONFIG_KERNEL_BZIP2 is not set
>> # CONFIG_KERNEL_LZMA is not set
>> # CONFIG_KERNEL_XZ is not set
>> # CONFIG_KERNEL_LZO is not set
>> CONFIG_DEFAULT_HOSTNAME=3D"(none)"
>> CONFIG_SWAP=3Dy
>> CONFIG_SYSVIPC=3Dy
>> CONFIG_SYSVIPC_SYSCTL=3Dy
>> CONFIG_POSIX_MQUEUE=3Dy
>> CONFIG_POSIX_MQUEUE_SYSCTL=3Dy
>> CONFIG_BSD_PROCESS_ACCT=3Dy
>> CONFIG_BSD_PROCESS_ACCT_V3=3Dy
>> # CONFIG_FHANDLE is not set
>> CONFIG_TASKSTATS=3Dy
>> CONFIG_TASK_DELAY_ACCT=3Dy
>> CONFIG_TASK_XACCT=3Dy
>> CONFIG_TASK_IO_ACCOUNTING=3Dy
>> CONFIG_AUDIT=3Dy
>> CONFIG_AUDITSYSCALL=3Dy
>> CONFIG_AUDIT_WATCH=3Dy
>> CONFIG_AUDIT_TREE=3Dy
>> # CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set
>> CONFIG_HAVE_GENERIC_HARDIRQS=3Dy
>>
>> #
>> # IRQ subsystem
>> #
>> CONFIG_GENERIC_HARDIRQS=3Dy
>> CONFIG_GENERIC_IRQ_PROBE=3Dy
>> CONFIG_GENERIC_IRQ_SHOW=3Dy
>> CONFIG_GENERIC_PENDING_IRQ=3Dy
>> CONFIG_IRQ_FORCED_THREADING=3Dy
>> CONFIG_SPARSE_IRQ=3Dy
>>
>> #
>> # RCU Subsystem
>> #
>> CONFIG_TREE_RCU=3Dy
>> # CONFIG_PREEMPT_RCU is not set
>> CONFIG_RCU_FANOUT=3D64
>> # CONFIG_RCU_FANOUT_EXACT is not set
>> # CONFIG_RCU_FAST_NO_HZ is not set
>> CONFIG_TREE_RCU_TRACE=3Dy
>> CONFIG_IKCONFIG=3Dy
>> CONFIG_IKCONFIG_PROC=3Dy
>> CONFIG_LOG_BUF_SHIFT=3D18
>> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy
>> CONFIG_CGROUPS=3Dy
>> CONFIG_CGROUP_DEBUG=3Dy
>> CONFIG_CGROUP_FREEZER=3Dy
>> CONFIG_CGROUP_DEVICE=3Dy
>> CONFIG_CPUSETS=3Dy
>> CONFIG_PROC_PID_CPUSET=3Dy
>> CONFIG_CGROUP_CPUACCT=3Dy
>> CONFIG_RESOURCE_COUNTERS=3Dy
>> CONFIG_CGROUP_MEM_RES_CTLR=3Dy
>> CONFIG_CGROUP_MEM_RES_CTLR_SWAP=3Dy
>> CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=3Dy
>> # CONFIG_CGROUP_MEM_RES_CTLR_KMEM is not set
>> # CONFIG_CGROUP_PERF is not set
>> CONFIG_CGROUP_SCHED=3Dy
>> CONFIG_FAIR_GROUP_SCHED=3Dy
>> # CONFIG_CFS_BANDWIDTH is not set
>> # CONFIG_RT_GROUP_SCHED is not set
>> CONFIG_BLK_CGROUP=3Dy
>> CONFIG_DEBUG_BLK_CGROUP=3Dy
>> # CONFIG_CHECKPOINT_RESTORE is not set
>> # CONFIG_NAMESPACES is not set
>> CONFIG_SCHED_AUTOGROUP=3Dy
>> CONFIG_MM_OWNER=3Dy
>> # CONFIG_SYSFS_DEPRECATED is not set
>> CONFIG_RELAY=3Dy
>> CONFIG_BLK_DEV_INITRD=3Dy
>> CONFIG_INITRAMFS_SOURCE=3D""
>> CONFIG_RD_GZIP=3Dy
>> # CONFIG_RD_BZIP2 is not set
>> # CONFIG_RD_LZMA is not set
>> # CONFIG_RD_XZ is not set
>> # CONFIG_RD_LZO is not set
>> CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy
>> CONFIG_SYSCTL=3Dy
>> CONFIG_ANON_INODES=3Dy
>> CONFIG_EXPERT=3Dy
>> CONFIG_UID16=3Dy
>> CONFIG_SYSCTL_SYSCALL=3Dy
>> CONFIG_KALLSYMS=3Dy
>> CONFIG_KALLSYMS_ALL=3Dy
>> CONFIG_HOTPLUG=3Dy
>> CONFIG_PRINTK=3Dy
>> CONFIG_BUG=3Dy
>> CONFIG_ELF_CORE=3Dy
>> CONFIG_PCSPKR_PLATFORM=3Dy
>> CONFIG_HAVE_PCSPKR_PLATFORM=3Dy
>> CONFIG_BASE_FULL=3Dy
>> CONFIG_FUTEX=3Dy
>> CONFIG_EPOLL=3Dy
>> CONFIG_SIGNALFD=3Dy
>> CONFIG_TIMERFD=3Dy
>> CONFIG_EVENTFD=3Dy
>> CONFIG_SHMEM=3Dy
>> CONFIG_AIO=3Dy
>> CONFIG_EMBEDDED=3Dy
>> CONFIG_HAVE_PERF_EVENTS=3Dy
>>
>> #
>> # Kernel Performance Events And Counters
>> #
>> CONFIG_PERF_EVENTS=3Dy
>> # CONFIG_PERF_COUNTERS is not set
>> # CONFIG_DEBUG_PERF_USE_VMALLOC is not set
>> CONFIG_VM_EVENT_COUNTERS=3Dy
>> CONFIG_PCI_QUIRKS=3Dy
>> CONFIG_SLUB_DEBUG=3Dy
>> CONFIG_COMPAT_BRK=3Dy
>> # CONFIG_SLAB is not set
>> CONFIG_SLUB=3Dy
>> # CONFIG_SLOB is not set
>> CONFIG_PROFILING=3Dy
>> CONFIG_TRACEPOINTS=3Dy
>> CONFIG_OPROFILE=3Dy
>> # CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
>> CONFIG_HAVE_OPROFILE=3Dy
>> CONFIG_OPROFILE_NMI_TIMER=3Dy
>> CONFIG_KPROBES=3Dy
>> # CONFIG_JUMP_LABEL is not set
>> CONFIG_OPTPROBES=3Dy
>> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=3Dy
>> CONFIG_KRETPROBES=3Dy
>> CONFIG_USER_RETURN_NOTIFIER=3Dy
>> CONFIG_HAVE_IOREMAP_PROT=3Dy
>> CONFIG_HAVE_KPROBES=3Dy
>> CONFIG_HAVE_KRETPROBES=3Dy
>> CONFIG_HAVE_OPTPROBES=3Dy
>> CONFIG_HAVE_ARCH_TRACEHOOK=3Dy
>> CONFIG_HAVE_DMA_ATTRS=3Dy
>> CONFIG_USE_GENERIC_SMP_HELPERS=3Dy
>> CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=3Dy
>> CONFIG_HAVE_DMA_API_DEBUG=3Dy
>> CONFIG_HAVE_HW_BREAKPOINT=3Dy
>> CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=3Dy
>> CONFIG_HAVE_USER_RETURN_NOTIFIER=3Dy
>> CONFIG_HAVE_PERF_EVENTS_NMI=3Dy
>> CONFIG_HAVE_ARCH_JUMP_LABEL=3Dy
>> CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=3Dy
>> CONFIG_HAVE_ALIGNED_STRUCT_PAGE=3Dy
>> CONFIG_HAVE_CMPXCHG_LOCAL=3Dy
>> CONFIG_HAVE_CMPXCHG_DOUBLE=3Dy
>> CONFIG_ARCH_WANT_OLD_COMPAT_IPC=3Dy
>>
>> #
>> # GCOV-based kernel profiling
>> #
>> # CONFIG_GCOV_KERNEL is not set
>> # CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
>> CONFIG_SLABINFO=3Dy
>> CONFIG_RT_MUTEXES=3Dy
>> CONFIG_BASE_SMALL=3D0
>> CONFIG_MODULES=3Dy
>> # CONFIG_MODULE_FORCE_LOAD is not set
>> CONFIG_MODULE_UNLOAD=3Dy
>> CONFIG_MODULE_FORCE_UNLOAD=3Dy
>> # CONFIG_MODVERSIONS is not set
>> # CONFIG_MODULE_SRCVERSION_ALL is not set
>> CONFIG_STOP_MACHINE=3Dy
>> CONFIG_BLOCK=3Dy
>> CONFIG_BLK_DEV_BSG=3Dy
>> CONFIG_BLK_DEV_BSGLIB=3Dy
>> CONFIG_BLK_DEV_INTEGRITY=3Dy
>> CONFIG_BLK_DEV_THROTTLING=3Dy
>>
>> #
>> # Partition Types
>> #
>> # CONFIG_PARTITION_ADVANCED is not set
>> CONFIG_MSDOS_PARTITION=3Dy
>> CONFIG_BLOCK_COMPAT=3Dy
>>
>> #
>> # IO Schedulers
>> #
>> CONFIG_IOSCHED_NOOP=3Dy
>> CONFIG_IOSCHED_DEADLINE=3Dy
>> CONFIG_IOSCHED_CFQ=3Dy
>> # CONFIG_CFQ_GROUP_IOSCHED is not set
>> # CONFIG_DEFAULT_DEADLINE is not set
>> CONFIG_DEFAULT_CFQ=3Dy
>> # CONFIG_DEFAULT_NOOP is not set
>> CONFIG_DEFAULT_IOSCHED=3D"cfq"
>> CONFIG_PREEMPT_NOTIFIERS=3Dy
>> # CONFIG_INLINE_SPIN_TRYLOCK is not set
>> # CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
>> # CONFIG_INLINE_SPIN_LOCK is not set
>> # CONFIG_INLINE_SPIN_LOCK_BH is not set
>> # CONFIG_INLINE_SPIN_LOCK_IRQ is not set
>> # CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
>> CONFIG_UNINLINE_SPIN_UNLOCK=3Dy
>> # CONFIG_INLINE_SPIN_UNLOCK_BH is not set
>> # CONFIG_INLINE_SPIN_UNLOCK_IRQ is not set
>> # CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
>> # CONFIG_INLINE_READ_TRYLOCK is not set
>> # CONFIG_INLINE_READ_LOCK is not set
>> # CONFIG_INLINE_READ_LOCK_BH is not set
>> # CONFIG_INLINE_READ_LOCK_IRQ is not set
>> # CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
>> # CONFIG_INLINE_READ_UNLOCK is not set
>> # CONFIG_INLINE_READ_UNLOCK_BH is not set
>> # CONFIG_INLINE_READ_UNLOCK_IRQ is not set
>> # CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
>> # CONFIG_INLINE_WRITE_TRYLOCK is not set
>> # CONFIG_INLINE_WRITE_LOCK is not set
>> # CONFIG_INLINE_WRITE_LOCK_BH is not set
>> # CONFIG_INLINE_WRITE_LOCK_IRQ is not set
>> # CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
>> # CONFIG_INLINE_WRITE_UNLOCK is not set
>> # CONFIG_INLINE_WRITE_UNLOCK_BH is not set
>> # CONFIG_INLINE_WRITE_UNLOCK_IRQ is not set
>> # CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
>> # CONFIG_MUTEX_SPIN_ON_OWNER is not set
>> CONFIG_FREEZER=3Dy
>>
>> #
>> # Processor type and features
>> #
>> CONFIG_ZONE_DMA=3Dy
>> CONFIG_TICK_ONESHOT=3Dy
>> CONFIG_NO_HZ=3Dy
>> CONFIG_HIGH_RES_TIMERS=3Dy
>> CONFIG_GENERIC_CLOCKEVENTS_BUILD=3Dy
>> CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=3Dy
>> CONFIG_SMP=3Dy
>> CONFIG_X86_MPPARSE=3Dy
>> CONFIG_X86_EXTENDED_PLATFORM=3Dy
>> # CONFIG_X86_VSMP is not set
>> CONFIG_X86_SUPPORTS_MEMORY_FAILURE=3Dy
>> CONFIG_SCHED_OMIT_FRAME_POINTER=3Dy
>> CONFIG_PARAVIRT_GUEST=3Dy
>> # CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
>> # CONFIG_XEN is not set
>> # CONFIG_XEN_PRIVILEGED_GUEST is not set
>> CONFIG_KVM_CLOCK=3Dy
>> CONFIG_KVM_GUEST=3Dy
>> CONFIG_PARAVIRT=3Dy
>> # CONFIG_PARAVIRT_SPINLOCKS is not set
>> CONFIG_PARAVIRT_CLOCK=3Dy
>> # CONFIG_PARAVIRT_DEBUG is not set
>> CONFIG_NO_BOOTMEM=3Dy
>> CONFIG_MEMTEST=3Dy
>> # CONFIG_MK8 is not set
>> # CONFIG_MPSC is not set
>> # CONFIG_MCORE2 is not set
>> # CONFIG_MATOM is not set
>> CONFIG_GENERIC_CPU=3Dy
>> CONFIG_X86_INTERNODE_CACHE_SHIFT=3D6
>> CONFIG_X86_CMPXCHG=3Dy
>> CONFIG_X86_L1_CACHE_SHIFT=3D6
>> CONFIG_X86_XADD=3Dy
>> CONFIG_X86_WP_WORKS_OK=3Dy
>> CONFIG_X86_TSC=3Dy
>> CONFIG_X86_CMPXCHG64=3Dy
>> CONFIG_X86_CMOV=3Dy
>> CONFIG_X86_MINIMUM_CPU_FAMILY=3D64
>> CONFIG_X86_DEBUGCTLMSR=3Dy
>> CONFIG_PROCESSOR_SELECT=3Dy
>> CONFIG_CPU_SUP_INTEL=3Dy
>> CONFIG_CPU_SUP_AMD=3Dy
>> CONFIG_CPU_SUP_CENTAUR=3Dy
>> CONFIG_HPET_TIMER=3Dy
>> CONFIG_HPET_EMULATE_RTC=3Dy
>> CONFIG_DMI=3Dy
>> CONFIG_GART_IOMMU=3Dy
>> # CONFIG_CALGARY_IOMMU is not set
>> CONFIG_SWIOTLB=3Dy
>> CONFIG_IOMMU_HELPER=3Dy
>> # CONFIG_MAXSMP is not set
>> CONFIG_NR_CPUS=3D64
>> CONFIG_SCHED_SMT=3Dy
>> CONFIG_SCHED_MC=3Dy
>> # CONFIG_IRQ_TIME_ACCOUNTING is not set
>> # CONFIG_PREEMPT_NONE is not set
>> CONFIG_PREEMPT_VOLUNTARY=3Dy
>> # CONFIG_PREEMPT is not set
>> CONFIG_X86_LOCAL_APIC=3Dy
>> CONFIG_X86_IO_APIC=3Dy
>> # CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
>> CONFIG_X86_MCE=3Dy
>> CONFIG_X86_MCE_INTEL=3Dy
>> # CONFIG_X86_MCE_AMD is not set
>> CONFIG_X86_MCE_THRESHOLD=3Dy
>> CONFIG_X86_MCE_INJECT=3Dy
>> CONFIG_X86_THERMAL_VECTOR=3Dy
>> # CONFIG_I8K is not set
>> CONFIG_MICROCODE=3Dy
>> CONFIG_MICROCODE_INTEL=3Dy
>> # CONFIG_MICROCODE_AMD is not set
>> CONFIG_MICROCODE_OLD_INTERFACE=3Dy
>> CONFIG_X86_MSR=3Dy
>> CONFIG_X86_CPUID=3Dy
>> CONFIG_ARCH_PHYS_ADDR_T_64BIT=3Dy
>> CONFIG_ARCH_DMA_ADDR_T_64BIT=3Dy
>> CONFIG_DIRECT_GBPAGES=3Dy
>> CONFIG_NUMA=3Dy
>> CONFIG_AMD_NUMA=3Dy
>> CONFIG_X86_64_ACPI_NUMA=3Dy
>> CONFIG_NODES_SPAN_OTHER_NODES=3Dy
>> CONFIG_NUMA_EMU=3Dy
>> CONFIG_NODES_SHIFT=3D6
>> CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
>> CONFIG_ARCH_SPARSEMEM_DEFAULT=3Dy
>> CONFIG_ARCH_SELECT_MEMORY_MODEL=3Dy
>> CONFIG_ARCH_MEMORY_PROBE=3Dy
>> CONFIG_ARCH_PROC_KCORE_TEXT=3Dy
>> CONFIG_ILLEGAL_POINTER_VALUE=3D0xdead000000000000
>> CONFIG_SELECT_MEMORY_MODEL=3Dy
>> CONFIG_SPARSEMEM_MANUAL=3Dy
>> CONFIG_SPARSEMEM=3Dy
>> CONFIG_NEED_MULTIPLE_NODES=3Dy
>> CONFIG_HAVE_MEMORY_PRESENT=3Dy
>> CONFIG_SPARSEMEM_EXTREME=3Dy
>> CONFIG_SPARSEMEM_VMEMMAP_ENABLE=3Dy
>> CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=3Dy
>> CONFIG_SPARSEMEM_VMEMMAP=3Dy
>> CONFIG_HAVE_MEMBLOCK=3Dy
>> CONFIG_HAVE_MEMBLOCK_NODE_MAP=3Dy
>> CONFIG_ARCH_DISCARD_MEMBLOCK=3Dy
>> CONFIG_MEMORY_HOTPLUG=3Dy
>> CONFIG_MEMORY_HOTPLUG_SPARSE=3Dy
>> CONFIG_MEMORY_HOTREMOVE=3Dy
>> CONFIG_PAGEFLAGS_EXTENDED=3Dy
>> CONFIG_SPLIT_PTLOCK_CPUS=3D999999
>> # CONFIG_COMPACTION is not set
>> CONFIG_MIGRATION=3Dy
>> CONFIG_PHYS_ADDR_T_64BIT=3Dy
>> CONFIG_ZONE_DMA_FLAG=3D1
>> CONFIG_BOUNCE=3Dy
>> CONFIG_VIRT_TO_BUS=3Dy
>> CONFIG_MMU_NOTIFIER=3Dy
>> CONFIG_KSM=3Dy
>> CONFIG_DEFAULT_MMAP_MIN_ADDR=3D4096
>> CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=3Dy
>> CONFIG_MEMORY_FAILURE=3Dy
>> CONFIG_HWPOISON_INJECT=3Dy
>> # CONFIG_TRANSPARENT_HUGEPAGE is not set
>> # CONFIG_CLEANCACHE is not set
>> CONFIG_X86_CHECK_BIOS_CORRUPTION=3Dy
>> CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=3Dy
>> CONFIG_X86_RESERVE_LOW=3D64
>> CONFIG_MTRR=3Dy
>> # CONFIG_MTRR_SANITIZER is not set
>> CONFIG_X86_PAT=3Dy
>> CONFIG_ARCH_USES_PG_UNCACHED=3Dy
>> CONFIG_ARCH_RANDOM=3Dy
>> CONFIG_EFI=3Dy
>> # CONFIG_EFI_STUB is not set
>> CONFIG_SECCOMP=3Dy
>> # CONFIG_CC_STACKPROTECTOR is not set
>> # CONFIG_HZ_100 is not set
>> # CONFIG_HZ_250 is not set
>> # CONFIG_HZ_300 is not set
>> CONFIG_HZ_1000=3Dy
>> CONFIG_HZ=3D1000
>> CONFIG_SCHED_HRTICK=3Dy
>> CONFIG_KEXEC=3Dy
>> CONFIG_CRASH_DUMP=3Dy
>> CONFIG_KEXEC_JUMP=3Dy
>> CONFIG_PHYSICAL_START=3D0x1000000
>> CONFIG_RELOCATABLE=3Dy
>> CONFIG_PHYSICAL_ALIGN=3D0x1000000
>> CONFIG_HOTPLUG_CPU=3Dy
>> CONFIG_COMPAT_VDSO=3Dy
>> # CONFIG_CMDLINE_BOOL is not set
>> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy
>> CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=3Dy
>> CONFIG_USE_PERCPU_NUMA_NODE_ID=3Dy
>>
>> #
>> # Power management and ACPI options
>> #
>> CONFIG_ARCH_HIBERNATION_HEADER=3Dy
>> CONFIG_SUSPEND=3Dy
>> CONFIG_SUSPEND_FREEZER=3Dy
>> CONFIG_HIBERNATE_CALLBACKS=3Dy
>> CONFIG_HIBERNATION=3Dy
>> CONFIG_PM_STD_PARTITION=3D""
>> CONFIG_PM_SLEEP=3Dy
>> CONFIG_PM_SLEEP_SMP=3Dy
>> # CONFIG_PM_RUNTIME is not set
>> CONFIG_PM=3Dy
>> CONFIG_PM_DEBUG=3Dy
>> CONFIG_PM_ADVANCED_DEBUG=3Dy
>> # CONFIG_PM_TEST_SUSPEND is not set
>> CONFIG_CAN_PM_TRACE=3Dy
>> CONFIG_PM_TRACE=3Dy
>> CONFIG_PM_TRACE_RTC=3Dy
>> CONFIG_ACPI=3Dy
>> CONFIG_ACPI_SLEEP=3Dy
>> CONFIG_ACPI_PROCFS=3Dy
>> CONFIG_ACPI_PROCFS_POWER=3Dy
>> CONFIG_ACPI_EC_DEBUGFS=3Dy
>> CONFIG_ACPI_PROC_EVENT=3Dy
>> CONFIG_ACPI_AC=3Dy
>> CONFIG_ACPI_BATTERY=3Dy
>> CONFIG_ACPI_BUTTON=3Dy
>> CONFIG_ACPI_VIDEO=3Dy
>> CONFIG_ACPI_FAN=3Dy
>> CONFIG_ACPI_DOCK=3Dy
>> CONFIG_ACPI_PROCESSOR=3Dy
>> CONFIG_ACPI_HOTPLUG_CPU=3Dy
>> # CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
>> CONFIG_ACPI_THERMAL=3Dy
>> CONFIG_ACPI_NUMA=3Dy
>> CONFIG_ACPI_CUSTOM_DSDT_FILE=3D""
>> # CONFIG_ACPI_CUSTOM_DSDT is not set
>> CONFIG_ACPI_BLACKLIST_YEAR=3D0
>> CONFIG_ACPI_DEBUG=3Dy
>> CONFIG_ACPI_DEBUG_FUNC_TRACE=3Dy
>> CONFIG_ACPI_PCI_SLOT=3Dy
>> CONFIG_X86_PM_TIMER=3Dy
>> CONFIG_ACPI_CONTAINER=3Dy
>> # CONFIG_ACPI_HOTPLUG_MEMORY is not set
>> CONFIG_ACPI_SBS=3Dy
>> # CONFIG_ACPI_HED is not set
>> # CONFIG_ACPI_CUSTOM_METHOD is not set
>> # CONFIG_ACPI_BGRT is not set
>> # CONFIG_ACPI_APEI is not set
>> # CONFIG_SFI is not set
>>
>> #
>> # CPU Frequency scaling
>> #
>> CONFIG_CPU_FREQ=3Dy
>> CONFIG_CPU_FREQ_TABLE=3Dy
>> CONFIG_CPU_FREQ_STAT=3Dy
>> CONFIG_CPU_FREQ_STAT_DETAILS=3Dy
>> # CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
>> # CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
>> # CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
>> CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=3Dy
>> # CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
>> CONFIG_CPU_FREQ_GOV_PERFORMANCE=3Dy
>> CONFIG_CPU_FREQ_GOV_POWERSAVE=3Dy
>> CONFIG_CPU_FREQ_GOV_USERSPACE=3Dy
>> CONFIG_CPU_FREQ_GOV_ONDEMAND=3Dy
>> CONFIG_CPU_FREQ_GOV_CONSERVATIVE=3Dy
>>
>> #
>> # x86 CPU frequency scaling drivers
>> #
>> # CONFIG_X86_PCC_CPUFREQ is not set
>> CONFIG_X86_ACPI_CPUFREQ=3Dy
>> # CONFIG_X86_POWERNOW_K8 is not set
>> CONFIG_X86_SPEEDSTEP_CENTRINO=3Dy
>> # CONFIG_X86_P4_CLOCKMOD is not set
>>
>> #
>> # shared options
>> #
>> # CONFIG_X86_SPEEDSTEP_LIB is not set
>> CONFIG_CPU_IDLE=3Dy
>> CONFIG_CPU_IDLE_GOV_LADDER=3Dy
>> CONFIG_CPU_IDLE_GOV_MENU=3Dy
>> # CONFIG_INTEL_IDLE is not set
>>
>> #
>> # Memory power savings
>> #
>> CONFIG_I7300_IDLE_IOAT_CHANNEL=3Dy
>> CONFIG_I7300_IDLE=3Dy
>>
>> #
>> # Bus options (PCI etc.)
>> #
>> CONFIG_PCI=3Dy
>> CONFIG_PCI_DIRECT=3Dy
>> CONFIG_PCI_MMCONFIG=3Dy
>> CONFIG_PCI_DOMAINS=3Dy
>> # CONFIG_PCI_CNB20LE_QUIRK is not set
>> CONFIG_PCIEPORTBUS=3Dy
>> # CONFIG_HOTPLUG_PCI_PCIE is not set
>> CONFIG_PCIEAER=3Dy
>> # CONFIG_PCIE_ECRC is not set
>> # CONFIG_PCIEAER_INJECT is not set
>> # CONFIG_PCIEASPM is not set
>> CONFIG_ARCH_SUPPORTS_MSI=3Dy
>> CONFIG_PCI_MSI=3Dy
>> # CONFIG_PCI_DEBUG is not set
>> # CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
>> # CONFIG_PCI_STUB is not set
>> CONFIG_HT_IRQ=3Dy
>> # CONFIG_PCI_IOV is not set
>> # CONFIG_PCI_PRI is not set
>> # CONFIG_PCI_PASID is not set
>> CONFIG_PCI_IOAPIC=3Dy
>> CONFIG_PCI_LABEL=3Dy
>> CONFIG_ISA_DMA_API=3Dy
>> CONFIG_AMD_NB=3Dy
>> # CONFIG_PCCARD is not set
>> CONFIG_HOTPLUG_PCI=3Dy
>> # CONFIG_HOTPLUG_PCI_FAKE is not set
>> # CONFIG_HOTPLUG_PCI_ACPI is not set
>> # CONFIG_HOTPLUG_PCI_CPCI is not set
>> # CONFIG_HOTPLUG_PCI_SHPC is not set
>> # CONFIG_RAPIDIO is not set
>>
>> #
>> # Executable file formats / Emulations
>> #
>> CONFIG_BINFMT_ELF=3Dy
>> CONFIG_COMPAT_BINFMT_ELF=3Dy
>> CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=3Dy
>> # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
>> # CONFIG_HAVE_AOUT is not set
>> # CONFIG_BINFMT_MISC is not set
>> CONFIG_IA32_EMULATION=3Dy
>> # CONFIG_IA32_AOUT is not set
>> # CONFIG_X86_X32 is not set
>> CONFIG_COMPAT=3Dy
>> CONFIG_COMPAT_FOR_U64_ALIGNMENT=3Dy
>> CONFIG_SYSVIPC_COMPAT=3Dy
>> CONFIG_KEYS_COMPAT=3Dy
>> CONFIG_HAVE_TEXT_POKE_SMP=3Dy
>> CONFIG_NET=3Dy
>>
>> #
>> # Networking options
>> #
>> CONFIG_PACKET=3Dy
>> CONFIG_UNIX=3Dy
>> # CONFIG_UNIX_DIAG is not set
>> CONFIG_XFRM=3Dy
>> CONFIG_XFRM_USER=3Dy
>> # CONFIG_XFRM_SUB_POLICY is not set
>> # CONFIG_XFRM_MIGRATE is not set
>> # CONFIG_XFRM_STATISTICS is not set
>> CONFIG_XFRM_IPCOMP=3Dy
>> CONFIG_NET_KEY=3Dy
>> # CONFIG_NET_KEY_MIGRATE is not set
>> CONFIG_INET=3Dy
>> # CONFIG_IP_MULTICAST is not set
>> # CONFIG_IP_ADVANCED_ROUTER is not set
>> CONFIG_IP_ROUTE_CLASSID=3Dy
>> CONFIG_IP_PNP=3Dy
>> CONFIG_IP_PNP_DHCP=3Dy
>> # CONFIG_IP_PNP_BOOTP is not set
>> # CONFIG_IP_PNP_RARP is not set
>> # CONFIG_NET_IPIP is not set
>> # CONFIG_NET_IPGRE_DEMUX is not set
>> # CONFIG_ARPD is not set
>> # CONFIG_SYN_COOKIES is not set
>> CONFIG_INET_AH=3Dy
>> CONFIG_INET_ESP=3Dy
>> CONFIG_INET_IPCOMP=3Dy
>> CONFIG_INET_XFRM_TUNNEL=3Dy
>> CONFIG_INET_TUNNEL=3Dy
>> # CONFIG_INET_XFRM_MODE_TRANSPORT is not set
>> # CONFIG_INET_XFRM_MODE_TUNNEL is not set
>> # CONFIG_INET_XFRM_MODE_BEET is not set
>> CONFIG_INET_LRO=3Dy
>> CONFIG_INET_DIAG=3Dy
>> CONFIG_INET_TCP_DIAG=3Dy
>> # CONFIG_INET_UDP_DIAG is not set
>> CONFIG_TCP_CONG_ADVANCED=3Dy
>> CONFIG_TCP_CONG_BIC=3Dy
>> CONFIG_TCP_CONG_CUBIC=3Dy
>> CONFIG_TCP_CONG_WESTWOOD=3Dy
>> CONFIG_TCP_CONG_HTCP=3Dy
>> CONFIG_TCP_CONG_HSTCP=3Dy
>> CONFIG_TCP_CONG_HYBLA=3Dy
>> CONFIG_TCP_CONG_VEGAS=3Dy
>> CONFIG_TCP_CONG_SCALABLE=3Dy
>> CONFIG_TCP_CONG_LP=3Dy
>> CONFIG_TCP_CONG_VENO=3Dy
>> CONFIG_TCP_CONG_YEAH=3Dy
>> CONFIG_TCP_CONG_ILLINOIS=3Dy
>> # CONFIG_DEFAULT_BIC is not set
>> CONFIG_DEFAULT_CUBIC=3Dy
>> # CONFIG_DEFAULT_HTCP is not set
>> # CONFIG_DEFAULT_HYBLA is not set
>> # CONFIG_DEFAULT_VEGAS is not set
>> # CONFIG_DEFAULT_VENO is not set
>> # CONFIG_DEFAULT_WESTWOOD is not set
>> # CONFIG_DEFAULT_RENO is not set
>> CONFIG_DEFAULT_TCP_CONG=3D"cubic"
>> # CONFIG_TCP_MD5SIG is not set
>> CONFIG_IPV6=3Dy
>> # CONFIG_IPV6_PRIVACY is not set
>> # CONFIG_IPV6_ROUTER_PREF is not set
>> # CONFIG_IPV6_OPTIMISTIC_DAD is not set
>> # CONFIG_INET6_AH is not set
>> # CONFIG_INET6_ESP is not set
>> # CONFIG_INET6_IPCOMP is not set
>> # CONFIG_IPV6_MIP6 is not set
>> # CONFIG_INET6_XFRM_TUNNEL is not set
>> # CONFIG_INET6_TUNNEL is not set
>> CONFIG_INET6_XFRM_MODE_TRANSPORT=3Dy
>> CONFIG_INET6_XFRM_MODE_TUNNEL=3Dy
>> CONFIG_INET6_XFRM_MODE_BEET=3Dy
>> # CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
>> CONFIG_IPV6_SIT=3Dy
>> # CONFIG_IPV6_SIT_6RD is not set
>> CONFIG_IPV6_NDISC_NODETYPE=3Dy
>> # CONFIG_IPV6_TUNNEL is not set
>> # CONFIG_IPV6_MULTIPLE_TABLES is not set
>> # CONFIG_IPV6_MROUTE is not set
>> # CONFIG_NETWORK_SECMARK is not set
>> # CONFIG_NETWORK_PHY_TIMESTAMPING is not set
>> CONFIG_NETFILTER=3Dy
>> # CONFIG_NETFILTER_DEBUG is not set
>> CONFIG_NETFILTER_ADVANCED=3Dy
>> CONFIG_BRIDGE_NETFILTER=3Dy
>>
>> #
>> # Core Netfilter Configuration
>> #
>> CONFIG_NETFILTER_NETLINK=3Dy
>> # CONFIG_NETFILTER_NETLINK_ACCT is not set
>> CONFIG_NETFILTER_NETLINK_QUEUE=3Dy
>> CONFIG_NETFILTER_NETLINK_LOG=3Dy
>> CONFIG_NF_CONNTRACK=3Dy
>> CONFIG_NF_CONNTRACK_MARK=3Dy
>> CONFIG_NF_CONNTRACK_ZONES=3Dy
>> CONFIG_NF_CONNTRACK_PROCFS=3Dy
>> CONFIG_NF_CONNTRACK_EVENTS=3Dy
>> # CONFIG_NF_CONNTRACK_TIMEOUT is not set
>> # CONFIG_NF_CONNTRACK_TIMESTAMP is not set
>> CONFIG_NF_CT_PROTO_DCCP=3Dy
>> CONFIG_NF_CT_PROTO_GRE=3Dy
>> CONFIG_NF_CT_PROTO_SCTP=3Dy
>> CONFIG_NF_CT_PROTO_UDPLITE=3Dy
>> CONFIG_NF_CONNTRACK_AMANDA=3Dy
>> CONFIG_NF_CONNTRACK_FTP=3Dy
>> CONFIG_NF_CONNTRACK_H323=3Dy
>> CONFIG_NF_CONNTRACK_IRC=3Dy
>> CONFIG_NF_CONNTRACK_BROADCAST=3Dy
>> CONFIG_NF_CONNTRACK_NETBIOS_NS=3Dy
>> # CONFIG_NF_CONNTRACK_SNMP is not set
>> CONFIG_NF_CONNTRACK_PPTP=3Dy
>> CONFIG_NF_CONNTRACK_SANE=3Dy
>> CONFIG_NF_CONNTRACK_SIP=3Dy
>> CONFIG_NF_CONNTRACK_TFTP=3Dy
>> CONFIG_NF_CT_NETLINK=3Dy
>> # CONFIG_NF_CT_NETLINK_TIMEOUT is not set
>> CONFIG_NETFILTER_TPROXY=3Dy
>> CONFIG_NETFILTER_XTABLES=3Dy
>>
>> #
>> # Xtables combined modules
>> #
>> CONFIG_NETFILTER_XT_MARK=3Dy
>> CONFIG_NETFILTER_XT_CONNMARK=3Dy
>>
>> #
>> # Xtables targets
>> #
>> # CONFIG_NETFILTER_XT_TARGET_AUDIT is not set
>> CONFIG_NETFILTER_XT_TARGET_CHECKSUM=3Dy
>> CONFIG_NETFILTER_XT_TARGET_CLASSIFY=3Dy
>> CONFIG_NETFILTER_XT_TARGET_CONNMARK=3Dy
>> CONFIG_NETFILTER_XT_TARGET_CT=3Dy
>> CONFIG_NETFILTER_XT_TARGET_DSCP=3Dy
>> CONFIG_NETFILTER_XT_TARGET_HL=3Dy
>> CONFIG_NETFILTER_XT_TARGET_IDLETIMER=3Dy
>> CONFIG_NETFILTER_XT_TARGET_LED=3Dy
>> # CONFIG_NETFILTER_XT_TARGET_LOG is not set
>> CONFIG_NETFILTER_XT_TARGET_MARK=3Dy
>> CONFIG_NETFILTER_XT_TARGET_NFLOG=3Dy
>> CONFIG_NETFILTER_XT_TARGET_NFQUEUE=3Dy
>> CONFIG_NETFILTER_XT_TARGET_NOTRACK=3Dy
>> CONFIG_NETFILTER_XT_TARGET_RATEEST=3Dy
>> CONFIG_NETFILTER_XT_TARGET_TEE=3Dy
>> CONFIG_NETFILTER_XT_TARGET_TPROXY=3Dy
>> CONFIG_NETFILTER_XT_TARGET_TRACE=3Dy
>> CONFIG_NETFILTER_XT_TARGET_TCPMSS=3Dy
>> CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=3Dy
>>
>> #
>> # Xtables matches
>> #
>> # CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
>> CONFIG_NETFILTER_XT_MATCH_CLUSTER=3Dy
>> CONFIG_NETFILTER_XT_MATCH_COMMENT=3Dy
>> CONFIG_NETFILTER_XT_MATCH_CONNBYTES=3Dy
>> CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=3Dy
>> CONFIG_NETFILTER_XT_MATCH_CONNMARK=3Dy
>> CONFIG_NETFILTER_XT_MATCH_CONNTRACK=3Dy
>> CONFIG_NETFILTER_XT_MATCH_CPU=3Dy
>> CONFIG_NETFILTER_XT_MATCH_DCCP=3Dy
>> # CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set
>> CONFIG_NETFILTER_XT_MATCH_DSCP=3Dy
>> CONFIG_NETFILTER_XT_MATCH_ECN=3Dy
>> CONFIG_NETFILTER_XT_MATCH_ESP=3Dy
>> CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=3Dy
>> CONFIG_NETFILTER_XT_MATCH_HELPER=3Dy
>> CONFIG_NETFILTER_XT_MATCH_HL=3Dy
>> CONFIG_NETFILTER_XT_MATCH_IPRANGE=3Dy
>> CONFIG_NETFILTER_XT_MATCH_LENGTH=3Dy
>> CONFIG_NETFILTER_XT_MATCH_LIMIT=3Dy
>> CONFIG_NETFILTER_XT_MATCH_MAC=3Dy
>> CONFIG_NETFILTER_XT_MATCH_MARK=3Dy
>> CONFIG_NETFILTER_XT_MATCH_MULTIPORT=3Dy
>> # CONFIG_NETFILTER_XT_MATCH_NFACCT is not set
>> CONFIG_NETFILTER_XT_MATCH_OSF=3Dy
>> CONFIG_NETFILTER_XT_MATCH_OWNER=3Dy
>> CONFIG_NETFILTER_XT_MATCH_POLICY=3Dy
>> CONFIG_NETFILTER_XT_MATCH_PHYSDEV=3Dy
>> CONFIG_NETFILTER_XT_MATCH_PKTTYPE=3Dy
>> CONFIG_NETFILTER_XT_MATCH_QUOTA=3Dy
>> CONFIG_NETFILTER_XT_MATCH_RATEEST=3Dy
>> CONFIG_NETFILTER_XT_MATCH_REALM=3Dy
>> CONFIG_NETFILTER_XT_MATCH_RECENT=3Dy
>> CONFIG_NETFILTER_XT_MATCH_SCTP=3Dy
>> CONFIG_NETFILTER_XT_MATCH_SOCKET=3Dy
>> CONFIG_NETFILTER_XT_MATCH_STATE=3Dy
>> CONFIG_NETFILTER_XT_MATCH_STATISTIC=3Dy
>> CONFIG_NETFILTER_XT_MATCH_STRING=3Dy
>> CONFIG_NETFILTER_XT_MATCH_TCPMSS=3Dy
>> CONFIG_NETFILTER_XT_MATCH_TIME=3Dy
>> CONFIG_NETFILTER_XT_MATCH_U32=3Dy
>> # CONFIG_IP_SET is not set
>> # CONFIG_IP_VS is not set
>>
>> #
>> # IP: Netfilter Configuration
>> #
>> CONFIG_NF_DEFRAG_IPV4=3Dy
>> CONFIG_NF_CONNTRACK_IPV4=3Dy
>> CONFIG_NF_CONNTRACK_PROC_COMPAT=3Dy
>> # CONFIG_IP_NF_QUEUE is not set
>> CONFIG_IP_NF_IPTABLES=3Dy
>> CONFIG_IP_NF_MATCH_AH=3Dy
>> CONFIG_IP_NF_MATCH_ECN=3Dy
>> # CONFIG_IP_NF_MATCH_RPFILTER is not set
>> CONFIG_IP_NF_MATCH_TTL=3Dy
>> CONFIG_IP_NF_FILTER=3Dy
>> CONFIG_IP_NF_TARGET_REJECT=3Dy
>> CONFIG_IP_NF_TARGET_ULOG=3Dy
>> CONFIG_NF_NAT=3Dy
>> CONFIG_NF_NAT_NEEDED=3Dy
>> CONFIG_IP_NF_TARGET_MASQUERADE=3Dy
>> CONFIG_IP_NF_TARGET_NETMAP=3Dy
>> CONFIG_IP_NF_TARGET_REDIRECT=3Dy
>> CONFIG_NF_NAT_PROTO_DCCP=3Dy
>> CONFIG_NF_NAT_PROTO_GRE=3Dy
>> CONFIG_NF_NAT_PROTO_UDPLITE=3Dy
>> CONFIG_NF_NAT_PROTO_SCTP=3Dy
>> CONFIG_NF_NAT_FTP=3Dy
>> CONFIG_NF_NAT_IRC=3Dy
>> CONFIG_NF_NAT_TFTP=3Dy
>> CONFIG_NF_NAT_AMANDA=3Dy
>> CONFIG_NF_NAT_PPTP=3Dy
>> CONFIG_NF_NAT_H323=3Dy
>> CONFIG_NF_NAT_SIP=3Dy
>> CONFIG_IP_NF_MANGLE=3Dy
>> CONFIG_IP_NF_TARGET_CLUSTERIP=3Dy
>> CONFIG_IP_NF_TARGET_ECN=3Dy
>> CONFIG_IP_NF_TARGET_TTL=3Dy
>> CONFIG_IP_NF_RAW=3Dy
>> CONFIG_IP_NF_ARPTABLES=3Dy
>> CONFIG_IP_NF_ARPFILTER=3Dy
>> CONFIG_IP_NF_ARP_MANGLE=3Dy
>>
>> #
>> # IPv6: Netfilter Configuration
>> #
>> # CONFIG_NF_DEFRAG_IPV6 is not set
>> # CONFIG_NF_CONNTRACK_IPV6 is not set
>> # CONFIG_IP6_NF_QUEUE is not set
>> # CONFIG_IP6_NF_IPTABLES is not set
>> CONFIG_BRIDGE_NF_EBTABLES=3Dy
>> CONFIG_BRIDGE_EBT_BROUTE=3Dy
>> CONFIG_BRIDGE_EBT_T_FILTER=3Dy
>> CONFIG_BRIDGE_EBT_T_NAT=3Dy
>> CONFIG_BRIDGE_EBT_802_3=3Dy
>> CONFIG_BRIDGE_EBT_AMONG=3Dy
>> CONFIG_BRIDGE_EBT_ARP=3Dy
>> CONFIG_BRIDGE_EBT_IP=3Dy
>> # CONFIG_BRIDGE_EBT_IP6 is not set
>> CONFIG_BRIDGE_EBT_LIMIT=3Dy
>> CONFIG_BRIDGE_EBT_MARK=3Dy
>> CONFIG_BRIDGE_EBT_PKTTYPE=3Dy
>> CONFIG_BRIDGE_EBT_STP=3Dy
>> CONFIG_BRIDGE_EBT_VLAN=3Dy
>> CONFIG_BRIDGE_EBT_ARPREPLY=3Dy
>> CONFIG_BRIDGE_EBT_DNAT=3Dy
>> CONFIG_BRIDGE_EBT_MARK_T=3Dy
>> CONFIG_BRIDGE_EBT_REDIRECT=3Dy
>> CONFIG_BRIDGE_EBT_SNAT=3Dy
>> CONFIG_BRIDGE_EBT_LOG=3Dy
>> CONFIG_BRIDGE_EBT_ULOG=3Dy
>> CONFIG_BRIDGE_EBT_NFLOG=3Dy
>> # CONFIG_IP_DCCP is not set
>> # CONFIG_IP_SCTP is not set
>> # CONFIG_RDS is not set
>> # CONFIG_TIPC is not set
>> # CONFIG_ATM is not set
>> # CONFIG_L2TP is not set
>> CONFIG_STP=3Dy
>> CONFIG_BRIDGE=3Dy
>> CONFIG_BRIDGE_IGMP_SNOOPING=3Dy
>> # CONFIG_NET_DSA is not set
>> # CONFIG_VLAN_8021Q is not set
>> # CONFIG_DECNET is not set
>> CONFIG_LLC=3Dy
>> # CONFIG_LLC2 is not set
>> # CONFIG_IPX is not set
>> # CONFIG_ATALK is not set
>> # CONFIG_X25 is not set
>> # CONFIG_LAPB is not set
>> # CONFIG_ECONET is not set
>> # CONFIG_WAN_ROUTER is not set
>> # CONFIG_PHONET is not set
>> # CONFIG_IEEE802154 is not set
>> CONFIG_NET_SCHED=3Dy
>>
>> #
>> # Queueing/Scheduling
>> #
>> # CONFIG_NET_SCH_CBQ is not set
>> # CONFIG_NET_SCH_HTB is not set
>> # CONFIG_NET_SCH_HFSC is not set
>> # CONFIG_NET_SCH_PRIO is not set
>> # CONFIG_NET_SCH_MULTIQ is not set
>> # CONFIG_NET_SCH_RED is not set
>> # CONFIG_NET_SCH_SFB is not set
>> # CONFIG_NET_SCH_SFQ is not set
>> # CONFIG_NET_SCH_TEQL is not set
>> # CONFIG_NET_SCH_TBF is not set
>> # CONFIG_NET_SCH_GRED is not set
>> # CONFIG_NET_SCH_DSMARK is not set
>> CONFIG_NET_SCH_NETEM=3Dy
>> # CONFIG_NET_SCH_DRR is not set
>> # CONFIG_NET_SCH_MQPRIO is not set
>> # CONFIG_NET_SCH_CHOKE is not set
>> # CONFIG_NET_SCH_QFQ is not set
>> # CONFIG_NET_SCH_PLUG is not set
>>
>> #
>> # Classification
>> #
>> # CONFIG_NET_CLS_BASIC is not set
>> # CONFIG_NET_CLS_TCINDEX is not set
>> # CONFIG_NET_CLS_ROUTE4 is not set
>> # CONFIG_NET_CLS_FW is not set
>> # CONFIG_NET_CLS_U32 is not set
>> # CONFIG_NET_CLS_RSVP is not set
>> # CONFIG_NET_CLS_RSVP6 is not set
>> # CONFIG_NET_CLS_FLOW is not set
>> # CONFIG_NET_CLS_CGROUP is not set
>> # CONFIG_NET_EMATCH is not set
>> # CONFIG_NET_CLS_ACT is not set
>> CONFIG_NET_SCH_FIFO=3Dy
>> # CONFIG_DCB is not set
>> CONFIG_DNS_RESOLVER=3Dy
>> # CONFIG_BATMAN_ADV is not set
>> # CONFIG_OPENVSWITCH is not set
>> CONFIG_RPS=3Dy
>> CONFIG_RFS_ACCEL=3Dy
>> CONFIG_XPS=3Dy
>> # CONFIG_NETPRIO_CGROUP is not set
>> CONFIG_BQL=3Dy
>> CONFIG_HAVE_BPF_JIT=3Dy
>> # CONFIG_BPF_JIT is not set
>>
>> #
>> # Network testing
>> #
>> # CONFIG_NET_PKTGEN is not set
>> # CONFIG_NET_TCPPROBE is not set
>> # CONFIG_NET_DROP_MONITOR is not set
>> # CONFIG_HAMRADIO is not set
>> # CONFIG_CAN is not set
>> # CONFIG_IRDA is not set
>> # CONFIG_BT is not set
>> # CONFIG_AF_RXRPC is not set
>> # CONFIG_WIRELESS is not set
>> # CONFIG_WIMAX is not set
>> # CONFIG_RFKILL is not set
>> # CONFIG_NET_9P is not set
>> # CONFIG_CAIF is not set
>> # CONFIG_CEPH_LIB is not set
>> # CONFIG_NFC is not set
>>
>> #
>> # Device Drivers
>> #
>>
>> #
>> # Generic Driver Options
>> #
>> CONFIG_UEVENT_HELPER_PATH=3D"/sbin/hotplug"
>> CONFIG_DEVTMPFS=3Dy
>> CONFIG_DEVTMPFS_MOUNT=3Dy
>> # CONFIG_STANDALONE is not set
>> # CONFIG_PREVENT_FIRMWARE_BUILD is not set
>> CONFIG_FW_LOADER=3Dy
>> CONFIG_FIRMWARE_IN_KERNEL=3Dy
>> CONFIG_EXTRA_FIRMWARE=3D"isci/isci_firmware.bin"
>> CONFIG_EXTRA_FIRMWARE_DIR=3D"firmware"
>> # CONFIG_DEBUG_DRIVER is not set
>> # CONFIG_DEBUG_DEVRES is not set
>> # CONFIG_SYS_HYPERVISOR is not set
>> # CONFIG_GENERIC_CPU_DEVICES is not set
>> CONFIG_DMA_SHARED_BUFFER=3Dy
>> CONFIG_CONNECTOR=3Dy
>> CONFIG_PROC_EVENTS=3Dy
>> # CONFIG_MTD is not set
>> # CONFIG_PARPORT is not set
>> CONFIG_PNP=3Dy
>> CONFIG_PNP_DEBUG_MESSAGES=3Dy
>>
>> #
>> # Protocols
>> #
>> CONFIG_PNPACPI=3Dy
>> CONFIG_BLK_DEV=3Dy
>> CONFIG_BLK_DEV_FD=3Dy
>> # CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
>> # CONFIG_BLK_CPQ_DA is not set
>> # CONFIG_BLK_CPQ_CISS_DA is not set
>> # CONFIG_BLK_DEV_DAC960 is not set
>> # CONFIG_BLK_DEV_UMEM is not set
>> # CONFIG_BLK_DEV_COW_COMMON is not set
>> CONFIG_BLK_DEV_LOOP=3Dy
>> CONFIG_BLK_DEV_LOOP_MIN_COUNT=3D8
>> CONFIG_BLK_DEV_CRYPTOLOOP=3Dy
>> # CONFIG_BLK_DEV_DRBD is not set
>> # CONFIG_BLK_DEV_NBD is not set
>> # CONFIG_BLK_DEV_NVME is not set
>> # CONFIG_BLK_DEV_SX8 is not set
>> # CONFIG_BLK_DEV_UB is not set
>> CONFIG_BLK_DEV_RAM=3Dy
>> CONFIG_BLK_DEV_RAM_COUNT=3D16
>> CONFIG_BLK_DEV_RAM_SIZE=3D65536
>> # CONFIG_BLK_DEV_XIP is not set
>> CONFIG_CDROM_PKTCDVD=3Dy
>> CONFIG_CDROM_PKTCDVD_BUFFERS=3D128
>> # CONFIG_CDROM_PKTCDVD_WCACHE is not set
>> # CONFIG_ATA_OVER_ETH is not set
>> CONFIG_VIRTIO_BLK=3Dy
>> # CONFIG_BLK_DEV_HD is not set
>> # CONFIG_BLK_DEV_RBD is not set
>>
>> #
>> # Misc devices
>> #
>> # CONFIG_SENSORS_LIS3LV02D is not set
>> # CONFIG_AD525X_DPOT is not set
>> # CONFIG_IBM_ASM is not set
>> # CONFIG_PHANTOM is not set
>> # CONFIG_INTEL_MID_PTI is not set
>> # CONFIG_SGI_IOC4 is not set
>> # CONFIG_TIFM_CORE is not set
>> # CONFIG_ICS932S401 is not set
>> # CONFIG_ENCLOSURE_SERVICES is not set
>> # CONFIG_HP_ILO is not set
>> # CONFIG_APDS9802ALS is not set
>> # CONFIG_ISL29003 is not set
>> # CONFIG_ISL29020 is not set
>> # CONFIG_SENSORS_TSL2550 is not set
>> # CONFIG_SENSORS_BH1780 is not set
>> # CONFIG_SENSORS_BH1770 is not set
>> # CONFIG_SENSORS_APDS990X is not set
>> # CONFIG_HMC6352 is not set
>> # CONFIG_DS1682 is not set
>> # CONFIG_VMWARE_BALLOON is not set
>> # CONFIG_BMP085 is not set
>> # CONFIG_PCH_PHUB is not set
>> # CONFIG_USB_SWITCH_FSA9480 is not set
>> # CONFIG_C2PORT is not set
>>
>> #
>> # EEPROM support
>> #
>> # CONFIG_EEPROM_AT24 is not set
>> # CONFIG_EEPROM_LEGACY is not set
>> # CONFIG_EEPROM_MAX6875 is not set
>> # CONFIG_EEPROM_93CX6 is not set
>> # CONFIG_CB710_CORE is not set
>>
>> #
>> # Texas Instruments shared transport line discipline
>> #
>> # CONFIG_SENSORS_LIS3_I2C is not set
>>
>> #
>> # Altera FPGA firmware download module
>> #
>> # CONFIG_ALTERA_STAPL is not set
>> CONFIG_HAVE_IDE=3Dy
>> # CONFIG_IDE is not set
>>
>> #
>> # SCSI device support
>> #
>> CONFIG_SCSI_MOD=3Dy
>> CONFIG_RAID_ATTRS=3Dy
>> CONFIG_SCSI=3Dy
>> CONFIG_SCSI_DMA=3Dy
>> # CONFIG_SCSI_TGT is not set
>> CONFIG_SCSI_NETLINK=3Dy
>> CONFIG_SCSI_PROC_FS=3Dy
>>
>> #
>> # SCSI support type (disk, tape, CD-ROM)
>> #
>> CONFIG_BLK_DEV_SD=3Dy
>> # CONFIG_CHR_DEV_ST is not set
>> # CONFIG_CHR_DEV_OSST is not set
>> # CONFIG_BLK_DEV_SR is not set
>> # CONFIG_CHR_DEV_SG is not set
>> # CONFIG_CHR_DEV_SCH is not set
>> # CONFIG_SCSI_MULTI_LUN is not set
>> CONFIG_SCSI_CONSTANTS=3Dy
>> # CONFIG_SCSI_LOGGING is not set
>> CONFIG_SCSI_SCAN_ASYNC=3Dy
>> CONFIG_SCSI_WAIT_SCAN=3Dm
>>
>> #
>> # SCSI Transports
>> #
>> CONFIG_SCSI_SPI_ATTRS=3Dy
>> CONFIG_SCSI_FC_ATTRS=3Dy
>> CONFIG_SCSI_ISCSI_ATTRS=3Dy
>> CONFIG_SCSI_SAS_ATTRS=3Dy
>> CONFIG_SCSI_SAS_LIBSAS=3Dy
>> CONFIG_SCSI_SAS_ATA=3Dy
>> CONFIG_SCSI_SAS_HOST_SMP=3Dy
>> # CONFIG_SCSI_SRP_ATTRS is not set
>> CONFIG_SCSI_LOWLEVEL=3Dy
>> # CONFIG_ISCSI_TCP is not set
>> CONFIG_ISCSI_BOOT_SYSFS=3Dy
>> # CONFIG_SCSI_CXGB3_ISCSI is not set
>> # CONFIG_SCSI_CXGB4_ISCSI is not set
>> # CONFIG_SCSI_BNX2_ISCSI is not set
>> # CONFIG_SCSI_BNX2X_FCOE is not set
>> # CONFIG_BE2ISCSI is not set
>> # CONFIG_BLK_DEV_3W_XXXX_RAID is not set
>> # CONFIG_SCSI_HPSA is not set
>> # CONFIG_SCSI_3W_9XXX is not set
>> # CONFIG_SCSI_3W_SAS is not set
>> # CONFIG_SCSI_ACARD is not set
>> CONFIG_SCSI_AACRAID=3Dy
>> CONFIG_SCSI_AIC7XXX=3Dy
>> CONFIG_AIC7XXX_CMDS_PER_DEVICE=3D32
>> CONFIG_AIC7XXX_RESET_DELAY_MS=3D5000
>> # CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
>> CONFIG_AIC7XXX_DEBUG_ENABLE=3Dy
>> CONFIG_AIC7XXX_DEBUG_MASK=3D0
>> CONFIG_AIC7XXX_REG_PRETTY_PRINT=3Dy
>> CONFIG_SCSI_AIC7XXX_OLD=3Dy
>> CONFIG_SCSI_AIC79XX=3Dy
>> CONFIG_AIC79XX_CMDS_PER_DEVICE=3D32
>> CONFIG_AIC79XX_RESET_DELAY_MS=3D5000
>> # CONFIG_AIC79XX_BUILD_FIRMWARE is not set
>> CONFIG_AIC79XX_DEBUG_ENABLE=3Dy
>> CONFIG_AIC79XX_DEBUG_MASK=3D0
>> CONFIG_AIC79XX_REG_PRETTY_PRINT=3Dy
>> CONFIG_SCSI_AIC94XX=3Dy
>> CONFIG_AIC94XX_DEBUG=3Dy
>> CONFIG_SCSI_MVSAS=3Dy
>> CONFIG_SCSI_MVSAS_DEBUG=3Dy
>> # CONFIG_SCSI_MVSAS_TASKLET is not set
>> # CONFIG_SCSI_MVUMI is not set
>> CONFIG_SCSI_DPT_I2O=3Dy
>> CONFIG_SCSI_ADVANSYS=3Dy
>> # CONFIG_SCSI_ARCMSR is not set
>> CONFIG_MEGARAID_NEWGEN=3Dy
>> CONFIG_MEGARAID_MM=3Dy
>> CONFIG_MEGARAID_MAILBOX=3Dy
>> CONFIG_MEGARAID_LEGACY=3Dy
>> CONFIG_MEGARAID_SAS=3Dy
>> CONFIG_SCSI_MPT2SAS=3Dy
>> CONFIG_SCSI_MPT2SAS_MAX_SGE=3D128
>> # CONFIG_SCSI_MPT2SAS_LOGGING is not set
>> # CONFIG_SCSI_UFSHCD is not set
>> # CONFIG_SCSI_HPTIOP is not set
>> # CONFIG_SCSI_BUSLOGIC is not set
>> # CONFIG_VMWARE_PVSCSI is not set
>> # CONFIG_LIBFC is not set
>> # CONFIG_LIBFCOE is not set
>> # CONFIG_FCOE is not set
>> # CONFIG_FCOE_FNIC is not set
>> # CONFIG_SCSI_DMX3191D is not set
>> # CONFIG_SCSI_EATA is not set
>> # CONFIG_SCSI_FUTURE_DOMAIN is not set
>> CONFIG_SCSI_GDTH=3Dy
>> CONFIG_SCSI_ISCI=3Dy
>> # CONFIG_SCSI_IPS is not set
>> # CONFIG_SCSI_INITIO is not set
>> # CONFIG_SCSI_INIA100 is not set
>> # CONFIG_SCSI_STEX is not set
>> # CONFIG_SCSI_SYM53C8XX_2 is not set
>> # CONFIG_SCSI_IPR is not set
>> CONFIG_SCSI_QLOGIC_1280=3Dy
>> CONFIG_SCSI_QLA_FC=3Dy
>> CONFIG_SCSI_QLA_ISCSI=3Dy
>> # CONFIG_SCSI_LPFC is not set
>> # CONFIG_SCSI_DC395x is not set
>> # CONFIG_SCSI_DC390T is not set
>> # CONFIG_SCSI_DEBUG is not set
>> # CONFIG_SCSI_PMCRAID is not set
>> # CONFIG_SCSI_PM8001 is not set
>> # CONFIG_SCSI_SRP is not set
>> # CONFIG_SCSI_BFA_FC is not set
>> # CONFIG_SCSI_VIRTIO is not set
>> # CONFIG_SCSI_DH is not set
>> # CONFIG_SCSI_OSD_INITIATOR is not set
>> CONFIG_ATA=3Dy
>> # CONFIG_ATA_NONSTANDARD is not set
>> CONFIG_ATA_VERBOSE_ERROR=3Dy
>> CONFIG_ATA_ACPI=3Dy
>> CONFIG_SATA_PMP=3Dy
>>
>> #
>> # Controllers with non-SFF native interface
>> #
>> CONFIG_SATA_AHCI=3Dy
>> # CONFIG_SATA_AHCI_PLATFORM is not set
>> # CONFIG_SATA_INIC162X is not set
>> # CONFIG_SATA_ACARD_AHCI is not set
>> # CONFIG_SATA_SIL24 is not set
>> CONFIG_ATA_SFF=3Dy
>>
>> #
>> # SFF controllers with custom DMA interface
>> #
>> # CONFIG_PDC_ADMA is not set
>> # CONFIG_SATA_QSTOR is not set
>> # CONFIG_SATA_SX4 is not set
>> CONFIG_ATA_BMDMA=3Dy
>>
>> #
>> # SATA SFF controllers with BMDMA
>> #
>> CONFIG_ATA_PIIX=3Dy
>> # CONFIG_SATA_MV is not set
>> # CONFIG_SATA_NV is not set
>> # CONFIG_SATA_PROMISE is not set
>> # CONFIG_SATA_SIL is not set
>> # CONFIG_SATA_SIS is not set
>> # CONFIG_SATA_SVW is not set
>> # CONFIG_SATA_ULI is not set
>> # CONFIG_SATA_VIA is not set
>> # CONFIG_SATA_VITESSE is not set
>>
>> #
>> # PATA SFF controllers with BMDMA
>> #
>> # CONFIG_PATA_ALI is not set
>> # CONFIG_PATA_AMD is not set
>> # CONFIG_PATA_ARASAN_CF is not set
>> # CONFIG_PATA_ARTOP is not set
>> # CONFIG_PATA_ATIIXP is not set
>> # CONFIG_PATA_ATP867X is not set
>> # CONFIG_PATA_CMD64X is not set
>> # CONFIG_PATA_CS5520 is not set
>> # CONFIG_PATA_CS5530 is not set
>> # CONFIG_PATA_CS5536 is not set
>> # CONFIG_PATA_CYPRESS is not set
>> # CONFIG_PATA_EFAR is not set
>> # CONFIG_PATA_HPT366 is not set
>> # CONFIG_PATA_HPT37X is not set
>> # CONFIG_PATA_HPT3X2N is not set
>> # CONFIG_PATA_HPT3X3 is not set
>> # CONFIG_PATA_IT8213 is not set
>> # CONFIG_PATA_IT821X is not set
>> # CONFIG_PATA_JMICRON is not set
>> # CONFIG_PATA_MARVELL is not set
>> # CONFIG_PATA_NETCELL is not set
>> # CONFIG_PATA_NINJA32 is not set
>> # CONFIG_PATA_NS87415 is not set
>> # CONFIG_PATA_OLDPIIX is not set
>> # CONFIG_PATA_OPTIDMA is not set
>> # CONFIG_PATA_PDC2027X is not set
>> # CONFIG_PATA_PDC_OLD is not set
>> # CONFIG_PATA_RADISYS is not set
>> # CONFIG_PATA_RDC is not set
>> # CONFIG_PATA_SC1200 is not set
>> # CONFIG_PATA_SCH is not set
>> # CONFIG_PATA_SERVERWORKS is not set
>> # CONFIG_PATA_SIL680 is not set
>> # CONFIG_PATA_SIS is not set
>> # CONFIG_PATA_TOSHIBA is not set
>> # CONFIG_PATA_TRIFLEX is not set
>> # CONFIG_PATA_VIA is not set
>> # CONFIG_PATA_WINBOND is not set
>>
>> #
>> # PIO-only SFF controllers
>> #
>> # CONFIG_PATA_CMD640_PCI is not set
>> # CONFIG_PATA_MPIIX is not set
>> # CONFIG_PATA_NS87410 is not set
>> # CONFIG_PATA_OPTI is not set
>> CONFIG_PATA_PLATFORM=3Dy
>> # CONFIG_PATA_RZ1000 is not set
>>
>> #
>> # Generic fallback / legacy drivers
>> #
>> # CONFIG_PATA_ACPI is not set
>> CONFIG_ATA_GENERIC=3Dy
>> # CONFIG_PATA_LEGACY is not set
>> CONFIG_MD=3Dy
>> CONFIG_BLK_DEV_MD=3Dy
>> CONFIG_MD_AUTODETECT=3Dy
>> CONFIG_MD_LINEAR=3Dy
>> CONFIG_MD_RAID0=3Dy
>> CONFIG_MD_RAID1=3Dy
>> CONFIG_MD_RAID10=3Dy
>> CONFIG_MD_RAID456=3Dy
>> CONFIG_MULTICORE_RAID456=3Dy
>> CONFIG_MD_MULTIPATH=3Dy
>> CONFIG_MD_FAULTY=3Dy
>> CONFIG_BLK_DEV_DM=3Dy
>> CONFIG_DM_DEBUG=3Dy
>> CONFIG_DM_CRYPT=3Dy
>> CONFIG_DM_SNAPSHOT=3Dy
>> # CONFIG_DM_THIN_PROVISIONING is not set
>> CONFIG_DM_MIRROR=3Dy
>> # CONFIG_DM_RAID is not set
>> CONFIG_DM_LOG_USERSPACE=3Dy
>> CONFIG_DM_ZERO=3Dy
>> CONFIG_DM_MULTIPATH=3Dy
>> CONFIG_DM_MULTIPATH_QL=3Dy
>> CONFIG_DM_MULTIPATH_ST=3Dy
>> CONFIG_DM_DELAY=3Dy
>> CONFIG_DM_UEVENT=3Dy
>> # CONFIG_DM_FLAKEY is not set
>> # CONFIG_DM_VERITY is not set
>> # CONFIG_TARGET_CORE is not set
>> CONFIG_FUSION=3Dy
>> CONFIG_FUSION_SPI=3Dy
>> CONFIG_FUSION_FC=3Dy
>> CONFIG_FUSION_SAS=3Dy
>> CONFIG_FUSION_MAX_SGE=3D128
>> CONFIG_FUSION_CTL=3Dy
>> CONFIG_FUSION_LOGGING=3Dy
>>
>> #
>> # IEEE 1394 (FireWire) support
>> #
>> # CONFIG_FIREWIRE is not set
>> # CONFIG_FIREWIRE_NOSY is not set
>> # CONFIG_I2O is not set
>> # CONFIG_MACINTOSH_DRIVERS is not set
>> CONFIG_NETDEVICES=3Dy
>> CONFIG_NET_CORE=3Dy
>> # CONFIG_BONDING is not set
>> CONFIG_DUMMY=3Dy
>> # CONFIG_EQUALIZER is not set
>> # CONFIG_NET_FC is not set
>> CONFIG_MII=3Dy
>> # CONFIG_NET_TEAM is not set
>> # CONFIG_MACVLAN is not set
>> CONFIG_NETCONSOLE=3Dy
>> CONFIG_NETCONSOLE_DYNAMIC=3Dy
>> CONFIG_NETPOLL=3Dy
>> # CONFIG_NETPOLL_TRAP is not set
>> CONFIG_NET_POLL_CONTROLLER=3Dy
>> CONFIG_TUN=3Dy
>> # CONFIG_VETH is not set
>> CONFIG_VIRTIO_NET=3Dy
>> # CONFIG_ARCNET is not set
>>
>> #
>> # CAIF transport drivers
>> #
>> CONFIG_ETHERNET=3Dy
>> CONFIG_MDIO=3Dy
>> # CONFIG_NET_VENDOR_3COM is not set
>> CONFIG_NET_VENDOR_ADAPTEC=3Dy
>> # CONFIG_ADAPTEC_STARFIRE is not set
>> CONFIG_NET_VENDOR_ALTEON=3Dy
>> # CONFIG_ACENIC is not set
>> CONFIG_NET_VENDOR_AMD=3Dy
>> # CONFIG_AMD8111_ETH is not set
>> # CONFIG_PCNET32 is not set
>> CONFIG_NET_VENDOR_ATHEROS=3Dy
>> CONFIG_ATL2=3Dy
>> CONFIG_ATL1=3Dy
>> CONFIG_ATL1E=3Dy
>> CONFIG_ATL1C=3Dy
>> CONFIG_NET_VENDOR_BROADCOM=3Dy
>> # CONFIG_B44 is not set
>> CONFIG_BNX2=3Dy
>> CONFIG_CNIC=3Dy
>> CONFIG_TIGON3=3Dy
>> # CONFIG_BNX2X is not set
>> CONFIG_NET_VENDOR_BROCADE=3Dy
>> # CONFIG_BNA is not set
>> # CONFIG_NET_CALXEDA_XGMAC is not set
>> CONFIG_NET_VENDOR_CHELSIO=3Dy
>> # CONFIG_CHELSIO_T1 is not set
>> # CONFIG_CHELSIO_T3 is not set
>> # CONFIG_CHELSIO_T4 is not set
>> # CONFIG_CHELSIO_T4VF is not set
>> CONFIG_NET_VENDOR_CISCO=3Dy
>> # CONFIG_ENIC is not set
>> # CONFIG_DNET is not set
>> CONFIG_NET_VENDOR_DEC=3Dy
>> CONFIG_NET_TULIP=3Dy
>> # CONFIG_DE2104X is not set
>> # CONFIG_TULIP is not set
>> # CONFIG_DE4X5 is not set
>> # CONFIG_WINBOND_840 is not set
>> # CONFIG_DM9102 is not set
>> # CONFIG_ULI526X is not set
>> CONFIG_NET_VENDOR_DLINK=3Dy
>> # CONFIG_DL2K is not set
>> # CONFIG_SUNDANCE is not set
>> CONFIG_NET_VENDOR_EMULEX=3Dy
>> # CONFIG_BE2NET is not set
>> CONFIG_NET_VENDOR_EXAR=3Dy
>> # CONFIG_S2IO is not set
>> # CONFIG_VXGE is not set
>> CONFIG_NET_VENDOR_HP=3Dy
>> # CONFIG_HP100 is not set
>> CONFIG_NET_VENDOR_INTEL=3Dy
>> CONFIG_E100=3Dy
>> CONFIG_E1000=3Dy
>> CONFIG_E1000E=3Dy
>> CONFIG_IGB=3Dy
>> CONFIG_IGB_DCA=3Dy
>> CONFIG_IGBVF=3Dy
>> CONFIG_IXGB=3Dy
>> CONFIG_IXGBE=3Dy
>> CONFIG_IXGBE_DCA=3Dy
>> # CONFIG_IXGBEVF is not set
>> CONFIG_NET_VENDOR_I825XX=3Dy
>> # CONFIG_ZNET is not set
>> CONFIG_IP1000=3Dy
>> CONFIG_JME=3Dy
>> CONFIG_NET_VENDOR_MARVELL=3Dy
>> CONFIG_SKGE=3Dy
>> # CONFIG_SKGE_DEBUG is not set
>> # CONFIG_SKGE_GENESIS is not set
>> CONFIG_SKY2=3Dy
>> # CONFIG_SKY2_DEBUG is not set
>> CONFIG_NET_VENDOR_MELLANOX=3Dy
>> # CONFIG_MLX4_EN is not set
>> # CONFIG_MLX4_CORE is not set
>> CONFIG_NET_VENDOR_MICREL=3Dy
>> # CONFIG_KS8842 is not set
>> # CONFIG_KS8851_MLL is not set
>> # CONFIG_KSZ884X_PCI is not set
>> CONFIG_NET_VENDOR_MYRI=3Dy
>> # CONFIG_MYRI10GE is not set
>> # CONFIG_FEALNX is not set
>> CONFIG_NET_VENDOR_NATSEMI=3Dy
>> # CONFIG_NATSEMI is not set
>> # CONFIG_NS83820 is not set
>> CONFIG_NET_VENDOR_8390=3Dy
>> # CONFIG_NE2K_PCI is not set
>> CONFIG_NET_VENDOR_NVIDIA=3Dy
>> # CONFIG_FORCEDETH is not set
>> CONFIG_NET_VENDOR_OKI=3Dy
>> CONFIG_PCH_GBE=3Dy
>> # CONFIG_ETHOC is not set
>> # CONFIG_NET_PACKET_ENGINE is not set
>> CONFIG_NET_VENDOR_QLOGIC=3Dy
>> # CONFIG_QLA3XXX is not set
>> # CONFIG_QLCNIC is not set
>> # CONFIG_QLGE is not set
>> # CONFIG_NETXEN_NIC is not set
>> CONFIG_NET_VENDOR_REALTEK=3Dy
>> CONFIG_8139CP=3Dy
>> CONFIG_8139TOO=3Dy
>> CONFIG_8139TOO_PIO=3Dy
>> # CONFIG_8139TOO_TUNE_TWISTER is not set
>> # CONFIG_8139TOO_8129 is not set
>> # CONFIG_8139_OLD_RX_RESET is not set
>> CONFIG_R8169=3Dy
>> CONFIG_NET_VENDOR_RDC=3Dy
>> # CONFIG_R6040 is not set
>> CONFIG_NET_VENDOR_SEEQ=3Dy
>> # CONFIG_SEEQ8005 is not set
>> CONFIG_NET_VENDOR_SILAN=3Dy
>> # CONFIG_SC92031 is not set
>> CONFIG_NET_VENDOR_SIS=3Dy
>> # CONFIG_SIS900 is not set
>> CONFIG_SIS190=3Dy
>> # CONFIG_SFC is not set
>> CONFIG_NET_VENDOR_SMSC=3Dy
>> # CONFIG_EPIC100 is not set
>> # CONFIG_SMSC9420 is not set
>> CONFIG_NET_VENDOR_STMICRO=3Dy
>> # CONFIG_STMMAC_ETH is not set
>> CONFIG_NET_VENDOR_SUN=3Dy
>> # CONFIG_HAPPYMEAL is not set
>> # CONFIG_SUNGEM is not set
>> # CONFIG_CASSINI is not set
>> # CONFIG_NIU is not set
>> CONFIG_NET_VENDOR_TEHUTI=3Dy
>> # CONFIG_TEHUTI is not set
>> CONFIG_NET_VENDOR_TI=3Dy
>> # CONFIG_TLAN is not set
>> CONFIG_NET_VENDOR_VIA=3Dy
>> # CONFIG_VIA_RHINE is not set
>> CONFIG_VIA_VELOCITY=3Dy
>> # CONFIG_FDDI is not set
>> # CONFIG_HIPPI is not set
>> # CONFIG_NET_SB1000 is not set
>> CONFIG_PHYLIB=3Dy
>>
>> #
>> # MII PHY device drivers
>> #
>> # CONFIG_AMD_PHY is not set
>> CONFIG_MARVELL_PHY=3Dy
>> CONFIG_DAVICOM_PHY=3Dy
>> CONFIG_QSEMI_PHY=3Dy
>> CONFIG_LXT_PHY=3Dy
>> CONFIG_CICADA_PHY=3Dy
>> CONFIG_VITESSE_PHY=3Dy
>> CONFIG_SMSC_PHY=3Dy
>> CONFIG_BROADCOM_PHY=3Dy
>> CONFIG_ICPLUS_PHY=3Dy
>> # CONFIG_REALTEK_PHY is not set
>> # CONFIG_NATIONAL_PHY is not set
>> # CONFIG_STE10XP is not set
>> # CONFIG_LSI_ET1011C_PHY is not set
>> # CONFIG_MICREL_PHY is not set
>> # CONFIG_FIXED_PHY is not set
>> # CONFIG_MDIO_BITBANG is not set
>> # CONFIG_PPP is not set
>> # CONFIG_SLIP is not set
>> # CONFIG_TR is not set
>>
>> #
>> # USB Network Adapters
>> #
>> CONFIG_USB_CATC=3Dy
>> CONFIG_USB_KAWETH=3Dy
>> CONFIG_USB_PEGASUS=3Dy
>> CONFIG_USB_RTL8150=3Dy
>> CONFIG_USB_USBNET=3Dy
>> CONFIG_USB_NET_AX8817X=3Dy
>> CONFIG_USB_NET_CDCETHER=3Dy
>> CONFIG_USB_NET_CDC_EEM=3Dy
>> CONFIG_USB_NET_CDC_NCM=3Dy
>> CONFIG_USB_NET_DM9601=3Dy
>> CONFIG_USB_NET_SMSC75XX=3Dy
>> CONFIG_USB_NET_SMSC95XX=3Dy
>> CONFIG_USB_NET_GL620A=3Dy
>> CONFIG_USB_NET_NET1080=3Dy
>> CONFIG_USB_NET_PLUSB=3Dy
>> CONFIG_USB_NET_MCS7830=3Dy
>> CONFIG_USB_NET_RNDIS_HOST=3Dy
>> CONFIG_USB_NET_CDC_SUBSET=3Dy
>> CONFIG_USB_ALI_M5632=3Dy
>> CONFIG_USB_AN2720=3Dy
>> CONFIG_USB_BELKIN=3Dy
>> CONFIG_USB_ARMLINUX=3Dy
>> CONFIG_USB_EPSON2888=3Dy
>> CONFIG_USB_KC2190=3Dy
>> CONFIG_USB_NET_ZAURUS=3Dy
>> # CONFIG_USB_NET_CX82310_ETH is not set
>> # CONFIG_USB_NET_KALMIA is not set
>> # CONFIG_USB_NET_QMI_WWAN is not set
>> CONFIG_USB_NET_INT51X1=3Dy
>> # CONFIG_USB_IPHETH is not set
>> # CONFIG_USB_SIERRA_NET is not set
>> # CONFIG_USB_VL600 is not set
>> # CONFIG_WLAN is not set
>>
>> #
>> # Enable WiMAX (Networking options) to see the WiMAX drivers
>> #
>> # CONFIG_WAN is not set
>> # CONFIG_VMXNET3 is not set
>> # CONFIG_ISDN is not set
>>
>> #
>> # Input device support
>> #
>> CONFIG_INPUT=3Dy
>> # CONFIG_INPUT_FF_MEMLESS is not set
>> CONFIG_INPUT_POLLDEV=3Dy
>> CONFIG_INPUT_SPARSEKMAP=3Dy
>>
>> #
>> # Userland interfaces
>> #
>> CONFIG_INPUT_MOUSEDEV=3Dy
>> CONFIG_INPUT_MOUSEDEV_PSAUX=3Dy
>> CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
>> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768
>> # CONFIG_INPUT_JOYDEV is not set
>> CONFIG_INPUT_EVDEV=3Dy
>> # CONFIG_INPUT_EVBUG is not set
>>
>> #
>> # Input Device Drivers
>> #
>> CONFIG_INPUT_KEYBOARD=3Dy
>> # CONFIG_KEYBOARD_ADP5588 is not set
>> # CONFIG_KEYBOARD_ADP5589 is not set
>> CONFIG_KEYBOARD_ATKBD=3Dy
>> # CONFIG_KEYBOARD_QT1070 is not set
>> # CONFIG_KEYBOARD_QT2160 is not set
>> # CONFIG_KEYBOARD_LKKBD is not set
>> # CONFIG_KEYBOARD_TCA6416 is not set
>> # CONFIG_KEYBOARD_TCA8418 is not set
>> # CONFIG_KEYBOARD_LM8323 is not set
>> # CONFIG_KEYBOARD_MAX7359 is not set
>> # CONFIG_KEYBOARD_MCS is not set
>> # CONFIG_KEYBOARD_MPR121 is not set
>> CONFIG_KEYBOARD_NEWTON=3Dy
>> # CONFIG_KEYBOARD_OPENCORES is not set
>> # CONFIG_KEYBOARD_STOWAWAY is not set
>> # CONFIG_KEYBOARD_SUNKBD is not set
>> # CONFIG_KEYBOARD_OMAP4 is not set
>> CONFIG_KEYBOARD_XTKBD=3Dy
>> CONFIG_INPUT_MOUSE=3Dy
>> CONFIG_MOUSE_PS2=3Dy
>> CONFIG_MOUSE_PS2_ALPS=3Dy
>> CONFIG_MOUSE_PS2_LOGIPS2PP=3Dy
>> CONFIG_MOUSE_PS2_SYNAPTICS=3Dy
>> CONFIG_MOUSE_PS2_LIFEBOOK=3Dy
>> CONFIG_MOUSE_PS2_TRACKPOINT=3Dy
>> # CONFIG_MOUSE_PS2_ELANTECH is not set
>> # CONFIG_MOUSE_PS2_SENTELIC is not set
>> # CONFIG_MOUSE_PS2_TOUCHKIT is not set
>> # CONFIG_MOUSE_SERIAL is not set
>> # CONFIG_MOUSE_APPLETOUCH is not set
>> # CONFIG_MOUSE_BCM5974 is not set
>> # CONFIG_MOUSE_VSXXXAA is not set
>> # CONFIG_MOUSE_SYNAPTICS_I2C is not set
>> # CONFIG_MOUSE_SYNAPTICS_USB is not set
>> # CONFIG_INPUT_JOYSTICK is not set
>> # CONFIG_INPUT_TABLET is not set
>> # CONFIG_INPUT_TOUCHSCREEN is not set
>> CONFIG_INPUT_MISC=3Dy
>> # CONFIG_INPUT_AD714X is not set
>> # CONFIG_INPUT_BMA150 is not set
>> # CONFIG_INPUT_PCSPKR is not set
>> # CONFIG_INPUT_MMA8450 is not set
>> # CONFIG_INPUT_MPU3050 is not set
>> # CONFIG_INPUT_APANEL is not set
>> # CONFIG_INPUT_ATLAS_BTNS is not set
>> # CONFIG_INPUT_ATI_REMOTE2 is not set
>> # CONFIG_INPUT_KEYSPAN_REMOTE is not set
>> # CONFIG_INPUT_KXTJ9 is not set
>> # CONFIG_INPUT_POWERMATE is not set
>> # CONFIG_INPUT_YEALINK is not set
>> # CONFIG_INPUT_CM109 is not set
>> CONFIG_INPUT_UINPUT=3Dy
>> # CONFIG_INPUT_PCF8574 is not set
>> # CONFIG_INPUT_ADXL34X is not set
>> # CONFIG_INPUT_CMA3000 is not set
>>
>> #
>> # Hardware I/O ports
>> #
>> CONFIG_SERIO=3Dy
>> CONFIG_SERIO_I8042=3Dy
>> # CONFIG_SERIO_SERPORT is not set
>> # CONFIG_SERIO_CT82C710 is not set
>> # CONFIG_SERIO_PCIPS2 is not set
>> CONFIG_SERIO_LIBPS2=3Dy
>> # CONFIG_SERIO_RAW is not set
>> # CONFIG_SERIO_ALTERA_PS2 is not set
>> # CONFIG_SERIO_PS2MULT is not set
>> # CONFIG_GAMEPORT is not set
>>
>> #
>> # Character devices
>> #
>> CONFIG_VT=3Dy
>> CONFIG_CONSOLE_TRANSLATIONS=3Dy
>> CONFIG_VT_CONSOLE=3Dy
>> CONFIG_VT_CONSOLE_SLEEP=3Dy
>> CONFIG_HW_CONSOLE=3Dy
>> CONFIG_VT_HW_CONSOLE_BINDING=3Dy
>> CONFIG_UNIX98_PTYS=3Dy
>> # CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
>> CONFIG_LEGACY_PTYS=3Dy
>> CONFIG_LEGACY_PTY_COUNT=3D256
>> # CONFIG_SERIAL_NONSTANDARD is not set
>> CONFIG_NOZOMI=3Dy
>> # CONFIG_N_GSM is not set
>> # CONFIG_TRACE_SINK is not set
>> CONFIG_DEVKMEM=3Dy
>>
>> #
>> # Serial drivers
>> #
>> CONFIG_SERIAL_8250=3Dy
>> CONFIG_SERIAL_8250_CONSOLE=3Dy
>> CONFIG_FIX_EARLYCON_MEM=3Dy
>> CONFIG_SERIAL_8250_PCI=3Dy
>> CONFIG_SERIAL_8250_PNP=3Dy
>> CONFIG_SERIAL_8250_NR_UARTS=3D16
>> CONFIG_SERIAL_8250_RUNTIME_UARTS=3D4
>> CONFIG_SERIAL_8250_EXTENDED=3Dy
>> CONFIG_SERIAL_8250_MANY_PORTS=3Dy
>> CONFIG_SERIAL_8250_SHARE_IRQ=3Dy
>> # CONFIG_SERIAL_8250_DETECT_IRQ is not set
>> CONFIG_SERIAL_8250_RSA=3Dy
>>
>> #
>> # Non-8250 serial port support
>> #
>> # CONFIG_SERIAL_MFD_HSU is not set
>> CONFIG_SERIAL_CORE=3Dy
>> CONFIG_SERIAL_CORE_CONSOLE=3Dy
>> # CONFIG_SERIAL_JSM is not set
>> # CONFIG_SERIAL_TIMBERDALE is not set
>> # CONFIG_SERIAL_ALTERA_JTAGUART is not set
>> # CONFIG_SERIAL_ALTERA_UART is not set
>> # CONFIG_SERIAL_PCH_UART is not set
>> # CONFIG_SERIAL_XILINX_PS_UART is not set
>> # CONFIG_TTY_PRINTK is not set
>> CONFIG_HVC_DRIVER=3Dy
>> CONFIG_VIRTIO_CONSOLE=3Dy
>> # CONFIG_IPMI_HANDLER is not set
>> CONFIG_HW_RANDOM=3Dy
>> # CONFIG_HW_RANDOM_TIMERIOMEM is not set
>> CONFIG_HW_RANDOM_INTEL=3Dy
>> # CONFIG_HW_RANDOM_AMD is not set
>> CONFIG_HW_RANDOM_VIA=3Dy
>> CONFIG_HW_RANDOM_VIRTIO=3Dy
>> CONFIG_NVRAM=3Dy
>> # CONFIG_R3964 is not set
>> # CONFIG_APPLICOM is not set
>> # CONFIG_MWAVE is not set
>> # CONFIG_RAW_DRIVER is not set
>> CONFIG_HPET=3Dy
>> CONFIG_HPET_MMAP=3Dy
>> CONFIG_HANGCHECK_TIMER=3Dy
>> # CONFIG_TCG_TPM is not set
>> # CONFIG_TELCLOCK is not set
>> CONFIG_DEVPORT=3Dy
>> # CONFIG_RAMOOPS is not set
>> CONFIG_I2C=3Dy
>> CONFIG_I2C_BOARDINFO=3Dy
>> CONFIG_I2C_COMPAT=3Dy
>> # CONFIG_I2C_CHARDEV is not set
>> # CONFIG_I2C_MUX is not set
>> CONFIG_I2C_HELPER_AUTO=3Dy
>> CONFIG_I2C_ALGOBIT=3Dy
>>
>> #
>> # I2C Hardware Bus support
>> #
>>
>> #
>> # PC SMBus host controller drivers
>> #
>> # CONFIG_I2C_ALI1535 is not set
>> # CONFIG_I2C_ALI1563 is not set
>> # CONFIG_I2C_ALI15X3 is not set
>> # CONFIG_I2C_AMD756 is not set
>> # CONFIG_I2C_AMD8111 is not set
>> # CONFIG_I2C_I801 is not set
>> # CONFIG_I2C_ISCH is not set
>> # CONFIG_I2C_PIIX4 is not set
>> # CONFIG_I2C_NFORCE2 is not set
>> # CONFIG_I2C_SIS5595 is not set
>> # CONFIG_I2C_SIS630 is not set
>> # CONFIG_I2C_SIS96X is not set
>> # CONFIG_I2C_VIA is not set
>> # CONFIG_I2C_VIAPRO is not set
>>
>> #
>> # ACPI drivers
>> #
>> # CONFIG_I2C_SCMI is not set
>>
>> #
>> # I2C system bus drivers (mostly embedded / system-on-chip)
>> #
>> # CONFIG_I2C_DESIGNWARE_PCI is not set
>> # CONFIG_I2C_EG20T is not set
>> # CONFIG_I2C_INTEL_MID is not set
>> # CONFIG_I2C_OCORES is not set
>> # CONFIG_I2C_PCA_PLATFORM is not set
>> # CONFIG_I2C_PXA_PCI is not set
>> # CONFIG_I2C_SIMTEC is not set
>> # CONFIG_I2C_XILINX is not set
>>
>> #
>> # External I2C/SMBus adapter drivers
>> #
>> # CONFIG_I2C_DIOLAN_U2C is not set
>> # CONFIG_I2C_PARPORT_LIGHT is not set
>> # CONFIG_I2C_TAOS_EVM is not set
>> # CONFIG_I2C_TINY_USB is not set
>>
>> #
>> # Other I2C/SMBus bus drivers
>> #
>> # CONFIG_I2C_STUB is not set
>> # CONFIG_I2C_DEBUG_CORE is not set
>> # CONFIG_I2C_DEBUG_ALGO is not set
>> # CONFIG_I2C_DEBUG_BUS is not set
>> # CONFIG_SPI is not set
>> # CONFIG_HSI is not set
>>
>> #
>> # PPS support
>> #
>> # CONFIG_PPS is not set
>>
>> #
>> # PPS generators support
>> #
>>
>> #
>> # PTP clock support
>> #
>>
>> #
>> # Enable Device Drivers -> PPS to see the PTP clock options.
>> #
>> CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=3Dy
>> # CONFIG_GPIOLIB is not set
>> # CONFIG_W1 is not set
>> CONFIG_POWER_SUPPLY=3Dy
>> # CONFIG_POWER_SUPPLY_DEBUG is not set
>> # CONFIG_PDA_POWER is not set
>> # CONFIG_TEST_POWER is not set
>> # CONFIG_BATTERY_DS2780 is not set
>> # CONFIG_BATTERY_DS2781 is not set
>> # CONFIG_BATTERY_DS2782 is not set
>> # CONFIG_BATTERY_SBS is not set
>> # CONFIG_BATTERY_BQ27x00 is not set
>> # CONFIG_BATTERY_MAX17040 is not set
>> # CONFIG_BATTERY_MAX17042 is not set
>> # CONFIG_CHARGER_MAX8903 is not set
>> # CONFIG_CHARGER_LP8727 is not set
>> # CONFIG_CHARGER_SMB347 is not set
>> CONFIG_HWMON=3Dy
>> # CONFIG_HWMON_VID is not set
>> # CONFIG_HWMON_DEBUG_CHIP is not set
>>
>> #
>> # Native drivers
>> #
>> # CONFIG_SENSORS_ABITUGURU is not set
>> # CONFIG_SENSORS_ABITUGURU3 is not set
>> # CONFIG_SENSORS_AD7414 is not set
>> # CONFIG_SENSORS_AD7418 is not set
>> # CONFIG_SENSORS_ADM1021 is not set
>> # CONFIG_SENSORS_ADM1025 is not set
>> # CONFIG_SENSORS_ADM1026 is not set
>> # CONFIG_SENSORS_ADM1029 is not set
>> # CONFIG_SENSORS_ADM1031 is not set
>> # CONFIG_SENSORS_ADM9240 is not set
>> # CONFIG_SENSORS_ADT7411 is not set
>> # CONFIG_SENSORS_ADT7462 is not set
>> # CONFIG_SENSORS_ADT7470 is not set
>> # CONFIG_SENSORS_ADT7475 is not set
>> # CONFIG_SENSORS_ASC7621 is not set
>> # CONFIG_SENSORS_K8TEMP is not set
>> # CONFIG_SENSORS_K10TEMP is not set
>> # CONFIG_SENSORS_FAM15H_POWER is not set
>> # CONFIG_SENSORS_ASB100 is not set
>> # CONFIG_SENSORS_ATXP1 is not set
>> # CONFIG_SENSORS_DS620 is not set
>> # CONFIG_SENSORS_DS1621 is not set
>> # CONFIG_SENSORS_I5K_AMB is not set
>> # CONFIG_SENSORS_F71805F is not set
>> # CONFIG_SENSORS_F71882FG is not set
>> # CONFIG_SENSORS_F75375S is not set
>> # CONFIG_SENSORS_FSCHMD is not set
>> # CONFIG_SENSORS_G760A is not set
>> # CONFIG_SENSORS_GL518SM is not set
>> # CONFIG_SENSORS_GL520SM is not set
>> # CONFIG_SENSORS_CORETEMP is not set
>> # CONFIG_SENSORS_IT87 is not set
>> # CONFIG_SENSORS_JC42 is not set
>> # CONFIG_SENSORS_LINEAGE is not set
>> # CONFIG_SENSORS_LM63 is not set
>> # CONFIG_SENSORS_LM73 is not set
>> # CONFIG_SENSORS_LM75 is not set
>> # CONFIG_SENSORS_LM77 is not set
>> # CONFIG_SENSORS_LM78 is not set
>> # CONFIG_SENSORS_LM80 is not set
>> # CONFIG_SENSORS_LM83 is not set
>> # CONFIG_SENSORS_LM85 is not set
>> # CONFIG_SENSORS_LM87 is not set
>> # CONFIG_SENSORS_LM90 is not set
>> # CONFIG_SENSORS_LM92 is not set
>> # CONFIG_SENSORS_LM93 is not set
>> # CONFIG_SENSORS_LTC4151 is not set
>> # CONFIG_SENSORS_LTC4215 is not set
>> # CONFIG_SENSORS_LTC4245 is not set
>> # CONFIG_SENSORS_LTC4261 is not set
>> # CONFIG_SENSORS_LM95241 is not set
>> # CONFIG_SENSORS_LM95245 is not set
>> # CONFIG_SENSORS_MAX16065 is not set
>> # CONFIG_SENSORS_MAX1619 is not set
>> # CONFIG_SENSORS_MAX1668 is not set
>> # CONFIG_SENSORS_MAX6639 is not set
>> # CONFIG_SENSORS_MAX6642 is not set
>> # CONFIG_SENSORS_MAX6650 is not set
>> # CONFIG_SENSORS_MCP3021 is not set
>> # CONFIG_SENSORS_NTC_THERMISTOR is not set
>> # CONFIG_SENSORS_PC87360 is not set
>> # CONFIG_SENSORS_PC87427 is not set
>> # CONFIG_SENSORS_PCF8591 is not set
>> # CONFIG_PMBUS is not set
>> # CONFIG_SENSORS_SHT21 is not set
>> # CONFIG_SENSORS_SIS5595 is not set
>> # CONFIG_SENSORS_SMM665 is not set
>> # CONFIG_SENSORS_DME1737 is not set
>> # CONFIG_SENSORS_EMC1403 is not set
>> # CONFIG_SENSORS_EMC2103 is not set
>> # CONFIG_SENSORS_EMC6W201 is not set
>> # CONFIG_SENSORS_SMSC47M1 is not set
>> # CONFIG_SENSORS_SMSC47M192 is not set
>> # CONFIG_SENSORS_SMSC47B397 is not set
>> # CONFIG_SENSORS_SCH56XX_COMMON is not set
>> # CONFIG_SENSORS_SCH5627 is not set
>> # CONFIG_SENSORS_SCH5636 is not set
>> # CONFIG_SENSORS_ADS1015 is not set
>> # CONFIG_SENSORS_ADS7828 is not set
>> # CONFIG_SENSORS_AMC6821 is not set
>> # CONFIG_SENSORS_THMC50 is not set
>> # CONFIG_SENSORS_TMP102 is not set
>> # CONFIG_SENSORS_TMP401 is not set
>> # CONFIG_SENSORS_TMP421 is not set
>> # CONFIG_SENSORS_VIA_CPUTEMP is not set
>> # CONFIG_SENSORS_VIA686A is not set
>> # CONFIG_SENSORS_VT1211 is not set
>> # CONFIG_SENSORS_VT8231 is not set
>> # CONFIG_SENSORS_W83781D is not set
>> # CONFIG_SENSORS_W83791D is not set
>> # CONFIG_SENSORS_W83792D is not set
>> # CONFIG_SENSORS_W83793 is not set
>> # CONFIG_SENSORS_W83795 is not set
>> # CONFIG_SENSORS_W83L785TS is not set
>> # CONFIG_SENSORS_W83L786NG is not set
>> # CONFIG_SENSORS_W83627HF is not set
>> # CONFIG_SENSORS_W83627EHF is not set
>> # CONFIG_SENSORS_APPLESMC is not set
>>
>> #
>> # ACPI drivers
>> #
>> # CONFIG_SENSORS_ACPI_POWER is not set
>> # CONFIG_SENSORS_ATK0110 is not set
>> CONFIG_THERMAL=3Dy
>> CONFIG_THERMAL_HWMON=3Dy
>> CONFIG_WATCHDOG=3Dy
>> CONFIG_WATCHDOG_CORE=3Dy
>> # CONFIG_WATCHDOG_NOWAYOUT is not set
>>
>> #
>> # Watchdog Device Drivers
>> #
>> CONFIG_SOFT_WATCHDOG=3Dy
>> # CONFIG_ACQUIRE_WDT is not set
>> # CONFIG_ADVANTECH_WDT is not set
>> # CONFIG_ALIM1535_WDT is not set
>> # CONFIG_ALIM7101_WDT is not set
>> # CONFIG_F71808E_WDT is not set
>> # CONFIG_SP5100_TCO is not set
>> # CONFIG_SC520_WDT is not set
>> # CONFIG_SBC_FITPC2_WATCHDOG is not set
>> # CONFIG_EUROTECH_WDT is not set
>> # CONFIG_IB700_WDT is not set
>> # CONFIG_IBMASR is not set
>> # CONFIG_WAFER_WDT is not set
>> # CONFIG_I6300ESB_WDT is not set
>> CONFIG_ITCO_WDT=3Dy
>> CONFIG_ITCO_VENDOR_SUPPORT=3Dy
>> # CONFIG_IT8712F_WDT is not set
>> # CONFIG_IT87_WDT is not set
>> # CONFIG_HP_WATCHDOG is not set
>> # CONFIG_SC1200_WDT is not set
>> # CONFIG_PC87413_WDT is not set
>> # CONFIG_NV_TCO is not set
>> # CONFIG_60XX_WDT is not set
>> # CONFIG_SBC8360_WDT is not set
>> # CONFIG_CPU5_WDT is not set
>> # CONFIG_SMSC_SCH311X_WDT is not set
>> # CONFIG_SMSC37B787_WDT is not set
>> # CONFIG_VIA_WDT is not set
>> # CONFIG_W83627HF_WDT is not set
>> # CONFIG_W83697HF_WDT is not set
>> # CONFIG_W83697UG_WDT is not set
>> # CONFIG_W83877F_WDT is not set
>> # CONFIG_W83977F_WDT is not set
>> # CONFIG_MACHZ_WDT is not set
>> # CONFIG_SBC_EPX_C3_WATCHDOG is not set
>>
>> #
>> # PCI-based Watchdog Cards
>> #
>> # CONFIG_PCIPCWATCHDOG is not set
>> # CONFIG_WDTPCI is not set
>>
>> #
>> # USB-based Watchdog Cards
>> #
>> # CONFIG_USBPCWATCHDOG is not set
>> CONFIG_SSB_POSSIBLE=3Dy
>>
>> #
>> # Sonics Silicon Backplane
>> #
>> CONFIG_SSB=3Dy
>> CONFIG_SSB_SPROM=3Dy
>> CONFIG_SSB_PCIHOST_POSSIBLE=3Dy
>> CONFIG_SSB_PCIHOST=3Dy
>> # CONFIG_SSB_B43_PCI_BRIDGE is not set
>> # CONFIG_SSB_SILENT is not set
>> # CONFIG_SSB_DEBUG is not set
>> CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=3Dy
>> CONFIG_SSB_DRIVER_PCICORE=3Dy
>> CONFIG_BCMA_POSSIBLE=3Dy
>>
>> #
>> # Broadcom specific AMBA
>> #
>> # CONFIG_BCMA is not set
>>
>> #
>> # Multifunction device drivers
>> #
>> # CONFIG_MFD_CORE is not set
>> # CONFIG_MFD_88PM860X is not set
>> # CONFIG_MFD_SM501 is not set
>> # CONFIG_HTC_PASIC3 is not set
>> # CONFIG_TPS6105X is not set
>> # CONFIG_TPS6507X is not set
>> # CONFIG_MFD_TPS65217 is not set
>> # CONFIG_TWL4030_CORE is not set
>> # CONFIG_TWL6040_CORE is not set
>> # CONFIG_MFD_STMPE is not set
>> # CONFIG_MFD_TC3589X is not set
>> # CONFIG_MFD_TMIO is not set
>> # CONFIG_PMIC_DA903X is not set
>> # CONFIG_MFD_DA9052_I2C is not set
>> # CONFIG_PMIC_ADP5520 is not set
>> # CONFIG_MFD_MAX8925 is not set
>> # CONFIG_MFD_MAX8997 is not set
>> # CONFIG_MFD_MAX8998 is not set
>> # CONFIG_MFD_S5M_CORE is not set
>> # CONFIG_MFD_WM8400 is not set
>> # CONFIG_MFD_WM831X_I2C is not set
>> # CONFIG_MFD_WM8350_I2C is not set
>> # CONFIG_MFD_WM8994 is not set
>> # CONFIG_MFD_PCF50633 is not set
>> # CONFIG_ABX500_CORE is not set
>> # CONFIG_MFD_CS5535 is not set
>> # CONFIG_LPC_SCH is not set
>> # CONFIG_MFD_RDC321X is not set
>> # CONFIG_MFD_JANZ_CMODIO is not set
>> # CONFIG_MFD_VX855 is not set
>> # CONFIG_MFD_WL1273_CORE is not set
>> # CONFIG_MFD_TPS65090 is not set
>> # CONFIG_MFD_RC5T583 is not set
>> # CONFIG_REGULATOR is not set
>> # CONFIG_MEDIA_SUPPORT is not set
>>
>> #
>> # Graphics support
>> #
>> CONFIG_AGP=3Dy
>> # CONFIG_AGP_AMD64 is not set
>> CONFIG_AGP_INTEL=3Dy
>> # CONFIG_AGP_SIS is not set
>> # CONFIG_AGP_VIA is not set
>> CONFIG_VGA_ARB=3Dy
>> CONFIG_VGA_ARB_MAX_GPUS=3D16
>> # CONFIG_VGA_SWITCHEROO is not set
>> CONFIG_DRM=3Dy
>> CONFIG_DRM_KMS_HELPER=3Dy
>> # CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
>> # CONFIG_DRM_TDFX is not set
>> # CONFIG_DRM_R128 is not set
>> # CONFIG_DRM_RADEON is not set
>> # CONFIG_DRM_NOUVEAU is not set
>>
>> #
>> # I2C encoder or helper chips
>> #
>> CONFIG_DRM_I2C_CH7006=3Dm
>> CONFIG_DRM_I2C_SIL164=3Dm
>> # CONFIG_DRM_I810 is not set
>> CONFIG_DRM_I915=3Dy
>> CONFIG_DRM_I915_KMS=3Dy
>> # CONFIG_DRM_MGA is not set
>> # CONFIG_DRM_SIS is not set
>> # CONFIG_DRM_VIA is not set
>> # CONFIG_DRM_SAVAGE is not set
>> # CONFIG_DRM_VMWGFX is not set
>> # CONFIG_DRM_GMA500 is not set
>> # CONFIG_DRM_UDL is not set
>> # CONFIG_STUB_POULSBO is not set
>> CONFIG_VGASTATE=3Dy
>> CONFIG_VIDEO_OUTPUT_CONTROL=3Dy
>> CONFIG_FB=3Dy
>> # CONFIG_FIRMWARE_EDID is not set
>> # CONFIG_FB_DDC is not set
>> CONFIG_FB_BOOT_VESA_SUPPORT=3Dy
>> CONFIG_FB_CFB_FILLRECT=3Dy
>> CONFIG_FB_CFB_COPYAREA=3Dy
>> CONFIG_FB_CFB_IMAGEBLIT=3Dy
>> # CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
>> # CONFIG_FB_SYS_FILLRECT is not set
>> # CONFIG_FB_SYS_COPYAREA is not set
>> # CONFIG_FB_SYS_IMAGEBLIT is not set
>> # CONFIG_FB_FOREIGN_ENDIAN is not set
>> # CONFIG_FB_SYS_FOPS is not set
>> # CONFIG_FB_WMT_GE_ROPS is not set
>> # CONFIG_FB_SVGALIB is not set
>> # CONFIG_FB_MACMODES is not set
>> CONFIG_FB_BACKLIGHT=3Dy
>> CONFIG_FB_MODE_HELPERS=3Dy
>> # CONFIG_FB_TILEBLITTING is not set
>>
>> #
>> # Frame buffer hardware drivers
>> #
>> # CONFIG_FB_CIRRUS is not set
>> # CONFIG_FB_PM2 is not set
>> # CONFIG_FB_CYBER2000 is not set
>> # CONFIG_FB_ARC is not set
>> # CONFIG_FB_ASILIANT is not set
>> # CONFIG_FB_IMSTT is not set
>> # CONFIG_FB_VGA16 is not set
>> # CONFIG_FB_UVESA is not set
>> CONFIG_FB_VESA=3Dy
>> # CONFIG_FB_EFI is not set
>> # CONFIG_FB_N411 is not set
>> # CONFIG_FB_HGA is not set
>> # CONFIG_FB_S1D13XXX is not set
>> CONFIG_FB_NVIDIA=3Dy
>> # CONFIG_FB_NVIDIA_I2C is not set
>> # CONFIG_FB_NVIDIA_DEBUG is not set
>> CONFIG_FB_NVIDIA_BACKLIGHT=3Dy
>> # CONFIG_FB_RIVA is not set
>> # CONFIG_FB_I740 is not set
>> # CONFIG_FB_LE80578 is not set
>> # CONFIG_FB_MATROX is not set
>> # CONFIG_FB_RADEON is not set
>> # CONFIG_FB_ATY128 is not set
>> # CONFIG_FB_ATY is not set
>> # CONFIG_FB_S3 is not set
>> # CONFIG_FB_SAVAGE is not set
>> # CONFIG_FB_SIS is not set
>> # CONFIG_FB_VIA is not set
>> # CONFIG_FB_NEOMAGIC is not set
>> # CONFIG_FB_KYRO is not set
>> # CONFIG_FB_3DFX is not set
>> # CONFIG_FB_VOODOO1 is not set
>> # CONFIG_FB_VT8623 is not set
>> # CONFIG_FB_TRIDENT is not set
>> # CONFIG_FB_ARK is not set
>> # CONFIG_FB_PM3 is not set
>> # CONFIG_FB_CARMINE is not set
>> # CONFIG_FB_GEODE is not set
>> # CONFIG_FB_SMSCUFX is not set
>> # CONFIG_FB_UDL is not set
>> # CONFIG_FB_VIRTUAL is not set
>> # CONFIG_FB_METRONOME is not set
>> # CONFIG_FB_MB862XX is not set
>> # CONFIG_FB_BROADSHEET is not set
>> # CONFIG_EXYNOS_VIDEO is not set
>> CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy
>> CONFIG_LCD_CLASS_DEVICE=3Dy
>> # CONFIG_LCD_PLATFORM is not set
>> CONFIG_BACKLIGHT_CLASS_DEVICE=3Dy
>> CONFIG_BACKLIGHT_GENERIC=3Dy
>> # CONFIG_BACKLIGHT_PROGEAR is not set
>> # CONFIG_BACKLIGHT_APPLE is not set
>> # CONFIG_BACKLIGHT_SAHARA is not set
>> # CONFIG_BACKLIGHT_ADP8860 is not set
>> # CONFIG_BACKLIGHT_ADP8870 is not set
>> # CONFIG_BACKLIGHT_LP855X is not set
>>
>> #
>> # Console display driver support
>> #
>> CONFIG_VGA_CONSOLE=3Dy
>> CONFIG_VGACON_SOFT_SCROLLBACK=3Dy
>> CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=3D1024
>> CONFIG_DUMMY_CONSOLE=3Dy
>> CONFIG_FRAMEBUFFER_CONSOLE=3Dy
>> CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=3Dy
>> # CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
>> # CONFIG_FONTS is not set
>> CONFIG_FONT_8x8=3Dy
>> CONFIG_FONT_8x16=3Dy
>> # CONFIG_LOGO is not set
>> CONFIG_SOUND=3Dy
>> # CONFIG_SOUND_OSS_CORE is not set
>> CONFIG_SND=3Dy
>> CONFIG_SND_TIMER=3Dy
>> CONFIG_SND_PCM=3Dy
>> CONFIG_SND_HWDEP=3Dy
>> CONFIG_SND_JACK=3Dy
>> CONFIG_SND_SEQUENCER=3Dy
>> CONFIG_SND_SEQ_DUMMY=3Dy
>> # CONFIG_SND_MIXER_OSS is not set
>> # CONFIG_SND_PCM_OSS is not set
>> # CONFIG_SND_SEQUENCER_OSS is not set
>> CONFIG_SND_HRTIMER=3Dy
>> CONFIG_SND_SEQ_HRTIMER_DEFAULT=3Dy
>> CONFIG_SND_DYNAMIC_MINORS=3Dy
>> # CONFIG_SND_SUPPORT_OLD_API is not set
>> CONFIG_SND_VERBOSE_PROCFS=3Dy
>> CONFIG_SND_VERBOSE_PRINTK=3Dy
>> CONFIG_SND_DEBUG=3Dy
>> CONFIG_SND_DEBUG_VERBOSE=3Dy
>> CONFIG_SND_PCM_XRUN_DEBUG=3Dy
>> CONFIG_SND_VMASTER=3Dy
>> CONFIG_SND_KCTL_JACK=3Dy
>> CONFIG_SND_DMA_SGBUF=3Dy
>> # CONFIG_SND_RAWMIDI_SEQ is not set
>> # CONFIG_SND_OPL3_LIB_SEQ is not set
>> # CONFIG_SND_OPL4_LIB_SEQ is not set
>> # CONFIG_SND_SBAWE_SEQ is not set
>> # CONFIG_SND_EMU10K1_SEQ is not set
>> CONFIG_SND_DRIVERS=3Dy
>> CONFIG_SND_PCSP=3Dm
>> # CONFIG_SND_DUMMY is not set
>> # CONFIG_SND_ALOOP is not set
>> # CONFIG_SND_VIRMIDI is not set
>> # CONFIG_SND_MTPAV is not set
>> # CONFIG_SND_SERIAL_U16550 is not set
>> # CONFIG_SND_MPU401 is not set
>> CONFIG_SND_PCI=3Dy
>> # CONFIG_SND_AD1889 is not set
>> # CONFIG_SND_ALS300 is not set
>> # CONFIG_SND_ALS4000 is not set
>> # CONFIG_SND_ALI5451 is not set
>> # CONFIG_SND_ASIHPI is not set
>> # CONFIG_SND_ATIIXP is not set
>> # CONFIG_SND_ATIIXP_MODEM is not set
>> # CONFIG_SND_AU8810 is not set
>> # CONFIG_SND_AU8820 is not set
>> # CONFIG_SND_AU8830 is not set
>> # CONFIG_SND_AW2 is not set
>> # CONFIG_SND_AZT3328 is not set
>> # CONFIG_SND_BT87X is not set
>> # CONFIG_SND_CA0106 is not set
>> # CONFIG_SND_CMIPCI is not set
>> # CONFIG_SND_OXYGEN is not set
>> # CONFIG_SND_CS4281 is not set
>> # CONFIG_SND_CS46XX is not set
>> # CONFIG_SND_CS5530 is not set
>> # CONFIG_SND_CS5535AUDIO is not set
>> # CONFIG_SND_CTXFI is not set
>> # CONFIG_SND_DARLA20 is not set
>> # CONFIG_SND_GINA20 is not set
>> # CONFIG_SND_LAYLA20 is not set
>> # CONFIG_SND_DARLA24 is not set
>> # CONFIG_SND_GINA24 is not set
>> # CONFIG_SND_LAYLA24 is not set
>> # CONFIG_SND_MONA is not set
>> # CONFIG_SND_MIA is not set
>> # CONFIG_SND_ECHO3G is not set
>> # CONFIG_SND_INDIGO is not set
>> # CONFIG_SND_INDIGOIO is not set
>> # CONFIG_SND_INDIGODJ is not set
>> # CONFIG_SND_INDIGOIOX is not set
>> # CONFIG_SND_INDIGODJX is not set
>> # CONFIG_SND_EMU10K1 is not set
>> # CONFIG_SND_EMU10K1X is not set
>> # CONFIG_SND_ENS1370 is not set
>> # CONFIG_SND_ENS1371 is not set
>> # CONFIG_SND_ES1938 is not set
>> # CONFIG_SND_ES1968 is not set
>> # CONFIG_SND_FM801 is not set
>> CONFIG_SND_HDA_INTEL=3Dy
>> CONFIG_SND_HDA_PREALLOC_SIZE=3D64
>> CONFIG_SND_HDA_HWDEP=3Dy
>> CONFIG_SND_HDA_RECONFIG=3Dy
>> CONFIG_SND_HDA_INPUT_BEEP=3Dy
>> CONFIG_SND_HDA_INPUT_BEEP_MODE=3D1
>> CONFIG_SND_HDA_INPUT_JACK=3Dy
>> CONFIG_SND_HDA_PATCH_LOADER=3Dy
>> CONFIG_SND_HDA_CODEC_REALTEK=3Dy
>> CONFIG_SND_HDA_ENABLE_REALTEK_QUIRKS=3Dy
>> CONFIG_SND_HDA_CODEC_ANALOG=3Dy
>> CONFIG_SND_HDA_CODEC_SIGMATEL=3Dy
>> CONFIG_SND_HDA_CODEC_VIA=3Dy
>> CONFIG_SND_HDA_CODEC_HDMI=3Dy
>> CONFIG_SND_HDA_CODEC_CIRRUS=3Dy
>> CONFIG_SND_HDA_CODEC_CONEXANT=3Dy
>> CONFIG_SND_HDA_CODEC_CA0110=3Dy
>> CONFIG_SND_HDA_CODEC_CA0132=3Dy
>> CONFIG_SND_HDA_CODEC_CMEDIA=3Dy
>> CONFIG_SND_HDA_CODEC_SI3054=3Dy
>> CONFIG_SND_HDA_GENERIC=3Dy
>> CONFIG_SND_HDA_POWER_SAVE=3Dy
>> CONFIG_SND_HDA_POWER_SAVE_DEFAULT=3D0
>> # CONFIG_SND_HDSP is not set
>> # CONFIG_SND_HDSPM is not set
>> # CONFIG_SND_ICE1712 is not set
>> # CONFIG_SND_ICE1724 is not set
>> # CONFIG_SND_INTEL8X0 is not set
>> # CONFIG_SND_INTEL8X0M is not set
>> # CONFIG_SND_KORG1212 is not set
>> # CONFIG_SND_LOLA is not set
>> # CONFIG_SND_LX6464ES is not set
>> # CONFIG_SND_MAESTRO3 is not set
>> # CONFIG_SND_MIXART is not set
>> # CONFIG_SND_NM256 is not set
>> # CONFIG_SND_PCXHR is not set
>> # CONFIG_SND_RIPTIDE is not set
>> # CONFIG_SND_RME32 is not set
>> # CONFIG_SND_RME96 is not set
>> # CONFIG_SND_RME9652 is not set
>> # CONFIG_SND_SONICVIBES is not set
>> # CONFIG_SND_TRIDENT is not set
>> # CONFIG_SND_VIA82XX is not set
>> # CONFIG_SND_VIA82XX_MODEM is not set
>> # CONFIG_SND_VIRTUOSO is not set
>> # CONFIG_SND_VX222 is not set
>> # CONFIG_SND_YMFPCI is not set
>> # CONFIG_SND_USB is not set
>> # CONFIG_SND_SOC is not set
>> # CONFIG_SOUND_PRIME is not set
>> CONFIG_HID_SUPPORT=3Dy
>> CONFIG_HID=3Dy
>> # CONFIG_HID_BATTERY_STRENGTH is not set
>> # CONFIG_HIDRAW is not set
>>
>> #
>> # USB Input Devices
>> #
>> CONFIG_USB_HID=3Dy
>> # CONFIG_HID_PID is not set
>> CONFIG_USB_HIDDEV=3Dy
>>
>> #
>> # Special HID drivers
>> #
>> # CONFIG_HID_A4TECH is not set
>> # CONFIG_HID_ACRUX is not set
>> # CONFIG_HID_APPLE is not set
>> # CONFIG_HID_BELKIN is not set
>> # CONFIG_HID_CHERRY is not set
>> # CONFIG_HID_CHICONY is not set
>> # CONFIG_HID_PRODIKEYS is not set
>> # CONFIG_HID_CYPRESS is not set
>> # CONFIG_HID_DRAGONRISE is not set
>> # CONFIG_HID_EMS_FF is not set
>> # CONFIG_HID_EZKEY is not set
>> # CONFIG_HID_HOLTEK is not set
>> # CONFIG_HID_KEYTOUCH is not set
>> # CONFIG_HID_KYE is not set
>> # CONFIG_HID_UCLOGIC is not set
>> # CONFIG_HID_WALTOP is not set
>> # CONFIG_HID_GYRATION is not set
>> # CONFIG_HID_TWINHAN is not set
>> # CONFIG_HID_KENSINGTON is not set
>> # CONFIG_HID_LCPOWER is not set
>> # CONFIG_HID_LOGITECH is not set
>> # CONFIG_HID_MICROSOFT is not set
>> # CONFIG_HID_MONTEREY is not set
>> # CONFIG_HID_MULTITOUCH is not set
>> # CONFIG_HID_NTRIG is not set
>> # CONFIG_HID_ORTEK is not set
>> # CONFIG_HID_PANTHERLORD is not set
>> # CONFIG_HID_PETALYNX is not set
>> # CONFIG_HID_PICOLCD is not set
>> # CONFIG_HID_PRIMAX is not set
>> # CONFIG_HID_ROCCAT is not set
>> # CONFIG_HID_SAITEK is not set
>> # CONFIG_HID_SAMSUNG is not set
>> # CONFIG_HID_SONY is not set
>> # CONFIG_HID_SPEEDLINK is not set
>> # CONFIG_HID_SUNPLUS is not set
>> # CONFIG_HID_GREENASIA is not set
>> # CONFIG_HID_SMARTJOYPLUS is not set
>> # CONFIG_HID_TIVO is not set
>> # CONFIG_HID_TOPSEED is not set
>> # CONFIG_HID_THRUSTMASTER is not set
>> # CONFIG_HID_ZEROPLUS is not set
>> # CONFIG_HID_ZYDACRON is not set
>> CONFIG_USB_ARCH_HAS_OHCI=3Dy
>> CONFIG_USB_ARCH_HAS_EHCI=3Dy
>> CONFIG_USB_ARCH_HAS_XHCI=3Dy
>> CONFIG_USB_SUPPORT=3Dy
>> CONFIG_USB_COMMON=3Dy
>> CONFIG_USB_ARCH_HAS_HCD=3Dy
>> CONFIG_USB=3Dy
>> CONFIG_USB_DEBUG=3Dy
>> CONFIG_USB_ANNOUNCE_NEW_DEVICES=3Dy
>>
>> #
>> # Miscellaneous USB options
>> #
>> CONFIG_USB_DEVICEFS=3Dy
>> # CONFIG_USB_DEVICE_CLASS is not set
>> CONFIG_USB_DYNAMIC_MINORS=3Dy
>> # CONFIG_USB_OTG_WHITELIST is not set
>> # CONFIG_USB_OTG_BLACKLIST_HUB is not set
>> # CONFIG_USB_MON is not set
>> # CONFIG_USB_WUSB_CBAF is not set
>>
>> #
>> # USB Host Controller Drivers
>> #
>> # CONFIG_USB_C67X00_HCD is not set
>> # CONFIG_USB_XHCI_HCD is not set
>> CONFIG_USB_EHCI_HCD=3Dy
>> CONFIG_USB_EHCI_ROOT_HUB_TT=3Dy
>> # CONFIG_USB_EHCI_TT_NEWSCHED is not set
>> # CONFIG_USB_OXU210HP_HCD is not set
>> # CONFIG_USB_ISP116X_HCD is not set
>> # CONFIG_USB_ISP1760_HCD is not set
>> # CONFIG_USB_ISP1362_HCD is not set
>> # CONFIG_USB_OHCI_HCD is not set
>> # CONFIG_USB_EHCI_HCD_PLATFORM is not set
>> CONFIG_USB_UHCI_HCD=3Dy
>> # CONFIG_USB_SL811_HCD is not set
>> # CONFIG_USB_R8A66597_HCD is not set
>>
>> #
>> # USB Device Class drivers
>> #
>> # CONFIG_USB_ACM is not set
>> # CONFIG_USB_PRINTER is not set
>> # CONFIG_USB_WDM is not set
>> # CONFIG_USB_TMC is not set
>>
>> #
>> # NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
>> #
>>
>> #
>> # also be needed; see USB_STORAGE Help for more info
>> #
>> CONFIG_USB_STORAGE=3Dy
>> # CONFIG_USB_STORAGE_DEBUG is not set
>> # CONFIG_USB_STORAGE_REALTEK is not set
>> CONFIG_USB_STORAGE_DATAFAB=3Dy
>> CONFIG_USB_STORAGE_FREECOM=3Dy
>> CONFIG_USB_STORAGE_ISD200=3Dy
>> CONFIG_USB_STORAGE_USBAT=3Dy
>> CONFIG_USB_STORAGE_SDDR09=3Dy
>> CONFIG_USB_STORAGE_SDDR55=3Dy
>> CONFIG_USB_STORAGE_JUMPSHOT=3Dy
>> CONFIG_USB_STORAGE_ALAUDA=3Dy
>> CONFIG_USB_STORAGE_ONETOUCH=3Dy
>> CONFIG_USB_STORAGE_KARMA=3Dy
>> CONFIG_USB_STORAGE_CYPRESS_ATACB=3Dy
>> # CONFIG_USB_STORAGE_ENE_UB6250 is not set
>> # CONFIG_USB_UAS is not set
>> CONFIG_USB_LIBUSUAL=3Dy
>>
>> #
>> # USB Imaging devices
>> #
>> # CONFIG_USB_MDC800 is not set
>> # CONFIG_USB_MICROTEK is not set
>>
>> #
>> # USB port drivers
>> #
>> CONFIG_USB_SERIAL=3Dy
>> CONFIG_USB_SERIAL_CONSOLE=3Dy
>> # CONFIG_USB_EZUSB is not set
>> CONFIG_USB_SERIAL_GENERIC=3Dy
>> # CONFIG_USB_SERIAL_AIRCABLE is not set
>> # CONFIG_USB_SERIAL_ARK3116 is not set
>> CONFIG_USB_SERIAL_BELKIN=3Dy
>> # CONFIG_USB_SERIAL_CH341 is not set
>> # CONFIG_USB_SERIAL_WHITEHEAT is not set
>> # CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
>> # CONFIG_USB_SERIAL_CP210X is not set
>> # CONFIG_USB_SERIAL_CYPRESS_M8 is not set
>> # CONFIG_USB_SERIAL_EMPEG is not set
>> # CONFIG_USB_SERIAL_FTDI_SIO is not set
>> # CONFIG_USB_SERIAL_FUNSOFT is not set
>> # CONFIG_USB_SERIAL_VISOR is not set
>> # CONFIG_USB_SERIAL_IPAQ is not set
>> # CONFIG_USB_SERIAL_IR is not set
>> # CONFIG_USB_SERIAL_EDGEPORT is not set
>> # CONFIG_USB_SERIAL_EDGEPORT_TI is not set
>> # CONFIG_USB_SERIAL_F81232 is not set
>> # CONFIG_USB_SERIAL_GARMIN is not set
>> # CONFIG_USB_SERIAL_IPW is not set
>> # CONFIG_USB_SERIAL_IUU is not set
>> # CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
>> # CONFIG_USB_SERIAL_KEYSPAN is not set
>> # CONFIG_USB_SERIAL_KLSI is not set
>> # CONFIG_USB_SERIAL_KOBIL_SCT is not set
>> CONFIG_USB_SERIAL_MCT_U232=3Dy
>> # CONFIG_USB_SERIAL_METRO is not set
>> # CONFIG_USB_SERIAL_MOS7720 is not set
>> # CONFIG_USB_SERIAL_MOS7840 is not set
>> # CONFIG_USB_SERIAL_MOTOROLA is not set
>> # CONFIG_USB_SERIAL_NAVMAN is not set
>> # CONFIG_USB_SERIAL_PL2303 is not set
>> # CONFIG_USB_SERIAL_OTI6858 is not set
>> # CONFIG_USB_SERIAL_QCAUX is not set
>> # CONFIG_USB_SERIAL_QUALCOMM is not set
>> # CONFIG_USB_SERIAL_SPCP8X5 is not set
>> # CONFIG_USB_SERIAL_HP4X is not set
>> # CONFIG_USB_SERIAL_SAFE is not set
>> # CONFIG_USB_SERIAL_SIEMENS_MPI is not set
>> # CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
>> # CONFIG_USB_SERIAL_SYMBOL is not set
>> # CONFIG_USB_SERIAL_TI is not set
>> # CONFIG_USB_SERIAL_CYBERJACK is not set
>> # CONFIG_USB_SERIAL_XIRCOM is not set
>> # CONFIG_USB_SERIAL_OPTION is not set
>> # CONFIG_USB_SERIAL_OMNINET is not set
>> # CONFIG_USB_SERIAL_OPTICON is not set
>> # CONFIG_USB_SERIAL_VIVOPAY_SERIAL is not set
>> # CONFIG_USB_SERIAL_ZIO is not set
>> # CONFIG_USB_SERIAL_SSU100 is not set
>> # CONFIG_USB_SERIAL_DEBUG is not set
>>
>> #
>> # USB Miscellaneous drivers
>> #
>> # CONFIG_USB_EMI62 is not set
>> # CONFIG_USB_EMI26 is not set
>> # CONFIG_USB_ADUTUX is not set
>> # CONFIG_USB_SEVSEG is not set
>> # CONFIG_USB_RIO500 is not set
>> # CONFIG_USB_LEGOTOWER is not set
>> # CONFIG_USB_LCD is not set
>> # CONFIG_USB_LED is not set
>> # CONFIG_USB_CYPRESS_CY7C63 is not set
>> # CONFIG_USB_CYTHERM is not set
>> # CONFIG_USB_IDMOUSE is not set
>> # CONFIG_USB_FTDI_ELAN is not set
>> # CONFIG_USB_APPLEDISPLAY is not set
>> # CONFIG_USB_SISUSBVGA is not set
>> # CONFIG_USB_LD is not set
>> # CONFIG_USB_TRANCEVIBRATOR is not set
>> # CONFIG_USB_IOWARRIOR is not set
>> # CONFIG_USB_TEST is not set
>> # CONFIG_USB_ISIGHTFW is not set
>> # CONFIG_USB_YUREX is not set
>> # CONFIG_USB_GADGET is not set
>>
>> #
>> # OTG and related infrastructure
>> #
>> # CONFIG_NOP_USB_XCEIV is not set
>> # CONFIG_UWB is not set
>> # CONFIG_MMC is not set
>> # CONFIG_MEMSTICK is not set
>> CONFIG_NEW_LEDS=3Dy
>> CONFIG_LEDS_CLASS=3Dy
>>
>> #
>> # LED drivers
>> #
>> # CONFIG_LEDS_LM3530 is not set
>> # CONFIG_LEDS_PCA9532 is not set
>> # CONFIG_LEDS_LP3944 is not set
>> # CONFIG_LEDS_LP5521 is not set
>> # CONFIG_LEDS_LP5523 is not set
>> # CONFIG_LEDS_CLEVO_MAIL is not set
>> # CONFIG_LEDS_PCA955X is not set
>> # CONFIG_LEDS_PCA9633 is not set
>> # CONFIG_LEDS_BD2802 is not set
>> # CONFIG_LEDS_INTEL_SS4200 is not set
>> # CONFIG_LEDS_DELL_NETBOOKS is not set
>> # CONFIG_LEDS_TCA6507 is not set
>> # CONFIG_LEDS_OT200 is not set
>> CONFIG_LEDS_TRIGGERS=3Dy
>>
>> #
>> # LED Triggers
>> #
>> # CONFIG_LEDS_TRIGGER_TIMER is not set
>> # CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
>> # CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
>> # CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set
>>
>> #
>> # iptables trigger is under Netfilter config (LED target)
>> #
>> # CONFIG_ACCESSIBILITY is not set
>> # CONFIG_INFINIBAND is not set
>> # CONFIG_EDAC is not set
>> CONFIG_RTC_LIB=3Dy
>> CONFIG_RTC_CLASS=3Dy
>> CONFIG_RTC_HCTOSYS=3Dy
>> CONFIG_RTC_HCTOSYS_DEVICE=3D"rtc0"
>> # CONFIG_RTC_DEBUG is not set
>>
>> #
>> # RTC interfaces
>> #
>> CONFIG_RTC_INTF_SYSFS=3Dy
>> CONFIG_RTC_INTF_PROC=3Dy
>> CONFIG_RTC_INTF_DEV=3Dy
>> # CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
>> # CONFIG_RTC_DRV_TEST is not set
>>
>> #
>> # I2C RTC drivers
>> #
>> # CONFIG_RTC_DRV_DS1307 is not set
>> # CONFIG_RTC_DRV_DS1374 is not set
>> # CONFIG_RTC_DRV_DS1672 is not set
>> # CONFIG_RTC_DRV_DS3232 is not set
>> # CONFIG_RTC_DRV_MAX6900 is not set
> ...
>
> [Message clipped]
