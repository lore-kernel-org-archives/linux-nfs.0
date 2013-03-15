Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.jansen-systems.de ([88.198.64.82]:53283 "EHLO
	mail.jansen-systems.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251Ab3CONA2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2013 09:00:28 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.jansen-systems.de (Postfix) with ESMTP id 1A70E3807D
	for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2013 14:00:24 +0100 (CET)
Received: from mail.jansen-systems.de ([127.0.0.1])
	by localhost (mail.jansen-systems.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id l1pWQGeALEAd for <linux-nfs@vger.kernel.org>;
	Fri, 15 Mar 2013 14:00:16 +0100 (CET)
Received: from [192.168.0.120] (dslb-084-062-093-099.pools.arcor-ip.net [84.62.93.99])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.jansen-systems.de (Postfix) with ESMTPSA
	for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2013 14:00:16 +0100 (CET)
Subject: NFSv4 blocking applications on NFS home
From: Matthias Jansen <mail@matthiasjansen.de>
To: linux-nfs@vger.kernel.org
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature"; boundary="=-iGBjNsqlNxvy6/FerUCr"
Date: Fri, 15 Mar 2013 14:00:15 +0100
Message-ID: <1363352415.4494.21.camel@workstation.home-lan>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-iGBjNsqlNxvy6/FerUCr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear all,

I already talked a little bit with Trond about my recent problems with
NFS. I just switched from NFSv3 to NFSv4 after a server update because
NFSv3 wasn't working correct any more (which seems to be fixed in the
meantime).

My kernel versions are:

Server: 3.8.2-gentoo
Workstation: 3.8.2-gentoo

After switching to NFSv4 (which I wanted for a longer time as it should
be faster etc.) at first I had some trouble with kernel oops on the
client. As Trond told me to get rid of the nvidia driver to have an oops
without taint I switched to nouveau and since then couldn't reproduce
the kernel oops. So it seems like it was nvidias fault or a combination
only triggered when the nvidia driver is loaded.

But even with the nouveau driver NFSv4 isn't working really good,
because I have lockups from time to time (randomly it seems) where most
of the programs become unresponsive (as my home-dir is a NFS share).

I checked with Magic SysRq + w and got the following examples:

Mar 15 10:16:17 workstation kernel: [ 7188.311533] SysRq : Show Blocked
State
Mar 15 10:16:17 workstation kernel: [ 7188.313476]   task
PC stack   pid father
Mar 15 10:16:17 workstation kernel: [ 7188.313520] mozStorage #4   D
ffff88041c7ddbc8     0  4349      1 0x00000000
Mar 15 10:16:17 workstation kernel: [ 7188.313525]  ffff88041c7dd910
0000000000000086 ffff88041d0b4d30 ffff8803f92e9fd8
Mar 15 10:16:17 workstation kernel: [ 7188.313529]  0000000000011200
0000000000004000 ffff88040d205234 ffff88042f44d040
Mar 15 10:16:17 workstation kernel: [ 7188.313533]  ffff88041c808140
ffff88041c96fa80 0000000000000000 0000000000000001
Mar 15 10:16:17 workstation kernel: [ 7188.313536] Call Trace:
Mar 15 10:16:17 workstation kernel: [ 7188.313546]
[<ffffffff81067b5b>] ? __queue_work+0x242/0x267
Mar 15 10:16:17 workstation kernel: [ 7188.313552]
[<ffffffff8147a9f1>] ? rpc_execute+0xe/0x22
Mar 15 10:16:17 workstation kernel: [ 7188.313557]
[<ffffffff814758d1>] ? rpc_run_task+0x6e/0x76
Mar 15 10:16:17 workstation kernel: [ 7188.313561]
[<ffffffff810a438e>] ? __lock_page+0x66/0x66
Mar 15 10:16:17 workstation kernel: [ 7188.313566]
[<ffffffff814a3482>] ? io_schedule+0x84/0xbf
Mar 15 10:16:17 workstation kernel: [ 7188.313569]
[<ffffffff810a4394>] ? sleep_on_page+0x6/0xa
Mar 15 10:16:17 workstation kernel: [ 7188.313572]
[<ffffffff814a1d19>] ? __wait_on_bit+0x3e/0x71
Mar 15 10:16:17 workstation kernel: [ 7188.313577]
[<ffffffff81077070>] ? set_next_entity+0x32/0x4e
Mar 15 10:16:17 workstation kernel: [ 7188.313581]
[<ffffffff810a4570>] ? wait_on_page_bit+0x6e/0x73
Mar 15 10:16:17 workstation kernel: [ 7188.313585]
[<ffffffff8106c6f6>] ? autoremove_wake_function+0x2a/0x2a
Mar 15 10:16:17 workstation kernel: [ 7188.313589]
[<ffffffff810a4df6>] ? grab_cache_page_write_begin+0xbd/0xcf
Mar 15 10:16:17 workstation kernel: [ 7188.313593]
[<ffffffff811b220c>] ? nfs_write_begin+0x86/0x1bb
Mar 15 10:16:17 workstation kernel: [ 7188.313597]
[<ffffffff810a4883>] ? generic_file_buffered_write+0x116/0x276
Mar 15 10:16:17 workstation kernel: [ 7188.313602]
[<ffffffff810a555c>] ? __generic_file_aio_write+0x2aa/0x2da
Mar 15 10:16:17 workstation kernel: [ 7188.313606]
[<ffffffff810d6067>] ? __sb_start_write+0xb5/0xe7
Mar 15 10:16:17 workstation kernel: [ 7188.313610]
[<ffffffff810a55f6>] ? generic_file_aio_write+0x6a/0xcf
Mar 15 10:16:17 workstation kernel: [ 7188.313614]
[<ffffffff811b286e>] ? nfs_file_write+0xa9/0x120
Mar 15 10:16:17 workstation kernel: [ 7188.313617]
[<ffffffff810d456d>] ? do_sync_write+0x83/0xbb
Mar 15 10:16:17 workstation kernel: [ 7188.313621]
[<ffffffff810d4a78>] ? vfs_write+0xa6/0x112
Mar 15 10:16:17 workstation kernel: [ 7188.313624]
[<ffffffff810d4caf>] ? sys_write+0x4b/0x73
Mar 15 10:16:17 workstation kernel: [ 7188.313628]
[<ffffffff814a4a12>] ? system_call_fastpath+0x16/0x1b
Mar 15 10:16:17 workstation kernel: [ 7188.313635] javaws          D
ffff88041c902068     0  5692   5691 0x00000006
Mar 15 10:16:17 workstation kernel: [ 7188.313638]  ffff88041c901db0
0000000000000086 ffff88041d0b5f00 ffff8803f2c2dfd8
Mar 15 10:16:17 workstation kernel: [ 7188.313642]  0000000000011200
0000000000004000 ffff8803f2c2da50 ffffffff810a4101
Mar 15 10:16:17 workstation kernel: [ 7188.313645]  ffffffff8110a4a2
ffff8803ed141a60 0007ffffffffffff 0000000000000000
Mar 15 10:16:17 workstation kernel: [ 7188.313649] Call Trace:
Mar 15 10:16:17 workstation kernel: [ 7188.313652]
[<ffffffff810a4101>] ? find_get_pages_tag+0x10b/0x13b
Mar 15 10:16:17 workstation kernel: [ 7188.313657]
[<ffffffff8110a4a2>] ? locks_remove_posix+0xa1/0xa9
Mar 15 10:16:17 workstation kernel: [ 7188.313661]
[<ffffffff810ac764>] ? pagevec_lookup_tag+0x18/0x1f
Mar 15 10:16:17 workstation kernel: [ 7188.313664]
[<ffffffff810aabae>] ? write_cache_pages+0x131/0x2d4
Mar 15 10:16:17 workstation kernel: [ 7188.313667]
[<ffffffff810a438e>] ? __lock_page+0x66/0x66
Mar 15 10:16:17 workstation kernel: [ 7188.313670]
[<ffffffff814a3482>] ? io_schedule+0x84/0xbf
Mar 15 10:16:17 workstation kernel: [ 7188.313674]
[<ffffffff810a4394>] ? sleep_on_page+0x6/0xa
Mar 15 10:16:17 workstation kernel: [ 7188.313676]
[<ffffffff814a1d19>] ? __wait_on_bit+0x3e/0x71
Mar 15 10:16:17 workstation kernel: [ 7188.313680]
[<ffffffff810a4101>] ? find_get_pages_tag+0x10b/0x13b
Mar 15 10:16:17 workstation kernel: [ 7188.313683]
[<ffffffff810a4570>] ? wait_on_page_bit+0x6e/0x73
Mar 15 10:16:17 workstation kernel: [ 7188.313687]
[<ffffffff8106c6f6>] ? autoremove_wake_function+0x2a/0x2a
Mar 15 10:16:17 workstation kernel: [ 7188.313690]
[<ffffffff810a4620>] ? filemap_fdatawait_range+0x73/0x121
Mar 15 10:16:17 workstation kernel: [ 7188.313695]
[<ffffffff810a5159>] ? filemap_write_and_wait_range+0x3b/0x4e
Mar 15 10:16:17 workstation kernel: [ 7188.313699]
[<ffffffff811cf02c>] ? nfs4_file_fsync+0x48/0x96
Mar 15 10:16:17 workstation kernel: [ 7188.313702]
[<ffffffff810d3515>] ? filp_close+0x3b/0x6a
Mar 15 10:16:17 workstation kernel: [ 7188.313707]
[<ffffffff810ea3a4>] ? do_close_on_exec+0xa7/0xd9
Mar 15 10:16:17 workstation kernel: [ 7188.313712]
[<ffffffff8110f8b4>] ? load_elf_binary+0x315/0x170b
Mar 15 10:16:17 workstation kernel: [ 7188.313717]
[<ffffffff810d8919>] ? search_binary_handler+0xba/0x26b
Mar 15 10:16:17 workstation kernel: [ 7188.313720]
[<ffffffff8110f59f>] ? load_elf_library+0x1ae/0x1ae
Mar 15 10:16:17 workstation kernel: [ 7188.313724]
[<ffffffff8110f296>] ? load_script+0x1aa/0x1b4
Mar 15 10:16:17 workstation kernel: [ 7188.313728]
[<ffffffff810d91a2>] ? get_arg_page+0x79/0xbe
Mar 15 10:16:17 workstation kernel: [ 7188.313732]
[<ffffffff810d8919>] ? search_binary_handler+0xba/0x26b
Mar 15 10:16:17 workstation kernel: [ 7188.313736]
[<ffffffff8110f0ec>] ? bm_status_write+0xd0/0xd0
Mar 15 10:16:17 workstation kernel: [ 7188.313741]
[<ffffffff810da39e>] ? do_execve_common.isra.32+0x2dd/0x3ee
Mar 15 10:16:17 workstation kernel: [ 7188.313745]
[<ffffffff810da6d1>] ? sys_execve+0x32/0x46
Mar 15 10:16:17 workstation kernel: [ 7188.313749]
[<ffffffff814a4ec9>] ? stub_execve+0x69/0xc0




Or the other day:
Mar 14 21:00:47 workstation kernel: [37645.540769] SysRq : Show Blocked
State
Mar 14 21:00:47 workstation kernel: [37645.541946]   task
PC stack   pid father
Mar 14 21:00:47 workstation kernel: [37645.541984] emerald         D
ffff88041c051a78     0  4208   4207 0x00000000
Mar 14 21:00:47 workstation kernel: [37645.541989]  ffff88041c0517c0
0000000000000086 ffff88041d0b4150 ffff8803f797dfd8
Mar 14 21:00:47 workstation kernel: [37645.541993]  0000000000011200
0000000000004000 ffff8803580901d8 ffff88042f7e06e8
Mar 14 21:00:47 workstation kernel: [37645.541997]  0000000000000000
000022f400004040 0000000000000000 ffff8803f797dbe8
Mar 14 21:00:47 workstation kernel: [37645.542000] Call Trace:
Mar 14 21:00:47 workstation kernel: [37645.542010]
[<ffffffff813d8a8f>] ? sock_sendmsg+0x89/0xa4
Mar 14 21:00:47 workstation kernel: [37645.542016]
[<ffffffff811b3213>] ? nfs_clear_inode+0x71/0x71
Mar 14 21:00:47 workstation kernel: [37645.542019]
[<ffffffff811b326a>] ? nfs_wait_bit_killable+0x57/0x6f
Mar 14 21:00:47 workstation kernel: [37645.542023]
[<ffffffff814a1d19>] ? __wait_on_bit+0x3e/0x71
Mar 14 21:00:47 workstation kernel: [37645.542028]
[<ffffffff8122d708>] ? _kstrtoull+0x2b/0x64
Mar 14 21:00:47 workstation kernel: [37645.542031]
[<ffffffff814a1dbb>] ? out_of_line_wait_on_bit+0x6f/0x78
Mar 14 21:00:47 workstation kernel: [37645.542034]
[<ffffffff811b3213>] ? nfs_clear_inode+0x71/0x71
Mar 14 21:00:47 workstation kernel: [37645.542039]
[<ffffffff8106c6f6>] ? autoremove_wake_function+0x2a/0x2a
Mar 14 21:00:47 workstation kernel: [37645.542043]
[<ffffffff811ce7a0>] ? nfs4_wait_clnt_recover+0x29/0x39
Mar 14 21:00:47 workstation kernel: [37645.542046]
[<ffffffff811ce7c3>] ? nfs4_client_recover_expired_lease+0x13/0x44
Mar 14 21:00:47 workstation kernel: [37645.542051]
[<ffffffff811c6295>] ? _nfs4_do_open+0x50/0x376
Mar 14 21:00:47 workstation kernel: [37645.542055]
[<ffffffff811c7eef>] ? verify_attr_len+0xc/0x27
Mar 14 21:00:47 workstation kernel: [37645.542060]
[<ffffffff8147b285>] ? rpcauth_lookup_credcache+0xbf/0x1ff
Mar 14 21:00:47 workstation kernel: [37645.542063]
[<ffffffff811cf4e1>] ? nfs4_have_delegation+0x33/0x39
Mar 14 21:00:47 workstation kernel: [37645.542067]
[<ffffffff811c661b>] ? nfs4_do_open+0x60/0xfe
Mar 14 21:00:47 workstation kernel: [37645.542070]
[<ffffffff811cf4e1>] ? nfs4_have_delegation+0x33/0x39
Mar 14 21:00:47 workstation kernel: [37645.542074]
[<ffffffff811c66e0>] ? nfs4_atomic_open+0x27/0x47
Mar 14 21:00:47 workstation kernel: [37645.542077]
[<ffffffff811b0a3b>] ? nfs_atomic_open+0x116/0x291
Mar 14 21:00:47 workstation kernel: [37645.542082]
[<ffffffff810df865>] ? do_last.isra.46+0x373/0x9c2
Mar 14 21:00:47 workstation kernel: [37645.542085]
[<ffffffff810dd1f1>] ? link_path_walk+0x76/0x78f
Mar 14 21:00:47 workstation kernel: [37645.542089]
[<ffffffff810dff67>] ? path_openat.isra.47+0xb3/0x3de
Mar 14 21:00:47 workstation kernel: [37645.542093]
[<ffffffff810e051a>] ? do_filp_open+0x2a/0x6e
Mar 14 21:00:47 workstation kernel: [37645.542097]
[<ffffffff810ea1ca>] ? __alloc_fd+0xe2/0xf5
Mar 14 21:00:47 workstation kernel: [37645.542101]
[<ffffffff810d435e>] ? do_sys_open+0x103/0x18a
Mar 14 21:00:47 workstation kernel: [37645.542105]
[<ffffffff814a4a12>] ? system_call_fastpath+0x16/0x1b
Mar 14 21:00:47 workstation kernel: [37645.542108] firefox         D
ffff88041c055bc8     0  4229      1 0x00000000
Mar 14 21:00:47 workstation kernel: [37645.542111]  ffff88041c055910
0000000000000082 ffff88041c09af80 ffff8803f53fffd8
Mar 14 21:00:47 workstation kernel: [37645.542115]  0000000000011200
0000000000004000 ffff8802d7eed3c0 ffff88041c85da80
Mar 14 21:00:47 workstation kernel: [37645.542118]  0000000000000000
ffff8802d7eed2a0 ffff8803fcb25b88 ffffffff81067b5b
Mar 14 21:00:47 workstation kernel: [37645.542122] Call Trace:
Mar 14 21:00:47 workstation kernel: [37645.542126]
[<ffffffff81067b5b>] ? __queue_work+0x242/0x267
Mar 14 21:00:47 workstation kernel: [37645.542130]
[<ffffffff8147a9f1>] ? rpc_execute+0xe/0x22
Mar 14 21:00:47 workstation kernel: [37645.542135]
[<ffffffff814758d1>] ? rpc_run_task+0x6e/0x76
Mar 14 21:00:47 workstation kernel: [37645.542139]
[<ffffffff810a438e>] ? __lock_page+0x66/0x66
Mar 14 21:00:47 workstation kernel: [37645.542143]
[<ffffffff814a3482>] ? io_schedule+0x84/0xbf
Mar 14 21:00:47 workstation kernel: [37645.542146]
[<ffffffff810a4394>] ? sleep_on_page+0x6/0xa
Mar 14 21:00:47 workstation kernel: [37645.542149]
[<ffffffff814a1d19>] ? __wait_on_bit+0x3e/0x71
Mar 14 21:00:47 workstation kernel: [37645.542152]
[<ffffffff810a4101>] ? find_get_pages_tag+0x10b/0x13b
Mar 14 21:00:47 workstation kernel: [37645.542156]
[<ffffffff810a4570>] ? wait_on_page_bit+0x6e/0x73
Mar 14 21:00:47 workstation kernel: [37645.542159]
[<ffffffff8106c6f6>] ? autoremove_wake_function+0x2a/0x2a
Mar 14 21:00:47 workstation kernel: [37645.542163]
[<ffffffff810a4620>] ? filemap_fdatawait_range+0x73/0x121
Mar 14 21:00:47 workstation kernel: [37645.542168]
[<ffffffff810a5159>] ? filemap_write_and_wait_range+0x3b/0x4e
Mar 14 21:00:47 workstation kernel: [37645.542171]
[<ffffffff811cf02c>] ? nfs4_file_fsync+0x48/0x96
Mar 14 21:00:47 workstation kernel: [37645.542174]
[<ffffffff810d4ad8>] ? vfs_write+0x106/0x112
Mar 14 21:00:47 workstation kernel: [37645.542178]
[<ffffffff810d3515>] ? filp_close+0x3b/0x6a
Mar 14 21:00:47 workstation kernel: [37645.542181]
[<ffffffff810d30f2>] ? sys_close+0x18/0x42
Mar 14 21:00:47 workstation kernel: [37645.542184]
[<ffffffff814a4a12>] ? system_call_fastpath+0x16/0x1b
Mar 14 21:00:47 workstation kernel: [37645.542190] pool            D
ffff88040d8a3238     0 12641   3957 0x00000000
Mar 14 21:00:47 workstation kernel: [37645.542193]  ffff88040d8a2f80
0000000000000086 ffffffff81681400 ffff8803f7bd5fd8
Mar 14 21:00:47 workstation kernel: [37645.542196]  0000000000011200
0000000000004000 0000000000000000 ffffffff811c7ce3
Mar 14 21:00:47 workstation kernel: [37645.542200]  ffff880325497400
ffffffff811c8a82 ffff88040d8a2f80 ffff88041d281df8
Mar 14 21:00:47 workstation kernel: [37645.542203] Call Trace:
Mar 14 21:00:47 workstation kernel: [37645.542207]
[<ffffffff811c7ce3>] ? decode_attr_time+0xe/0x33
Mar 14 21:00:47 workstation kernel: [37645.542211]
[<ffffffff811c8a82>] ? decode_getfattr_attrs+0x73f/0xa7f
Mar 14 21:00:47 workstation kernel: [37645.542215]
[<ffffffff814826fc>] ? xdr_inline_decode+0x31/0x95
Mar 14 21:00:47 workstation kernel: [37645.542219]
[<ffffffff811c7eef>] ? verify_attr_len+0xc/0x27
Mar 14 21:00:47 workstation kernel: [37645.542222]
[<ffffffff811cbecb>] ? decode_getfattr_generic.constprop.63+0x88/0x93
Mar 14 21:00:47 workstation kernel: [37645.542226]
[<ffffffff811b3213>] ? nfs_clear_inode+0x71/0x71
Mar 14 21:00:47 workstation kernel: [37645.542229]
[<ffffffff811b326a>] ? nfs_wait_bit_killable+0x57/0x6f
Mar 14 21:00:47 workstation kernel: [37645.542232]
[<ffffffff814a1d19>] ? __wait_on_bit+0x3e/0x71
Mar 14 21:00:47 workstation kernel: [37645.542235]
[<ffffffff814a1dbb>] ? out_of_line_wait_on_bit+0x6f/0x78
Mar 14 21:00:47 workstation kernel: [37645.542238]
[<ffffffff811b3213>] ? nfs_clear_inode+0x71/0x71
Mar 14 21:00:47 workstation kernel: [37645.542242]
[<ffffffff8106c6f6>] ? autoremove_wake_function+0x2a/0x2a
Mar 14 21:00:47 workstation kernel: [37645.542245]
[<ffffffff811ce7a0>] ? nfs4_wait_clnt_recover+0x29/0x39
Mar 14 21:00:47 workstation kernel: [37645.542248]
[<ffffffff811ce7c3>] ? nfs4_client_recover_expired_lease+0x13/0x44
Mar 14 21:00:47 workstation kernel: [37645.542252]
[<ffffffff811c6295>] ? _nfs4_do_open+0x50/0x376
Mar 14 21:00:47 workstation kernel: [37645.542256]
[<ffffffff811b3cde>] ? nfs_refresh_inode_locked+0x5a6/0x78f
Mar 14 21:00:47 workstation kernel: [37645.542260]
[<ffffffff811c661b>] ? nfs4_do_open+0x60/0xfe
Mar 14 21:00:47 workstation kernel: [37645.542263]
[<ffffffff811c66e0>] ? nfs4_atomic_open+0x27/0x47
Mar 14 21:00:47 workstation kernel: [37645.542267]
[<ffffffff811cf135>] ? nfs4_file_open+0xbb/0x13e
Mar 14 21:00:47 workstation kernel: [37645.542270]
[<ffffffff811b0093>] ? nfs_do_access+0x1f0/0x22d
Mar 14 21:00:47 workstation kernel: [37645.542273]
[<ffffffff811cf07a>] ? nfs4_file_fsync+0x96/0x96
Mar 14 21:00:47 workstation kernel: [37645.542276]
[<ffffffff810d33ae>] ? do_dentry_open+0x17a/0x222
Mar 14 21:00:47 workstation kernel: [37645.542280]
[<ffffffff810d356e>] ? finish_open+0x2a/0x33
Mar 14 21:00:47 workstation kernel: [37645.542283]
[<ffffffff810dfd1a>] ? do_last.isra.46+0x828/0x9c2
Mar 14 21:00:47 workstation kernel: [37645.542286]
[<ffffffff810dd1f1>] ? link_path_walk+0x76/0x78f
Mar 14 21:00:47 workstation kernel: [37645.542290]
[<ffffffff810dff67>] ? path_openat.isra.47+0xb3/0x3de
Mar 14 21:00:47 workstation kernel: [37645.542294]
[<ffffffff810bf30b>] ? unmap_region+0xb0/0xc2
Mar 14 21:00:47 workstation kernel: [37645.542298]
[<ffffffff810e051a>] ? do_filp_open+0x2a/0x6e
Mar 14 21:00:47 workstation kernel: [37645.542301]
[<ffffffff810ea1ca>] ? __alloc_fd+0xe2/0xf5
Mar 14 21:00:47 workstation kernel: [37645.542305]
[<ffffffff810d435e>] ? do_sys_open+0x103/0x18a
Mar 14 21:00:47 workstation kernel: [37645.542308]
[<ffffffff814a4a12>] ? system_call_fastpath+0x16/0x1b
Mar 14 21:00:47 workstation kernel: [37645.542310] pool            D
ffff88040d8a4fe8     0 12642   3957 0x00000000
Mar 14 21:00:47 workstation kernel: [37645.542313]  ffff88040d8a4d30
0000000000000086 ffff88041d0b4740 ffff88040daedfd8
Mar 14 21:00:47 workstation kernel: [37645.542316]  0000000000011200
0000000000004000 0000000000000000 ffffffff811c7ce3
Mar 14 21:00:47 workstation kernel: [37645.542320]  ffff8803f5986b00
ffffffff811c8a82 ffff88040d8a4d30 ffff88041ca023e8
Mar 14 21:00:47 workstation kernel: [37645.542323] Call Trace:
Mar 14 21:00:47 workstation kernel: [37645.542327]
[<ffffffff811c7ce3>] ? decode_attr_time+0xe/0x33
Mar 14 21:00:47 workstation kernel: [37645.542330]
[<ffffffff811c8a82>] ? decode_getfattr_attrs+0x73f/0xa7f
Mar 14 21:00:47 workstation kernel: [37645.542334]
[<ffffffff814826fc>] ? xdr_inline_decode+0x31/0x95
Mar 14 21:00:47 workstation kernel: [37645.542337]
[<ffffffff811c7eef>] ? verify_attr_len+0xc/0x27
Mar 14 21:00:47 workstation kernel: [37645.542341]
[<ffffffff811cbecb>] ? decode_getfattr_generic.constprop.63+0x88/0x93
Mar 14 21:00:47 workstation kernel: [37645.542344]
[<ffffffff811b3213>] ? nfs_clear_inode+0x71/0x71
Mar 14 21:00:47 workstation kernel: [37645.542348]
[<ffffffff811b326a>] ? nfs_wait_bit_killable+0x57/0x6f
Mar 14 21:00:47 workstation kernel: [37645.542350]
[<ffffffff814a1d19>] ? __wait_on_bit+0x3e/0x71
Mar 14 21:00:47 workstation kernel: [37645.542353]
[<ffffffff814a1dbb>] ? out_of_line_wait_on_bit+0x6f/0x78
Mar 14 21:00:47 workstation kernel: [37645.542358]
[<ffffffff8105f1cb>] ? internal_add_timer+0xd/0x28
Mar 14 21:00:47 workstation kernel: [37645.542361]
[<ffffffff811b3213>] ? nfs_clear_inode+0x71/0x71
Mar 14 21:00:47 workstation kernel: [37645.542364]
[<ffffffff8106c6f6>] ? autoremove_wake_function+0x2a/0x2a
Mar 14 21:00:47 workstation kernel: [37645.542368]
[<ffffffff811ce7a0>] ? nfs4_wait_clnt_recover+0x29/0x39
Mar 14 21:00:47 workstation kernel: [37645.542371]
[<ffffffff811ce7c3>] ? nfs4_client_recover_expired_lease+0x13/0x44
Mar 14 21:00:47 workstation kernel: [37645.542375]
[<ffffffff811c6295>] ? _nfs4_do_open+0x50/0x376
Mar 14 21:00:47 workstation kernel: [37645.542379]
[<ffffffff811c661b>] ? nfs4_do_open+0x60/0xfe
Mar 14 21:00:47 workstation kernel: [37645.542382]
[<ffffffff811c66e0>] ? nfs4_atomic_open+0x27/0x47
Mar 14 21:00:47 workstation kernel: [37645.542386]
[<ffffffff811cf135>] ? nfs4_file_open+0xbb/0x13e
Mar 14 21:00:47 workstation kernel: [37645.542389]
[<ffffffff811b0093>] ? nfs_do_access+0x1f0/0x22d
Mar 14 21:00:47 workstation kernel: [37645.542392]
[<ffffffff811cf07a>] ? nfs4_file_fsync+0x96/0x96
Mar 14 21:00:47 workstation kernel: [37645.542395]
[<ffffffff810d33ae>] ? do_dentry_open+0x17a/0x222
Mar 14 21:00:47 workstation kernel: [37645.542398]
[<ffffffff810d356e>] ? finish_open+0x2a/0x33
Mar 14 21:00:47 workstation kernel: [37645.542401]
[<ffffffff810dfd1a>] ? do_last.isra.46+0x828/0x9c2
Mar 14 21:00:47 workstation kernel: [37645.542404]
[<ffffffff810dd1f1>] ? link_path_walk+0x76/0x78f
Mar 14 21:00:47 workstation kernel: [37645.542408]
[<ffffffff810dff67>] ? path_openat.isra.47+0xb3/0x3de
Mar 14 21:00:47 workstation kernel: [37645.542412]
[<ffffffff810bf30b>] ? unmap_region+0xb0/0xc2
Mar 14 21:00:47 workstation kernel: [37645.542415]
[<ffffffff810e051a>] ? do_filp_open+0x2a/0x6e
Mar 14 21:00:47 workstation kernel: [37645.542419]
[<ffffffff810ea1ca>] ? __alloc_fd+0xe2/0xf5
Mar 14 21:00:47 workstation kernel: [37645.542422]
[<ffffffff810d435e>] ? do_sys_open+0x103/0x18a
Mar 14 21:00:47 workstation kernel: [37645.542426]
[<ffffffff814a4a12>] ? system_call_fastpath+0x16/0x1b
Mar 14 21:00:47 workstation kernel: [37645.542430]  ffff880358d71db0
0000000000000086 ffff88041d0b5f00 ffff8803f6b5dfd8
Mar 14 21:00:47 workstation kernel: [37645.542434]  0000000000011200
0000000000004000 ffff88041c09af80 ffff88042f491200
Mar 14 21:00:47 workstation kernel: [37645.542437]  ffff88041ca04150
ffff88042f591200 ffff880358d71db0 ffff88041ca04198
Mar 14 21:00:47 workstation kernel: [37645.542440] Call Trace:
Mar 14 21:00:47 workstation kernel: [37645.542444]
[<ffffffff81077989>] ? check_preempt_wakeup+0xe6/0x15e
Mar 14 21:00:47 workstation kernel: [37645.542448]
[<ffffffff8107331b>] ? check_preempt_curr+0x25/0x62
Mar 14 21:00:47 workstation kernel: [37645.542452]
[<ffffffff81073366>] ? ttwu_do_wakeup+0xe/0x7e
Mar 14 21:00:47 workstation kernel: [37645.542455]
[<ffffffff811b3213>] ? nfs_clear_inode+0x71/0x71
Mar 14 21:00:47 workstation kernel: [37645.542459]
[<ffffffff811b326a>] ? nfs_wait_bit_killable+0x57/0x6f
Mar 14 21:00:47 workstation kernel: [37645.542461]
[<ffffffff814a1d19>] ? __wait_on_bit+0x3e/0x71
Mar 14 21:00:47 workstation kernel: [37645.542464]
[<ffffffff814a1dbb>] ? out_of_line_wait_on_bit+0x6f/0x78
Mar 14 21:00:47 workstation kernel: [37645.542468]
[<ffffffff811b3213>] ? nfs_clear_inode+0x71/0x71
Mar 14 21:00:47 workstation kernel: [37645.542471]
[<ffffffff8106c6f6>] ? autoremove_wake_function+0x2a/0x2a
Mar 14 21:00:47 workstation kernel: [37645.542474]
[<ffffffff811ce7a0>] ? nfs4_wait_clnt_recover+0x29/0x39
Mar 14 21:00:47 workstation kernel: [37645.542478]
[<ffffffff811ce7c3>] ? nfs4_client_recover_expired_lease+0x13/0x44
Mar 14 21:00:47 workstation kernel: [37645.542481]
[<ffffffff811c6295>] ? _nfs4_do_open+0x50/0x376
Mar 14 21:00:47 workstation kernel: [37645.542485]
[<ffffffff811b3cde>] ? nfs_refresh_inode_locked+0x5a6/0x78f
Mar 14 21:00:47 workstation kernel: [37645.542488]
[<ffffffff811c661b>] ? nfs4_do_open+0x60/0xfe
Mar 14 21:00:47 workstation kernel: [37645.542492]
[<ffffffff811c66e0>] ? nfs4_atomic_open+0x27/0x47
Mar 14 21:00:47 workstation kernel: [37645.542495]
[<ffffffff811cf135>] ? nfs4_file_open+0xbb/0x13e
Mar 14 21:00:47 workstation kernel: [37645.542499]
[<ffffffff811cf4e1>] ? nfs4_have_delegation+0x33/0x39
Mar 14 21:00:47 workstation kernel: [37645.542502]
[<ffffffff811affae>] ? nfs_do_access+0x10b/0x22d
Mar 14 21:00:47 workstation kernel: [37645.542505]
[<ffffffff811cf07a>] ? nfs4_file_fsync+0x96/0x96
Mar 14 21:00:47 workstation kernel: [37645.542508]
[<ffffffff810d33ae>] ? do_dentry_open+0x17a/0x222
Mar 14 21:00:47 workstation kernel: [37645.542511]
[<ffffffff810d356e>] ? finish_open+0x2a/0x33
Mar 14 21:00:47 workstation kernel: [37645.542514]
[<ffffffff810dfd1a>] ? do_last.isra.46+0x828/0x9c2
Mar 14 21:00:47 workstation kernel: [37645.542518]
[<ffffffff810dd1f1>] ? link_path_walk+0x76/0x78f
Mar 14 21:00:47 workstation kernel: [37645.542521]
[<ffffffff810dff67>] ? path_openat.isra.47+0xb3/0x3de
Mar 14 21:00:47 workstation kernel: [37645.542525]
[<ffffffff810bf30b>] ? unmap_region+0xb0/0xc2
Mar 14 21:00:47 workstation kernel: [37645.542528]
[<ffffffff810e051a>] ? do_filp_open+0x2a/0x6e
Mar 14 21:00:47 workstation kernel: [37645.542532]
[<ffffffff810ea1ca>] ? __alloc_fd+0xe2/0xf5
Mar 14 21:00:47 workstation kernel: [37645.542535]
[<ffffffff810d435e>] ? do_sys_open+0x103/0x18a
Mar 14 21:00:47 workstation kernel: [37645.542539]
[<ffffffff814a4a12>] ? system_call_fastpath+0x16/0x1b


and some more....

After waiting some minutes it sometimes recovers from these blocks and I
can continue to work. Today the block came after about 2 hours. So I
switched to NFSv3 again just now to see if that is more stable.

When the blocks are happing there is nothing in the logs on server nor
on client side.

Do you have any hints or ideas?

Best regards and thank you in advance,

Matthias Jansen

--=-iGBjNsqlNxvy6/FerUCr
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIN2DCCBjQw
ggQcoAMCAQICASAwDQYJKoZIhvcNAQEFBQAwfTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0
Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxKTAn
BgNVBAMTIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTA3MTAyNDIxMDI1NVoX
DTE3MTAyNDIxMDI1NVowgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSsw
KQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFy
dENvbSBDbGFzcyAyIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMsohUWcASz7GfKrpTOMKqANy9BV7V0igWdGxA8IU77L3aTxErQ+
fcxtDYZ36Z6GH0YFn7fq5RADteP0AYzrCA+EQTfi8q1+kA3m0nwtwXG94M5sIqsvs7lRP1aycBke
/s5g9hJHryZ2acScnzczjBCAo7X1v5G3yw8MDP2m2RCye0KfgZ4nODerZJVzhAlOD9YejvAXZqHk
sw56HzElVIoYSZ3q4+RJuPXXfIoyby+Y2m1E+YzX5iCZXBx05gk6MKAW1vaw4/v2OOLy6FZH3XHH
tOkzUreG//CsFnB9+uaYSlR65cdGzTsmoIK8WH1ygoXhRBm98SD7Hf/r3FELNvUCAwEAAaOCAa0w
ggGpMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBSuVYNv7DHKufcd
+q9rMfPIHeOsuzAfBgNVHSMEGDAWgBROC+8apEBbpRdphzDKNGhD0EGu8jBmBggrBgEFBQcBAQRa
MFgwJwYIKwYBBQUHMAGGG2h0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9jYTAtBggrBgEFBQcwAoYh
aHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3J0MFsGA1UdHwRUMFIwJ6AloCOGIWh0dHA6
Ly93d3cuc3RhcnRzc2wuY29tL3Nmc2NhLmNybDAnoCWgI4YhaHR0cDovL2NybC5zdGFydHNzbC5j
b20vc2ZzY2EuY3JsMIGABgNVHSAEeTB3MHUGCysGAQQBgbU3AQIBMGYwLgYIKwYBBQUHAgEWImh0
dHA6Ly93d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwNAYIKwYBBQUHAgEWKGh0dHA6Ly93d3cu
c3RhcnRzc2wuY29tL2ludGVybWVkaWF0ZS5wZGYwDQYJKoZIhvcNAQEFBQADggIBADqpJw3I07QW
ke9plNBpxUxcffc7nUrIQpJHDci91DFG7fVhHRkMZ1J+BKg5UNUxIFJ2Z9B90Micc/NXcs7kPBRd
n6XGO/vPc87Y6R+cWS9Nc9+fp3Enmsm94OxOwI9wn8qnr/6o3mD4noP9JphwUPTXwHovjavRnhUQ
HLfo/i2NG0XXgTHXS2Xm0kVUozXqpYpAdumMiB/vezj1QHQJDmUdPYMcp+reg9901zkyT3fDW/iv
JVv6pWtkh6Pw2ytZT7mvg7YhX3V50Nv860cV11mocUVcqBLv0gcT+HBDYtbuvexNftwNQKD5193A
7zN4vG7CTYkXxytSjKuXrpEatEiFPxWgb84nVj25SU5q/r1Xhwby6mLhkbaXslkVtwEWT3Van49r
KjlK4XrUKYYWtnfzq6aSak5u0Vpxd1rY79tWhD3EdCvOhNz/QplNa+VkIsrcp7+8ZhP1l1b2U6Ma
xIVteuVMD3X0vziIwr7jxYae9FZjbxlpUemqXjcC0QaFfN7qI0JsQMALL7iGRBg7K0CoOBzECdD3
fuZil5kU/LP9cr1BK31U0Uy651bFnAMMMkqhAChIbn0ei72VnbpSsrrSdF0BAGYQ8vyHae5aCg+H
75dVCV33K6FuxZrf09yTz+Vx/PkdRUYkXmZz/OTfyJXsUOUXrym6KvI2rYpccSk5MIIHnDCCBoSg
AwIBAgICJPkwDQYJKoZIhvcNAQEFBQAwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENv
bSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYD
VQQDEy9TdGFydENvbSBDbGFzcyAyIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTAeFw0x
MjA4MTkxNjA1NDVaFw0xNDA4MjAwOTMzNDhaMIGTMRkwFwYDVQQNExBtM2E3MWVoVjhzZFVyMFIy
MQswCQYDVQQGEwJERTEcMBoGA1UECBMTTm9yZHJoZWluLVdlc3RmYWxlbjERMA8GA1UEBxMIU29s
aW5nZW4xGDAWBgNVBAMTD01hdHRoaWFzIEphbnNlbjEeMBwGCSqGSIb3DQEJARYPaW5mb0BlYXN5
dHJhLmRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA40Qz9sZ8oy/v9AyjIhbghF+a
gnAZPiv2E22cI6G8TD6qBqB8vz0qvgcZrvqIKG06ZUK1ks/DTleGUuRsCMEL0aRKv8MWBr+e8bDF
qJFZelfG54NaN4g3jVBin0RjipHQ+xFK02mLSn6mf/rsprA8OmrQgRJJTq9D7yk7Uh7x1Kw8Zu1+
2RRAEPXOoCArH56mN2vhfeITvFRqrfRKKaZ/eV40tbY0dndRIsQQQZC0mM8SPB7XhaJEk/BjAd+P
VfMvKMV7KorgqYV4voGujk34v3vlHs99gQHgV1s+KycjkY3B3wqRkg40rwaXQzoDyFEER0wSlrk9
5Yc6t6+C2Gz8swIDAQABo4ID/TCCA/kwCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0lBBYw
FAYIKwYBBQUHAwIGCCsGAQUFBwMEMB0GA1UdDgQWBBSMwzgiNG5XW4RZ+X4vOTtTgToy9zAfBgNV
HSMEGDAWgBSuVYNv7DHKufcd+q9rMfPIHeOsuzBtBgNVHREEZjBkgQ9pbmZvQGVhc3l0cmEuZGWB
D2luZm9AZWFzeXRyYS5kZYEWbWFpbEBqYW5zZW4tc3lzdGVtcy5kZYEQc2FsZXNAZWFzeXRyYS5k
ZYEWbWFpbEBtYXR0aGlhc2phbnNlbi5kZTCCAiEGA1UdIASCAhgwggIUMIICEAYLKwYBBAGBtTcB
AgIwggH/MC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMDQG
CCsGAQUFBwIBFihodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9pbnRlcm1lZGlhdGUucGRmMIH3Bggr
BgEFBQcCAjCB6jAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTADAgEBGoG+VGhp
cyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVkIGFjY29yZGluZyB0byB0aGUgQ2xhc3MgMiBWYWxpZGF0
aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUgU3RhcnRDb20gQ0EgcG9saWN5LCByZWxpYW5jZSBvbmx5
IGZvciB0aGUgaW50ZW5kZWQgcHVycG9zZSBpbiBjb21wbGlhbmNlIG9mIHRoZSByZWx5aW5nIHBh
cnR5IG9ibGlnYXRpb25zLjCBnAYIKwYBBQUHAgIwgY8wJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlv
biBBdXRob3JpdHkwAwIBAhpkTGlhYmlsaXR5IGFuZCB3YXJyYW50aWVzIGFyZSBsaW1pdGVkISBT
ZWUgc2VjdGlvbiAiTGVnYWwgYW5kIExpbWl0YXRpb25zIiBvZiB0aGUgU3RhcnRDb20gQ0EgcG9s
aWN5LjA2BgNVHR8ELzAtMCugKaAnhiVodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1Mi1jcmwu
Y3JsMIGOBggrBgEFBQcBAQSBgTB/MDkGCCsGAQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5j
b20vc3ViL2NsYXNzMi9jbGllbnQvY2EwQgYIKwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wu
Y29tL2NlcnRzL3N1Yi5jbGFzczIuY2xpZW50LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3
LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEFBQADggEBAAlvKRT0KSf+mbqF0/yKfo/5ohvAZmOH
aiMCUS1SS5KiKubRhwRN/NvtlqklHMXZi73yJ5toYPmFGV1BZ+4OvUqUfDtUPRPEO7dM72a9VvPn
xmRb+HvK23/nb3k4nY0Pk596eSEvQh7sWIw+7gTV9JNLjDZNlpCEN4MIK6Q+Z9n9S39UtilehG73
DFscg7szPVz7L1hHYOarUraobtBJhqxGecePjn8a6hHiqHxDEFd4tJSxngqrUGdHznLd7i+4Con1
uyR6l+gfhr4fl/CbaWUBLG+5HNso+nAue5DiuFu1Y+J9XkhQt5z6hHpxLMoBuaULrprcVpL2jn7K
H3gUio0xggIaMIICFgIBATCBkzCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDIgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgIk+TAJBgUr
DgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTMwMzE1
MTMwMDE1WjAjBgkqhkiG9w0BCQQxFgQUYTYOp/Lomz3m575LmJDJrKhrqT0wDQYJKoZIhvcNAQEB
BQAEggEA0i1/89MdkR8b433f1W8qbTx58Ei/NKCZtWm1AL+TZ/4Y9Isf2DhGjtlYoDOvrov0Sukp
Xpp1MT5ghRl9ufYzWLNND7rmPZJHQjZxktZEfGOit93eEoL7G4nhyJKP7lKaohuNdIEIqUylIHgR
UDrZJ5WB3qVezpddoHXuS2DmaYDGx1dVv+v1OaUiyXC4VqmK3pIr2YWS9ZZ1uXDQ5anVwlRjxQ10
XSoYRFaPuTG+l0rbCfGacjIjVwsuhWedwwnZ9H7J7OY6uJ7kdzJoqG/Za3X2cB/GlJszcfPk124b
bsFnwcSDxId+FUq8LuU83h5w/EC8+uRKPoeYHZtC8DGssgAAAAAAAA==


--=-iGBjNsqlNxvy6/FerUCr--

