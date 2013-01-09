Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.agmk.net ([91.192.224.71]:43968 "EHLO mail.agmk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932233Ab3AIRo5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2013 12:44:57 -0500
From: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, baggins@pld-linux.org,
        Trond.Myklebust@netapp.com
Subject: Re: mount.nfs: cannot allocate memory.
Date: Wed, 09 Jan 2013 18:44:50 +0100
Message-ID: <2367820.SDlsSOm8Xm@localhost>
In-Reply-To: <50EADFED.1070505@RedHat.com>
References: <2891788.0SBnrhN2VX@pawels> <7762040.Ky7rEDhaoc@localhost> <50EADFED.1070505@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart2363706.GEJYFcet1t"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.

--nextPart2363706.GEJYFcet1t
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"

On Monday 07 of January 2013 09:47:09 Steve Dickson wrote:
>=20
> On 05/01/13 05:08, Pawe=C5=82 Sikora wrote:
> > On Thursday 03 of January 2013 09:42:01 Steve Dickson wrote:
> >>
> >> On 03/01/13 04:27, Pawe=C5=82 Sikora wrote:
> >>> Hi,
> >>>
> >>> with the latest nfs-1.2.7/kernel-3.7.1 tools i've noticed an erro=
r during autofs mounting.
> >>> reduced testcase shows that mount.nfs with 'vers=3D4' has a probl=
em:
> >>>
> >>> [root@chufu ~]# mount.nfs -v -o vers=3D4 192.168.2.100:/home/ates=
t/farm-local /mnt
> >>> mount.nfs: timeout set for Thu Jan  3 10:22:00 2013
> >>> mount.nfs: trying text-based options 'vers=3D4,addr=3D192.168.2.1=
00,clientaddr=3D192.168.2.103'
> >>> mount.nfs: mount(2): Cannot allocate memory
> >>> mount.nfs: Cannot allocate memory
> >>>
> >>> while the vers=3D3 works fine:
> >>>
> >>> [root@chufu ~]# mount.nfs -v -o vers=3D3 192.168.2.100:/home/ates=
t/farm-local /mnt
> >>> mount.nfs: timeout set for Thu Jan  3 10:22:04 2013
> >>> mount.nfs: trying text-based options 'vers=3D3,addr=3D192.168.2.1=
00'
> >>> mount.nfs: prog 100003, trying vers=3D3, prot=3D6
> >>> mount.nfs: trying 192.168.2.100 prog 100003 vers 3 prot TCP port =
2049
> >>> mount.nfs: prog 100005, trying vers=3D3, prot=3D17
> >>> mount.nfs: trying 192.168.2.100 prog 100005 vers 3 prot UDP port =
42412
> >>>
> >>> no obvious errors in logs on nfs server/client side :(
> >>> i can provide more info if you need to diagnose this issue.
> >>
> >> Please set the kernel debugging with 'rpcdebug -m nfs -s mount' th=
en post the out put found in /var/log/messages.
> >=20
> > [root@pawels ~]# mount.nfs -v -o vers=3D4 192.168.2.100:/home/atest=
/farm-local /mnt
> >=20
> > mount.nfs: timeout set for Sat Jan  5 11:08:42 2013
> > mount.nfs: trying text-based options 'vers=3D4,addr=3D192.168.2.100=
,clientaddr=3D10.0.2.35'
> > mount.nfs: mount(2): Cannot allocate memory
> > mount.nfs: Cannot allocate memory
> >=20
> > [root@pawels ~]# dmesg|tail                                        =
             =20
> >=20
> > [ 4187.654183] NFS: nfs mount opts=3D'vers=3D4,addr=3D192.168.2.100=
,clientaddr=3D10.0.2.35'
> > [ 4187.654188] NFS:   parsing nfs mount option 'vers=3D4'
> > [ 4187.654193] NFS:   parsing nfs mount option 'addr=3D192.168.2.10=
0'
> > [ 4187.654198] NFS:   parsing nfs mount option 'clientaddr=3D10.0.2=
.35'
> > [ 4187.654204] NFS: MNTPATH: '/home/atest/farm-local'
> > [ 4187.654206] --> nfs4_try_mount()
> > [ 4187.975255] <-- nfs4_try_mount() =3D -12 [error]
> >=20
> Hmm... it appears to me that the kernel modules are not be loaded...=20=

> What does 'lsmod | grep nfs' show, anything?
>=20
> steved.

in fact, all modules are automatically loaded by kernel. better log att=
ached.

--nextPart2363706.GEJYFcet1t
Content-Disposition: inline; filename="nfs.txt"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="nfs.txt"

[root@pawels ~]# rpcdebug -m nfs -s all                                
nfs        vfs dircache lookupcache pagecache proc xdr file root callback client mount fscache pnfs pnfs_ld state

[root@pawels ~]# lsmod|grep nfs                                        
nfsv4                 150390  0 
nfsv3                  39327  0 
nfs                   168978  2 nfsv3,nfsv4
dns_resolver           13064  1 nfs
fscache                46138  1 nfs
nfsd                  273079  13 
auth_rpcgss            40327  2 nfsd,nfsv4
nfs_acl                12742  2 nfsd,nfsv3
lockd                  89142  3 nfs,nfsd,nfsv3
sunrpc                245986  153 nfs,nfsd,auth_rpcgss,lockd,nfsv3,nfsv4,nfs_acl

[root@pawels ~]# mount.nfs -v 192.168.2.100:/home/atest/farm-local /mnt
mount.nfs: timeout set for Wed Jan  9 15:19:14 2013
mount.nfs: trying text-based options 'vers=4,addr=192.168.2.100,clientaddr=10.0.2.35'
mount.nfs: mount(2): Cannot allocate memory
mount.nfs: Cannot allocate memory

[364653.942259] NFS: nfs mount opts='vers=4,addr=192.168.2.100,clientaddr=10.0.2.35'
[364653.942265] NFS:   parsing nfs mount option 'vers=4'
[364653.942270] NFS:   parsing nfs mount option 'addr=192.168.2.100'
[364653.942275] NFS:   parsing nfs mount option 'clientaddr=10.0.2.35'
[364653.942280] NFS: MNTPATH: '/home/atest/farm-local'
[364653.942282] --> nfs4_try_mount()
[364653.942289] --> nfs4_create_server()
[364653.942315] --> nfs4_init_server()
[364653.942317] --> nfs4_set_client()
[364653.942319] --> nfs_get_client(192.168.2.100,v4)
[364653.942326] NFS: get client cookie (0xffff880099f63c00/0xffff8802099b90a0)
[364654.109249] nfs_callback_create_svc: service created
[364654.109254] NFS: create per-net callback data; net=ffffffff81865400
[364654.109280] NFS: Callback listener port = 56756 (af 2, net ffffffff81865400)
[364654.109292] NFS: Callback listener port = 47890 (af 10, net ffffffff81865400)
[364654.109600] nfs_callback_up: service started
[364654.109605] NFS: nfs4_discover_server_trunking: testing '192.168.2.100'
[364654.109612] NFS call  setclientid auth=UNIX, 'Linux NFSv4.0 10.0.2.35/192.168.2.100 tcp'
[364654.180335] NFS reply setclientid: 0
[364654.180343] NFS call  setclientid_confirm auth=UNIX, (client ID 7c7eed5002000000)
[364654.256157] decode_attr_lease_time: file size=90
[364654.256160] decode_attr_maxfilesize: maxfilesize=0
[364654.256162] decode_attr_maxread: maxread=1024
[364654.256163] decode_attr_maxwrite: maxwrite=1024
[364654.256164] decode_attr_time_delta: time_delta=0 0
[364654.256166] decode_attr_pnfstype: bitmap is 0
[364654.256167] decode_attr_layout_blksize: bitmap is 0
[364654.256169] decode_fsinfo: xdr returned 0!
[364654.256176] NFS reply setclientid_confirm: 0
[364654.256178] --> nfs_put_client({2})
[364654.256180] NFS: <-- nfs40_walk_client_list using nfs_client = ffff880099f63c00 ({1})
[364654.256183] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
[364654.256186] NFS: nfs4_discover_server_trunking: status = 0
[364654.256188] <-- nfs4_set_client() = 0 [new ffff880099f63c00]
[364654.256214] <-- nfs4_init_server() = 0
[364654.256216] --> nfs4_get_rootfh()
[364654.314209] decode_attr_type: type=040000
[364654.314213] decode_attr_change: change attribute=5831456116311064576
[364654.314215] decode_attr_size: file size=4096
[364654.314217] decode_attr_fsid: fsid=(0x0/0x0)
[364654.314218] decode_attr_fileid: fileid=2
[364654.314221] decode_attr_fs_locations: fs_locations done, error = 0
[364654.314222] decode_attr_mode: file mode=0755
[364654.314224] decode_attr_nlink: nlink=28
[364654.314227] decode_attr_owner: uid=0
[364654.314229] decode_attr_group: gid=0
[364654.314230] decode_attr_rdev: rdev=(0x0:0x0)
[364654.314232] decode_attr_space_used: space used=4096
[364654.314234] decode_attr_time_access: atime=1357741696
[364654.314236] decode_attr_time_metadata: ctime=1357741681
[364654.314237] decode_attr_time_modify: mtime=1357741681
[364654.314239] decode_attr_mounted_on_fileid: fileid=0
[364654.314240] decode_getfattr_attrs: xdr returned 0
[364654.314243] decode_getfattr_generic: xdr returned 0
[364654.378213] decode_attr_supported: bitmask=fdffafff:00f9be3e:00000000
[364654.378218] decode_attr_fh_expire_type: expire type=0x0
[364654.378220] decode_attr_link_support: link support=true
[364654.378221] decode_attr_symlink_support: symlink support=true
[364654.378223] decode_attr_aclsupport: ACLs supported=0
[364654.378225] decode_server_caps: xdr returned 0!
[364654.447161] decode_attr_lease_time: file size=90
[364654.447166] decode_attr_maxfilesize: maxfilesize=18446744073709551615
[364654.447168] decode_attr_maxread: maxread=1048576
[364654.447170] decode_attr_maxwrite: maxwrite=1048576
[364654.447173] decode_attr_time_delta: time_delta=1 0
[364654.447175] decode_attr_pnfstype: bitmap is 0
[364654.447177] decode_attr_layout_blksize: bitmap is 0
[364654.447179] decode_fsinfo: xdr returned 0!
[364654.447188] <-- nfs4_get_rootfh() = 0
[364654.447190] Server FSID: 0:0
[364654.447192] Mount FH: 8
[364654.447194] --> nfs_probe_fsinfo()
[364654.521091] decode_attr_supported: bitmask=fdffafff:00f9be3e:00000000
[364654.521094] decode_attr_fh_expire_type: expire type=0x0
[364654.521096] decode_attr_link_support: link support=true
[364654.521098] decode_attr_symlink_support: symlink support=true
[364654.521099] decode_attr_aclsupport: ACLs supported=0
[364654.521101] decode_server_caps: xdr returned 0!
[364654.583056] decode_attr_lease_time: file size=90
[364654.583058] decode_attr_maxfilesize: maxfilesize=18446744073709551615
[364654.583060] decode_attr_maxread: maxread=1048576
[364654.583061] decode_attr_maxwrite: maxwrite=1048576
[364654.583063] decode_attr_time_delta: time_delta=1 0
[364654.583064] decode_attr_pnfstype: bitmap is 0
[364654.583066] decode_attr_layout_blksize: bitmap is 0
[364654.583067] decode_fsinfo: xdr returned 0!
[364654.658078] decode_attr_maxlink: maxlink=255
[364654.658082] decode_attr_maxname: maxname=255
[364654.658083] decode_pathconf: xdr returned 0!
[364654.658090] <-- nfs_probe_fsinfo() = 0
[364654.658093] <-- nfs4_create_server() = ffff880209d86800
[364654.658183] NFS: get superblock cookie (0xffff880209d86800/0xffff880211934690)
[364654.723023] decode_attr_supported: bitmask=fdffafff:00f9be3e:00000000
[364654.723026] decode_attr_fh_expire_type: expire type=0x0
[364654.723028] decode_attr_link_support: link support=true
[364654.723030] decode_attr_symlink_support: symlink support=true
[364654.723031] decode_attr_aclsupport: ACLs supported=0
[364654.723033] decode_server_caps: xdr returned 0!
[364654.801009] decode_attr_type: type=040000
[364654.801013] decode_attr_change: change attribute=5831456116311064576
[364654.801015] decode_attr_size: file size=4096
[364654.801016] decode_attr_fsid: fsid=(0x0/0x0)
[364654.801018] decode_attr_fileid: fileid=2
[364654.801020] decode_attr_fs_locations: fs_locations done, error = 0
[364654.801022] decode_attr_mode: file mode=0755
[364654.801024] decode_attr_nlink: nlink=28
[364654.801027] decode_attr_owner: uid=0
[364654.801028] decode_attr_group: gid=0
[364654.801030] decode_attr_rdev: rdev=(0x0:0x0)
[364654.801032] decode_attr_space_used: space used=4096
[364654.801034] decode_attr_time_access: atime=1357741696
[364654.801035] decode_attr_time_metadata: ctime=1357741681
[364654.801037] decode_attr_time_modify: mtime=1357741681
[364654.801038] decode_attr_mounted_on_fileid: fileid=0
[364654.801040] decode_getfattr_attrs: xdr returned 0
[364654.801042] decode_getfattr_generic: xdr returned 0
[364654.801056] NFS: nfs_fhget(0:26/2 fh_crc=0x62d40c52 ct=1)
[364654.864173] decode_attr_type: type=00
[364654.864177] decode_attr_change: change attribute=5831456116311064576
[364654.864179] decode_attr_size: file size=4096
[364654.864180] decode_attr_fsid: fsid=(0x0/0x0)
[364654.864182] decode_attr_fileid: fileid=0
[364654.864184] decode_attr_fs_locations: fs_locations done, error = 0
[364654.864186] decode_attr_mode: file mode=00
[364654.864187] decode_attr_nlink: nlink=1
[364654.864189] decode_attr_owner: uid=-2
[364654.864191] decode_attr_group: gid=-2
[364654.864192] decode_attr_rdev: rdev=(0x0:0x0)
[364654.864194] decode_attr_space_used: space used=0
[364654.864196] decode_attr_time_access: atime=0
[364654.864197] decode_attr_time_metadata: ctime=1357741681
[364654.864199] decode_attr_time_modify: mtime=1357741681
[364654.864201] decode_attr_mounted_on_fileid: fileid=0
[364654.864202] decode_getfattr_attrs: xdr returned 0
[364654.864204] decode_getfattr_generic: xdr returned 0
[364654.864213] NFS: nfs_update_inode(0:26/2 fh_crc=0x62d40c52 ct=2 info=0x26040)
[364654.864218] NFS: permission(0:26/2), mask=0x1, res=0
[364654.864222] NFS: permission(0:26/2), mask=0x1, res=0
[364654.864226] NFS: lookup(/home)
[364654.864229] NFS call  lookup home
[364654.941877] decode_attr_type: type=040000
[364654.941881] decode_attr_change: change attribute=5787575346372492205
[364654.941883] decode_attr_size: file size=4096
[364654.941885] decode_attr_fsid: fsid=(0xdb103cf865ee4fc9/0x80976379169865f6)
[364654.941887] decode_attr_fileid: fileid=2
[364654.941889] decode_attr_fs_locations: fs_locations done, error = 0
[364654.941891] decode_attr_mode: file mode=0755
[364654.941892] decode_attr_nlink: nlink=7
[364654.941894] decode_attr_owner: uid=0
[364654.941896] decode_attr_group: gid=0
[364654.941898] decode_attr_rdev: rdev=(0x0:0x0)
[364654.941900] decode_attr_space_used: space used=4096
[364654.941901] decode_attr_time_access: atime=1346069707
[364654.941903] decode_attr_time_metadata: ctime=1347524893
[364654.941905] decode_attr_time_modify: mtime=1347524893
[364654.941906] decode_attr_mounted_on_fileid: fileid=0
[364654.941908] decode_getfattr_attrs: xdr returned 0
[364654.941910] decode_getfattr_generic: xdr returned 0
[364654.941916] NFS reply lookup: 0
[364654.941923] NFS: nfs_fhget(0:26/2 fh_crc=0x58dab32e ct=1)
[364654.941927] --> nfs_d_automount()
[364654.941930] nfs_d_automount: enter
[364654.941954] NFS call  lookup home
[364655.015886] decode_attr_type: type=040000
[364655.015890] decode_attr_change: change attribute=5787575346372492205
[364655.015892] decode_attr_size: file size=4096
[364655.015894] decode_attr_fsid: fsid=(0xdb103cf865ee4fc9/0x80976379169865f6)
[364655.015895] decode_attr_fileid: fileid=2
[364655.015897] decode_attr_fs_locations: fs_locations done, error = 0
[364655.015899] decode_attr_mode: file mode=0755
[364655.015901] decode_attr_nlink: nlink=7
[364655.015903] decode_attr_owner: uid=0
[364655.015904] decode_attr_group: gid=0
[364655.015906] decode_attr_rdev: rdev=(0x0:0x0)
[364655.015908] decode_attr_space_used: space used=4096
[364655.015910] decode_attr_time_access: atime=1346069707
[364655.015911] decode_attr_time_metadata: ctime=1347524893
[364655.015913] decode_attr_time_modify: mtime=1347524893
[364655.015915] decode_attr_mounted_on_fileid: fileid=0
[364655.015916] decode_getfattr_attrs: xdr returned 0
[364655.015918] decode_getfattr_generic: xdr returned 0
[364655.015924] NFS reply lookup: 0
[364655.015928] --> nfs_do_submount()
[364655.015930] nfs_do_submount: submounting on /home
[364655.015947] --> nfs_xdev_mount_common()
[364655.015949] --> nfs_clone_server(,db103cf865ee4fc9:80976379169865f6,)
[364655.015986] --> nfs_probe_fsinfo()
[364655.085984] nfs_probe_fsinfo: error = 116
[364655.085988] --> nfs_free_server()
[364655.107578] --> nfs_put_client({2})
[364655.107597] <-- nfs_free_server()
[364655.107599] <-- nfs_clone_server() = error -116
[364655.107600] <-- nfs_xdev_mount_common() = -116 [error]
[364655.107607] nfs_do_submount: done
[364655.107609] <-- nfs_do_submount() = fffffffffffffff4
[364655.107619] <-- nfs_d_automount(): error -12
[364655.107622] NFS: dentry_delete(/home, 2008c)
[364655.107739] NFS: clear cookie (0xffff8800b0163468/0x          (null))
[364655.107742] NFS: clear cookie (0xffff8800b0163870/0x          (null))
[364655.107826] NFS: releasing superblock cookie (0xffff880209d86800/0xffff880211934690)
[364655.107829] --> nfs_free_server()
[364655.107874] --> nfs_put_client({1})
[364655.107881] NFS: destroy per-net callback data; net=ffffffff81865400
[364655.107960] nfs_callback_down: service stopped
[364655.107972] nfs_callback_down: service destroyed
[364655.107979] --> nfs_free_client(4)
[364655.107981] NFS: releasing client cookie (0xffff880099f63c00/0xffff8802099b90a0)
[364655.108012] <-- nfs_free_client()
[364655.108028] <-- nfs_free_server()
[364655.108041] <-- nfs4_try_mount() = -12 [error]
--nextPart2363706.GEJYFcet1t--

