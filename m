Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:38262 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934735AbcIFWmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 18:42:38 -0400
From: Oleg Drokin <green@linuxhacker.ru>
Content-Type: text/plain; charset=windows-1252
Subject: NFS client stuck in a tight loop
Date: Tue, 6 Sep 2016 18:42:27 -0400
Message-Id: <0ABF496B-2E1F-46B6-A3EA-55C447F71073@linuxhacker.ru>
Cc: Trond Myklebust <trondmy@primarydata.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Apple Message framework v1283)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

  I saw this in 4.6-rc and it's still there in 4.8-rc5 and judging by commit history
  might have been there since all the way to 2008 (or something since then made it
  possible).

  Basically nfs client gets stuck in nfs4_reclaim_open_state() looping in:

restart:
        list_for_each_entry(state, &sp->so_states, open_states) {
…
                status = ops->recover_open(sp, state);
                if (status >= 0) {   // <=== Status is always 0 here in the loop
…
                                goto restart;
		}
	}

The -1 nfs debug looks like this looping over and over (note the
two different fh_crc values):

[10666.109326] NFS: nfs_update_inode(0:48/184 fh_crc=0x86636bbd ct=4 info=0x427e7f)
[10666.109327] NFS: nfs_fhget(0:48/184 fh_crc=0x86636bbd ct=4)
[10666.109329] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[10666.109346] --> nfs4_setup_sequence clp ffff880098c86800 session ffff8800d6473800 sr_slot 4294967295
[10666.109347] --> nfs41_setup_sequence
[10666.109347] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[10666.109348] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[10666.109348] <-- nfs41_setup_sequence slotid=0 seqid=40242184
[10666.109349] <-- nfs4_setup_sequence status=0
[10666.109357] encode_sequence: sessionid=1473188904:1:2:0 seqid=40242184 slotid=0 max_slotid=0 cache_this=1
[10666.109495] decode_attr_type: type=0100000
[10666.109495] decode_attr_change: change attribute=6327302647620605281
[10666.109496] decode_attr_size: file size=32592
[10666.109496] decode_attr_fsid: fsid=(0x0/0x0)
[10666.109497] decode_attr_fileid: fileid=33
[10666.109497] decode_attr_fs_locations: fs_locations done, error = 0
[10666.109497] decode_attr_mode: file mode=01752
[10666.109498] decode_attr_nlink: nlink=0
[10666.109499] decode_attr_owner: uid=-2
[10666.109499] decode_attr_group: gid=-2
[10666.109500] decode_attr_rdev: rdev=(0x0:0x0)
[10666.109500] decode_attr_space_used: space used=36864
[10666.109500] decode_attr_time_access: atime=1473189948
[10666.109501] decode_attr_time_metadata: ctime=1473189948
[10666.109501] decode_attr_time_modify: mtime=1473189948
[10666.109501] decode_attr_mounted_on_fileid: fileid=33
[10666.109502] decode_getfattr_attrs: xdr returned 0
[10666.109502] decode_getfattr_generic: xdr returned 0
[10666.109503] nfs41_handle_sequence_flag_errors: "localhost" (client ID 2814cf5701000000) flags=0x00000040
[10666.109514] nfs41_handle_some_state_revoked: state revoked on server localhost
[10666.109514] nfs41_handle_recallable_state_revoked: Recallable state revoked on server localhost!
[10666.109515] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[10666.109516] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[10666.109516] nfs4_free_slot: slotid 1 highest_used_slotid 0
[10666.109517] nfs41_sequence_process: Error 0 free the slot 
[10666.109547] NFS: nfs_update_inode(0:48/33 fh_crc=0x7318ec88 ct=3 info=0x427e7f)
[10666.109548] NFS: nfs_fhget(0:48/33 fh_crc=0x7318ec88 ct=3)
[10666.109551] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[10666.109568] --> nfs4_setup_sequence clp ffff880098c86800 session ffff8800d6473800 sr_slot 4294967295
[10666.109568] --> nfs41_setup_sequence
[10666.109569] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[10666.109569] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[10666.109570] <-- nfs41_setup_sequence slotid=0 seqid=40242185
[10666.109570] <-- nfs4_setup_sequence status=0
[10666.109577] encode_sequence: sessionid=1473188904:1:2:0 seqid=40242185 slotid=0 max_slotid=0 cache_this=1
[10666.109710] decode_attr_type: type=0100000
[10666.109710] decode_attr_change: change attribute=6327303042766923666
[10666.109711] decode_attr_size: file size=4096
[10666.109711] decode_attr_fsid: fsid=(0x0/0x0)
[10666.109711] decode_attr_fileid: fileid=184
[10666.109712] decode_attr_fs_locations: fs_locations done, error = 0
[10666.109712] decode_attr_mode: file mode=03461
[10666.109712] decode_attr_nlink: nlink=0
[10666.109713] decode_attr_owner: uid=-2
[10666.109714] decode_attr_group: gid=-2
[10666.109714] decode_attr_rdev: rdev=(0x0:0x0)
[10666.109715] decode_attr_space_used: space used=4096
[10666.109715] decode_attr_time_access: atime=1473189947
[10666.109715] decode_attr_time_metadata: ctime=1473190040
[10666.109716] decode_attr_time_modify: mtime=1473190040
[10666.109716] decode_attr_mounted_on_fileid: fileid=184
[10666.109717] decode_getfattr_attrs: xdr returned 0
[10666.109717] decode_getfattr_generic: xdr returned 0
[10666.109718] nfs41_handle_sequence_flag_errors: "localhost" (client ID 2814cf5701000000) flags=0x00000040
[10666.109729] nfs41_handle_some_state_revoked: state revoked on server localhost
[10666.109729] nfs41_handle_recallable_state_revoked: Recallable state revoked on server localhost!
[10666.109730] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[10666.109730] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[10666.109731] nfs4_free_slot: slotid 1 highest_used_slotid 0
[10666.109732] nfs41_sequence_process: Error 0 free the slot 


Server side messages at -1 level look like this (from another instance):

[154944.451610] renewing client (clientid 57ce4a54/00000031)
[154944.451740] nfsd_dispatch: vers 4 proc 1
[154944.451741] nfsv4 compound op #1/5: 53 (OP_SEQUENCE)
[154944.451743] __find_in_sessionid_hashtbl: 1473137236:49:50:0
[154944.451744] nfsd4_sequence: slotid 0
[154944.451745] check_slot_seqid enter. seqid 355302832 slot_seqid 355302831
[154944.451747] nfsv4 compound op ffff8800b0664080 opcnt 5 #1: 53: status 0
[154944.451748] nfsv4 compound op #2/5: 22 (OP_PUTFH)
[154944.451749] nfsd: fh_verify(16: 01010001 00000000 00000324 30202305 00000000 00000000)
[154944.451757] nfsv4 compound op ffff8800b0664080 opcnt 5 #2: 22: status 0
[154944.451758] nfsv4 compound op #3/5: 18 (OP_OPEN)
[154944.451759] NFSD: nfsd4_open filename  op_openowner           (null)
[154944.451768] nfsd: fh_verify(16: 01010001 00000000 00000324 30202305 00000000 00000000)
[154944.451773] nfsd4_process_open2: stateid=(57ce4a54/00000031/00000247/0a96b4a5)
[154944.451788] nfsv4 compound op ffff8800b0664080 opcnt 5 #3: 18: status 0
[154944.451788] nfsv4 compound op #4/5: 3 (OP_ACCESS)
[154944.451790] nfsd: fh_verify(16: 01010001 00000000 00000324 30202305 00000000 00000000)
[154944.451794] nfsv4 compound op ffff8800b0664080 opcnt 5 #4: 3: status 0
[154944.451795] nfsv4 compound op #5/5: 9 (OP_GETATTR)
[154944.451796] nfsd: fh_verify(16: 01010001 00000000 00000324 30202305 00000000 00000000)
[154944.451800] nfsv4 compound op ffff8800b0664080 opcnt 5 #5: 9: status 0
[154944.451801] nfsv4 compound returned 0
[154944.451802] --> nfsd4_store_cache_entry slot ffff8800a7629000
[154944.451803] renewing client (clientid 57ce4a54/00000031)
[154944.452019] nfsd_dispatch: vers 4 proc 1
[154944.452020] nfsv4 compound op #1/5: 53 (OP_SEQUENCE)
[154944.452022] __find_in_sessionid_hashtbl: 1473137236:49:50:0
[154944.452023] nfsd4_sequence: slotid 0
[154944.452024] check_slot_seqid enter. seqid 355302833 slot_seqid 355302832
[154944.452026] nfsv4 compound op ffff8800aa787080 opcnt 5 #1: 53: status 0
[154944.452026] nfsv4 compound op #2/5: 22 (OP_PUTFH)
[154944.452028] nfsd: fh_verify(16: 01010001 00000000 000002f4 302021dd 00000000 00000000)
[154944.452037] nfsv4 compound op ffff8800aa787080 opcnt 5 #2: 22: status 0
[154944.452037] nfsv4 compound op #3/5: 18 (OP_OPEN)
[154944.452038] NFSD: nfsd4_open filename  op_openowner           (null)
[154944.452054] nfsd: fh_verify(16: 01010001 00000000 000002f4 302021dd 00000000 00000000)
[154944.452059] nfsd4_process_open2: stateid=(57ce4a54/00000031/00000246/0a96b4a5)
[154944.452076] nfsv4 compound op ffff8800aa787080 opcnt 5 #3: 18: status 0
[154944.452076] nfsv4 compound op #4/5: 3 (OP_ACCESS)
[154944.452078] nfsd: fh_verify(16: 01010001 00000000 000002f4 302021dd 00000000 00000000)
[154944.452081] nfsv4 compound op ffff8800aa787080 opcnt 5 #4: 3: status 0
[154944.452082] nfsv4 compound op #5/5: 9 (OP_GETATTR)
[154944.452083] nfsd: fh_verify(16: 01010001 00000000 000002f4 302021dd 00000000 00000000)
[154944.452087] nfsv4 compound op ffff8800aa787080 opcnt 5 #5: 9: status 0
[154944.452088] nfsv4 compound returned 0
[154944.452088] --> nfsd4_store_cache_entry slot ffff8800a7629000


This is fairly easy to reproduce (though takes some time).
Once client enters this state, some kernel threads are stuck at 100% cpu,
there's a bunch of processes in D state and the mountpoint is pinned

You can do umount -f and then unmount does work on the second try,
this also results in the following dmesg message:
[155381.995368] NFS: nfs4_reclaim_open_state: unhandled error -5

I don't know this code well enough to take my own stab at a fix, but I can
help testing if needed.

Bye,
    Oleg

