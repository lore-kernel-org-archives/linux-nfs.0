Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36075 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdCNFlh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Mar 2017 01:41:37 -0400
Received: by mail-io0-f195.google.com with SMTP id 68so15455010ioh.3
        for <linux-nfs@vger.kernel.org>; Mon, 13 Mar 2017 22:41:36 -0700 (PDT)
Subject: Re: some problems about nfs mount
To: Houlinfei <hou.linfei@h3c.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <3858597F7658604DB90E3F60F716249C4696B42E@H3CMLB12-EX.srv.huawei-3com.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "neilb@suse.com" <neilb@suse.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <d8a1fbe6-0373-ea97-16d3-c9c4b5e49880@gmail.com>
Date: Tue, 14 Mar 2017 13:41:16 +0800
MIME-Version: 1.0
In-Reply-To: <3858597F7658604DB90E3F60F716249C4696B42E@H3CMLB12-EX.srv.huawei-3com.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/14/2017 11:52, Houlinfei wrote:
> hi Kinglong:
> There has no firewall. While my client system is Ubuntu 14.04, it's ok.
> There has problem on ubuntu12.04 system. But if I add a parameter sec=sys, it is also ok. Such as, #mount -t nfs -o sec=sys 193.168.70.26:/root/hh /mnt/uu
> But when my mount command line t is #mount -t nfs 193.168.70.26:/root/hh /mnt/uu   it fail.
> There is some client fail log:

The ubuntu12.04 system contains an old kernel, the problem should be a bug in that kernel.
I don't have an old kernel as ubuntu12.04 system, so I don't check the code.

Can you have a try with the following patch ?
Your can get more information from the comments in the patch.

Commit 4580a92d4 ("NFS: Use server-recommended security flavor by default"),
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4580a92d4

thanks,
Kinglong Mee

> 
> Mar 14 08:30:41 ubuntu12 kernel: [347881.225950] NFS: nfs mount opts='vers=4,addr=192.168.70.26,clientaddr=192.168.70.228'
> Mar 14 08:30:41 ubuntu12 kernel: [347881.225962] NFS:   parsing nfs mount option 'vers=4'
> Mar 14 08:30:41 ubuntu12 kernel: [347881.225973] NFS:   parsing nfs mount option 'addr=192.168.70.26'
> Mar 14 08:30:41 ubuntu12 kernel: [347881.225983] NFS:   parsing nfs mount option 'clientaddr=192.168.70.228'
> Mar 14 08:30:41 ubuntu12 kernel: [347881.225989] NFS: MNTPATH: '/root/hh'
> Mar 14 08:30:41 ubuntu12 kernel: [347881.225998] --> nfs4_try_mount()
> Mar 14 08:30:41 ubuntu12 kernel: [347881.226005] --> nfs4_create_server()
> Mar 14 08:30:41 ubuntu12 kernel: [347881.226027] --> nfs4_init_server()
> Mar 14 08:30:41 ubuntu12 kernel: [347881.226028] --> nfs4_set_client()
> Mar 14 08:30:41 ubuntu12 kernel: [347881.226031] --> nfs_get_client(192.168.70.26,v4)
> Mar 14 08:30:41 ubuntu12 kernel: [347881.226054] NFS: get client cookie (0xffff880036e80400/0xffff88003a724058)
> Mar 14 08:30:41 ubuntu12 kernel: [347881.227257] --> nfs4_realloc_slot_table: max_reqs=1024, tbl->max_slots 0
> Mar 14 08:30:41 ubuntu12 kernel: [347881.227398] nfs4_realloc_slot_table: tbl=ffff88003c382800 slots=ffff88003b895740 max_slots=1024
> Mar 14 08:30:41 ubuntu12 kernel: [347881.227401] <-- nfs4_realloc_slot_table: return 0
> Mar 14 08:30:41 ubuntu12 kernel: [347881.227407] NFS: nfs4_discover_server_trunking: testing '192.168.70.26'
> Mar 14 08:30:41 ubuntu12 kernel: [347881.227412] NFS call  setclientid auth=RPCSEC_GSS, 'Linux NFSv4.0 192.168.70.228/192.168.70.26 tcp'
> Mar 14 08:30:56 ubuntu12 kernel: [347896.219667] RPC: AUTH_GSS upcall timed out.
> Mar 14 08:30:56 ubuntu12 kernel: [347896.219667] Please check user daemon is running.
> Mar 14 08:30:56 ubuntu12 kernel: [347896.219690] NFS reply setclientid: -13
> Mar 14 08:30:56 ubuntu12 kernel: [347896.219700] NFS call  setclientid auth=RPCSEC_GSS, 'Linux NFSv4.0 192.168.70.228/192.168.70.26 tcp'
> Mar 14 08:30:56 ubuntu12 kernel: [347896.467612] NFS reply setclientid: -13
> Mar 14 08:30:56 ubuntu12 kernel: [347896.467675] NFS call  setclientid auth=UNIX, 'Linux NFSv4.0 192.168.70.228/192.168.70.26 tcp'
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468364] NFS reply setclientid: 0
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468370] NFS call  setclientid_confirm auth=UNIX, (client ID 9366c6580d000000)
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468708] NFS reply setclientid_confirm: 0
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468713] NFS: <-- nfs40_walk_client_list using nfs_client = ffff880036e80400 ({2})
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468715] NFS: <-- nfs40_walk_client_list status = 0
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468717] nfs4_schedule_state_renewal: requeueing work. Lease period = 5
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468721] NFS: nfs4_discover_server_trunking: status = 0
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468722] --> nfs_put_client({2})
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468725] <-- nfs4_set_client() = 0 [new ffff880036e80400]
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468788] <-- nfs4_init_server() = 0
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468791] --> nfs4_get_rootfh()
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468802] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:56 ubuntu12 kernel: [347896.468805] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:56 ubuntu12 kernel: [347896.715547] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:56 ubuntu12 kernel: [347896.715571] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:56 ubuntu12 kernel: [347896.715575] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:56 ubuntu12 kernel: [347896.963430] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:56 ubuntu12 kernel: [347896.963469] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:56 ubuntu12 kernel: [347896.963474] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.211331] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.211347] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.211350] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212115] decode_attr_type: type=040000
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212119] decode_attr_change: change attribute=6394568334484006929
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212121] decode_attr_size: file size=4096
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212123] decode_attr_fsid: fsid=(0x0/0x0)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212126] decode_attr_fileid: fileid=2
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212128] decode_attr_fs_locations: fs_locations done, error = 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212130] decode_attr_mode: file mode=0755
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212132] decode_attr_nlink: nlink=24
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212135] decode_attr_owner: uid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212137] decode_attr_group: gid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212139] decode_attr_rdev: rdev=(0x0:0x0)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212142] decode_attr_space_used: space used=4096
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212144] decode_attr_time_access: atime=1489456301
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212146] decode_attr_time_metadata: ctime=1488851461
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212147] decode_attr_time_modify: mtime=1488851461
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212149] decode_attr_mounted_on_fileid: fileid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212151] decode_getfattr_attrs: xdr returned 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212152] decode_getfattr_generic: xdr returned 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212155] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212163] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212166] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212446] decode_attr_supported: bitmask=fdffbfff:00f9be3e:00000000
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212449] decode_attr_fh_expire_type: expire type=0x0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212451] decode_attr_link_support: link support=true
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212453] decode_attr_symlink_support: symlink support=true
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212454] decode_attr_aclsupport: ACLs supported=3
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212456] decode_server_caps: xdr returned 0!
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212459] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212465] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212467] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212719] decode_attr_lease_time: file size=30
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212722] decode_attr_maxfilesize: maxfilesize=17592186040320
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212724] decode_attr_maxread: maxread=1048576
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212726] decode_attr_maxwrite: maxwrite=1048576
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212728] decode_attr_time_delta: time_delta=1 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212729] decode_attr_pnfstype: bitmap is 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212731] decode_attr_layout_blksize: bitmap is 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212733] decode_fsinfo: xdr returned 0!
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212735] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212740] <-- nfs4_get_rootfh() = 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212742] Server FSID: 0:0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212761] Pseudo-fs root FH at ffff88003bbcf0c0 is 8 bytes, crc: 0x62d40c52:
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212763]  01000100 00000000
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212765] --> nfs_probe_fsinfo()
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212768] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.212770] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213028] decode_attr_supported: bitmask=fdffbfff:00f9be3e:00000000
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213031] decode_attr_fh_expire_type: expire type=0x0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213032] decode_attr_link_support: link support=true
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213034] decode_attr_symlink_support: symlink support=true
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213036] decode_attr_aclsupport: ACLs supported=3
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213037] decode_server_caps: xdr returned 0!
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213040] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213046] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213047] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213283] decode_attr_lease_time: file size=30
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213286] decode_attr_maxfilesize: maxfilesize=17592186040320
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213288] decode_attr_maxread: maxread=1048576
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213290] decode_attr_maxwrite: maxwrite=1048576
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213291] decode_attr_time_delta: time_delta=1 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213293] decode_attr_pnfstype: bitmap is 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213294] decode_attr_layout_blksize: bitmap is 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213302] decode_fsinfo: xdr returned 0!
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213305] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213310] set_pnfs_layoutdriver: Using NFSv4 I/O
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213315] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213317] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213553] decode_attr_maxlink: maxlink=255
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213556] decode_attr_maxname: maxname=255
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213558] decode_pathconf: xdr returned 0!
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213560] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213564] <-- nfs_probe_fsinfo() = 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213568] <-- nfs4_create_server() = ffff88003bbab800
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213726] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.213728] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.217688] decode_attr_supported: bitmask=fdffbfff:00f9be3e:00000000
> Mar 14 08:30:57 ubuntu12 kernel: [347897.217692] decode_attr_fh_expire_type: expire type=0x0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.217694] decode_attr_link_support: link support=true
> Mar 14 08:30:57 ubuntu12 kernel: [347897.217696] decode_attr_symlink_support: symlink support=true
> Mar 14 08:30:57 ubuntu12 kernel: [347897.217698] decode_attr_aclsupport: ACLs supported=3
> Mar 14 08:30:57 ubuntu12 kernel: [347897.217700] decode_server_caps: xdr returned 0!
> Mar 14 08:30:57 ubuntu12 kernel: [347897.217704] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.217720] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.217723] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218073] decode_attr_type: type=040000
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218077] decode_attr_change: change attribute=6394568334484006929
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218079] decode_attr_size: file size=4096
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218081] decode_attr_fsid: fsid=(0x0/0x0)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218083] decode_attr_fileid: fileid=2
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218085] decode_attr_fs_locations: fs_locations done, error = 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218086] decode_attr_mode: file mode=0755
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218088] decode_attr_nlink: nlink=24
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218091] decode_attr_owner: uid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218093] decode_attr_group: gid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218095] decode_attr_rdev: rdev=(0x0:0x0)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218096] decode_attr_space_used: space used=4096
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218098] decode_attr_time_access: atime=1489456301
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218100] decode_attr_time_metadata: ctime=1488851461
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218102] decode_attr_time_modify: mtime=1488851461
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218103] decode_attr_mounted_on_fileid: fileid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218105] decode_getfattr_attrs: xdr returned 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218106] decode_getfattr_generic: xdr returned 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218109] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218127] NFS: nfs_fhget(0:32/2 fh_crc=0x62d40c52 ct=1)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218146] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218148] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218426] decode_attr_type: type=00
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218429] decode_attr_change: change attribute=6394568334484006929
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218431] decode_attr_size: file size=4096
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218433] decode_attr_fsid: fsid=(0x0/0x0)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218434] decode_attr_fileid: fileid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218436] decode_attr_fs_locations: fs_locations done, error = 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218438] decode_attr_mode: file mode=00
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218439] decode_attr_nlink: nlink=1
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218441] decode_attr_owner: uid=-2
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218443] decode_attr_group: gid=-2
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218444] decode_attr_rdev: rdev=(0x0:0x0)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218446] decode_attr_space_used: space used=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218448] decode_attr_time_access: atime=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218449] decode_attr_time_metadata: ctime=1488851461
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218451] decode_attr_time_modify: mtime=1488851461
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218452] decode_attr_mounted_on_fileid: fileid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218454] decode_getfattr_attrs: xdr returned 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218455] decode_getfattr_generic: xdr returned 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218458] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218465] NFS: nfs_update_inode(0:32/2 fh_crc=0x62d40c52 ct=2 info=0x26040)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218477] NFS: permission(0:32/2), mask=0x1, res=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218481] NFS: permission(0:32/2), mask=0x1, res=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218489] NFS: lookup(/root)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218495] NFS call  lookup root
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218498] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218503] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218943] decode_attr_type: type=040000
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218946] decode_attr_change: change attribute=6397154514070534174
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218948] decode_attr_size: file size=4096
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218950] decode_attr_fsid: fsid=(0x96e7857195ab4a4b/0x8bb47786a5dc434a)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218952] decode_attr_fileid: fileid=262145
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218953] decode_attr_fs_locations: fs_locations done, error = 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218955] decode_attr_mode: file mode=0700
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218956] decode_attr_nlink: nlink=5
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218959] decode_attr_owner: uid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218961] decode_attr_group: gid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218962] decode_attr_rdev: rdev=(0x0:0x0)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218964] decode_attr_space_used: space used=4096
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218966] decode_attr_time_access: atime=1489453599
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218967] decode_attr_time_metadata: ctime=1489453603
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218969] decode_attr_time_modify: mtime=1489453603
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218970] decode_attr_mounted_on_fileid: fileid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218971] decode_getfattr_attrs: xdr returned 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218973] decode_getfattr_generic: xdr returned 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218976] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218980] NFS reply lookup: 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218985] NFS: nfs_fhget(0:32/262145 fh_crc=0x282dfa5b ct=1)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218996] --> nfs_d_automount()
> Mar 14 08:30:57 ubuntu12 kernel: [347897.218998] nfs_d_automount: enter
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219000] NFS call  lookup root
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219003] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219005] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219319] decode_attr_type: type=040000
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219323] decode_attr_change: change attribute=6397154514070534174
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219324] decode_attr_size: file size=4096
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219326] decode_attr_fsid: fsid=(0x96e7857195ab4a4b/0x8bb47786a5dc434a)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219328] decode_attr_fileid: fileid=262145
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219330] decode_attr_fs_locations: fs_locations done, error = 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219331] decode_attr_mode: file mode=0700
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219333] decode_attr_nlink: nlink=5
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219335] decode_attr_owner: uid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219336] decode_attr_group: gid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219338] decode_attr_rdev: rdev=(0x0:0x0)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219340] decode_attr_space_used: space used=4096
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219341] decode_attr_time_access: atime=1489453599
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219343] decode_attr_time_metadata: ctime=1489453603
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219344] decode_attr_time_modify: mtime=1489453603
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219346] decode_attr_mounted_on_fileid: fileid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219347] decode_getfattr_attrs: xdr returned 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219349] decode_getfattr_generic: xdr returned 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219351] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219355] NFS reply lookup: 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219530] NFS call  secinfo root
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219535] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.219537] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.220215] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.220222] NFS reply  secinfo: 0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.230984] --> nfs_do_submount()
> Mar 14 08:30:57 ubuntu12 kernel: [347897.230990] nfs_do_submount: submounting on /root
> Mar 14 08:30:57 ubuntu12 kernel: [347897.230999] --> nfs_xdev_mount()
> Mar 14 08:30:57 ubuntu12 kernel: [347897.231002] --> nfs_clone_server(,96e7857195ab4a4b:8bb47786a5dc434a,)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.231045] --> nfs_probe_fsinfo()
> Mar 14 08:30:57 ubuntu12 kernel: [347897.231052] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=1024
> Mar 14 08:30:57 ubuntu12 kernel: [347897.231054] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475244] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475255] nfs_probe_fsinfo: error = 13
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475258] --> nfs_free_server()
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475284] --> nfs_put_client({2})
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475300] <-- nfs_free_server()
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475301] <-- nfs_clone_server() = error -13
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475303] <-- nfs_xdev_mount() = -13
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475309] nfs_do_submount: done
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475311] <-- nfs_do_submount() = fffffffffffffff3
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475319] <-- nfs_d_automount(): error -13
> Mar 14 08:30:57 ubuntu12 kernel: [347897.475334] NFS: dentry_delete(/root, 22008c)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.476094] NFS: clear cookie (0xffff88001b70d060/0x          (null))
> Mar 14 08:30:57 ubuntu12 kernel: [347897.476100] NFS: clear cookie (0xffff88001b70c000/0x          (null))
> Mar 14 08:30:57 ubuntu12 kernel: [347897.476223] NFS: releasing superblock cookie (0xffff88003bbab800/0x          (null))
> Mar 14 08:30:57 ubuntu12 kernel: [347897.476226] --> nfs_free_server()
> Mar 14 08:30:57 ubuntu12 kernel: [347897.476241] --> nfs_put_client({1})
> Mar 14 08:30:57 ubuntu12 kernel: [347897.476347] --> nfs_free_client(4)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.476349] NFS: releasing client cookie (0xffff880036e80400/0xffff88003a724058)
> Mar 14 08:30:57 ubuntu12 kernel: [347897.476415] <-- nfs_free_client()
> Mar 14 08:30:57 ubuntu12 kernel: [347897.476428] <-- nfs_free_server()
> Mar 14 08:30:57 ubuntu12 kernel: [347897.476438] <-- nfs4_try_mount() = -13 [error]
> 
> Thanks,
> houlinfei
> 
> 
> 
> On 3/13/2017 11:42, houlinfei wrote:
>> hi Kinglong:
>>
>> At server,
>> #cat /etc/exports
>> /root/hh *(rw,sync,insecure,subtree_check,no_root_squash)
>> #cat /proc/fs/nfsd/versions
>> -2 +3 +4 +4.1 +4.2
>>
>> At client,
>> #mount -t nfs 193.168.70.26:/root/hh /mnt/uu
>> mount.nfs: access denied by server while mounting
>> 192.168.70.26:/root/hh
> 
> Everything is okay on my test machine.
> Is it failed every client? or only one client?
> What't the state of filewalld ? Can you try again with filewalld turndown?
> 
> thanks,
> Kinglong Mee
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
> -------------------------------------------------------------------------------------------------------------------------------------
> 本邮件及其附件含有杭州华三通信技术有限公司的保密信息，仅限于发送给上面地址中列出
> 的个人或群组。禁止任何其他人以任何形式使用（包括但不限于全部或部分地泄露、复制、
> 或散发）本邮件中的信息。如果您错收了本邮件，请您立即电话或邮件通知发件人并删除本
> 邮件！
> This e-mail and its attachments contain confidential information from H3C, which is
> intended only for the person or entity whose address is listed above. Any use of the
> information contained herein in any way (including, but not limited to, total or partial
> disclosure, reproduction, or dissemination) by persons other than the intended
> recipient(s) is prohibited. If you receive this e-mail in error, please notify the sender
> by phone or email immediately and delete it!
> 
