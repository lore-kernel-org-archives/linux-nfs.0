Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62528 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751793Ab0JYTiW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Oct 2010 15:38:22 -0400
Subject: [GIT PULL] Please pull NFS client changes for mainline
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 25 Oct 2010 15:37:18 -0400
Message-ID: <1288035438.2989.20.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "nfs-for-2.6.37" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git nfs-for-2.6.37

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 Documentation/filesystems/nfs/00-INDEX     |    2 +
 Documentation/filesystems/nfs/idmapper.txt |   67 ++
 Documentation/filesystems/nfs/nfsroot.txt  |   22 +
 Documentation/kernel-parameters.txt        |    5 +-
 fs/lockd/clntlock.c                        |   15 +-
 fs/lockd/clntproc.c                        |   13 +-
 fs/nfs/Kconfig                             |   11 +
 fs/nfs/client.c                            |   17 +-
 fs/nfs/dir.c                               | 1015 +++++++++++++++++-----------
 fs/nfs/file.c                              |   81 ++-
 fs/nfs/idmap.c                             |  211 ++++++-
 fs/nfs/inode.c                             |   36 +-
 fs/nfs/internal.h                          |   12 +-
 fs/nfs/mount_clnt.c                        |    2 +-
 fs/nfs/nfs2xdr.c                           |  107 ++--
 fs/nfs/nfs3proc.c                          |   62 ++-
 fs/nfs/nfs3xdr.c                           |  196 +++---
 fs/nfs/nfs4_fs.h                           |    4 +-
 fs/nfs/nfs4proc.c                          |  279 +++-----
 fs/nfs/nfs4state.c                         |   40 +-
 fs/nfs/nfs4xdr.c                           |  340 ++++++----
 fs/nfs/nfsroot.c                           |  566 +++++-----------
 fs/nfs/proc.c                              |   35 +-
 fs/nfs/read.c                              |    1 -
 fs/nfs/super.c                             |   72 ++-
 fs/nfs/sysctl.c                            |    2 +
 fs/nfs/unlink.c                            |  259 +++++++-
 fs/nfs/write.c                             |   18 +-
 include/linux/nfs_fs.h                     |   14 +-
 include/linux/nfs_fs_sb.h                  |    1 +
 include/linux/nfs_idmap.h                  |   31 +-
 include/linux/nfs_mount.h                  |    3 +
 include/linux/nfs_xdr.h                    |   78 +--
 include/linux/sunrpc/clnt.h                |    1 -
 include/linux/sunrpc/xdr.h                 |    2 +
 init/do_mounts.c                           |   12 +-
 net/sunrpc/auth.c                          |    2 +-
 net/sunrpc/clnt.c                          |    2 +-
 net/sunrpc/rpcb_clnt.c                     |   56 +--
 net/sunrpc/sched.c                         |    2 +-
 net/sunrpc/xdr.c                           |   61 ++-
 41 files changed, 2236 insertions(+), 1519 deletions(-)

commit 9a84d38031c258a17bb39beed1e500eadee67407
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Oct 24 18:00:46 2010 -0400

    SUNRPC: Cleanup duplicate assignment in rpcauth_refreshcred
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3388bff5cfe91589a912cdc7f00d3aae3aa18adc
Author: Roman Borisov <ext-roman.borisov@nokia.com>
Date:   Wed Oct 13 16:54:51 2010 +0400

    nfs: fix unchecked value
    
    Return value of "decode_attr_bitmap()" was not checked;
    
    Signed-off-by: Roman Borisov <ext-roman.borisov@nokia.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 55b6e7742d5b25182edf410369379b9727b2e5bc
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Tue Oct 12 16:30:06 2010 -0700

    Ask for time_delta during fsinfo probe
    
    Used by the client to determine if the server has a granular enough
    time stamp.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6b96724e507fecc3e6440e86426fe4f44359ed66
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Tue Oct 12 16:30:05 2010 -0700

    Revalidate caches on lock
    
    Instead of blindly zapping the caches, attempt to revalidate them if
    the server has indicated that it uses high resolution timestamps.
    
    NFSv4 should be able to always revalidate the cache since the
    protocol requires the update of the change attribute on modification of
    the data.  In reality, there are servers (the Linux NFS server
    for example) that do not obey this requirement and use ctime as the
    basis for change attribute.  Long term, the server needs to be fixed.
    At this time, and to be on the safe side, continue zapping caches if
    the server indicates that it does not have a high resolution timestamp.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 118df3d17f11733b294ea2cd988d56ee376ef9fd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Oct 24 17:17:31 2010 -0400

    SUNRPC: After calling xprt_release(), we must restart from call_reserve
    
    Rob Leslie reports seeing the following Oops after his Kerberos session
    expired.
    
    BUG: unable to handle kernel NULL pointer dereference at 00000058
    IP: [<e186ed94>] rpcauth_refreshcred+0x11/0x12c [sunrpc]
    *pde = 00000000
    Oops: 0000 [#1]
    last sysfs file: /sys/devices/platform/pc87360.26144/temp3_input
    Modules linked in: autofs4 authenc esp4 xfrm4_mode_transport ipt_LOG ipt_REJECT xt_limit xt_state ipt_REDIRECT xt_owner xt_HL xt_hl xt_tcpudp xt_mark cls_u32 cls_tcindex sch_sfq sch_htb sch_dsmark geodewdt deflate ctr twofish_generic twofish_i586 twofish_common camellia serpent blowfish cast5 cbc xcbc rmd160 sha512_generic sha1_generic hmac crypto_null af_key rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ip_gre sit tunnel4 dummy ext3 jbd nf_nat_irc nf_conntrack_irc nf_nat_ftp nf_conntrack_ftp iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_filter ip_tables x_tables pc8736x_gpio nsc_gpio pc87360 hwmon_vid loop aes_i586 aes_generic sha256_generic dm_crypt cs5535_gpio serio_raw cs5535_mfgpt hifn_795x des_generic geode_rng rng_core led_class ext4 mbcache jbd2 crc16 dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif ide_pci_generic cs5536 amd74xx ide_core pata_cs5536 ata_generic libata usb_!
 storage via_rhine mii scsi_mod btrfs zlib_deflate crc32c libcrc32c [last unloaded: scsi_wait_scan]
    
    Pid: 12875, comm: sudo Not tainted 2.6.36-net5501 #1 /
    EIP: 0060:[<e186ed94>] EFLAGS: 00010292 CPU: 0
    EIP is at rpcauth_refreshcred+0x11/0x12c [sunrpc]
    EAX: 00000000 EBX: defb13a0 ECX: 00000006 EDX: e18683b8
    ESI: defb13a0 EDI: 00000000 EBP: 00000000 ESP: de571d58
     DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
    Process sudo (pid: 12875, ti=de570000 task=decd1430 task.ti=de570000)
    Stack:
     e186e008 00000000 defb13a0 0000000d deda6000 e1868f22 e196f12b defb13a0
    <0> defb13d8 00000000 00000000 e186e0aa 00000000 defb13a0 de571dac 00000000
    <0> e186956c de571e34 debea5c0 de571dc8 e186967a 00000000 debea5c0 de571e34
    Call Trace:
     [<e186e008>] ? rpc_wake_up_next+0x114/0x11b [sunrpc]
     [<e1868f22>] ? call_decode+0x24a/0x5af [sunrpc]
     [<e196f12b>] ? nfs4_xdr_dec_access+0x0/0xa2 [nfs]
     [<e186e0aa>] ? __rpc_execute+0x62/0x17b [sunrpc]
     [<e186956c>] ? rpc_run_task+0x91/0x97 [sunrpc]
     [<e186967a>] ? rpc_call_sync+0x40/0x5b [sunrpc]
     [<e1969ca2>] ? nfs4_proc_access+0x10a/0x176 [nfs]
     [<e19572fa>] ? nfs_do_access+0x2b1/0x2c0 [nfs]
     [<e186ed61>] ? rpcauth_lookupcred+0x62/0x84 [sunrpc]
     [<e19573b6>] ? nfs_permission+0xad/0x13b [nfs]
     [<c0177824>] ? exec_permission+0x15/0x4b
     [<c0177fbd>] ? link_path_walk+0x4f/0x456
     [<c017867d>] ? path_walk+0x4c/0xa8
     [<c0179678>] ? do_path_lookup+0x1f/0x68
     [<c017a3fb>] ? user_path_at+0x37/0x5f
     [<c016359c>] ? handle_mm_fault+0x229/0x55b
     [<c0170a2d>] ? sys_faccessat+0x93/0x146
     [<c0170aef>] ? sys_access+0xf/0x13
     [<c02cf615>] ? syscall_call+0x7/0xb
    Code: 0f 94 c2 84 d2 74 09 8b 44 24 0c e8 6a e9 8b de 83 c4 14 89 d8 5b 5e 5f 5d c3 55 57 56 53 83 ec 1c fc 89 c6 8b 40 10 89 44 24 04 <8b> 58 58 85 db 0f 85 d4 00 00 00 0f b7 46 70 8b 56 20 89 c5 83
    EIP: [<e186ed94>] rpcauth_refreshcred+0x11/0x12c [sunrpc] SS:ESP 0068:de571d58
    CR2: 0000000000000058
    
    This appears to be caused by the function rpc_verify_header() first
    calling xprt_release(), then doing a call_refresh. If we release the
    transport slot, we should _always_ jump back to call_reserve before
    calling anything else.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 6f7a35bd23bdbbb40c07ee1120ef047190e77d9b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Oct 24 12:11:42 2010 -0400

    NFSv4: Fix up the 'dircount' hint in encode_readdir
    
    Also ensure we only ask for either fileid or mounted_on_fileid in the
    readdirplus case too...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9af8c222ca5eae88f000664f693316480bf58fbc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Oct 24 11:52:55 2010 -0400

    NFSv4: Clean up nfs4_decode_dirent
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4f082222fad3c8471abe0c8e8f18c72f335a34c7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Oct 24 13:14:02 2010 -0400

    NFSv4: nfs4_decode_dirent must clear entry->fattr->valid
    
    Otherwise, we may end up reading uninitialised data from the resulting
    struct nfs_fattr.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3201f3dd7370f2d29dfb689ae16f8f5d4066cc33
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Oct 23 15:43:10 2010 -0400

    NFSv4: Fix a regression in decode_getfattr
    
    We don't want to have the mounted_on_fileid overwrite the true fileid. We
    only return the former if the server didn't supply the true fileid.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7ad07353003d6ff69fe0b987813bb77b4d5ac23d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Oct 23 15:34:20 2010 -0400

    NFSv4: Fix up decode_attr_filehandle() to handle the case of empty fh pointer
    
    decode_attr_filehandle still needs to skip the XDR-encoded filehandle if
    someone passes a null pointer argument.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4a201d6e3f4253f918555cc7c27c418f8ac1bb65
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Oct 23 14:53:23 2010 -0400

    NFS: Ensure we check all allocation return values in new readdir code
    
    Also some clean ups.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 82f2e5472e2304e531c2fa85e457f4a71070044e
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Oct 21 16:33:18 2010 -0400

    NFS: Readdir plus in v4
    
    By requsting more attributes during a readdir, we can mimic the readdir plus
    operation that was in NFSv3.
    
    To test, I ran the command `ls -lU --color=none` on directories with various
    numbers of files.  Without readdir plus, I see this:
    
    n files |    100    |   1,000   |  10,000   |  100,000  | 1,000,000
    --------+-----------+-----------+-----------+-----------+----------
    real    | 0m00.153s | 0m00.589s | 0m05.601s | 0m56.691s | 9m59.128s
    user    | 0m00.007s | 0m00.007s | 0m00.077s | 0m00.703s | 0m06.800s
    sys     | 0m00.010s | 0m00.070s | 0m00.633s | 0m06.423s | 1m10.005s
    access  | 3         | 1         | 1         | 4         | 31
    getattr | 2         | 1         | 1         | 1         | 1
    lookup  | 104       | 1,003     | 10,003    | 100,003   | 1,000,003
    readdir | 2         | 16        | 158       | 1,575     | 15,749
    total   | 111       | 1,021     | 10,163    | 101,583   | 1,015,784
    
    With readdir plus enabled, I see this:
    
    n files |    100    |   1,000   |  10,000   |  100,000  | 1,000,000
    --------+-----------+-----------+-----------+-----------+----------
    real    | 0m00.115s | 0m00.206s | 0m01.079s | 0m12.521s | 2m07.528s
    user    | 0m00.003s | 0m00.003s | 0m00.040s | 0m00.290s | 0m03.296s
    sys     | 0m00.007s | 0m00.020s | 0m00.120s | 0m01.357s | 0m17.556s
    access  | 3         | 1         | 1         | 1         | 7
    getattr | 2         | 1         | 1         | 1         | 1
    lookup  | 4         | 3         | 3         | 3         | 3
    readdir | 6         | 62        | 630       | 6,300     | 62,993
    total   | 15        | 67        | 635       | 6,305     | 63,004
    
    Readdir plus disabled has about a 16x increase in the number of rpc calls and
    is 4 - 5 times slower on large directories.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ae42c70a60fe330d9c2af7c4b92ce78484308e37
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Oct 21 16:33:17 2010 -0400

    NFS: introduce generic decode_getattr function
    
    Getattr should be able to decode errors and the readdir file handle.
    decode_getfattr_attrs does the actual attribute decoding, while
    decode_getfattr_generic will check the opcode before decoding.  This will
    let other functions call decode_getfattr_attrs to decode their attributes.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9942438089d5c0e3adecdcb7bc360b8fe0ce7e62
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Oct 21 16:33:16 2010 -0400

    NFS: check xdr_decode for errors
    
    Check if the decoded entry has the eof bit set when returning from xdr_decode
    with an error.  If it does, we should set the eof bits in the array before
    returning.  This should keep us from looping when we expect more data but the
    server doesn't give us anything new.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3c8a1aeed8fd7f89bd0400fad72cbc1ac3460217
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Oct 21 16:33:16 2010 -0400

    NFS: nfs_readdir_filler catch all errors
    
    Check for all errors, not a specific one.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 56e4ebf877b6043c289bda32a5a7385b80c17dee
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Oct 20 15:44:37 2010 -0400

    NFS: readdir with vmapped pages
    
    We can use vmapped pages to read more information from the network at once.
    This will reduce the number of calls needed to complete a readdir.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    [trondmy: Added #include for linux/vmalloc.h> in fs/nfs/dir.c]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit afa8ccc978c24d8ab22e3b3b8cbd1054c84c070b
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Oct 20 15:44:31 2010 -0400

    NFS: remove page size checking code
    
    Remove the page size checking code for a readdir decode.  This is now done
    by decode_dirent with xdr_streams.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit babddc72a9468884ce1a23db3c3d54b0afa299f0
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Oct 20 15:44:29 2010 -0400

    NFS: decode_dirent should use an xdr_stream
    
    Convert nfs*xdr.c to use an xdr stream in decode_dirent.  This will prevent a
    kernel oops that has been occuring when reading a vmapped page.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ba8e452a4fe64a51b74d43761e14d99f0666cc45
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 19 19:58:49 2010 -0400

    SUNRPC: Add a helper function xdr_inline_peek
    
    We sometimes need to be able to read ahead in an xdr_stream without
    incrementing the current pointer position.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0715dc632a271fc0fedf3ef4779fe28ac1e53ef4
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Fri Sep 24 18:50:01 2010 -0400

    NFS: remove readdir plus limit
    
    We will now use readdir plus even on directories that are very large.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d39ab9de3b80da5835049b1c3b49da4e84e01c07
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Fri Sep 24 18:50:01 2010 -0400

    NFS: re-add readdir plus
    
    This patch adds readdir plus support to the cache array.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit baf57a09e9d87b14be5e2788828169394a2525ab
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 24 18:49:43 2010 -0400

    NFS: Optimise the readdir searches
    
    If we're going through the loop in nfs_readdir() more than once, we usually
    do not want to restart searching from the beginning of the pages cache.
    
    We only want to do that if the previous search failed...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d1bacf9eb2fd0e7ef870acf84b9e3b157dcfa7dc
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Fri Sep 24 14:48:42 2010 -0400

    NFS: add readdir cache array
    
    This patch adds the readdir cache array and functions to retreive the array
    stored on a cache page, clear the array by freeing allocated memory, add an
    entry to the array, and search the array for a given cookie.
    
    It then modifies readdir to make use of the new cache array.
    With the new cache array method, we no longer need some of this code.
    
    Finally, nfs_llseek_dir() will set file->f_pos to a value greater than 0 and
    desc->dir_cookie to zero.  When we see this, readdir needs to find the file
    at position file->f_pos from the start of the directory.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8c7597f6ce212bbc8ca05090e21820ffe9792b3d
Author: Randy Dunlap <randy.dunlap@oracle.com>
Date:   Fri Oct 22 16:18:52 2010 -0700

    nfs: include ratelimit.h, fix nfs4state build error
    
    nfs4state.c uses interfaces from ratelimit.h.  It needs to include
    that header file to fix build errors:
    
    fs/nfs/nfs4state.c:1195: warning: type defaults to 'int' in declaration of 'DEFINE_RATELIMIT_STATE'
    fs/nfs/nfs4state.c:1195: warning: parameter names (without types) in function declaration
    fs/nfs/nfs4state.c:1195: error: invalid storage class for function 'DEFINE_RATELIMIT_STATE'
    fs/nfs/nfs4state.c:1195: error: implicit declaration of function '__ratelimit'
    fs/nfs/nfs4state.c:1195: error: '_rs' undeclared (first use in this function)
    
    Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
    Cc:	Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc:	linux-nfs@vger.kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 168667c43bbafff11b46014a1e94477ff7619f45
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 19 19:47:49 2010 -0400

    NFSv4: The state manager must ignore EKEYEXPIRED.
    
    Otherwise, we cannot recover state correctly.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 898f635c4297e91ceac675d83c4a460f26118342
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Oct 23 11:24:25 2010 -0400

    NFSv4: Don't ignore the error return codes from nfs_intent_set_file
    
    If nfs_intent_set_file() returns an error, we usually want to pass that
    back up the stack.
    
    Also ensure that nfs_open_revalidate() returns '1' on success.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6eaa61496fb3b93cceface7a296415fc4c030bce
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 4 17:59:08 2010 -0400

    NFSv4: Don't call nfs4_reclaim_complete() on receiving NFS4ERR_STALE_CLIENTID
    
    If the server sends us an NFS4ERR_STALE_CLIENTID while the state management
    thread is busy reclaiming state, we do want to treat all state that wasn't
    reclaimed before the STALE_CLIENTID as if a network partition occurred (see
    the edge conditions described in RFC3530 and RFC5661).
    What we do not want to do is to send an nfs4_reclaim_complete(), since we
    haven't yet even started reclaiming state after the server rebooted.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit ae1007d37e00144b72906a4bdc47d517ae91bcc1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 4 17:59:08 2010 -0400

    NFSv4: Don't call nfs4_state_mark_reclaim_reboot() from error handlers
    
    In the case of a server reboot, the state recovery thread starts by calling
    nfs4_state_end_reclaim_reboot() in order to avoid edge conditions when
    the server reboots while the client is in the middle of recovery.
    
    However, if the client has already marked the nfs4_state as requiring
    reboot recovery, then the above behaviour will cause the recovery thread to
    treat the open as if it was part of such an edge condition: the open will
    be recovered as if it was part of a lease expiration (and all the locks
    will be lost).
    Fix is to remove the call to nfs4_state_mark_reclaim_reboot from
    nfs4_async_handle_error(), and nfs4_handle_exception(). Instead we leave it
    to the recovery thread to do this for us.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit b0ed9dbc24f1fd912b2dd08b995153cafc1d5b1c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 4 17:59:08 2010 -0400

    NFSv4: Fix open recovery
    
    NFSv4 open recovery is currently broken: since we do not clear the
    state->flags states before attempting recovery, we end up with the
    'can_open_cached()' function triggering. This again leads to no OPEN call
    being put on the wire.
    
    Reported-by: Sachin Prabhu <sprabhu@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit bc4866b6e0b44f8ea0df22a16e5927714beb4983
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 4 17:59:08 2010 -0400

    NFS: Don't SIGBUS if nfs_vm_page_mkwrite races with a cache invalidation
    
    In the case where we lock the page, and then find out that the page has
    been thrown out of the page cache, we should just return VM_FAULT_NOPAGE.
    This is what block_page_mkwrite() does in these situations.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 955a857e062642cd3ebe1dc7bb38c0f85d8f8f17
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Sep 29 15:41:49 2010 -0400

    NFS: new idmapper
    
    This patch creates a new idmapper system that uses the request-key function to
    place a call into userspace to map user and group ids to names.  The old
    idmapper was single threaded, which prevented more than one request from running
    at a single time.  This means that a user would have to wait for an upcall to
    finish before accessing a cached result.
    
    The upcall result is stored on a keyring of type id_resolver.  See the file
    Documentation/filesystems/nfs/idmapper.txt for instructions.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    [Trond: fix up the return value of nfs_idmap_lookup_name and clean up code]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aa510da5bfe1dfe263215fd0e05dac96e738a782
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Sep 29 15:11:56 2010 -0400

    NFS: We must use list_for_each_entry_safe in nfs_access_cache_shrinker
    
    We may end up removing the current entry from nfs_access_lru_list.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a00dd6c03dd97a777c291a8af8682be4b5fadf8d
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Sep 28 09:14:01 2010 -0400

    NFS: don't use FLUSH_SYNC on WB_SYNC_NONE COMMIT calls (try #2)
    
    WB_SYNC_NONE is supposed to mean "don't wait on anything". That should
    also include not waiting for COMMIT calls to complete.
    
    WB_SYNC_NONE is also implied when wbc->nonblocking and
    wbc->for_background are set, so we can replace those checks in
    nfs_commit_unstable_pages with a check for WB_SYNC_NONE.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5c78f58e2d5cef65c255a556184f1f43c8d84c84
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Sep 27 15:51:20 2010 -0400

    NFS: Really fix put_nfs_open_context()
    
    In nfs_open_revalidate(), if the open_context() call returns an inode that
    is not the same as dentry->d_inode, then we will call
    put_nfs_open_context() with a valid dentry->d_inode, but without the
    context being part of the nfsi->open_files list.
    
    In this case too, we want to just skip the list removal, but we do want to
    call the ->close_context() callback in order to close the NFSv4 state.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Acked-by: Jeff Layton <jlayton@redhat.com>

commit dfb4f309830359352539919f23accc59a20a3758
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Sep 24 09:17:01 2010 -0400

    NFSv4.1: keep seq_res.sr_slot as pointer rather than an index
    
    Having to explicitly initialize sr_slotid to NFS4_MAX_SLOT_TABLE
    resulted in numerous bugs.  Keeping the current slot as a pointer
    to the slot table is more straight forward and robust as it's
    implicitly set up to NULL wherever the seq_res member is initialized
    to zeroes.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7c563cc9f3f4aca70c27bd08a135499227f67014
Author: Suresh Jayaraman <sjayaraman@suse.de>
Date:   Thu Sep 23 14:26:48 2010 -0400

    nfs: show "local_lock" mount option in /proc/mounts
    
    Display the status of 'local_lock' mount option in /proc/mounts.
    
    
    Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ef84303ebc77a9041265faaccd56b7fcef151077
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Thu Sep 23 12:22:09 2010 -0400

    NFS: handle inode==NULL in __put_nfs_open_context
    
    inode may be NULL when put_nfs_open_context is called from nfs_atomic_lookup
    before d_add_unique(dentry, inode)
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5eebde23223aeb0ad2d9e3be6590ff8bbfab0fc2
Author: Suresh Jayaraman <sjayaraman@suse.de>
Date:   Thu Sep 23 08:55:58 2010 -0400

    nfs: introduce mount option '-olocal_lock' to make locks local
    
    NFS clients since 2.6.12 support flock locks by emulating fcntl byte-range
    locks. Due to this, some windows applications which seem to use both flock
    (share mode lock mapped as flock by Samba) and fcntl locks sequentially on
    the same file, can't lock as they falsely assume the file is already locked.
    The problem was reported on a setup with windows clients accessing excel files
    on a Samba exported share which is originally a NFS mount from a NetApp filer.
    
    Older NFS clients (< 2.6.12) did not see this problem as flock locks were
    considered local. To support legacy flock behavior, this patch adds a mount
    option "-olocal_lock=" which can take the following values:
    
       'none'  		- Neither flock locks nor POSIX locks are local
       'flock' 		- flock locks are local
       'posix' 		- fcntl/POSIX locks are local
       'all'		- Both flock locks and POSIX locks are local
    
    Testing:
    
       - This patch was tested by using -olocal_lock option with different values
         and the NLM calls were noted from the network packet captured.
    
         'none'  - NLM calls were seen during both flock() and fcntl(), flock lock
       	       was granted, fcntl was denied
         'flock' - no NLM calls for flock(), NLM call was seen for fcntl(),
       	       granted
         'posix' - NLM call was seen for flock() - granted, no NLM call for fcntl()
         'all'   - no NLM calls were seen during both flock() and fcntl()
    
       - No bugs were seen during NFSv4 locking/unlocking in general and NFSv4
         reboot recovery.
    
    Cc: Neil Brown <neilb@suse.de>
    Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 63185942c5f138c62de16b4cbc7eee494a58fea8
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Sep 22 09:50:35 2010 -0400

    lockd: Remove BKL from the client
    
    This patch removes all calls to lock_kernel() from the client.  This patch
    should be applied after the "fs/lock.c prepare for BKL removal" patch submitted
    by Arnd Bergmann on September 18.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b4687da7fc5f741af7fee9b0248a2cf2ad9c4478
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 21 16:55:48 2010 -0400

    SUNRPC: Refactor logic to NUL-terminate strings in pages
    
    Clean up: Introduce a helper to '\0'-terminate XDR strings
    that are placed in a page in the page cache.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 38359352fcb0d776b562a9e0ed4f0d355d5a332e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 21 16:55:48 2010 -0400

    SUNRPC: Correct an rpcbind debugging message
    
    Clean up.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d141d97437a3c84aa18cfd5c8d91b89c4173f25c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 21 16:55:47 2010 -0400

    NFS: Fix NFSv3 debugging messages in fs/nfs/nfs3proc.c
    
    Clean up.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 609588928fae2c977c887d6d31b1f0aae60ea09e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Sep 21 16:55:31 2010 -0400

    NFS: Convert nfsiod to use alloc_workqueue()
    
    create_singlethread_workqueue() is deprecated.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4fbf6e507888da902b02a3c4f5f493fab1071312
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Sep 21 16:54:34 2010 -0400

    SUNRPC: Convert rpciod to use the alloc_workqueue() interface
    
    create_workqueue() is a deprecated function.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d688e11007419fd060ae74d8d952a5c4ece735aa
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Sep 21 16:52:40 2010 -0400

    NFSv4.1: Fix the slotid initialisation in nfs_async_rename()
    
    This fixes an Oopsable condition that was introduced by commit
    d3d4152a5d59af9e13a73efa9e9c24383fbe307f (nfs: make sillyrename an async
    operation)
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f7732d6573c4f29fc1ca5d384bbf82ddfa115030
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Sep 21 16:52:40 2010 -0400

    NFS: Fix a use-after-free case in nfs_async_rename()
    
    The call to nfs_async_rename_release() after rpc_run_task() is incorrect.
    The rpc_run_task() is always guaranteed to call the ->rpc_release() method.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d3d4152a5d59af9e13a73efa9e9c24383fbe307f
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Sep 17 17:31:57 2010 -0400

    nfs: make sillyrename an async operation
    
    A synchronous rename can be interrupted by a SIGKILL. If that happens
    during a sillyrename operation, it's possible for the rename call to
    be sent to the server, but the task exits before processing the
    reply. If this happens, the sillyrenamed file won't get cleaned up
    during nfs_dentry_iput and the server is left with a dangling .nfs* file
    hanging around.
    
    Fix this problem by turning sillyrename into an asynchronous operation
    and have the task doing the sillyrename just wait on the reply. If the
    task is killed before the sillyrename completes, it'll still proceed
    to completion.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 779c51795bfb35c2403c924b9de90ca9356bc693
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Sep 17 17:31:30 2010 -0400

    nfs: move nfs_sillyrename to unlink.c
    
    ...since that's where most of the sillyrenaming code lives. A comment
    block is added to the beginning as well to clarify how sillyrenaming
    works. Also, make nfs_async_unlink static as nfs_sillyrename is the only
    caller.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e8582a8b96f329083b4da29aa87bc43cc0d80dd1
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Sep 17 17:31:06 2010 -0400

    nfs: standardize the rename response container
    
    Right now, v3 and v4 have their own variants. Create a standard struct
    that will work for v3 and v4. v2 doesn't get anything but a simple error
    and so isn't affected by this.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 920769f031a8aff87b66bdf49d1a0d0988241ef9
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Sep 17 17:30:25 2010 -0400

    nfs: standardize the rename args container
    
    Each NFS version has its own version of the rename args container.
    Standardize them on a common one that's identical to the one NFSv4
    uses.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2b484297e48c3fbb1846fc6ea10036d9465273e7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 17 10:56:51 2010 -0400

    NFS: Add an 'open_context' element to struct nfs_rpc_ops
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c0204fd2b8fe047b18b67e07e1bf2a03691240cd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 17 10:56:51 2010 -0400

    NFS: Clean up nfs4_proc_create()
    
    Remove all remaining references to the struct nameidata from the low level
    NFS layers. Again pass down a partially initialised struct nfs_open_context
    when we want to do atomic open+create.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 535918f14176396646b5547b7d1353c932f24f5e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 17 10:56:51 2010 -0400

    NFSv4: Further cleanups for nfs4_open_revalidate()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b8d4caddd871758ffa156be51b4c8be82fea470d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 17 10:56:51 2010 -0400

    NFSv4: Clean up nfs4_open_revalidate
    
    Remove references to 'struct nameidata' from the low-level open_revalidate
    code, and replace them with a struct nfs_open_context which will be
    correctly initialised upon success.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f46e0bd34ec002d0727761da52b8fd47f06d4440
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 17 10:56:50 2010 -0400

    NFSv4: Further minor cleanups for nfs4_atomic_open()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cd9a1c0e5ac681871d64804f82291649e2a0accb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 17 10:56:50 2010 -0400

    NFSv4: Clean up nfs4_atomic_open
    
    Start moving the 'struct nameidata' dependent code out of the lower level
    NFS code in preparation for the removal of open intents.
    
    Instead of the struct nameidata, we pass down a partially initialised
    struct nfs_open_context that will be fully initialised by the atomic open
    upon success.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 859d5024f450686ad0a42ed3c06f2fa20295c9e6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 17 10:54:37 2010 -0400

    SUNRPC: Remove rpcb_getport_sync()
    
    Clean up: rpcb_getport_sync() has no more users, so remove it.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 306a075362a288683f6346185f97dd0e06df19da
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 17 10:54:37 2010 -0400

    NFS: Allow NFSROOT debugging messages to be enabled dynamically
    
    As a convenience, introduce a kernel command line option to enable
    NFSROOT debugging messages.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8d2321037896aa4868a67f45b2d6ed52b579a48a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 17 10:54:37 2010 -0400

    NFS: Clean up nfsroot.c
    
    Clean up: now that mount option parsing for nfsroot is handled
    in fs/nfs/super.c, remove code in fs/nfs/nfsroot.c that is no
    longer used.  This includes code that constructs the legacy
    nfs_mount_data structure, and code that does a MNT call to the
    server.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 56463e50d1fc3f070492434cea6303b35ea000de
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 17 10:54:37 2010 -0400

    NFS: Use super.c for NFSROOT mount option parsing
    
    Replace duplicate code in NFSROOT for mounting an NFS server on '/'
    with logic that uses the existing mainline text-based logic in the NFS
    client.
    
    Add documenting comments where appropriate.
    
    Note that this means NFSROOT mounts now use the same default settings
    as v2/v3 mounts done via mount(2) from user space.
    
      vers=3,tcp,rsize=<negotiated default>,wsize=<negotiated default>
    
    As before, however, no version/protocol negotiation with the server is
    done.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 60ac03685bf513f9d9b6e8e098018b35309ed326
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 17 10:54:37 2010 -0400

    NFS: Clean up NFSROOT command line parsing
    
    Clean up: To reduce confusion, rename nfs_root_name as nfs_root_parms,
    as this buffer contains more than just the name of the remote server.
    
    Introduce documenting comments around nfs_root_setup().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ed58b2917be24fc8603128e32d50a1378afe66e1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 17 10:54:37 2010 -0400

    NFS: Remove \t from mount debugging message
    
    During boot, a random character is displayed instead of a tab.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cf187c2d7ec763cdd459fe43933a5cc4f5f48e1b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 29 12:13:16 2010 -0400

    SUNRPC: Don't truncate tail data unnecessarily in xdr_shrink_pagelen
    
    If we have unused buffer space, then we should make use of that rather
    than unnecessarily truncating the message.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 42d6d8ab51ca04afcb8a64759076da624cdb71e8
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun Aug 29 12:13:15 2010 -0400

    sunrpc: simplify xdr_shrink_pagelen use of "copy"
    
    The "copy" variable value can be computed using the existing
    logic rather than repeating it.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2e29ebb8119e6037133921fac09cc5f9d625b511
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun Aug 29 12:13:15 2010 -0400

    sunrpc: don't use the copy variable in nested block
    
    to clean up the code "copy" will be set prior to the block
    hence it mustn't be used there.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0fe62a35903e11fb41b492bd5b0e8e4c751d5c94
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun Aug 29 12:13:15 2010 -0400

    sunrpc: clean up xdr_shrink_pagelen use of temporary pointer
    
    char *p is used only as a shorthand for tail->iov_base + len in a nested
    block.  Move it there.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b1a7a91ada8388936ffff92cf1ad57b3e926f412
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun Aug 29 12:13:15 2010 -0400

    sunrpc: don't shorten buflen twice in xdr_shrink_pagelen
    
    On Jan. 14, 2009, 2:50 +0200, andros@netapp.com wrote:
    > From: Andy Adamson <andros@netapp.com>
    >
    > The buflen is reset for all cases at the end of xdr_shrink_pagelen.
    > The data left in the tail after xdr_read_pages is not processed when the
    > buflen is incorrectly set.
    
    Note that in this case we also lose (len - tail->iov_len)
    bytes from the buffered data in pages.
    
    Reported-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


