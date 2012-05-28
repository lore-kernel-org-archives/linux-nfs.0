Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32307 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887Ab2E1WFt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 May 2012 18:05:49 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        "Linux NFS mailing list" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client updates for Linux 3.5
Date: Mon, 28 May 2012 22:05:14 +0000
Message-ID: <1338242713.3472.27.camel@lade.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-wV3dn2yx7qYajYfPOQEq"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-wV3dn2yx7qYajYfPOQEq
Content-Type: multipart/mixed; boundary="=-VVaISaPUbrioza8b+Hdf"


--=-VVaISaPUbrioza8b+Hdf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

Please pull from the signed tag "nfs-for-3.5-1" in the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs=
-for-3.5-1

This will update the following files through the appended changesets.

There is one known conflict with your patch "vfs: make it possible to
access the dentry hash/len as one 64-bit entry". It can be resolved
using the attached patch from Stephen Rothwell. Alternatively, I can do
a backmerge, but my understanding was that you prefer to resolve simple
merge conflicts yourself.

  Cheers,
    Trond

----
 fs/nfs/Kconfig                      |   11 +
 fs/nfs/Makefile                     |    5 +-
 fs/nfs/blocklayout/blocklayout.c    |   90 +++--
 fs/nfs/blocklayout/blocklayoutdev.c |    2 +-
 fs/nfs/client.c                     |  268 +++++++------
 fs/nfs/delegation.c                 |   16 +-
 fs/nfs/delegation.h                 |    1 +
 fs/nfs/dir.c                        |   39 ++-
 fs/nfs/direct.c                     |  746 +++++++++++++++----------------=
-
 fs/nfs/file.c                       |    8 +
 fs/nfs/fscache.c                    |   15 +-
 fs/nfs/fscache.h                    |   10 +-
 fs/nfs/getroot.c                    |   85 +----
 fs/nfs/idmap.c                      |   30 +-
 fs/nfs/inode.c                      |  118 +++---
 fs/nfs/internal.h                   |  135 ++++---
 fs/nfs/namespace.c                  |  103 +----
 fs/nfs/netns.h                      |    5 +
 fs/nfs/nfs2xdr.c                    |    5 +-
 fs/nfs/nfs3proc.c                   |   27 +-
 fs/nfs/nfs3xdr.c                    |  112 ++++-
 fs/nfs/nfs4_fs.h                    |   23 +-
 fs/nfs/nfs4filelayout.c             |  688 ++++++++++++++++++++----------
 fs/nfs/nfs4filelayout.h             |   63 +++-
 fs/nfs/nfs4filelayoutdev.c          |  102 +++---
 fs/nfs/nfs4namespace.c              |   55 +++-
 fs/nfs/nfs4proc.c                   |  537 +++++++++++++++--------
 fs/nfs/nfs4renewd.c                 |    2 +-
 fs/nfs/nfs4state.c                  |  225 +++++++---
 fs/nfs/nfs4xdr.c                    |  399 +++++++++++++-----
 fs/nfs/objlayout/objio_osd.c        |   18 +-
 fs/nfs/objlayout/objlayout.c        |   19 +-
 fs/nfs/pagelist.c                   |   61 +++-
 fs/nfs/pnfs.c                       |  352 ++++++++++++----
 fs/nfs/pnfs.h                       |  127 +++++--
 fs/nfs/proc.c                       |   21 +-
 fs/nfs/read.c                       |  437 +++++++++----------
 fs/nfs/super.c                      |  760 ++++++++++++-------------------=
-
 fs/nfs/write.c                      |  809 +++++++++++++++++++------------=
----
 include/linux/nfs4.h                |   13 +
 include/linux/nfs_fs.h              |   31 +-
 include/linux/nfs_fs_sb.h           |   17 +-
 include/linux/nfs_page.h            |   20 +-
 include/linux/nfs_xdr.h             |  210 ++++++++--
 net/sunrpc/clnt.c                   |    2 +
 net/sunrpc/rpc_pipe.c               |   10 +-
 net/sunrpc/rpcb_clnt.c              |    2 +
 net/sunrpc/xprt.c                   |    7 +-
 48 files changed, 3960 insertions(+), 2881 deletions(-)

Andy Adamson (19):
      NFSv4.1: cleanup filelayout invalid deviceid handling
      NFSv4.1 cleanup filelayout invalid layout handling
      NFSv4.1 set RPC_TASK_SOFTCONN for filelayout DS RPC calls
      NFSv4.1 data server timeo and retrans module parameters
      NFSv4.1: mark deviceid invalid on filelayout DS connection errors
      NFSv4.1 remove nfs4_reset_write and nfs4_reset_read
      NFSv4.1 Check invalid deviceid upon slot table waitq wakeup
      NFSv4.1 wake up all tasks on un-connected DS slot table waitq
      NFSv4.1 send layoutreturn to fence disconnected data server
      NFSv4.1 ref count nfs_client across filelayout data server io
      NFSv4.1 dereference a disconnected data server client record
      NFSv4.1 resend LAYOUTGET on data server invalid layout errors
      NFSv4.1 fix null state reference in filelayout_async_handle_error
      NFSv4.1 Just use nfs_put_client in filelayout release
      NFSv4.1 skip rpc_call_done only on disconnected DS slot_table_waitq t=
asks
      NFSv4.1 mdsthreshold attribute xdr
      NFSv4.1 cache mdsthreshold values on OPEN
      NFSv4.1 add nfs_inode book keeping for mdsthreshold
      NFSv4.1 test the mdsthreshold hint parameters

Benny Halevy (1):
      NFS: fix unsigned comparison in nfs4_create_sec_client

Bryan Schumaker (24):
      NFS: Remove secinfo knowledge out of the generic client
      NFS: Create a submount rpc_op
      NFS: Remove extra rpc_clnt argument to proc_lookup
      NFS: pnfs_pageio_init_read() and init_write() need an extra argument
      NFS: Define nfs_direct_write_schedule_work() when v3 and v4 are disab=
led
      NFS: Define dummy nfs_init_cinfo() and nfs_init_cinfo_from_inode()
      NFS: Rename nfs4_proc_get_root()
      NFS: Create a single nfs_get_root()
      NFS: Don't pass mount data to nfs_fscache_get_super_cookie()
      NFS: Remove NFS4_MOUNT_UNSHARED
      NFS: Create a common fs_mount() function
      NFS: Create a common xdev_mount() function
      NFS: Use nfs_fs_mount_common() for xdev mounts
      NFS: Use nfs_fs_mount_common() for remote referral mounts
      NFS: Let mount data parsing set the NFS version
      NFS: Create a new nfs_try_mount()
      NFS: Create a single function for text mount data
      NFS: Create a single nfs_validate_mount_data() function
      NFS: Allocate parsed mount data directly to the nfs_mount_info struct=
ure
      NFS: Pass mntfh as part of the nfs_mount_info structure
      NFS: Create an NFS v3 stat_to_errno()
      NFS: Make v2 configurable
      NFS: Turn v3 on by default
      NFS: Fix compiler warnings

Chuck Lever (14):
      NFS: Don't swap bytes in nfs4_construct_boot_verifier()
      NFS: Add NFSDBG_STATE
      NFS: Fix comment misspelling in struct nfs_client definition
      NFS: Use proper naming conventions for NFSv4.1 server scope fields
      NFS: Use proper naming conventions for nfs_client.impl_id field
      NFS: Use proper naming conventions for the nfs_client.net field
      NFS: Clean up return code checking in nfs4_proc_exchange_id()
      NFS: Remove nfs_unique_id
      NFS: Force server to drop NFSv4 state
      NFS: Always use the same SETCLIENTID boot verifier
      NFS: Refactor nfs_get_client(): add nfs_found_client()
      NFS: Refactor nfs_get_client(): initialize nfs_client
      NFS: Add nfs_client behavior flags
      NFS: EXCHANGE_ID should save the server major and minor ID

Dan Carpenter (1):
      NFS: kmalloc() doesn't return an ERR_PTR()

Fred Isaman (23):
      NFS: grab open context in direct read
      NFS4.1: make pnfs_ld_[read|write]_done consistent
      NFS4.1: Add lseg to struct nfs4_fl_commit_bucket
      NFS: add a struct nfs_commit_data to replace nfs_write_data in commit=
s
      NFS: dprintks in directio code were referencing task after put
      NFS: reverse arg order in nfs_initiate_[read|write]
      NFS: remove unnecessary casts of void pointers in nfs4filelayout.c
      NFS: use req_offset where appropriate
      NFS: create common nfs_pgio_header for both read and write
      NFS: create struct nfs_page_array
      NFS: merge _full and _partial read rpc_ops
      NFS: merge _full and _partial write rpc_ops
      NFS: create completion structure to pass into page_init functions
      NFS: remove unused wb_complete field from struct nfs_page
      NFS: prepare coalesce testing for directio
      NFS: rewrite directio read to use async coalesce code
      NFS: create nfs_generic_commit_list
      NFS: create struct nfs_commit_info
      NFS: create nfs_commit_completion_ops
      NFS: add dreq to nfs_commit_info
      NFS: avoid some stat gathering for direct io
      NFS: rewrite directio write to use async coalesce code
      NFS: Prevent garbage cinfo->ds from leaking out

Jeff Layton (2):
      rpc_pipefs: clear write bit from top level rpc_pipefs directory
      sunrpc: suppress page allocation warnings in xprt_alloc_slot()

Matthew Treinish (1):
      Fixed goto readability in nfs_update_inode.

Randy Dunlap (1):
      sunrpc: fix kernel-doc warnings

Trond Myklebust (58):
      NFS: Fix a use-before-initialised warning in fs/nfs/write.c and fs/nf=
s/pnfs.c
      NFS: Ensure that we break out of read/write_schedule_segment on error
      NFS: O_DIRECT pgio_completion_ops error_cleanup must unlock the reque=
st
      NFS: Simplify O_DIRECT page referencing
      NFS: Use kmem_cache_zalloc() in nfs_direct_req_alloc
      NFS: Fix a compile issue when CONFIG_NFS_V4_1 is undefined
      NFS: Read cleanups
      NFS: Clean up nfs read and write error paths
      NFS: Simplify the nfs_read_completion functions
      NFSv4: Fix a typo in NFS4_enc_link_sz
      NFSv4: Delegreturn only needs the cache consistency bitmask
      NFSv4: Retrieve attributes _before_ calling delegreturn
      NFS: Don't force page cache revalidations when holding a delegation
      NFS: Optimise away nfs_check_inode_attributes() when holding a delega=
tion
      NFS: Always trust the PageUptodate flag when we have a delegation
      NFS: Simplify nfs_fhget()
      NFS: Change attribute updates should set NFS_INO_REVAL_PAGECACHE
      NFSv2/v3: Simulate the change attribute
      NFS: Simplify the cache invalidation code
      NFSv4: Simplify the NFSv4 OPEN compound
      NFSv4: Simplify the NFSv4 CREATE compound
      NFSv4: Simplify the NFSv4 REMOVE, LINK and RENAME compounds
      NFSv4: Don't request cache consistency attributes on some writes
      NFSv4: COMMIT does not need post-op attributes
      NFS: Adapt readdirplus to application usage patterns
      NFS: Fix O_DIRECT compile warnings
      NFS: Fix sparse warnings
      NFS: Don't do a full flush to disk on close() if we hold a delegation
      NFS: nfs_inode_return_delegation() should always flush dirty data
      NFSv4: nfs_client_return_marked_delegations can't flush data
      NFS: Prevent a deadlock in the new writeback code
      NFS: nfs_set_page_writeback no longer needs to reference the page
      NFS: Clean up - simplify nfs_lock_request()
      NFS: Clean up - Rename nfs_unlock_request and nfs_unlock_request_dont=
_release
      NFS: Clean up - Simplify reference counting in fs/nfs/direct.c
      NFS: Fix a compile issue when CONFIG_NFS_FSCACHE was undefined
      sunrpc: fix loss of task->tk_status after rpc_delay call in xprt_allo=
c_slot
      NFSv4.1: Fix a bad reference count issue in the pNFS commit code
      NFSv4.1: Fix session initialisation races
      NFSv4: Fix a race in the net namespace mount notification
      NFS: Add memory barriers to the nfs_client->cl_cons_state initialisat=
ion
      NFSv4.1: Exchange ID must use GFP_NOFS allocation mode
      NFSv4: Clean up the error handling for nfs4_reclaim_lease
      NFSv4: When purging the lease, we must clear NFS4CLNT_LEASE_CONFIRM
      NFSv4.1: Handle NFS4ERR_SEQ_MISORDERED when confirming the lease
      NFSv4.1: Move NFSPROC4_CLNT_BIND_CONN_TO_SESSION to the end of the op=
erations
      NFSv4.1: Ensure we use the correct credentials for session create/des=
troy
      NFSv4.1: Ensure we use the correct credentials for bind_conn_to_sessi=
on
      NFSv4.1: Add DESTROY_CLIENTID
      NFSv4.1: Don't clobber the seqid if exchange_id returns a confirmed c=
lientid
      NFSv4.1: nfs4_bind_conn_to_session should drain the session
      NFSv4.1: Handle errors in nfs4_bind_conn_to_session
      NFSv4.1: Handle NFS4ERR_CONN_NOT_BOUND_TO_SESSION in the state manage=
r
      NFSv4.1: Handle other occurrences of NFS4ERR_CONN_NOT_BOUND_TO_SESSIO=
N
      NFSv4.1: nfs4_reset_session should use nfs4_handle_reclaim_lease_erro=
r
      NFSv4: update_changeattr does not need to set NFS_INO_REVAL_PAGECACHE
      NFSv4: Map NFS4ERR_SHARE_DENIED into an EACCES error instead of EIO
      NFSv4: Add debugging printks to state manager

Weston Andros Adamson (2):
      nfs4.1: add BIND_CONN_TO_SESSION operation
      nfs41: Use BIND_CONN_TO_SESSION for CB_PATH_DOWN*



--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


--=-VVaISaPUbrioza8b+Hdf
Content-Disposition: inline
Content-Description: Attached message - linux-next: manual merge of the nfs
 tree with Linus' tree
Content-Type: message/rfc822

Return-Path: <sfr@canb.auug.org.au>
Received: from mail-imap1.uio.no ([unix socket]) by mail-imap1.uio.no
 (Cyrus v2.4.11) with LMTPA; Tue, 22 May 2012 04:10:14 +0200
X-Sieve: CMU Sieve 2.4
Delivery-date: Tue, 22 May 2012 04:10:14 +0200
Received: from mail-mx3.uio.no ([129.240.10.44]) by mail-imap1.uio.no with
 esmtp (Exim 4.69) (envelope-from <sfr@canb.auug.org.au>) id
 1SWeYA-00013R-DT for trond.myklebust@fys.uio.no; Tue, 22 May 2012 04:10:14
 +0200
Received: from haggis.pcug.org.au ([203.10.76.10] helo=members.tip.net.au)
 by mail-mx3.uio.no with esmtp  (Exim 4.76) (envelope-from
 <sfr@canb.auug.org.au>) id 1SWeY9-0000jg-CE for trond.myklebust@fys.uio.no;
 Tue, 22 May 2012 04:10:14 +0200
Received: from canb.auug.org.au (ibmaus65.lnk.telstra.net [165.228.126.9])
 (using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits)) (No client
 certificate requested) by members.tip.net.au (Postfix) with ESMTPSA id
 367C916406F; Tue, 22 May 2012 12:10:05 +1000 (EST)
Date: Tue, 22 May 2012 12:10:03 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Linus
 <torvalds@linux-foundation.org>
Subject: linux-next: manual merge of the nfs tree with Linus' tree
Message-Id: <20120522121003.f8f163ec2514308b8f000166@canb.auug.org.au>
X-Mailer: Sylpheed 3.2.0beta7 (GTK+ 2.24.10; i486-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg="PGP-SHA256"; boundary="Signature=_Tue__22_May_2012_12_10_03_+1000_icI6.EdUpIFTcnku"
X-UiO-MailScanner: No virus found
X-UiO-Spam-info: not spam, SpamAssassin (score=0.0, required=5.0,
 autolearn=disabled, T_FILL_THIS_FORM_SHORT=0.01, uiobl=NO, uiouri=NO)
X-UiO-Scanned: A21D414CB40600180D7AC5202103DBBBE16B1D26
X-UiO-SPAM-Test: remote_host: 203.10.76.10 spam_score: 0 maxlevel 30
 minaction 1 bait 0 mail/h: 1 total 12 max/h 2 blacklist 0 greylist 1
 ratelimit 0
X-Evolution-Source: 1149135252.7829.2@lade.trondhjem.org
X-Evolution-Source: local

--Signature=_Tue__22_May_2012_12_10_03_+1000_icI6.EdUpIFTcnku
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Trond,

Today's linux-next merge of the nfs tree got a conflict in
fs/nfs/nfs4proc.c between commit 26fe57502870 ("vfs: make it possible to
access the dentry hash/len as one 64-bit entry") from Linus' tree and
commit 778d28172f71 ("NFSv4: Simplify the NFSv4 REMOVE, LINK and RENAME
compounds") from the nfs tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc fs/nfs/nfs4proc.c
index ab985f6,78784e5..0000000
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@@ -2782,8 -2799,8 +2799,7 @@@ static int _nfs4_proc_remove(struct ino
  	struct nfs_server *server =3D NFS_SERVER(dir);
  	struct nfs_removeargs args =3D {
  		.fh =3D NFS_FH(dir),
 -		.name.len =3D name->len,
 -		.name.name =3D name->name,
 +		.name =3D *name,
- 		.bitmask =3D server->attr_bitmask,
  	};
  	struct nfs_removeres res =3D {
  		.server =3D server,

--Signature=_Tue__22_May_2012_12_10_03_+1000_icI6.EdUpIFTcnku
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPuvV7AAoJEECxmPOUX5FEj1oP/RpJNdOc4krBO0UxeloC6pg9
f8G+9tqLO7bKmmF4joInTvm+iivaa3dwJYFTj6eaK9CEDsEfLiTXjtQplDNP7xxW
F/SyVnl0xeiVHX++7fqu15h3sc+6CetbpSagiQsRtGKQOnBbbz7QOjKsE87YH6wM
9rl6oz5G7oqOWbBI5d9gfYRIHi6I92Ql4rPXeO4lPoRJt04m3RlXa3XM8XhlyNub
2/cJemLWYS/OJeHWTg9Wva2I6CNTyQWUFnYj2aKKcwDmq2h3965f8I3wriyWFTDg
zFWoqWzaLsnn1igmH120/aJTSe3ivPNFOdbRsC+MzbL1In9vqprM2uzrlO9bpwGP
eYYu/tv6DWUd3+TJ+bCcm5iIkeGTnRlOI/hp+/4e2IzNKs3RDetJ/L4k3UZKcqtA
9oAEuhAULx+7zY++KDahW4qI8Bpr/AGh4uGPkpXoaXRqvYzFMH7bpDt7xj66O/4w
M9GQHK+UdPZR3qguQiJX0Y8ug0lIozTTeSU8U/Q755ItLCqKdZx+tOGYfE1DzZQk
ul4Lbjjt5W8Mk8yIES93XqCaBOyuzCWszRi6uGdgDFNRcC4VEymJI+F1bN5aArhr
YATmnPDZa84dGamfZzYoVGSqVuIzQ5sZ1IodY/TX2nb/0EaFPjgZ3AEpLaIG4q+n
9ZiCNQVwLbRpkp+n7Pd6
=nms4
-----END PGP SIGNATURE-----

--Signature=_Tue__22_May_2012_12_10_03_+1000_icI6.EdUpIFTcnku--

--=-VVaISaPUbrioza8b+Hdf--

--=-wV3dn2yx7qYajYfPOQEq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJPw/aZAAoJEGcL54qWCgDybqYP/j4+T9d4zzq52bbCCnJFrEoi
agrvJvlDNSYhf+3mXaxsbztD3KgVTVsMku+N04WQxMqDtMFB2waJDVFi3ZU/GWZd
1X2cwdgcjZOE7SUm6xO1nK1IZrjE2eUNn/943oy7iNEJJ6LJ4t7VJrXjG50FWPaj
xIxJaR3oWbHh5gMQgs4IkpWNCPQL6+wI0CHYGSOvYu1tHWckWnjB0GiHvfJTg+AX
TFHrgyb03ufsTr9fv/i1LprvMQlD+P4jhlHKHAZMt9p1lz7BG4ySEOJVaKJ5KNyB
djAonX0aR9fU584PQe+KzXl/XQkCZ7nN8lHNR06/z3dhxx7qOEgm8dAc6uOhp37G
e58+Rz/QpVrWTB8IqKfrGmlz1N5lKytJB0OVLpqEJdp9n76fvz3HLu4UfNWp7FO4
XXXXmdSSp+As+V8XNMZsBxymC1KoOcSt180aHRqZGwbe8m6Slq+vHi9X8VEfbr3+
alBqdaVIuNa81SnpmY9uGsfSWuJcnLzRarQ8Ml1/WtOllgQtbUYbdB/jsTyG40Qf
z2UFDDUqpSlwDH7ihElyWgzQBSRcVU169TsQgN0caI5F87kUdx/3sCDyCKkOYpCa
Uaok0OdToIkJbY71YoPhbGG4lS3G8RIE0DJRhlgUkczj6HQs7waSE81AfrwD1Kwp
wY5aDSG3YGHm+4/N2QWl
=swoR
-----END PGP SIGNATURE-----

--=-wV3dn2yx7qYajYfPOQEq--
