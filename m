From: yo mama <mamamia69@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
	0000000000000020
Date: Sat, 31 Jul 2010 10:26:54 +0530
Message-ID: <AANLkTi=nA8FCQrOB09uqCfFyduSATgzg-Q2GyZk-D+GP@mail.gmail.com>
References: <AANLkTikYDGpeX8kcK3ygFzjM+bYMFTtqr8Wgx+CygUt8@mail.gmail.com>
	<4C5105F8.5050101@cn.fujitsu.com>
	<1280514531.12852.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bian Naimeng <biannm@cn.fujitsu.com>, linux-nfs@vger.kernel.org,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:48248 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab0GaE4z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Jul 2010 00:56:55 -0400
Received: by iwn7 with SMTP id 7so2009493iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 30 Jul 2010 21:56:54 -0700 (PDT)
In-Reply-To: <1280514531.12852.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just an update, kernel crash occurs even when running iozone in
automode, please see the updated /var/log/messages


Jul 30 21:26:21 localhost kernel: FS-Cache: Loaded
Jul 30 21:26:22 localhost kernel: FS-Cache: Netfs 'nfs' registered for =
caching
Jul 30 21:29:22 localhost kernel: nfs: server 192.168.100.12 not respon=
ding, ti
med out
Jul 30 21:29:22 localhost kernel: Error: state manager failed on NFSv4 =
server 1
92.168.100.12 with error 5
Jul 30 21:37:38 localhost kernel: nfs4filelayout_init: NFSv4 File Layou=
t Driver
 Registering...
Jul 30 21:39:29 localhost kernel: BUG: unable to handle kernel NULL poi=
nter der
eference at 0000000000000030
Jul 30 21:39:29 localhost kernel: IP: [<ffffffff814411d4>] _raw_spin_lo=
ck+0xe/0
x25
Jul 30 21:39:29 localhost kernel: PGD 0
Jul 30 21:39:29 localhost kernel: Oops: 0002 [#1] SMP
Jul 30 21:39:29 localhost kernel: last sysfs file: /sys/devices/pci0000=
:00/0000
:00:19.0/irq
Jul 30 21:39:29 localhost kernel: CPU 3
Jul 30 21:39:29 localhost kernel: Modules linked in: nfslayoutdriver nf=
s lockd
fscache nfs_acl auth_rpcgss sunrpc ipv6 p4_clockmod freq_table speedste=
p_lib dm
_multipath uinput e1000e iTCO_wdt iTCO_vendor_support i2c_i801 pcspkr s=
erio_raw
 usb_storage i915 drm_kms_helper drm i2c_algo_bit i2c_core video output=
 [last u
nloaded: mperf]
Jul 30 21:39:29 localhost kernel:
Jul 30 21:39:29 localhost kernel: Pid: 1629, comm: 192.168.100.12- Not =
tainted
2.6.35-rc5-pnfs #1 To be filled by O.E.M./To Be Filled By O.E.M.
Jul 30 21:39:29 localhost kernel: RIP: 0010:[<ffffffff814411d4>]  [<fff=
fffff814
411d4>] _raw_spin_lock+0xe/0x25
Jul 30 21:39:29 localhost kernel: RSP: 0018:ffff8800700b5cb0  EFLAGS: 0=
0010282
Jul 30 21:39:29 localhost kernel: RAX: 0000000000010000 RBX: 0000000000=
000000 R
CX: 000000000020001d
Jul 30 21:39:29 localhost kernel: RDX: ffff88007bfc9900 RSI: ffffffffa0=
225fe0 R
DI: 0000000000000030
Jul 30 21:39:29 localhost kernel: RBP: ffff8800700b5cb0 R08: ffff88007c=
7c1800 R
09: ffff880000000001
Jul 30 21:39:29 localhost kernel: R10: ffff88007bfc9c00 R11: ffff880070=
b12a00 R
12: ffffffffa0225fe0
Jul 30 21:39:29 localhost kernel: R13: ffff880070bdaf64 R14: ffff880079=
79f800 R
15: ffff8800700b5d60
Jul 30 21:39:29 localhost kernel: FS:  0000000000000000(0000) GS:ffff88=
00021800
00(0000) knlGS:0000000000000000
Jul 30 21:39:29 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000=
00008005
003b
Jul 30 21:39:29 localhost kernel: CR2: 0000000000000030 CR3: 0000000001=
a42000 C
R4: 00000000000006e0
Jul 30 21:39:29 localhost kernel: DR0: 0000000000000000 DR1: 0000000000=
000000 D
R2: 0000000000000000
Jul 30 21:39:29 localhost kernel: DR3: 0000000000000000 DR6: 00000000ff=
ff0ff0 D
R7: 0000000000000400
Jul 30 21:39:29 localhost kernel: Process 192.168.100.12- (pid: 1629, t=
hreadinf
o ffff8800700b4000, task ffff8800796e1730)
Jul 30 21:39:29 localhost kernel: Stack:
Jul 30 21:39:29 localhost kernel: ffff8800700b5cc0 ffffffffa0212c6e fff=
f8800700
b5ce0 ffffffffa0214168
Jul 30 21:39:29 localhost kernel: <0> ffff880070bdaf00 ffff880070bdaf54=
 ffff880
0700b5d00 ffffffffa0201ab1
Jul 30 21:39:29 localhost kernel: <0> ffff8800700b5d00 ffff880070bdaf00=
 ffff880
0700b5d40 ffffffffa0201b92
Jul 30 21:39:29 localhost kernel: Call Trace:
Jul 30 21:39:29 localhost kernel: [<ffffffffa0212c6e>] spin_lock+0xe/0x=
10 [nfs]
Jul 30 21:39:29 localhost kernel: [<ffffffffa0214168>] pnfs_set_layout_=
stateid+
0x1b/0x3b [nfs]
Jul 30 21:39:29 localhost kernel: [<ffffffffa0201ab1>] pnfs4_layout_rec=
laim+0x3
5/0x39 [nfs]
Jul 30 21:39:29 localhost kernel: [<ffffffffa0201b92>] nfs4_open_recove=
r+0xdd/0
xf1 [nfs]
Jul 30 21:39:29 localhost kernel: [<ffffffffa0201d04>] nfs4_open_delega=
tion_rec
all+0x80/0x13f [nfs]
Jul 30 21:39:29 localhost kernel: [<ffffffffa020e7e0>] __nfs_inode_retu=
rn_deleg
ation+0xc7/0x1f5 [nfs]
Jul 30 21:39:29 localhost kernel: [<ffffffff810caf61>] ? do_writepages+=
0x21/0x2
a
Jul 30 21:39:29 localhost kernel: [<ffffffffa020e9ff>] nfs_client_retur=
n_marked
_delegations+0x85/0xc6 [nfs]
Jul 30 21:39:29 localhost kernel: [<ffffffffa020d7da>] nfs4_run_state_m=
anager+0
x368/0x494 [nfs]
Jul 30 21:39:29 localhost kernel: [<ffffffffa020d472>] ? nfs4_run_state=
_manager
+0x0/0x494 [nfs]
Jul 30 21:39:29 localhost kernel: [<ffffffff81064bd9>] kthread+0x7f/0x8=
7
Jul 30 21:39:29 localhost kernel: [<ffffffff8100aa24>] kernel_thread_he=
lper+0x4
/0x10
Jul 30 21:39:29 localhost kernel: [<ffffffff81064b5a>] ? kthread+0x0/0x=
87
Jul 30 21:39:29 localhost kernel: [<ffffffff8100aa20>] ? kernel_thread_=
helper+0
x0/0x10
Jul 30 21:39:29 localhost kernel: Code: c2 8d 90 00 00 01 00 75 04 f0 0=
f b1 17
0f 94 c2 0f b6 c2 85 c0 c9 0f 95 c0 0f b6 c0 c3 55 48 89 e5 0f 1f 44 00=
 00 b8 0
0 00 01 00 <f0> 0f c1 07 0f b7 d0 c1 e8 10 39 c2 74 07 f3 90 0f b7 17 e=
b f5
Jul 30 21:39:29 localhost kernel: RIP  [<ffffffff814411d4>] _raw_spin_l=
ock+0xe/
0x25


On Fri, Jul 30, 2010 at 11:58 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Thu, 2010-07-29 at 12:39 +0800, Bian Naimeng wrote:
>> > Hello,
>> >
>> > I am running Kernel version 2.6.35-rc5-pnfs and notice there is ke=
rnel
>> > crash everytime i run iozone on the mounted directory. Is there a
>> > patch already developed for this bug which i can apply. Please see=
 the
>> > error message from message log.
>> >
>>
>> =A0I'm not sure it's ok, please try it.
>>
>> ----
>>
>> =A0nfs_writeargs.lock_context always NULL at direct write procedure,
>> it will cause kernel panic when encode stateid.
>>
>> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
>>
>> ---
>> =A0fs/nfs/direct.c | =A0 =A01 +
>> =A01 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>> index 3ef9b0c..cb2e1fd 100644
>> --- a/fs/nfs/direct.c
>> +++ b/fs/nfs/direct.c
>> @@ -801,6 +801,7 @@ static ssize_t nfs_direct_write_schedule_segment=
(struct nfs_direct_req *dreq,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->cred =3D msg.rpc_cred;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->args.fh =3D NFS_FH(inode);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->args.context =3D ctx;
>> + =A0 =A0 =A0 =A0 =A0 =A0 data->args.lock_context =3D nfs_get_lock_c=
ontext(ctx);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->args.offset =3D pos;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->args.pgbase =3D pgbase;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->args.pages =3D data->pagevec;
>> --
>> 1.6.5.2
>>
>
> Well caught. There is a similar issue with NFS reads too. I'll fix up
> the lock state tracking patch...
>
> Thanks
> =A0Trond
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
