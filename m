Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57553 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755826Ab0H3QTb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:19:31 -0400
Received: by eyg5 with SMTP id 5so3317354eyg.19
        for <linux-nfs@vger.kernel.org>; Mon, 30 Aug 2010 09:19:30 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1008301101560.10316@router.home>
References: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com>
	<AANLkTi=gj901aF_84+40j9MhvAwNJSNB8qRnpY8o0gBZ@mail.gmail.com>
	<AANLkTinEoMgXLvN4MvfnCHjHtHCwV1HDP67BoKQ3ZbQx@mail.gmail.com>
	<alpine.DEB.2.00.1008301101560.10316@router.home>
Date: Mon, 30 Aug 2010 09:19:30 -0700
Message-ID: <AANLkTinieSM_-x4qra7_HOCsONFAdyjn3LQbyBDJRebT@mail.gmail.com>
Subject: Re: fsync/wb deadlocks in 2.6.32
From: Kian Mohageri <kian.mohageri@gmail.com>
To: Christoph Lameter <cl@linux.com>
Cc: davidr@ressman.org, linux-nfs@vger.kernel.org, cl@linux-foundation.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 30, 2010 at 9:04 AM, Christoph Lameter <cl@linux.com> wrote:
> On Fri, 27 Aug 2010, Kian Mohageri wrote:
>
>> Just happened upon this message.  My symptoms are a little different,
>> however, and I'm still investigating the possibility of a faulty drive
>> on the NFS server.... but thought I'd chime in anyway:
>
> Its a bit troublesome that a faulty drive on an NFS server could cause
> kernel backtraces to show up on the NFS client. The faulty NFS server
> should also give you some indication that there are issues with the drive.
> Does it?
>

Some other messages in the logs on the NFS server pointed me to the
possibility of disk failure, for example (there are more instances of
similar messages, and they correspond to times when I see NFS
problems):

Aug 24 08:17:51 www01 kernel: [143799.812353] ata3.00: configured for UDMA/133
Aug 24 08:17:51 www01 kernel: [143799.812365] ata3: EH complete
Aug 24 08:17:58 www01 kernel: [143806.844363] ata3.00: configured for UDMA/133
Aug 24 08:17:58 www01 kernel: [143806.844372] ata3: EH complete
Aug 24 08:18:05 www01 kernel: [143813.868368] ata3.00: configured for UDMA/133
Aug 24 08:18:05 www01 kernel: [143813.868382] sd 2:0:0:0: [sda]
Unhandled sense code
Aug 24 08:18:05 www01 kernel: [143813.868383] sd 2:0:0:0: [sda]
Result: hostbyte=DID_OK driverbyte=DRIVER_SENSE
Aug 24 08:18:05 www01 kernel: [143813.868386] sd 2:0:0:0: [sda] Sense
Key : Medium Error [current] [descriptor]
Aug 24 08:18:05 www01 kernel: [143813.868390] Descriptor sense data
with sense descriptors (in hex):
Aug 24 08:18:05 www01 kernel: [143813.868392]         72 03 11 04 00
00 00 0c 00 0a 80 00 00 00 00 00
Aug 24 08:18:05 www01 kernel: [143813.868398]         03 41 18 c8
Aug 24 08:18:05 www01 kernel: [143813.868400] sd 2:0:0:0: [sda] Add.
Sense: Unrecovered read error - auto reallocate failed
Aug 24 08:18:05 www01 kernel: [143813.868404] sd 2:0:0:0: [sda] CDB:
Read(10): 28 00 03 41 18 c8 00 00 08 00
Aug 24 08:18:05 www01 kernel: [143813.868456] ata3: EH complete
Aug 24 08:18:12 www01 kernel: [143820.892365] ata3.00: configured for UDMA/133
Aug 24 08:18:12 www01 kernel: [143820.892375] ata3: EH complete
Aug 24 08:18:19 www01 kernel: [143827.917368] ata3.00: configured for UDMA/133
Aug 24 08:18:19 www01 kernel: [143827.917381] ata3: EH complete
Aug 24 08:18:26 www01 kernel: [143834.940364] ata3.00: configured for UDMA/133
Aug 24 08:18:26 www01 kernel: [143834.940378] ata3: EH complete
Aug 24 08:18:33 www01 kernel: [143841.964365] ata3.00: configured for UDMA/133
Aug 24 08:18:33 www01 kernel: [143841.964372] ata3: EH complete
Aug 24 08:18:41 www01 kernel: [143848.992358] ata3.00: configured for UDMA/133
Aug 24 08:18:41 www01 kernel: [143848.992374] ata3: EH complete
Aug 24 08:18:48 www01 kernel: [143856.016368] ata3.00: configured for UDMA/133
Aug 24 08:18:48 www01 kernel: [143856.016381] sd 2:0:0:0: [sda]
Unhandled sense code
Aug 24 08:18:48 www01 kernel: [143856.016383] sd 2:0:0:0: [sda]
Result: hostbyte=DID_OK driverbyte=DRIVER_SENSE
Aug 24 08:18:48 www01 kernel: [143856.016386] sd 2:0:0:0: [sda] Sense
Key : Medium Error [current] [descriptor]
Aug 24 08:18:48 www01 kernel: [143856.016389] Descriptor sense data
with sense descriptors (in hex):
Aug 24 08:18:48 www01 kernel: [143856.016391]         72 03 11 04 00
00 00 0c 00 0a 80 00 00 00 00 00
Aug 24 08:18:48 www01 kernel: [143856.016397]         03 ca d8 a0
Aug 24 08:18:48 www01 kernel: [143856.016400] sd 2:0:0:0: [sda] Add.
Sense: Unrecovered read error - auto reallocate failed
Aug 24 08:18:48 www01 kernel: [143856.016403] sd 2:0:0:0: [sda] CDB:
Read(10): 28 00 03 ca d8 a0 00 00 08 00
Aug 24 08:18:48 www01 kernel: [143856.016459] ata3: EH complete
Aug 24 08:18:55 www01 kernel: [143863.040364] ata3.00: configured for UDMA/133
Aug 24 08:18:55 www01 kernel: [143863.040374] ata3: EH complete
Aug 24 08:19:02 www01 kernel: [143870.064363] ata3.00: configured for UDMA/133
Aug 24 08:19:02 www01 kernel: [143870.064379] ata3: EH complete
Aug 24 08:19:09 www01 kernel: [143877.088360] ata3.00: configured for UDMA/133
Aug 24 08:19:09 www01 kernel: [143877.088376] ata3: EH complete
Aug 24 08:19:12 www01 kernel: [143880.704093] kjournald     D
0000000000000002     0   309      2 0x00000000
Aug 24 08:19:12 www01 kernel: [143880.704097]  ffff88012fad8710
0000000000000046 0000000000000002 0000000000015640
Aug 24 08:19:12 www01 kernel: [143880.704101]  0000000000015640
0000000000015640 000000000000f8a0 ffff88012bcbdfd8
Aug 24 08:19:12 www01 kernel: [143880.704104]  0000000000015640
0000000000015640 ffff88012bccb170 ffff88012bccb468
Aug 24 08:19:12 www01 kernel: [143880.704107] Call Trace:
Aug 24 08:19:12 www01 kernel: [143880.704116]  [<ffffffff8103fe62>] ?
update_curr+0xa6/0x147
Aug 24 08:19:12 www01 kernel: [143880.704121]  [<ffffffff810170d9>] ?
read_tsc+0xa/0x20
Aug 24 08:19:12 www01 kernel: [143880.704125]  [<ffffffff8110d2f8>] ?
sync_buffer+0x0/0x40
Aug 24 08:19:12 www01 kernel: [143880.704129]  [<ffffffff812f9549>] ?
io_schedule+0x73/0xb7
Aug 24 08:19:12 www01 kernel: [143880.704132]  [<ffffffff8110d333>] ?
sync_buffer+0x3b/0x40
Aug 24 08:19:12 www01 kernel: [143880.704134]  [<ffffffff812f9a56>] ?
__wait_on_bit+0x41/0x70
Aug 24 08:19:12 www01 kernel: [143880.704136]  [<ffffffff8110d2f8>] ?
sync_buffer+0x0/0x40
Aug 24 08:19:12 www01 kernel: [143880.704139]  [<ffffffff812f9af0>] ?
out_of_line_wait_on_bit+0x6b/0x77
Aug 24 08:19:12 www01 kernel: [143880.704143]  [<ffffffff81064b28>] ?
wake_bit_function+0x0/0x23
Aug 24 08:19:12 www01 kernel: [143880.704158]  [<ffffffffa01391d1>] ?
journal_commit_transaction+0x508/0xe2b [jbd]
Aug 24 08:19:12 www01 kernel: [143880.704163]  [<ffffffff8105a4ac>] ?
lock_timer_base+0x26/0x4b
Aug 24 08:19:12 www01 kernel: [143880.704167]  [<ffffffffa013c423>] ?
kjournald+0xdf/0x226 [jbd]
Aug 24 08:19:12 www01 kernel: [143880.704169]  [<ffffffff81064afa>] ?
autoremove_wake_function+0x0/0x2e
Aug 24 08:19:12 www01 kernel: [143880.704173]  [<ffffffffa013c344>] ?
kjournald+0x0/0x226 [jbd]
Aug 24 08:19:12 www01 kernel: [143880.704176]  [<ffffffff8106482d>] ?
kthread+0x79/0x81
Aug 24 08:19:12 www01 kernel: [143880.704179]  [<ffffffff81011baa>] ?
child_rip+0xa/0x20
Aug 24 08:19:12 www01 kernel: [143880.704181]  [<ffffffff810647b4>] ?
kthread+0x0/0x81
Aug 24 08:19:12 www01 kernel: [143880.704183]  [<ffffffff81011ba0>] ?
child_rip+0x0/0x20


I'm still running diagnostics on the disk, but SMART did complain
about at least 1 thing:

 Currently unreadable (pending) sectors detected:
 	/dev/sda [SAT] - 48 Time(s)
 	5 unreadable sectors detected

Though the numbers are all within their "safe" ranges, and I ran an
extended test last night which the drive passed :\  Of course
hardware/software doesn't always fail predictably, but the server ran
seemingly fine all weekend.

Not sure if there's other information that would be valuable, but let
me know and I'll provide what I can if it's of use to anyone.
