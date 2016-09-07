Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:43721 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751970AbcIGOfL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Sep 2016 10:35:11 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Oleg Drokin <green@linuxhacker.ru>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: NFS client stuck in a tight loop
Date: Wed, 7 Sep 2016 14:35:04 +0000
Message-ID: <59CD8653-D109-408E-A5BA-124220051094@primarydata.com>
References: <0ABF496B-2E1F-46B6-A3EA-55C447F71073@linuxhacker.ru>
In-Reply-To: <0ABF496B-2E1F-46B6-A3EA-55C447F71073@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Oleg,


> On Sep 6, 2016, at 18:42, Oleg Drokin <green@linuxhacker.ru> wrote:
>=20
> Hello!
>=20
>  I saw this in 4.6-rc and it's still there in 4.8-rc5 and judging by comm=
it history
>  might have been there since all the way to 2008 (or something since then=
 made it
>  possible).
>=20
>  Basically nfs client gets stuck in nfs4_reclaim_open_state() looping in:
>=20
> restart:
>        list_for_each_entry(state, &sp->so_states, open_states) {
> =85
>                status =3D ops->recover_open(sp, state);
>                if (status >=3D 0) {   // <=3D=3D=3D Status is always 0 he=
re in the loop
> =85
>                                goto restart;
> =09=09}
> =09}
>=20
> The -1 nfs debug looks like this looping over and over (note the
> two different fh_crc values):
>=20
> [10666.109326] NFS: nfs_update_inode(0:48/184 fh_crc=3D0x86636bbd ct=3D4 =
info=3D0x427e7f)
> [10666.109327] NFS: nfs_fhget(0:48/184 fh_crc=3D0x86636bbd ct=3D4)
> [10666.109329] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [10666.109346] --> nfs4_setup_sequence clp ffff880098c86800 session ffff8=
800d6473800 sr_slot 4294967295
> [10666.109347] --> nfs41_setup_sequence
> [10666.109347] --> nfs4_alloc_slot used_slots=3D0000 highest_used=3D42949=
67295 max_slots=3D31
> [10666.109348] <-- nfs4_alloc_slot used_slots=3D0001 highest_used=3D0 slo=
tid=3D0
> [10666.109348] <-- nfs41_setup_sequence slotid=3D0 seqid=3D40242184
> [10666.109349] <-- nfs4_setup_sequence status=3D0
> [10666.109357] encode_sequence: sessionid=3D1473188904:1:2:0 seqid=3D4024=
2184 slotid=3D0 max_slotid=3D0 cache_this=3D1
> [10666.109495] decode_attr_type: type=3D0100000
> [10666.109495] decode_attr_change: change attribute=3D6327302647620605281
> [10666.109496] decode_attr_size: file size=3D32592
> [10666.109496] decode_attr_fsid: fsid=3D(0x0/0x0)
> [10666.109497] decode_attr_fileid: fileid=3D33
> [10666.109497] decode_attr_fs_locations: fs_locations done, error =3D 0
> [10666.109497] decode_attr_mode: file mode=3D01752
> [10666.109498] decode_attr_nlink: nlink=3D0
> [10666.109499] decode_attr_owner: uid=3D-2
> [10666.109499] decode_attr_group: gid=3D-2
> [10666.109500] decode_attr_rdev: rdev=3D(0x0:0x0)
> [10666.109500] decode_attr_space_used: space used=3D36864
> [10666.109500] decode_attr_time_access: atime=3D1473189948
> [10666.109501] decode_attr_time_metadata: ctime=3D1473189948
> [10666.109501] decode_attr_time_modify: mtime=3D1473189948
> [10666.109501] decode_attr_mounted_on_fileid: fileid=3D33
> [10666.109502] decode_getfattr_attrs: xdr returned 0
> [10666.109502] decode_getfattr_generic: xdr returned 0
> [10666.109503] nfs41_handle_sequence_flag_errors: "localhost" (client ID =
2814cf5701000000) flags=3D0x00000040
> [10666.109514] nfs41_handle_some_state_revoked: state revoked on server l=
ocalhost
> [10666.109514] nfs41_handle_recallable_state_revoked: Recallable state re=
voked on server localhost!
> [10666.109515] --> nfs4_alloc_slot used_slots=3D0001 highest_used=3D0 max=
_slots=3D31
> [10666.109516] <-- nfs4_alloc_slot used_slots=3D0003 highest_used=3D1 slo=
tid=3D1
> [10666.109516] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [10666.109517] nfs41_sequence_process: Error 0 free the slot=20
> [10666.109547] NFS: nfs_update_inode(0:48/33 fh_crc=3D0x7318ec88 ct=3D3 i=
nfo=3D0x427e7f)
> [10666.109548] NFS: nfs_fhget(0:48/33 fh_crc=3D0x7318ec88 ct=3D3)
> [10666.109551] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [10666.109568] --> nfs4_setup_sequence clp ffff880098c86800 session ffff8=
800d6473800 sr_slot 4294967295
> [10666.109568] --> nfs41_setup_sequence
> [10666.109569] --> nfs4_alloc_slot used_slots=3D0000 highest_used=3D42949=
67295 max_slots=3D31
> [10666.109569] <-- nfs4_alloc_slot used_slots=3D0001 highest_used=3D0 slo=
tid=3D0
> [10666.109570] <-- nfs41_setup_sequence slotid=3D0 seqid=3D40242185
> [10666.109570] <-- nfs4_setup_sequence status=3D0
> [10666.109577] encode_sequence: sessionid=3D1473188904:1:2:0 seqid=3D4024=
2185 slotid=3D0 max_slotid=3D0 cache_this=3D1
> [10666.109710] decode_attr_type: type=3D0100000
> [10666.109710] decode_attr_change: change attribute=3D6327303042766923666
> [10666.109711] decode_attr_size: file size=3D4096
> [10666.109711] decode_attr_fsid: fsid=3D(0x0/0x0)
> [10666.109711] decode_attr_fileid: fileid=3D184
> [10666.109712] decode_attr_fs_locations: fs_locations done, error =3D 0
> [10666.109712] decode_attr_mode: file mode=3D03461
> [10666.109712] decode_attr_nlink: nlink=3D0
> [10666.109713] decode_attr_owner: uid=3D-2
> [10666.109714] decode_attr_group: gid=3D-2
> [10666.109714] decode_attr_rdev: rdev=3D(0x0:0x0)
> [10666.109715] decode_attr_space_used: space used=3D4096
> [10666.109715] decode_attr_time_access: atime=3D1473189947
> [10666.109715] decode_attr_time_metadata: ctime=3D1473190040
> [10666.109716] decode_attr_time_modify: mtime=3D1473190040
> [10666.109716] decode_attr_mounted_on_fileid: fileid=3D184
> [10666.109717] decode_getfattr_attrs: xdr returned 0
> [10666.109717] decode_getfattr_generic: xdr returned 0
> [10666.109718] nfs41_handle_sequence_flag_errors: "localhost" (client ID =
2814cf5701000000) flags=3D0x00000040
> [10666.109729] nfs41_handle_some_state_revoked: state revoked on server l=
ocalhost
> [10666.109729] nfs41_handle_recallable_state_revoked: Recallable state re=
voked on server localhost!
> [10666.109730] --> nfs4_alloc_slot used_slots=3D0001 highest_used=3D0 max=
_slots=3D31
> [10666.109730] <-- nfs4_alloc_slot used_slots=3D0003 highest_used=3D1 slo=
tid=3D1
> [10666.109731] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [10666.109732] nfs41_sequence_process: Error 0 free the slot=20
>=20
>=20
> Server side messages at -1 level look like this (from another instance):
>=20
> [154944.451610] renewing client (clientid 57ce4a54/00000031)
> [154944.451740] nfsd_dispatch: vers 4 proc 1
> [154944.451741] nfsv4 compound op #1/5: 53 (OP_SEQUENCE)
> [154944.451743] __find_in_sessionid_hashtbl: 1473137236:49:50:0
> [154944.451744] nfsd4_sequence: slotid 0
> [154944.451745] check_slot_seqid enter. seqid 355302832 slot_seqid 355302=
831
> [154944.451747] nfsv4 compound op ffff8800b0664080 opcnt 5 #1: 53: status=
 0
> [154944.451748] nfsv4 compound op #2/5: 22 (OP_PUTFH)
> [154944.451749] nfsd: fh_verify(16: 01010001 00000000 00000324 30202305 0=
0000000 00000000)
> [154944.451757] nfsv4 compound op ffff8800b0664080 opcnt 5 #2: 22: status=
 0
> [154944.451758] nfsv4 compound op #3/5: 18 (OP_OPEN)
> [154944.451759] NFSD: nfsd4_open filename  op_openowner           (null)
> [154944.451768] nfsd: fh_verify(16: 01010001 00000000 00000324 30202305 0=
0000000 00000000)
> [154944.451773] nfsd4_process_open2: stateid=3D(57ce4a54/00000031/0000024=
7/0a96b4a5)
> [154944.451788] nfsv4 compound op ffff8800b0664080 opcnt 5 #3: 18: status=
 0
> [154944.451788] nfsv4 compound op #4/5: 3 (OP_ACCESS)
> [154944.451790] nfsd: fh_verify(16: 01010001 00000000 00000324 30202305 0=
0000000 00000000)
> [154944.451794] nfsv4 compound op ffff8800b0664080 opcnt 5 #4: 3: status =
0
> [154944.451795] nfsv4 compound op #5/5: 9 (OP_GETATTR)
> [154944.451796] nfsd: fh_verify(16: 01010001 00000000 00000324 30202305 0=
0000000 00000000)
> [154944.451800] nfsv4 compound op ffff8800b0664080 opcnt 5 #5: 9: status =
0
> [154944.451801] nfsv4 compound returned 0
> [154944.451802] --> nfsd4_store_cache_entry slot ffff8800a7629000
> [154944.451803] renewing client (clientid 57ce4a54/00000031)
> [154944.452019] nfsd_dispatch: vers 4 proc 1
> [154944.452020] nfsv4 compound op #1/5: 53 (OP_SEQUENCE)
> [154944.452022] __find_in_sessionid_hashtbl: 1473137236:49:50:0
> [154944.452023] nfsd4_sequence: slotid 0
> [154944.452024] check_slot_seqid enter. seqid 355302833 slot_seqid 355302=
832
> [154944.452026] nfsv4 compound op ffff8800aa787080 opcnt 5 #1: 53: status=
 0
> [154944.452026] nfsv4 compound op #2/5: 22 (OP_PUTFH)
> [154944.452028] nfsd: fh_verify(16: 01010001 00000000 000002f4 302021dd 0=
0000000 00000000)
> [154944.452037] nfsv4 compound op ffff8800aa787080 opcnt 5 #2: 22: status=
 0
> [154944.452037] nfsv4 compound op #3/5: 18 (OP_OPEN)
> [154944.452038] NFSD: nfsd4_open filename  op_openowner           (null)
> [154944.452054] nfsd: fh_verify(16: 01010001 00000000 000002f4 302021dd 0=
0000000 00000000)
> [154944.452059] nfsd4_process_open2: stateid=3D(57ce4a54/00000031/0000024=
6/0a96b4a5)
> [154944.452076] nfsv4 compound op ffff8800aa787080 opcnt 5 #3: 18: status=
 0
> [154944.452076] nfsv4 compound op #4/5: 3 (OP_ACCESS)
> [154944.452078] nfsd: fh_verify(16: 01010001 00000000 000002f4 302021dd 0=
0000000 00000000)
> [154944.452081] nfsv4 compound op ffff8800aa787080 opcnt 5 #4: 3: status =
0
> [154944.452082] nfsv4 compound op #5/5: 9 (OP_GETATTR)
> [154944.452083] nfsd: fh_verify(16: 01010001 00000000 000002f4 302021dd 0=
0000000 00000000)
> [154944.452087] nfsv4 compound op ffff8800aa787080 opcnt 5 #5: 9: status =
0
> [154944.452088] nfsv4 compound returned 0
> [154944.452088] --> nfsd4_store_cache_entry slot ffff8800a7629000
>=20
>=20
> This is fairly easy to reproduce (though takes some time).
> Once client enters this state, some kernel threads are stuck at 100% cpu,
> there's a bunch of processes in D state and the mountpoint is pinned

Can you explain how you reproduce the problem? I can see what is happening,=
 but I=92m still not understanding why the server is getting into this stat=
e in the first place.

> You can do umount -f and then unmount does work on the second try,
> this also results in the following dmesg message:
> [155381.995368] NFS: nfs4_reclaim_open_state: unhandled error -5
>=20
> I don't know this code well enough to take my own stab at a fix, but I ca=
n
> help testing if needed.

I did send out a set of patches a week ago that addresses an issue in this =
area, and I know of a couple more holes that need to be plugged.

