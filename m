Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:59879 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab0ESPB4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 May 2010 11:01:56 -0400
Message-ID: <4BF3FD61.3010208@mobileobjects.de>
Date: Wed, 19 May 2010 17:01:53 +0200
From: Jan Stilow <jstilow@mobileobjects.de>
To: linux-nfs@vger.kernel.org
CC: chuck.lever@oracle.com
Subject: Re: NFS4 mount finishes after 2 hours
References: <4BF29CD8.4060008@mobileobjects.de> <4BF2A82C.6000704@oracle.com>
In-Reply-To: <4BF2A82C.6000704@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 18.05.2010 16:46, Chuck Lever wrote:
>> After you run "sysctl sunrpc.nfs_debug=1023" you can find "laundromat
>> service - starting" and "NFSD: laundromat_main - sleeping for 90
>> seconds" messages in your logs during the mount process. These messages
>> also repeat from time to time. Obviously the client communicates with
>> the server.
> 
> I suspect those messages do not reflect activity between the client and 
> server.

You're right. These messages appear every time also when no client tries
to connect to the server.

>> For me it looks like a problem with nfs and VM environments. So does
>> anyone have an idea?
> 
> Probably the network between client and server is not fully up when the 
> mount request is initiated.
> 
> It may be the case, for example, that a cold start of your guest means 
> Vbox has to reassign network resources (ie a DHCP-assigned IP address) 
> to the guest.  So there is probably a timing issue here that is causing 
> the initial connection attempt by the kernel to be somehow lost.
> 
> Somehow enabling RPC level debugging messages before the mount might be 
> illuminating.

I have completed a few more tests. With "sysctl sunrpc.nfs_debug=1023"
and "echo 2048 > /proc/sys/sunrpc/rpc_debug" running first. I attached
the log file lines from 11:27:00 to 11:27:59 of the client and server.
These lines will repeat the whole time the client tries to connect. Also
I attached the beginning and end of the logs during the mount processes.
(I used "......" as the separator)

While the client tries to connect to the server it is possible to use
the same interface to connect via ssh or ping. So the connection seems
to work well.

What else could I try?

Thanks for your effort.

Client:
^^^^^^^
May 19 09:30:26 nfs4-client kernel: [  175.846952] --> nfs4_create_server()
May 19 09:30:26 nfs4-client kernel: [  175.848960] --> nfs4_init_server()
May 19 09:30:26 nfs4-client kernel: [  175.852126] --> nfs4_set_client()
May 19 09:30:26 nfs4-client kernel: [  175.855776] -->
nfs_get_client(192.168.56.101,v4)
May 19 09:30:26 nfs4-client kernel: [  175.860291] Callback port = 0xb305
May 19 09:30:26 nfs4-client kernel: [  175.863171] --> nfs_get_client()
= ffff81000dd06800 [new]
May 19 09:30:26 nfs4-client kernel: [  175.880229] <-- nfs4_set_client()
= 0 [new ffff81000dd06800]
May 19 09:30:26 nfs4-client kernel: [  175.887299] <--
nfs4_init_server() = 0
May 19 09:30:26 nfs4-client kernel: [  175.888057] --> nfs4_path_walk(,,/)
......
May 19 11:27:03 nfs4-client kernel: [ 7173.178036] encode_compound: tag=
May 19 11:27:03 nfs4-client kernel: [ 7173.228106] decode_getfattr: xdr
returned 10008
May 19 11:27:18 nfs4-client kernel: [ 7188.245964] encode_compound: tag=
May 19 11:27:18 nfs4-client kernel: [ 7188.306898] decode_getfattr: xdr
returned 10008
May 19 11:27:33 nfs4-client kernel: [ 7203.311650] encode_compound: tag=
May 19 11:27:33 nfs4-client kernel: [ 7203.367546] decode_getfattr: xdr
returned 10008
May 19 11:27:48 nfs4-client kernel: [ 7218.368669] encode_compound: tag=
May 19 11:27:48 nfs4-client kernel: [ 7218.424182] decode_getfattr: xdr
returned 10008
......
May 19 11:28:18 nfs4-client kernel: [ 7248.491576] encode_compound: tag=
May 19 11:28:18 nfs4-client kernel: [ 7248.559275] decode_attr_type: type=02
May 19 11:28:18 nfs4-client kernel: [ 7248.561306] decode_attr_change:
change attribute=5469640301700186112
May 19 11:28:18 nfs4-client kernel: [ 7248.565303] decode_attr_size:
file size=4096
May 19 11:28:18 nfs4-client kernel: [ 7248.569277] decode_attr_fsid:
fsid=(0x0/0x0)
May 19 11:28:18 nfs4-client kernel: [ 7248.572118] decode_attr_fileid:
fileid=114
May 19 11:28:18 nfs4-client kernel: [ 7248.574961]
decode_attr_fs_locations: fs_locations done, error = 0
May 19 11:28:18 nfs4-client kernel: [ 7248.580914] decode_attr_mode:
file mode=0755
May 19 11:28:18 nfs4-client kernel: [ 7248.583910] decode_attr_nlink:
nlink=3
May 19 11:28:18 nfs4-client kernel: [ 7248.591219] decode_attr_owner: uid=0
May 19 11:28:18 nfs4-client kernel: [ 7248.594703] decode_attr_group: gid=0
May 19 11:28:18 nfs4-client kernel: [ 7248.596382] decode_attr_rdev:
rdev=(0x0:0x0)
May 19 11:28:18 nfs4-client kernel: [ 7248.600144]
decode_attr_space_used: space used=4096
May 19 11:28:18 nfs4-client kernel: [ 7248.604428]
decode_attr_time_access: atime=1273498189
May 19 11:28:18 nfs4-client kernel: [ 7248.607892]
decode_attr_time_metadata: ctime=1273499872
May 19 11:28:18 nfs4-client kernel: [ 7248.615113]
decode_attr_time_modify: mtime=1273499872
May 19 11:28:18 nfs4-client kernel: [ 7248.618689]
decode_attr_mounted_on_fileid: fileid=0
May 19 11:28:18 nfs4-client kernel: [ 7248.620189] decode_getfattr: xdr
returned 0
May 19 11:28:18 nfs4-client kernel: [ 7248.625766] encode_compound: tag=
May 19 11:28:19 nfs4-client kernel: [ 7248.671314]
decode_attr_supported: bitmask=fcffafff:00f9be3e
May 19 11:28:19 nfs4-client kernel: [ 7248.671314]
decode_attr_link_support: link support=true
May 19 11:28:19 nfs4-client kernel: [ 7248.671314]
decode_attr_symlink_support: symlink support=true
May 19 11:28:19 nfs4-client kernel: [ 7248.672027]
decode_attr_aclsupport: ACLs supported=0
May 19 11:28:19 nfs4-client kernel: [ 7248.672919] decode_server_caps:
xdr returned 0!
May 19 11:28:19 nfs4-client kernel: [ 7248.672919] encode_compound: tag=
May 19 11:28:19 nfs4-client kernel: [ 7248.683506]
decode_attr_lease_time: file size=90
May 19 11:28:19 nfs4-client kernel: [ 7248.683506]
decode_attr_maxfilesize: maxfilesize=18446744073709551615
May 19 11:28:19 nfs4-client kernel: [ 7248.684338] decode_attr_maxread:
maxread=32768
May 19 11:28:19 nfs4-client kernel: [ 7248.685301] decode_attr_maxwrite:
maxwrite=32768
May 19 11:28:19 nfs4-client kernel: [ 7248.686297] decode_fsinfo: xdr
returned 0!
May 19 11:28:19 nfs4-client kernel: [ 7248.687270] Next:
May 19 11:28:19 nfs4-client kernel: [ 7248.688336] <-- nfs4_path_walk() = 0
May 19 11:28:19 nfs4-client kernel: [ 7248.689256] Server FSID: 0:0
May 19 11:28:19 nfs4-client kernel: [ 7248.690129] Mount FH: 28
May 19 11:28:19 nfs4-client kernel: [ 7248.690954] --> nfs_probe_fsinfo()
May 19 11:28:19 nfs4-client kernel: [ 7248.691878] encode_compound: tag=
May 19 11:28:19 nfs4-client kernel: [ 7248.702607]
decode_attr_supported: bitmask=fcffafff:00f9be3e
May 19 11:28:19 nfs4-client kernel: [ 7248.702607]
decode_attr_link_support: link support=true
May 19 11:28:19 nfs4-client kernel: [ 7248.705009]
decode_attr_symlink_support: symlink support=true
May 19 11:28:19 nfs4-client kernel: [ 7248.706109]
decode_attr_aclsupport: ACLs supported=0
May 19 11:28:19 nfs4-client kernel: [ 7248.707276] decode_server_caps:
xdr returned 0!
May 19 11:28:19 nfs4-client kernel: [ 7248.709026] encode_compound: tag=
May 19 11:28:19 nfs4-client kernel: [ 7248.719157]
decode_attr_lease_time: file size=90
May 19 11:28:19 nfs4-client kernel: [ 7248.719157]
decode_attr_maxfilesize: maxfilesize=18446744073709551615
May 19 11:28:19 nfs4-client kernel: [ 7248.720870] decode_attr_maxread:
maxread=32768
May 19 11:28:19 nfs4-client kernel: [ 7248.721858] decode_attr_maxwrite:
maxwrite=32768
May 19 11:28:19 nfs4-client kernel: [ 7248.722854] decode_fsinfo: xdr
returned 0!
May 19 11:28:19 nfs4-client kernel: [ 7248.723839] encode_compound: tag=
May 19 11:28:19 nfs4-client kernel: [ 7248.734113] decode_attr_maxlink:
maxlink=255
May 19 11:28:19 nfs4-client kernel: [ 7248.734113] decode_attr_maxname:
maxname=255
May 19 11:28:19 nfs4-client kernel: [ 7248.736124] decode_pathconf: xdr
returned 0!
May 19 11:28:19 nfs4-client kernel: [ 7248.737079] <--
nfs_probe_fsinfo() = 0
May 19 11:28:19 nfs4-client kernel: [ 7248.738000] <--
nfs4_create_server() = ffff81000dd06c00
May 19 11:28:19 nfs4-client kernel: [ 7248.739134] --> nfs4_get_root()
May 19 11:28:19 nfs4-client kernel: [ 7248.740127] encode_compound: tag=
May 19 11:28:19 nfs4-client kernel: [ 7248.764067]
decode_attr_supported: bitmask=fcffafff:00f9be3e
May 19 11:28:19 nfs4-client kernel: [ 7248.764664]
decode_attr_link_support: link support=true
May 19 11:28:19 nfs4-client kernel: [ 7248.764664]
decode_attr_symlink_support: symlink support=true
May 19 11:28:19 nfs4-client kernel: [ 7248.765726]
decode_attr_aclsupport: ACLs supported=0
May 19 11:28:19 nfs4-client kernel: [ 7248.766737] decode_server_caps:
xdr returned 0!
May 19 11:28:19 nfs4-client kernel: [ 7248.767884] encode_compound: tag=
May 19 11:28:19 nfs4-client kernel: [ 7248.779330] decode_attr_type: type=02
May 19 11:28:19 nfs4-client kernel: [ 7248.779330] decode_attr_change:
change attribute=5469640301700186112
May 19 11:28:19 nfs4-client kernel: [ 7248.781006] decode_attr_size:
file size=4096
May 19 11:28:19 nfs4-client kernel: [ 7248.781991] decode_attr_fsid:
fsid=(0x0/0x0)
May 19 11:28:19 nfs4-client kernel: [ 7248.782949] decode_attr_fileid:
fileid=114
May 19 11:28:19 nfs4-client kernel: [ 7248.783939]
decode_attr_fs_locations: fs_locations done, error = 0
May 19 11:28:19 nfs4-client kernel: [ 7248.785071] decode_attr_mode:
file mode=0755
May 19 11:28:19 nfs4-client kernel: [ 7248.786042] decode_attr_nlink:
nlink=3
May 19 11:28:19 nfs4-client kernel: [ 7248.786966] decode_attr_owner: uid=0
May 19 11:28:19 nfs4-client kernel: [ 7248.787859] decode_attr_group: gid=0
May 19 11:28:19 nfs4-client kernel: [ 7248.789072] decode_attr_rdev:
rdev=(0x0:0x0)
May 19 11:28:19 nfs4-client kernel: [ 7248.790042]
decode_attr_space_used: space used=4096
May 19 11:28:19 nfs4-client kernel: [ 7248.791049]
decode_attr_time_access: atime=1273498189
May 19 11:28:19 nfs4-client kernel: [ 7248.792243]
decode_attr_time_metadata: ctime=1273499872
May 19 11:28:19 nfs4-client kernel: [ 7248.793719]
decode_attr_time_modify: mtime=1273499872
May 19 11:28:19 nfs4-client kernel: [ 7248.794748]
decode_attr_mounted_on_fileid: fileid=0
May 19 11:28:19 nfs4-client kernel: [ 7248.795770] decode_getfattr: xdr
returned 0
May 19 11:28:19 nfs4-client kernel: [ 7248.797459] NFS:
nfs_fhget(0:12/114 ct=1)
May 19 11:28:19 nfs4-client kernel: [ 7248.798420] <-- nfs4_get_root()



Server:
^^^^^^^
May 19 09:30:26 nfs4-server kernel: [  178.889811] nfsd_dispatch: vers 4
proc 0
May 19 09:30:26 nfs4-server kernel: [  178.929841] nfsd_dispatch: vers 4
proc 0
May 19 09:30:26 nfs4-server kernel: [  178.954241] nfsd_dispatch: vers 4
proc 1
May 19 09:30:26 nfs4-server kernel: [  178.958564] nfsv4 compound op #1: 24
May 19 09:30:26 nfs4-server kernel: [  178.962408] nfsd: Dropping
request; may be revisited later
May 19 09:30:26 nfs4-server kernel: [  178.972754] found domain
192.168.56.102/32
May 19 09:30:26 nfs4-server kernel: [  178.975943] found fsidtype 1
May 19 09:30:26 nfs4-server kernel: [  178.979820] found fsid length 4
May 19 09:30:26 nfs4-server kernel: [  178.982894] Path seems to be </srv>
May 19 09:30:26 nfs4-server kernel: [  178.986080] Found the path /srv
......
May 19 11:27:03 nfs4-server kernel: [ 7176.155707] RPC:       Want
update, refage=120, age=105
May 19 11:27:03 nfs4-server kernel: [ 7176.269598] nfsd_dispatch: vers 4
proc 1
May 19 11:27:03 nfs4-server kernel: [ 7176.273750] nfsv4 compound op #1: 24
May 19 11:27:03 nfs4-server kernel: [ 7176.276082] nfsd: fh_compose(exp
03:02/114 //srv, ino=114)
May 19 11:27:03 nfs4-server kernel: [ 7176.280242] nfsv4 compound op #2: 10
May 19 11:27:03 nfs4-server kernel: [ 7176.287765] nfsv4 compound op #3: 9
May 19 11:27:03 nfs4-server kernel: [ 7176.288042] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:27:03 nfs4-server kernel: [ 7176.299902] nfsd: fh_verify -
just checking
May 19 11:27:03 nfs4-server kernel: [ 7176.303817] RPC:       Want
update, refage=600, age=15
May 19 11:27:18 nfs4-server kernel: [ 7191.218971] RPC:       Want
update, refage=120, age=120
May 19 11:27:18 nfs4-server kernel: [ 7191.347663] nfsd_dispatch: vers 4
proc 1
May 19 11:27:18 nfs4-server kernel: [ 7191.355552] nfsv4 compound op #1: 24
May 19 11:27:18 nfs4-server kernel: [ 7191.358586] nfsd: fh_compose(exp
03:02/114 //srv, ino=114)
May 19 11:27:18 nfs4-server kernel: [ 7191.362313] nfsv4 compound op #2: 10
May 19 11:27:18 nfs4-server kernel: [ 7191.364744] nfsv4 compound op #3: 9
May 19 11:27:18 nfs4-server kernel: [ 7191.369791] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:27:18 nfs4-server kernel: [ 7191.375901] nfsd: fh_verify -
just checking
May 19 11:27:18 nfs4-server kernel: [ 7191.379143] RPC:       Want
update, refage=120, age=0
May 19 11:27:33 nfs4-server kernel: [ 7206.275573] RPC:       Want
update, refage=120, age=135
May 19 11:27:33 nfs4-server kernel: [ 7206.404690] nfsd_dispatch: vers 4
proc 1
May 19 11:27:33 nfs4-server kernel: [ 7206.410747] nfsv4 compound op #1: 24
May 19 11:27:33 nfs4-server kernel: [ 7206.415300] nfsd: fh_compose(exp
03:02/114 //srv, ino=114)
May 19 11:27:33 nfs4-server kernel: [ 7206.419795] nfsv4 compound op #2: 10
May 19 11:27:33 nfs4-server kernel: [ 7206.427456] nfsv4 compound op #3: 9
May 19 11:27:33 nfs4-server kernel: [ 7206.431284] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:27:33 nfs4-server kernel: [ 7206.439307] nfsd: fh_verify -
just checking
May 19 11:27:33 nfs4-server kernel: [ 7206.443701] RPC:       Want
update, refage=600, age=15
May 19 11:27:48 nfs4-server kernel: [ 7221.326477] nfsd_dispatch: vers 4
proc 1
May 19 11:27:48 nfs4-server kernel: [ 7221.465204] nfsv4 compound op #1: 24
May 19 11:27:48 nfs4-server kernel: [ 7221.469217] nfsd: fh_compose(exp
03:02/114 //srv, ino=114)
May 19 11:27:48 nfs4-server kernel: [ 7221.472190] nfsv4 compound op #2: 10
May 19 11:27:48 nfs4-server kernel: [ 7221.475273] nfsv4 compound op #3: 9
May 19 11:27:48 nfs4-server kernel: [ 7221.478502] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:27:48 nfs4-server kernel: [ 7221.484074] nfsd: fh_verify -
just checking
May 19 11:27:48 nfs4-server kernel: [ 7221.490860] RPC:       Want
update, refage=120, age=0
......
May 19 11:28:18 nfs4-server kernel: [ 7251.444794] nfsd_dispatch: vers 4
proc 1
May 19 11:28:18 nfs4-server kernel: [ 7251.582387] nfsv4 compound op #1: 24
May 19 11:28:18 nfs4-server kernel: [ 7251.610490] nfsd: fh_compose(exp
03:02/114 //srv, ino=114)
May 19 11:28:18 nfs4-server kernel: [ 7251.612366] nfsv4 compound op #2: 10
May 19 11:28:18 nfs4-server kernel: [ 7251.616272] nfsv4 compound op #3: 9
May 19 11:28:18 nfs4-server kernel: [ 7251.616558] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:18 nfs4-server kernel: [ 7251.624355] nfsd: fh_verify -
just checking
May 19 11:28:18 nfs4-server kernel: [ 7251.628230] RPC:       Want
update, refage=120, age=0
May 19 11:28:19 nfs4-server kernel: [ 7251.709895] nfsd_dispatch: vers 4
proc 1
May 19 11:28:19 nfs4-server kernel: [ 7251.709895] nfsv4 compound op #1: 22
May 19 11:28:19 nfs4-server kernel: [ 7251.715439] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.723339] RPC:       Want
update, refage=120, age=0
May 19 11:28:19 nfs4-server kernel: [ 7251.725337] nfsd: Dropping
request; may be revisited later
May 19 11:28:19 nfs4-server kernel: [ 7251.730572] found domain
192.168.56.102/32
May 19 11:28:19 nfs4-server kernel: [ 7251.731278] found fsidtype 7
May 19 11:28:19 nfs4-server kernel: [ 7251.732118] found fsid length 24
May 19 11:28:19 nfs4-server kernel: [ 7251.732977] Path seems to be </srv>
May 19 11:28:19 nfs4-server kernel: [ 7251.733903] Found the path /srv
May 19 11:28:19 nfs4-server kernel: [ 7251.735888] nfsd_dispatch: vers 4
proc 1
May 19 11:28:19 nfs4-server kernel: [ 7251.737022] nfsv4 compound op #1: 22
May 19 11:28:19 nfs4-server kernel: [ 7251.737967] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.740007] nfsv4 compound op #2: 9
May 19 11:28:19 nfs4-server kernel: [ 7251.740924] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.742823] nfsd: fh_verify -
just checking
May 19 11:28:19 nfs4-server kernel: [ 7251.756286] nfsd_dispatch: vers 4
proc 1
May 19 11:28:19 nfs4-server kernel: [ 7251.756541] nfsv4 compound op #1: 22
May 19 11:28:19 nfs4-server kernel: [ 7251.756541] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.758646] nfsv4 compound op #2: 9
May 19 11:28:19 nfs4-server kernel: [ 7251.759551] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.761688] nfsd: fh_verify -
just checking
May 19 11:28:19 nfs4-server kernel: [ 7251.777484] nfsd_dispatch: vers 4
proc 1
May 19 11:28:19 nfs4-server kernel: [ 7251.777484] nfsv4 compound op #1: 22
May 19 11:28:19 nfs4-server kernel: [ 7251.778484] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.780352] nfsv4 compound op #2: 9
May 19 11:28:19 nfs4-server kernel: [ 7251.780352] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.782216] nfsd: fh_verify -
just checking
May 19 11:28:19 nfs4-server kernel: [ 7251.792907] nfsd_dispatch: vers 4
proc 1
May 19 11:28:19 nfs4-server kernel: [ 7251.792907] nfsv4 compound op #1: 22
May 19 11:28:19 nfs4-server kernel: [ 7251.793929] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.795755] nfsv4 compound op #2: 9
May 19 11:28:19 nfs4-server kernel: [ 7251.796633] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.798951] nfsd: fh_verify -
just checking
May 19 11:28:19 nfs4-server kernel: [ 7251.808903] nfsd_dispatch: vers 4
proc 1
May 19 11:28:19 nfs4-server kernel: [ 7251.808903] nfsv4 compound op #1: 22
May 19 11:28:19 nfs4-server kernel: [ 7251.809976] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.811776] nfsv4 compound op #2: 9
May 19 11:28:19 nfs4-server kernel: [ 7251.812573] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.814444] nfsd: fh_verify -
just checking
May 19 11:28:19 nfs4-server kernel: [ 7251.832362] nfsd_dispatch: vers 4
proc 1
May 19 11:28:19 nfs4-server kernel: [ 7251.835142] nfsv4 compound op #1: 22
May 19 11:28:19 nfs4-server kernel: [ 7251.836354] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.838153] nfsv4 compound op #2: 9
May 19 11:28:19 nfs4-server kernel: [ 7251.839179] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.840800] nfsd: fh_verify -
just checking
May 19 11:28:19 nfs4-server kernel: [ 7251.852134] nfsd_dispatch: vers 4
proc 1
May 19 11:28:19 nfs4-server kernel: [ 7251.852153] nfsv4 compound op #1: 22
May 19 11:28:19 nfs4-server kernel: [ 7251.853153] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.854950] nfsv4 compound op #2: 9
May 19 11:28:19 nfs4-server kernel: [ 7251.855915] nfsd: fh_verify(28:
00070001 00000072 00000000 dc1fa744 684ca019 9902ffb4)
May 19 11:28:19 nfs4-server kernel: [ 7251.857806] nfsd: fh_verify -
just checking
