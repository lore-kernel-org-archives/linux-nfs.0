Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:34119 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757811Ab3BXPJ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Feb 2013 10:09:28 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@tonian.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs: fix resend_to_mds for directio
Date: Sun, 24 Feb 2013 15:09:25 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DDE9E@SACEXCMBX04-PRD.hq.netapp.com>
References: <1361712947-1778-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <1361712947-1778-1-git-send-email-bhalevy@tonian.com>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA9235DDE9ESACEXCMBX04PRDh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9235DDE9ESACEXCMBX04PRDh_
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <4BAD3AB1F904CA49B563BCCFA063CEAF@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-02-24 at 15:35 +0200, Benny Halevy wrote:
> Pass the directio request on pageio_init to clean up the API.
>=20
> Percolate pg_dreq from original nfs_pageio_descriptor to the
> pnfs_{read,write}_done_resend_to_mds and use it on respective
> call to nfs_pageio_init_{read,write} on the newly created
> nfs_pageio_descriptor.
>=20
> Reproduced by:
>=20
> Server: linux-pnfs pnfs-all-3.7 42aba94
>=20
> Client: linux-nfs/bugfixes 666b3d8
>=20
> Command:
> # mount -o minorversion=3D1 server:/ /mnt
> # dd bs=3D128k count=3D8 if=3D/dev/zero of=3D/mnt/dd.out oflag=3Ddirect
>=20
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000028
> IP: [<ffffffffa021a3a8>] atomic_inc+0x4/0x9 [nfs]
> PGD 34786067 PUD 34794067 PMD 0=20
> Oops: 0002 [#1] SMP=20
> Modules linked in: nfs_layout_nfsv41_files nfsv4 nfs nfsd lockd nfs_acl a=
uth_rpcgss exportfs sunrpc btrfs zlib_deflate libcrc32c ipv6 autofs4
> CPU 1=20
> Pid: 259, comm: kworker/1:2 Not tainted 3.8.0-rc6 #2 Bochs Bochs
> RIP: 0010:[<ffffffffa021a3a8>]  [<ffffffffa021a3a8>] atomic_inc+0x4/0x9 [=
nfs]
> RSP: 0018:ffff880038f8fa68  EFLAGS: 00010206
> RAX: ffffffffa021a6a9 RBX: ffff880038f8fb48 RCX: 00000000000a0000
> RDX: ffffffffa021e616 RSI: ffff8800385e9a40 RDI: 0000000000000028
> RBP: ffff880038f8fa68 R08: ffffffff81ad6720 R09: ffff8800385e9510
> R10: ffffffffa0228450 R11: ffff880038e87418 R12: ffff8800385e9a40
> R13: ffff8800385e9a70 R14: ffff880038f8fb38 R15: ffffffffa0148878
> FS:  0000000000000000(0000) GS:ffff88003e400000(0000) knlGS:0000000000000=
000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000028 CR3: 0000000034789000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process kworker/1:2 (pid: 259, threadinfo ffff880038f8e000, task ffff8800=
38302480)
> Stack:
>  ffff880038f8fa78 ffffffffa021a6bf ffff880038f8fa88 ffffffffa021bb82
>  ffff880038f8fae8 ffffffffa021f454 ffff880038f8fae8 ffffffff8109689d
>  ffff880038f8fab8 ffffffff00000006 0000000000000000 ffff880038f8fb48
> Call Trace:
>  [<ffffffffa021a6bf>] nfs_direct_pgio_init+0x16/0x18 [nfs]
>  [<ffffffffa021bb82>] nfs_pgheader_init+0x6a/0x6c [nfs]
>  [<ffffffffa021f454>] nfs_generic_pg_writepages+0x51/0xf8 [nfs]
>  [<ffffffff8109689d>] ? mark_held_locks+0x71/0x99
>  [<ffffffffa0148878>] ? rpc_release_resources_task+0x37/0x37 [sunrpc]
>  [<ffffffffa021bc25>] nfs_pageio_doio+0x1a/0x43 [nfs]
>  [<ffffffffa021be7c>] nfs_pageio_complete+0x16/0x2c [nfs]
>  [<ffffffffa02608be>] pnfs_write_done_resend_to_mds+0x95/0xc5 [nfsv4]
>  [<ffffffffa0148878>] ? rpc_release_resources_task+0x37/0x37 [sunrpc]
>  [<ffffffffa028e27f>] filelayout_reset_write+0x8c/0x99 [nfs_layout_nfsv41=
_files]
>  [<ffffffffa028e5f9>] filelayout_write_done_cb+0x4d/0xc1 [nfs_layout_nfsv=
41_files]
>  [<ffffffffa024587a>] nfs4_write_done+0x36/0x49 [nfsv4]
>  [<ffffffffa021f996>] nfs_writeback_done+0x53/0x1cc [nfs]
>  [<ffffffffa021fb1d>] nfs_writeback_done_common+0xe/0x10 [nfs]
>  [<ffffffffa028e03d>] filelayout_write_call_done+0x28/0x2a [nfs_layout_nf=
sv41_files]
>  [<ffffffffa01488a1>] rpc_exit_task+0x29/0x87 [sunrpc]
>  [<ffffffffa014a0c9>] __rpc_execute+0x11d/0x3cc [sunrpc]
>  [<ffffffff810969dc>] ? trace_hardirqs_on_caller+0x117/0x173
>  [<ffffffffa014a39f>] rpc_async_schedule+0x27/0x32 [sunrpc]
>  [<ffffffffa014a378>] ? __rpc_execute+0x3cc/0x3cc [sunrpc]
>  [<ffffffff8105f8c1>] process_one_work+0x226/0x422
>  [<ffffffff8105f7f4>] ? process_one_work+0x159/0x422
>  [<ffffffff81094757>] ? lock_acquired+0x210/0x249
>  [<ffffffffa014a378>] ? __rpc_execute+0x3cc/0x3cc [sunrpc]
>  [<ffffffff810600d8>] worker_thread+0x126/0x1c4
>  [<ffffffff8105ffb2>] ? manage_workers+0x240/0x240
>  [<ffffffff81064ef8>] kthread+0xb1/0xb9
>  [<ffffffff81064e47>] ? __kthread_parkme+0x65/0x65
>  [<ffffffff815206ec>] ret_from_fork+0x7c/0xb0
>  [<ffffffff81064e47>] ? __kthread_parkme+0x65/0x65
> Code: 00 83 38 02 74 12 48 81 4b 50 00 00 01 00 c7 83 60 07 00 00 01 00 0=
0 00 48 89 df e8 55 fe ff ff 5b 41 5c 5d c3 66 90 55 48 89 e5 <f0> ff 07 5d=
 c3 55 48 89 e5 f0 ff 0f 0f 94 c0 84 c0 0f 95 c0 0f=20
> RIP  [<ffffffffa021a3a8>] atomic_inc+0x4/0x9 [nfs]
>  RSP <ffff880038f8fa68>
> CR2: 0000000000000028
>=20
> Cc: Since 3.6 <stable@kernel.org>
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfs/direct.c          |  9 +++------
>  fs/nfs/internal.h        |  6 ++++--
>  fs/nfs/nfs4filelayout.c  |  6 ++++--
>  fs/nfs/pagelist.c        |  5 +++--
>  fs/nfs/pnfs.c            | 30 ++++++++++++++++++------------
>  fs/nfs/pnfs.h            | 12 ++++++++----
>  fs/nfs/read.c            |  9 +++++----
>  fs/nfs/write.c           | 10 ++++++----
>  include/linux/nfs_page.h |  3 ++-
>  include/linux/nfs_xdr.h  |  6 ++++--
>  10 files changed, 57 insertions(+), 39 deletions(-)
>=20

Hi Benny,

Can we please trim away the cleanups if this is a stable patch? As far
as I can see, we can achieve the same result without having to propagate
the dreq argument all the way to nfs_pageio_init.

How about the following?

Cheers
  Trond

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9235DDE9ESACEXCMBX04PRDh_
Content-Type: text/x-patch;
	name="0001-pnfs-fix-resend_to_mds-for-directio.patch"
Content-Description: 0001-pnfs-fix-resend_to_mds-for-directio.patch
Content-Disposition: attachment;
	filename="0001-pnfs-fix-resend_to_mds-for-directio.patch"; size=7995;
	creation-date="Sun, 24 Feb 2013 15:09:25 GMT";
	modification-date="Sun, 24 Feb 2013 15:09:25 GMT"
Content-ID: <473FC1AD67AC584F98B54DC3C23D7ACB@tahoe.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSA3OGYzMzI3N2Y5NjQzMGVhMDAxYzM5ZTk1MmY2YjgyMDBiMmFiODUwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogQmVubnkgSGFsZXZ5IDxiaGFsZXZ5QHRvbmlhbi5jb20+DQpE
YXRlOiBTdW4sIDI0IEZlYiAyMDEzIDA5OjU1OjU3IC0wNTAwDQpTdWJqZWN0OiBbUEFUQ0hdIHBu
ZnM6IGZpeCByZXNlbmRfdG9fbWRzIGZvciBkaXJlY3Rpbw0KDQpQYXNzIHRoZSBkaXJlY3RpbyBy
ZXF1ZXN0IG9uIHBhZ2Vpb19pbml0IHRvIGNsZWFuIHVwIHRoZSBBUEkuDQoNClBlcmNvbGF0ZSBw
Z19kcmVxIGZyb20gb3JpZ2luYWwgbmZzX3BhZ2Vpb19kZXNjcmlwdG9yIHRvIHRoZQ0KcG5mc197
cmVhZCx3cml0ZX1fZG9uZV9yZXNlbmRfdG9fbWRzIGFuZCB1c2UgaXQgb24gcmVzcGVjdGl2ZQ0K
Y2FsbCB0byBuZnNfcGFnZWlvX2luaXRfe3JlYWQsd3JpdGV9IG9uIHRoZSBuZXdseSBjcmVhdGVk
DQpuZnNfcGFnZWlvX2Rlc2NyaXB0b3IuDQoNClJlcHJvZHVjZWQgYnkgY29tbWFuZDoNCiBtb3Vu
dCAtbyB2ZXJzPTQuMSBzZXJ2ZXI6LyAvbW50DQogZGQgYnM9MTI4ayBjb3VudD04IGlmPS9kZXYv
emVybyBvZj0vbW50L2RkLm91dCBvZmxhZz1kaXJlY3QNCg0KQlVHOiB1bmFibGUgdG8gaGFuZGxl
IGtlcm5lbCBOVUxMIHBvaW50ZXIgZGVyZWZlcmVuY2UgYXQgMDAwMDAwMDAwMDAwMDAyOA0KSVA6
IFs8ZmZmZmZmZmZhMDIxYTNhOD5dIGF0b21pY19pbmMrMHg0LzB4OSBbbmZzXQ0KUEdEIDM0Nzg2
MDY3IFBVRCAzNDc5NDA2NyBQTUQgMA0KT29wczogMDAwMiBbIzFdIFNNUA0KTW9kdWxlcyBsaW5r
ZWQgaW46IG5mc19sYXlvdXRfbmZzdjQxX2ZpbGVzIG5mc3Y0IG5mcyBuZnNkIGxvY2tkIG5mc19h
Y2wgYXV0aF9ycGNnc3MgZXhwb3J0ZnMgc3VucnBjIGJ0cmZzIHpsaWJfZGVmbGF0ZSBsaWJjcmMz
MmMgaXB2NiBhdXRvZnM0DQpDUFUgMQ0KUGlkOiAyNTksIGNvbW06IGt3b3JrZXIvMToyIE5vdCB0
YWludGVkIDMuOC4wLXJjNiAjMiBCb2NocyBCb2Nocw0KUklQOiAwMDEwOls8ZmZmZmZmZmZhMDIx
YTNhOD5dICBbPGZmZmZmZmZmYTAyMWEzYTg+XSBhdG9taWNfaW5jKzB4NC8weDkgW25mc10NClJT
UDogMDAxODpmZmZmODgwMDM4ZjhmYTY4ICBFRkxBR1M6IDAwMDEwMjA2DQpSQVg6IGZmZmZmZmZm
YTAyMWE2YTkgUkJYOiBmZmZmODgwMDM4ZjhmYjQ4IFJDWDogMDAwMDAwMDAwMDBhMDAwMA0KUkRY
OiBmZmZmZmZmZmEwMjFlNjE2IFJTSTogZmZmZjg4MDAzODVlOWE0MCBSREk6IDAwMDAwMDAwMDAw
MDAwMjgNClJCUDogZmZmZjg4MDAzOGY4ZmE2OCBSMDg6IGZmZmZmZmZmODFhZDY3MjAgUjA5OiBm
ZmZmODgwMDM4NWU5NTEwDQpSMTA6IGZmZmZmZmZmYTAyMjg0NTAgUjExOiBmZmZmODgwMDM4ZTg3
NDE4IFIxMjogZmZmZjg4MDAzODVlOWE0MA0KUjEzOiBmZmZmODgwMDM4NWU5YTcwIFIxNDogZmZm
Zjg4MDAzOGY4ZmIzOCBSMTU6IGZmZmZmZmZmYTAxNDg4NzgNCkZTOiAgMDAwMDAwMDAwMDAwMDAw
MCgwMDAwKSBHUzpmZmZmODgwMDNlNDAwMDAwKDAwMDApIGtubEdTOjAwMDAwMDAwMDAwMDAwMDAN
CkNTOiAgMDAxMCBEUzogMDAwMCBFUzogMDAwMCBDUjA6IDAwMDAwMDAwODAwNTAwM2INCkNSMjog
MDAwMDAwMDAwMDAwMDAyOCBDUjM6IDAwMDAwMDAwMzQ3ODkwMDAgQ1I0OiAwMDAwMDAwMDAwMDAw
NmUwDQpEUjA6IDAwMDAwMDAwMDAwMDAwMDAgRFIxOiAwMDAwMDAwMDAwMDAwMDAwIERSMjogMDAw
MDAwMDAwMDAwMDAwMA0KRFIzOiAwMDAwMDAwMDAwMDAwMDAwIERSNjogMDAwMDAwMDBmZmZmMGZm
MCBEUjc6IDAwMDAwMDAwMDAwMDA0MDANClByb2Nlc3Mga3dvcmtlci8xOjIgKHBpZDogMjU5LCB0
aHJlYWRpbmZvIGZmZmY4ODAwMzhmOGUwMDAsIHRhc2sgZmZmZjg4MDAzODMwMjQ4MCkNClN0YWNr
Og0KIGZmZmY4ODAwMzhmOGZhNzggZmZmZmZmZmZhMDIxYTZiZiBmZmZmODgwMDM4ZjhmYTg4IGZm
ZmZmZmZmYTAyMWJiODINCiBmZmZmODgwMDM4ZjhmYWU4IGZmZmZmZmZmYTAyMWY0NTQgZmZmZjg4
MDAzOGY4ZmFlOCBmZmZmZmZmZjgxMDk2ODlkDQogZmZmZjg4MDAzOGY4ZmFiOCBmZmZmZmZmZjAw
MDAwMDA2IDAwMDAwMDAwMDAwMDAwMDAgZmZmZjg4MDAzOGY4ZmI0OA0KQ2FsbCBUcmFjZToNCiBb
PGZmZmZmZmZmYTAyMWE2YmY+XSBuZnNfZGlyZWN0X3BnaW9faW5pdCsweDE2LzB4MTggW25mc10N
CiBbPGZmZmZmZmZmYTAyMWJiODI+XSBuZnNfcGdoZWFkZXJfaW5pdCsweDZhLzB4NmMgW25mc10N
CiBbPGZmZmZmZmZmYTAyMWY0NTQ+XSBuZnNfZ2VuZXJpY19wZ193cml0ZXBhZ2VzKzB4NTEvMHhm
OCBbbmZzXQ0KIFs8ZmZmZmZmZmY4MTA5Njg5ZD5dID8gbWFya19oZWxkX2xvY2tzKzB4NzEvMHg5
OQ0KIFs8ZmZmZmZmZmZhMDE0ODg3OD5dID8gcnBjX3JlbGVhc2VfcmVzb3VyY2VzX3Rhc2srMHgz
Ny8weDM3IFtzdW5ycGNdDQogWzxmZmZmZmZmZmEwMjFiYzI1Pl0gbmZzX3BhZ2Vpb19kb2lvKzB4
MWEvMHg0MyBbbmZzXQ0KIFs8ZmZmZmZmZmZhMDIxYmU3Yz5dIG5mc19wYWdlaW9fY29tcGxldGUr
MHgxNi8weDJjIFtuZnNdDQogWzxmZmZmZmZmZmEwMjYwOGJlPl0gcG5mc193cml0ZV9kb25lX3Jl
c2VuZF90b19tZHMrMHg5NS8weGM1IFtuZnN2NF0NCiBbPGZmZmZmZmZmYTAxNDg4Nzg+XSA/IHJw
Y19yZWxlYXNlX3Jlc291cmNlc190YXNrKzB4MzcvMHgzNyBbc3VucnBjXQ0KIFs8ZmZmZmZmZmZh
MDI4ZTI3Zj5dIGZpbGVsYXlvdXRfcmVzZXRfd3JpdGUrMHg4Yy8weDk5IFtuZnNfbGF5b3V0X25m
c3Y0MV9maWxlc10NCiBbPGZmZmZmZmZmYTAyOGU1Zjk+XSBmaWxlbGF5b3V0X3dyaXRlX2RvbmVf
Y2IrMHg0ZC8weGMxIFtuZnNfbGF5b3V0X25mc3Y0MV9maWxlc10NCiBbPGZmZmZmZmZmYTAyNDU4
N2E+XSBuZnM0X3dyaXRlX2RvbmUrMHgzNi8weDQ5IFtuZnN2NF0NCiBbPGZmZmZmZmZmYTAyMWY5
OTY+XSBuZnNfd3JpdGViYWNrX2RvbmUrMHg1My8weDFjYyBbbmZzXQ0KIFs8ZmZmZmZmZmZhMDIx
ZmIxZD5dIG5mc193cml0ZWJhY2tfZG9uZV9jb21tb24rMHhlLzB4MTAgW25mc10NCiBbPGZmZmZm
ZmZmYTAyOGUwM2Q+XSBmaWxlbGF5b3V0X3dyaXRlX2NhbGxfZG9uZSsweDI4LzB4MmEgW25mc19s
YXlvdXRfbmZzdjQxX2ZpbGVzXQ0KIFs8ZmZmZmZmZmZhMDE0ODhhMT5dIHJwY19leGl0X3Rhc2sr
MHgyOS8weDg3IFtzdW5ycGNdDQogWzxmZmZmZmZmZmEwMTRhMGM5Pl0gX19ycGNfZXhlY3V0ZSsw
eDExZC8weDNjYyBbc3VucnBjXQ0KIFs8ZmZmZmZmZmY4MTA5NjlkYz5dID8gdHJhY2VfaGFyZGly
cXNfb25fY2FsbGVyKzB4MTE3LzB4MTczDQogWzxmZmZmZmZmZmEwMTRhMzlmPl0gcnBjX2FzeW5j
X3NjaGVkdWxlKzB4MjcvMHgzMiBbc3VucnBjXQ0KIFs8ZmZmZmZmZmZhMDE0YTM3OD5dID8gX19y
cGNfZXhlY3V0ZSsweDNjYy8weDNjYyBbc3VucnBjXQ0KIFs8ZmZmZmZmZmY4MTA1ZjhjMT5dIHBy
b2Nlc3Nfb25lX3dvcmsrMHgyMjYvMHg0MjINCiBbPGZmZmZmZmZmODEwNWY3ZjQ+XSA/IHByb2Nl
c3Nfb25lX3dvcmsrMHgxNTkvMHg0MjINCiBbPGZmZmZmZmZmODEwOTQ3NTc+XSA/IGxvY2tfYWNx
dWlyZWQrMHgyMTAvMHgyNDkNCiBbPGZmZmZmZmZmYTAxNGEzNzg+XSA/IF9fcnBjX2V4ZWN1dGUr
MHgzY2MvMHgzY2MgW3N1bnJwY10NCiBbPGZmZmZmZmZmODEwNjAwZDg+XSB3b3JrZXJfdGhyZWFk
KzB4MTI2LzB4MWM0DQogWzxmZmZmZmZmZjgxMDVmZmIyPl0gPyBtYW5hZ2Vfd29ya2VycysweDI0
MC8weDI0MA0KIFs8ZmZmZmZmZmY4MTA2NGVmOD5dIGt0aHJlYWQrMHhiMS8weGI5DQogWzxmZmZm
ZmZmZjgxMDY0ZTQ3Pl0gPyBfX2t0aHJlYWRfcGFya21lKzB4NjUvMHg2NQ0KIFs8ZmZmZmZmZmY4
MTUyMDZlYz5dIHJldF9mcm9tX2ZvcmsrMHg3Yy8weGIwDQogWzxmZmZmZmZmZjgxMDY0ZTQ3Pl0g
PyBfX2t0aHJlYWRfcGFya21lKzB4NjUvMHg2NQ0KQ29kZTogMDAgODMgMzggMDIgNzQgMTIgNDgg
ODEgNGIgNTAgMDAgMDAgMDEgMDAgYzcgODMgNjAgMDcgMDAgMDAgMDEgMDAgMDAgMDAgNDggODkg
ZGYgZTggNTUgZmUgZmYgZmYgNWIgNDEgNWMgNWQgYzMgNjYgOTAgNTUgNDggODkgZTUgPGYwPiBm
ZiAwNyA1ZCBjMyA1NSA0OCA4OSBlNSBmMCBmZiAwZiAwZiA5NCBjMCA4NCBjMCAwZiA5NSBjMCAw
Zg0KUklQICBbPGZmZmZmZmZmYTAyMWEzYTg+XSBhdG9taWNfaW5jKzB4NC8weDkgW25mc10NCiBS
U1AgPGZmZmY4ODAwMzhmOGZhNjg+DQpDUjI6IDAwMDAwMDAwMDAwMDAwMjgNCg0KU2lnbmVkLW9m
Zi1ieTogQmVubnkgSGFsZXZ5IDxiaGFsZXZ5QHRvbmlhbi5jb20+DQpDYzogc3RhYmxlQGtlcm5l
bC5vcmcgWz49IDMuNl0NClNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xlYnVzdCA8VHJvbmQuTXlr
bGVidXN0QG5ldGFwcC5jb20+DQotLS0NCiBmcy9uZnMvbmZzNGZpbGVsYXlvdXQuYyB8ICA2ICsr
KystLQ0KIGZzL25mcy9wbmZzLmMgICAgICAgICAgIHwgMTQgKysrKysrKysrKy0tLS0NCiBmcy9u
ZnMvcG5mcy5oICAgICAgICAgICB8ICA2ICsrKystLQ0KIDMgZmlsZXMgY2hhbmdlZCwgMTggaW5z
ZXJ0aW9ucygrKSwgOCBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdpdCBhL2ZzL25mcy9uZnM0Zmls
ZWxheW91dC5jIGIvZnMvbmZzL25mczRmaWxlbGF5b3V0LmMNCmluZGV4IDE5NGM0ODQuLjQ5ZWVi
MDQgMTAwNjQ0DQotLS0gYS9mcy9uZnMvbmZzNGZpbGVsYXlvdXQuYw0KKysrIGIvZnMvbmZzL25m
czRmaWxlbGF5b3V0LmMNCkBAIC05OSw3ICs5OSw4IEBAIHN0YXRpYyB2b2lkIGZpbGVsYXlvdXRf
cmVzZXRfd3JpdGUoc3RydWN0IG5mc193cml0ZV9kYXRhICpkYXRhKQ0KIA0KIAkJdGFzay0+dGtf
c3RhdHVzID0gcG5mc193cml0ZV9kb25lX3Jlc2VuZF90b19tZHMoaGRyLT5pbm9kZSwNCiAJCQkJ
CQkJJmhkci0+cGFnZXMsDQotCQkJCQkJCWhkci0+Y29tcGxldGlvbl9vcHMpOw0KKwkJCQkJCQlo
ZHItPmNvbXBsZXRpb25fb3BzLA0KKwkJCQkJCQloZHItPmRyZXEpOw0KIAl9DQogfQ0KIA0KQEAg
LTExOSw3ICsxMjAsOCBAQCBzdGF0aWMgdm9pZCBmaWxlbGF5b3V0X3Jlc2V0X3JlYWQoc3RydWN0
IG5mc19yZWFkX2RhdGEgKmRhdGEpDQogDQogCQl0YXNrLT50a19zdGF0dXMgPSBwbmZzX3JlYWRf
ZG9uZV9yZXNlbmRfdG9fbWRzKGhkci0+aW5vZGUsDQogCQkJCQkJCSZoZHItPnBhZ2VzLA0KLQkJ
CQkJCQloZHItPmNvbXBsZXRpb25fb3BzKTsNCisJCQkJCQkJaGRyLT5jb21wbGV0aW9uX29wcywN
CisJCQkJCQkJaGRyLT5kcmVxKTsNCiAJfQ0KIH0NCiANCmRpZmYgLS1naXQgYS9mcy9uZnMvcG5m
cy5jIGIvZnMvbmZzL3BuZnMuYw0KaW5kZXggNmJlNzBmNi4uOTc3NjdjOCAxMDA2NDQNCi0tLSBh
L2ZzL25mcy9wbmZzLmMNCisrKyBiL2ZzL25mcy9wbmZzLmMNCkBAIC0xNDIyLDEzICsxNDIyLDE1
IEBAIEVYUE9SVF9TWU1CT0xfR1BMKHBuZnNfZ2VuZXJpY19wZ190ZXN0KTsNCiANCiBpbnQgcG5m
c193cml0ZV9kb25lX3Jlc2VuZF90b19tZHMoc3RydWN0IGlub2RlICppbm9kZSwNCiAJCQkJc3Ry
dWN0IGxpc3RfaGVhZCAqaGVhZCwNCi0JCQkJY29uc3Qgc3RydWN0IG5mc19wZ2lvX2NvbXBsZXRp
b25fb3BzICpjb21wbF9vcHMpDQorCQkJCWNvbnN0IHN0cnVjdCBuZnNfcGdpb19jb21wbGV0aW9u
X29wcyAqY29tcGxfb3BzLA0KKwkJCQlzdHJ1Y3QgbmZzX2RpcmVjdF9yZXEgKmRyZXEpDQogew0K
IAlzdHJ1Y3QgbmZzX3BhZ2Vpb19kZXNjcmlwdG9yIHBnaW87DQogCUxJU1RfSEVBRChmYWlsZWQp
Ow0KIA0KIAkvKiBSZXNlbmQgYWxsIHJlcXVlc3RzIHRocm91Z2ggdGhlIE1EUyAqLw0KIAluZnNf
cGFnZWlvX2luaXRfd3JpdGUoJnBnaW8sIGlub2RlLCBGTFVTSF9TVEFCTEUsIGNvbXBsX29wcyk7
DQorCXBnaW8ucGdfZHJlcSA9IGRyZXE7DQogCXdoaWxlICghbGlzdF9lbXB0eShoZWFkKSkgew0K
IAkJc3RydWN0IG5mc19wYWdlICpyZXEgPSBuZnNfbGlzdF9lbnRyeShoZWFkLT5uZXh0KTsNCiAN
CkBAIC0xNDYzLDcgKzE0NjUsOCBAQCBzdGF0aWMgdm9pZCBwbmZzX2xkX2hhbmRsZV93cml0ZV9l
cnJvcihzdHJ1Y3QgbmZzX3dyaXRlX2RhdGEgKmRhdGEpDQogCWlmICghdGVzdF9hbmRfc2V0X2Jp
dChORlNfSU9IRFJfUkVETywgJmhkci0+ZmxhZ3MpKQ0KIAkJZGF0YS0+dGFzay50a19zdGF0dXMg
PSBwbmZzX3dyaXRlX2RvbmVfcmVzZW5kX3RvX21kcyhoZHItPmlub2RlLA0KIAkJCQkJCQkmaGRy
LT5wYWdlcywNCi0JCQkJCQkJaGRyLT5jb21wbGV0aW9uX29wcyk7DQorCQkJCQkJCWhkci0+Y29t
cGxldGlvbl9vcHMsDQorCQkJCQkJCWhkci0+ZHJlcSk7DQogfQ0KIA0KIC8qDQpAQCAtMTU3OCwx
MyArMTU4MSwxNSBAQCBFWFBPUlRfU1lNQk9MX0dQTChwbmZzX2dlbmVyaWNfcGdfd3JpdGVwYWdl
cyk7DQogDQogaW50IHBuZnNfcmVhZF9kb25lX3Jlc2VuZF90b19tZHMoc3RydWN0IGlub2RlICpp
bm9kZSwNCiAJCQkJc3RydWN0IGxpc3RfaGVhZCAqaGVhZCwNCi0JCQkJY29uc3Qgc3RydWN0IG5m
c19wZ2lvX2NvbXBsZXRpb25fb3BzICpjb21wbF9vcHMpDQorCQkJCWNvbnN0IHN0cnVjdCBuZnNf
cGdpb19jb21wbGV0aW9uX29wcyAqY29tcGxfb3BzLA0KKwkJCQlzdHJ1Y3QgbmZzX2RpcmVjdF9y
ZXEgKmRyZXEpDQogew0KIAlzdHJ1Y3QgbmZzX3BhZ2Vpb19kZXNjcmlwdG9yIHBnaW87DQogCUxJ
U1RfSEVBRChmYWlsZWQpOw0KIA0KIAkvKiBSZXNlbmQgYWxsIHJlcXVlc3RzIHRocm91Z2ggdGhl
IE1EUyAqLw0KIAluZnNfcGFnZWlvX2luaXRfcmVhZCgmcGdpbywgaW5vZGUsIGNvbXBsX29wcyk7
DQorCXBnaW8ucGdfZHJlcSA9IGRyZXE7DQogCXdoaWxlICghbGlzdF9lbXB0eShoZWFkKSkgew0K
IAkJc3RydWN0IG5mc19wYWdlICpyZXEgPSBuZnNfbGlzdF9lbnRyeShoZWFkLT5uZXh0KTsNCiAN
CkBAIC0xNjE1LDcgKzE2MjAsOCBAQCBzdGF0aWMgdm9pZCBwbmZzX2xkX2hhbmRsZV9yZWFkX2Vy
cm9yKHN0cnVjdCBuZnNfcmVhZF9kYXRhICpkYXRhKQ0KIAlpZiAoIXRlc3RfYW5kX3NldF9iaXQo
TkZTX0lPSERSX1JFRE8sICZoZHItPmZsYWdzKSkNCiAJCWRhdGEtPnRhc2sudGtfc3RhdHVzID0g
cG5mc19yZWFkX2RvbmVfcmVzZW5kX3RvX21kcyhoZHItPmlub2RlLA0KIAkJCQkJCQkmaGRyLT5w
YWdlcywNCi0JCQkJCQkJaGRyLT5jb21wbGV0aW9uX29wcyk7DQorCQkJCQkJCWhkci0+Y29tcGxl
dGlvbl9vcHMsDQorCQkJCQkJCWhkci0+ZHJlcSk7DQogfQ0KIA0KIC8qDQpkaWZmIC0tZ2l0IGEv
ZnMvbmZzL3BuZnMuaCBiL2ZzL25mcy9wbmZzLmgNCmluZGV4IDk3Y2IzNTguLjk0YmE4MDQgMTAw
NjQ0DQotLS0gYS9mcy9uZnMvcG5mcy5oDQorKysgYi9mcy9uZnMvcG5mcy5oDQpAQCAtMjMwLDkg
KzIzMCwxMSBAQCBzdHJ1Y3QgcG5mc19sYXlvdXRfc2VnbWVudCAqcG5mc191cGRhdGVfbGF5b3V0
KHN0cnVjdCBpbm9kZSAqaW5vLA0KIA0KIHZvaWQgbmZzNF9kZXZpY2VpZF9tYXJrX2NsaWVudF9p
bnZhbGlkKHN0cnVjdCBuZnNfY2xpZW50ICpjbHApOw0KIGludCBwbmZzX3JlYWRfZG9uZV9yZXNl
bmRfdG9fbWRzKHN0cnVjdCBpbm9kZSAqaW5vZGUsIHN0cnVjdCBsaXN0X2hlYWQgKmhlYWQsDQot
CQkJY29uc3Qgc3RydWN0IG5mc19wZ2lvX2NvbXBsZXRpb25fb3BzICpjb21wbF9vcHMpOw0KKwkJ
CWNvbnN0IHN0cnVjdCBuZnNfcGdpb19jb21wbGV0aW9uX29wcyAqY29tcGxfb3BzLA0KKwkJCXN0
cnVjdCBuZnNfZGlyZWN0X3JlcSAqZHJlcSk7DQogaW50IHBuZnNfd3JpdGVfZG9uZV9yZXNlbmRf
dG9fbWRzKHN0cnVjdCBpbm9kZSAqaW5vZGUsIHN0cnVjdCBsaXN0X2hlYWQgKmhlYWQsDQotCQkJ
Y29uc3Qgc3RydWN0IG5mc19wZ2lvX2NvbXBsZXRpb25fb3BzICpjb21wbF9vcHMpOw0KKwkJCWNv
bnN0IHN0cnVjdCBuZnNfcGdpb19jb21wbGV0aW9uX29wcyAqY29tcGxfb3BzLA0KKwkJCXN0cnVj
dCBuZnNfZGlyZWN0X3JlcSAqZHJlcSk7DQogc3RydWN0IG5mczRfdGhyZXNob2xkICpwbmZzX21k
c3RocmVzaG9sZF9hbGxvYyh2b2lkKTsNCiANCiAvKiBuZnM0X2RldmljZWlkX2ZsYWdzICovDQot
LSANCjEuOC4xLjINCg0K

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9235DDE9ESACEXCMBX04PRDh_--
