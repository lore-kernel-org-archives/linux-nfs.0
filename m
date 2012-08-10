Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:58900 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755942Ab2HJHsW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 03:48:22 -0400
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="utf-8"
Date: Fri, 10 Aug 2012 09:48:18 +0200
From: "Johannes Schild" <JSchild@gmx.de>
In-Reply-To: <CA+a=Yy7rH7kFKJvS3eOae+Mb0C1p+N01h+Zqz7jVzGE+HXHt9g@mail.gmail.com>
Message-ID: <20120810074818.119500@gmx.net>
MIME-Version: 1.0
References: <20120808155829.177400@gmx.net> <20120808163916.GA24539@umich.edu>
 <20120808182622.177380@gmx.net> <20120809084236.177380@gmx.net>
 <5DFC6BE3BA248842867E85C73BF94B050B17B698CF@MX41A.corp.emc.com>
 <20120809152744.149360@gmx.net>
 <CA+a=Yy7rH7kFKJvS3eOae+Mb0C1p+N01h+Zqz7jVzGE+HXHt9g@mail.gmail.com>
Subject: Re: RE: Blocklayout
To: Peng Tao <tao.peng@emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tao,

sry, here the complete debug output:


[  107.568142] scsi3 : iSCSI Initiator over TCP/IP
[  107.831688] scsi 3:0:0:0: RAID              IET      Controller       0001 PQ: 0 ANSI: 5
[  107.833425] scsi 3:0:0:0: Attached scsi generic sg4 type 12
[  107.836869] scsi 3:0:0:1: Direct-Access     IET      VIRTUAL-DISK     0001 PQ: 0 ANSI: 5
[  107.837494] sd 3:0:0:1: Attached scsi generic sg5 type 0
[  107.838664] sd 3:0:0:1: [sdd] 4196352 512-byte logical blocks: (2.14 GB/2.00 GiB)
[  107.838750] scsi 3:0:0:2: Direct-Access     IET      VIRTUAL-DISK     0001 PQ: 0 ANSI: 5
[  107.838843] sd 3:0:0:2: Attached scsi generic sg6 type 0
[  107.843793] sd 3:0:0:1: [sdd] Write Protect is off
[  107.843796] sd 3:0:0:1: [sdd] Mode Sense: 49 00 00 08
[  107.844193] sd 3:0:0:2: [sde] 4196352 512-byte logical blocks: (2.14 GB/2.00 GiB)
[  107.844814] sd 3:0:0:1: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  107.845943] sd 3:0:0:2: [sde] Write Protect is off
[  107.845945] sd 3:0:0:2: [sde] Mode Sense: 49 00 00 08
[  107.846699] sd 3:0:0:2: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  107.856535]  sdd: sdd1
[  107.859230]  sde: sde1
[  107.859941] sd 3:0:0:1: [sdd] Attached SCSI disk
[  107.861468] sd 3:0:0:2: [sde] Attached SCSI disk
[  179.557893] FS-Cache: Loaded
[  179.563310] NFS: Registering the id_resolver key type
[  179.563339] FS-Cache: Netfs 'nfs' registered for caching
[  207.222318] NFS: set_pnfs_layoutdriver: Error initializing pNFS layout driver 3.
[  308.078197] pcnet32 0000:02:01.0: eth0: link up
[  319.441328] eth0: no IPv6 routers present
[59260.317082] NFS: nfs mount opts='minorversion=1,addr=192.168.0.11,clientaddr=192.168.0.13'
[59260.317088] NFS:   parsing nfs mount option 'minorversion=1'
[59260.317092] NFS:   parsing nfs mount option 'addr=192.168.0.11'
[59260.317108] NFS:   parsing nfs mount option 'clientaddr=192.168.0.13'
[59260.317111] NFS: MNTPATH: '/'
[59260.317112] --> nfs4_try_mount()
[59260.317126] --> nfs4_create_server()
[59260.317134] --> nfs4_init_server()
[59260.317135] --> nfs4_set_client()
[59260.317147] --> nfs_get_client(fedorapnfs2,v4)
[59260.317167] NFS: get client cookie (0xffff88003c733400/0xffff88003d211050)
[59260.318191] --> nfs41_callback_up return 0
[59260.318219] --> nfs_get_client() = ffff88003c733400 [new]
[59260.318220] <-- nfs4_set_client() = 0 [new ffff88003c733400]
[59260.318225] <-- nfs4_init_server() = 0
[59260.318268] --> nfs4_proc_exchange_id
[59260.318813] nfs4_proc_exchange_id: Server Implementation ID: domain: , name: , date: 0,0
[59260.318815] <-- nfs4_proc_exchange_id status= 0
[59260.318816] --> nfs4_proc_create_session clp=ffff88003c733400 session=ffff88003c733c00
[59260.318818] nfs4_init_channel_attrs: Fore Channel : max_rqst_sz=1049620 max_resp_sz=1049480 max_ops=8 max_reqs=16
[59260.318820] nfs4_init_channel_attrs: Back Channel : max_rqst_sz=4096 max_resp_sz=4096 max_resp_sz_cached=0 max_ops=2 max_reqs=1
[59260.319156] --> nfs4_setup_session_slot_tables
[59260.319170] --> nfs4_realloc_slot_table: max_reqs=16, tbl->max_slots 0
[59260.319172] nfs4_realloc_slot_table: tbl=ffff88003c733c40 slots=ffff88003681c480 max_slots=16
[59260.319173] <-- nfs4_realloc_slot_table: return 0
[59260.319174] --> nfs4_realloc_slot_table: max_reqs=1, tbl->max_slots 0
[59260.319176] nfs4_realloc_slot_table: tbl=ffff88003c733d80 slots=ffff88003a3d9b68 max_slots=1
[59260.319177] <-- nfs4_realloc_slot_table: return 0
[59260.319187] slot table setup returned 0
[59260.319188] nfs4_proc_create_session client>seqid 2 sessionid 1344524732:4:4:0
[59260.319190] <-- nfs4_proc_create_session
[59260.319190] --> nfs4_proc_get_lease_time
[59260.319192] --> nfs4_get_lease_time_prepare
[59260.319193] --> nfs41_setup_sequence
[59260.319194] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.319196] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.319197] <-- nfs41_setup_sequence slotid=0 seqid=1
[59260.319198] <-- nfs4_get_lease_time_prepare
[59260.319359] encode_sequence: sessionid=1344524732:4:4:0 seqid=1 slotid=0 max_slotid=0 cache_this=0
[59260.319364] Invoking bc_svc_process()
[59260.319519] bc_svc_process() returned w/ error code= 0
[59260.321000] decode_attr_lease_time: file size=90
[59260.321001] decode_attr_maxfilesize: maxfilesize=0
[59260.321002] decode_attr_maxread: maxread=1024
[59260.321003] decode_attr_maxwrite: maxwrite=1024
[59260.321004] decode_attr_time_delta: time_delta=0 0
[59260.321005] decode_attr_pnfstype: bitmap is 0
[59260.321006] decode_attr_layout_blksize: bitmap is 0
[59260.321007] decode_fsinfo: xdr returned 0!
[59260.321008] --> nfs4_get_lease_time_done
[59260.321009] nfs41_sequence_done: Error 0 free the slot 
[59260.321011] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.321011] nfs4_check_drain_fc_complete COMPLETE: Session Fore Channel Drained
[59260.321013] <-- nfs4_get_lease_time_done
[59260.321015] <-- nfs4_proc_get_lease_time return 0
[59260.321017] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
[59260.321034] --> nfs41_proc_reclaim_complete
[59260.321039] --> nfs41_setup_sequence
[59260.321041] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.321042] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.321043] <-- nfs41_setup_sequence slotid=0 seqid=2
[59260.321047] encode_sequence: sessionid=1344524732:4:4:0 seqid=2 slotid=0 max_slotid=0 cache_this=0
[59260.322154] --> nfs4_reclaim_complete_done
[59260.322163] nfs41_sequence_done: Error 0 free the slot 
[59260.322165] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.322166] nfs4_check_drain_fc_complete COMPLETE: Session Fore Channel Drained
[59260.322167] <-- nfs4_reclaim_complete_done
[59260.322175] --> nfs_put_client({2})
[59260.322178] --> nfs4_get_rootfh()
[59260.322184] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.322185] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.322186] --> nfs41_setup_sequence
[59260.322188] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.322189] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.322190] <-- nfs41_setup_sequence slotid=0 seqid=3
[59260.322191] <-- nfs4_setup_sequence status=0
[59260.322195] encode_sequence: sessionid=1344524732:4:4:0 seqid=3 slotid=0 max_slotid=0 cache_this=0
[59260.322587] decode_attr_type: type=040000
[59260.322589] decode_attr_change: change attribute=13246251234597893889
[59260.322590] decode_attr_size: file size=4096
[59260.322591] decode_attr_fsid: fsid=(0x0/0x0)
[59260.322592] decode_attr_fileid: fileid=2
[59260.322593] decode_attr_fs_locations: fs_locations done, error = 0
[59260.322594] decode_attr_mode: file mode=0755
[59260.322595] decode_attr_nlink: nlink=3
[59260.322596] decode_attr_owner: uid=0
[59260.322597] decode_attr_group: gid=0
[59260.322598] decode_attr_rdev: rdev=(0x0:0x0)
[59260.322599] decode_attr_space_used: space used=4096
[59260.322611] decode_attr_time_access: atime=1344525504
[59260.322612] decode_attr_time_metadata: ctime=1344525495
[59260.322613] decode_attr_time_modify: mtime=1344525495
[59260.322614] decode_attr_mounted_on_fileid: fileid=0
[59260.322614] decode_getfattr_attrs: xdr returned 0
[59260.322615] decode_getfattr_generic: xdr returned 0
[59260.322635] nfs41_sequence_done: Error 0 free the slot 
[59260.322636] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.322640] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.322641] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.322642] --> nfs41_setup_sequence
[59260.322643] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.322645] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.322646] <-- nfs41_setup_sequence slotid=0 seqid=4
[59260.322646] <-- nfs4_setup_sequence status=0
[59260.322649] encode_sequence: sessionid=1344524732:4:4:0 seqid=4 slotid=0 max_slotid=0 cache_this=0
[59260.323028] decode_attr_supported: bitmask=fdffbfff:40f9be3e:00000803
[59260.323030] decode_attr_fh_expire_type: expire type=0x0
[59260.323031] decode_attr_link_support: link support=true
[59260.323032] decode_attr_symlink_support: symlink support=true
[59260.323033] decode_attr_aclsupport: ACLs supported=3
[59260.323033] decode_server_caps: xdr returned 0!
[59260.323034] nfs41_sequence_done: Error 0 free the slot 
[59260.323035] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.323041] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.323043] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.323044] --> nfs41_setup_sequence
[59260.323045] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.323046] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.323047] <-- nfs41_setup_sequence slotid=0 seqid=5
[59260.323048] <-- nfs4_setup_sequence status=0
[59260.323051] encode_sequence: sessionid=1344524732:4:4:0 seqid=5 slotid=0 max_slotid=0 cache_this=0
[59260.323438] decode_attr_lease_time: file size=90
[59260.323440] decode_attr_maxfilesize: maxfilesize=18446744073709551615
[59260.323441] decode_attr_maxread: maxread=131072
[59260.323442] decode_attr_maxwrite: maxwrite=131072
[59260.323443] decode_attr_time_delta: time_delta=1 0
[59260.323444] decode_attr_pnfstype: bitmap is 40000000
[59260.323445] decode_attr_layout_blksize: bitmap is 2
[59260.323446] decode_fsinfo: xdr returned 0!
[59260.323447] nfs41_sequence_done: Error 0 free the slot 
[59260.323448] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.323451] <-- nfs4_get_rootfh() = 0
[59260.323452] Server FSID: 0:0
[59260.323452] Mount FH: 8
[59260.323453] --> nfs_probe_fsinfo()
[59260.323454] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.323456] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.323457] --> nfs41_setup_sequence
[59260.323458] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.323459] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.323460] <-- nfs41_setup_sequence slotid=0 seqid=6
[59260.323461] <-- nfs4_setup_sequence status=0
[59260.323463] encode_sequence: sessionid=1344524732:4:4:0 seqid=6 slotid=0 max_slotid=0 cache_this=0
[59260.323735] decode_attr_supported: bitmask=fdffbfff:40f9be3e:00000803
[59260.323736] decode_attr_fh_expire_type: expire type=0x0
[59260.323737] decode_attr_link_support: link support=true
[59260.323738] decode_attr_symlink_support: symlink support=true
[59260.323739] decode_attr_aclsupport: ACLs supported=3
[59260.323740] decode_server_caps: xdr returned 0!
[59260.323741] nfs41_sequence_done: Error 0 free the slot 
[59260.323742] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.323745] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.323747] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.323748] --> nfs41_setup_sequence
[59260.323749] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.323750] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.323777] <-- nfs41_setup_sequence slotid=0 seqid=7
[59260.323777] <-- nfs4_setup_sequence status=0
[59260.323781] encode_sequence: sessionid=1344524732:4:4:0 seqid=7 slotid=0 max_slotid=0 cache_this=0
[59260.324170] decode_attr_lease_time: file size=90
[59260.324171] decode_attr_maxfilesize: maxfilesize=18446744073709551615
[59260.324172] decode_attr_maxread: maxread=131072
[59260.324173] decode_attr_maxwrite: maxwrite=131072
[59260.324174] decode_attr_time_delta: time_delta=1 0
[59260.324175] decode_attr_pnfstype: bitmap is 40000000
[59260.324175] decode_attr_layout_blksize: bitmap is 2
[59260.324176] decode_fsinfo: xdr returned 0!
[59260.324177] nfs41_sequence_done: Error 0 free the slot 
[59260.324178] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.324195] find_pnfs_driver_locked: Searching for id 3, found ffffffffa0409000
[59260.324218] bl_set_layoutdriver enter
[59260.324220] --> _nfs4_getdevicelist
[59260.324222] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.324223] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.324224] --> nfs41_setup_sequence
[59260.324225] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.324226] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.324227] <-- nfs41_setup_sequence slotid=0 seqid=8
[59260.324228] <-- nfs4_setup_sequence status=0
[59260.324231] encode_sequence: sessionid=1344524732:4:4:0 seqid=8 slotid=0 max_slotid=0 cache_this=0
[59260.324598] encoding getdevicelist!
[59260.324600] decode_getdevicelist: num_dev 1
[59260.324601] nfs41_sequence_done: Error 0 free the slot 
[59260.324602] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.324605] <-- _nfs4_getdevicelist status=0
[59260.324606] nfs4_proc_getdevicelist: err=0, num_devs=1
[59260.324607] bl_set_layoutdriver GETDEVICELIST numdevs=1, eof=1
[59260.324608] nfs4_blk_get_deviceinfo max_resp_sz 135168 max_pages 33
[59260.324629] nfs4_blk_get_deviceinfo: dev_id: 
[59260.324630] --> _nfs4_proc_getdeviceinfo
[59260.324632] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.324633] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.324634] --> nfs41_setup_sequence
[59260.324635] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.324636] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.324637] <-- nfs41_setup_sequence slotid=0 seqid=9
[59260.324638] <-- nfs4_setup_sequence status=0
[59260.324642] encode_sequence: sessionid=1344524732:4:4:0 seqid=9 slotid=0 max_slotid=0 cache_this=0
[59260.333545] nfs41_sequence_done: Error 0 free the slot 
[59260.333547] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.333553] <-- _nfs4_proc_getdeviceinfo status=0
[59260.333555] nfs4_blk_get_deviceinfo getdevice info returns 0
[59260.333572] nfs4_blk_decode_device CREATING PIPEFS MESSAGE
[59260.333573] nfs4_blk_decode_device: deviceid: , mincount: 136
[59260.333574] nfs4_blk_decode_device CALLING USERSPACE DAEMON
[59260.333595] NFS: set_pnfs_layoutdriver: Error initializing pNFS layout driver 3.
[59260.333618] set_pnfs_layoutdriver: Using NFSv4 I/O
[59260.333623] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.333624] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.333626] --> nfs41_setup_sequence
[59260.333627] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.333629] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.333630] <-- nfs41_setup_sequence slotid=0 seqid=10
[59260.333631] <-- nfs4_setup_sequence status=0
[59260.333637] encode_sequence: sessionid=1344524732:4:4:0 seqid=10 slotid=0 max_slotid=0 cache_this=0
[59260.333968] decode_attr_maxlink: maxlink=255
[59260.333969] decode_attr_maxname: maxname=255
[59260.333982] decode_pathconf: xdr returned 0!
[59260.333984] nfs41_sequence_done: Error 0 free the slot 
[59260.333985] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.333988] <-- nfs_probe_fsinfo() = 0
[59260.333990] <-- nfs4_create_server() = ffff88003c8d7800
[59260.334116] NFS: get superblock cookie (0xffff88003c8d7800/0xffff88003d2110a0)
[59260.334118] --> nfs4_get_root()
[59260.334120] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.334121] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.334122] --> nfs41_setup_sequence
[59260.334123] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.334125] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.334126] <-- nfs41_setup_sequence slotid=0 seqid=11
[59260.334127] <-- nfs4_setup_sequence status=0
[59260.334130] encode_sequence: sessionid=1344524732:4:4:0 seqid=11 slotid=0 max_slotid=0 cache_this=0
[59260.334427] decode_attr_supported: bitmask=fdffbfff:40f9be3e:00000803
[59260.334428] decode_attr_fh_expire_type: expire type=0x0
[59260.334429] decode_attr_link_support: link support=true
[59260.334430] decode_attr_symlink_support: symlink support=true
[59260.334431] decode_attr_aclsupport: ACLs supported=3
[59260.334432] decode_server_caps: xdr returned 0!
[59260.334433] nfs41_sequence_done: Error 0 free the slot 
[59260.334434] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.334442] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.334444] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.334445] --> nfs41_setup_sequence
[59260.334446] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.334447] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.334448] <-- nfs41_setup_sequence slotid=0 seqid=12
[59260.334449] <-- nfs4_setup_sequence status=0
[59260.334452] encode_sequence: sessionid=1344524732:4:4:0 seqid=12 slotid=0 max_slotid=0 cache_this=0
[59260.334687] decode_attr_type: type=040000
[59260.334688] decode_attr_change: change attribute=13246251234597893889
[59260.334690] decode_attr_size: file size=4096
[59260.334690] decode_attr_fsid: fsid=(0x0/0x0)
[59260.334691] decode_attr_fileid: fileid=2
[59260.334692] decode_attr_fs_locations: fs_locations done, error = 0
[59260.334693] decode_attr_mode: file mode=0755
[59260.334694] decode_attr_nlink: nlink=3
[59260.334696] decode_attr_owner: uid=0
[59260.334697] decode_attr_group: gid=0
[59260.334698] decode_attr_rdev: rdev=(0x0:0x0)
[59260.334699] decode_attr_space_used: space used=4096
[59260.334700] decode_attr_time_access: atime=1344525504
[59260.334701] decode_attr_time_metadata: ctime=1344525495
[59260.334701] decode_attr_time_modify: mtime=1344525495
[59260.334702] decode_attr_mounted_on_fileid: fileid=0
[59260.334703] decode_getfattr_attrs: xdr returned 0
[59260.334704] decode_getfattr_generic: xdr returned 0
[59260.334705] nfs41_sequence_done: Error 0 free the slot 
[59260.334706] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.334725] NFS: nfs_fhget(0:34/2 fh_crc=0x62d40c52 ct=1)
[59260.334727] <-- nfs4_get_root()
[59260.334734] --> nfs41_call_sync_prepare data->seq_server ffff88003c8d7800
[59260.334735] --> nfs4_setup_sequence clp ffff88003c733400 session ffff88003c733c00 sr_slot -1
[59260.334736] --> nfs41_setup_sequence
[59260.334737] --> nfs4_find_slot used_slots=0000 highest_used=4294967295 max_slots=16
[59260.334738] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[59260.334739] <-- nfs41_setup_sequence slotid=0 seqid=13
[59260.334740] <-- nfs4_setup_sequence status=0
[59260.334743] encode_sequence: sessionid=1344524732:4:4:0 seqid=13 slotid=0 max_slotid=0 cache_this=0
[59260.334965] decode_attr_type: type=00
[59260.334966] decode_attr_change: change attribute=13246251234597893889
[59260.334977] decode_attr_size: file size=4096
[59260.334978] decode_attr_fsid: fsid=(0x0/0x0)
[59260.334979] decode_attr_fileid: fileid=0
[59260.334980] decode_attr_fs_locations: fs_locations done, error = 0
[59260.334981] decode_attr_mode: file mode=00
[59260.334982] decode_attr_nlink: nlink=1
[59260.334983] decode_attr_owner: uid=-2
[59260.334983] decode_attr_group: gid=-2
[59260.334984] decode_attr_rdev: rdev=(0x0:0x0)
[59260.334985] decode_attr_space_used: space used=0
[59260.334986] decode_attr_time_access: atime=0
[59260.334987] decode_attr_time_metadata: ctime=1344525495
[59260.334988] decode_attr_time_modify: mtime=1344525495
[59260.334988] decode_attr_mounted_on_fileid: fileid=0
[59260.334989] decode_getfattr_attrs: xdr returned 0
[59260.334990] decode_getfattr_generic: xdr returned 0
[59260.334991] nfs41_sequence_done: Error 0 free the slot 
[59260.334992] nfs4_free_slot: slotid 16 highest_used_slotid -1
[59260.334997] NFS: nfs_update_inode(0:34/2 fh_crc=0x62d40c52 ct=2 info=0x26040)
[59260.334999] NFS: permission(0:34/2), mask=0x1, res=0
[59260.335002] NFS: nfs_lookup_revalidate(/) is valid
[59260.335009] <-- nfs4_try_mount() = 0
[59260.335011] <-- nfs4_mount() = 0
[root@client3 Downloads]# 






-------- Original-Nachricht --------
> Datum: Fri, 10 Aug 2012 01:12:19 +0800
> Von: Peng Tao <tao.peng@emc.com>
> An: Johannes Schild <JSchild@gmx.de>
> CC: rees@umich.edu, linux-nfs@vger.kernel.org
> Betreff: Re: RE: Blocklayout

> On Thu, Aug 9, 2012 at 11:27 PM, Johannes Schild <JSchild@gmx.de> wrote:
> >
> > -------- Original-Nachricht --------
> >> Datum: Thu, 9 Aug 2012 04:56:07 -0400
> >> Von: "Peng, Tao" <tao.peng@emc.com>
> >> An: Johannes Schild <JSchild@gmx.de>, "rees@umich.edu" <rees@umich.edu>
> >> CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
> >> Betreff: RE: Blocklayout
> >
> >>
> >> > -----Original Message-----
> >> > From: linux-nfs-owner@vger.kernel.org
> >> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Johannes
> >> > Schild
> >> > Sent: Thursday, August 09, 2012 4:43 PM
> >> > To: Johannes Schild; rees@umich.edu
> >> > Cc: linux-nfs@vger.kernel.org
> >> > Subject: Re: Blocklayout
> >> >
> >> > Hi Guys,
> >> >
> >> > some additional Information,
> >> >
> >> > [ 1644.874549] FS-Cache: Loaded
> >> > [ 1644.895122] NFS: Registering the id_resolver key type
> >> > [ 1644.895158] FS-Cache: Netfs 'nfs' registered for caching
> >> > [ 1644.920204] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1644.920207] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1644.920208] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1644.920263] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1644.920264] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1644.920265] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1653.129460] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1653.129463] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1653.129464] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1653.129528] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1653.129530] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1653.129531] blkmapd: sending ioctl 2285 to a partition!
> >> > [ 1653.136682] NFS: set_pnfs_layoutdriver: Error initializing pNFS
> >> layout driver 3.
> >> >
> >> > someone any ideas whats going wrong? The above output is from dmesg.
> >> > Iam using 3.4.7-1.fc16.x86_64 Kernel from Fedora. The utils are from
> >> > http://steved.fedorapeople.org/repos/pnfs.
> >> >
> >> There is a regression about saving proper pnfs_blksize before setting
> >> block layout driver by commit e38eb650 (NFS: set_pnfs_layoutdriver()
> from
> >> nfs4_proc_fsinfo()).
> >> If your client includes the specific commit (although I don't think the
> >> commit is in 3.4 kernel), please retry after applying the fix at
> >> http://www.spinics.net/lists/linux-nfs/msg31868.html
> >
> > The patch doesn't fit my kernel. My cliet.c looks a little bit different
> from the client.c in the patch:
> >
> Then you don't have the buggy commit.
> 
> <snip...>
> > [  179.557893] FS-Cache: Loaded
> > [  179.563310] NFS: Registering the id_resolver key type
> > [  179.563339] FS-Cache: Netfs 'nfs' registered for caching
> > [  207.222318] NFS: set_pnfs_layoutdriver: Error initializing pNFS
> layout driver 3.
> This is the same log without nfs_debug. Please run
> "echo 65535 > /proc/sys/sunrpc/nfs_debug"
> and then mount, to get a verbose log output.
> 
> Thanks,
> Tao
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



Thanks
Johannes
