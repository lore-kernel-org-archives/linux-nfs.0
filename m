Return-Path: linux-nfs-owner@vger.kernel.org
Received: from outrelay08.libero.it ([212.52.84.112]:47701 "EHLO
	outrelay08.libero.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235Ab1K1HuY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Nov 2011 02:50:24 -0500
Received: from [192.168.1.2] (87.4.205.149) by outrelay08.libero.it (8.5.133) (authenticated as bpgm@libero.it)
        id 4EBCFB60025A509D for linux-nfs@vger.kernel.org; Mon, 28 Nov 2011 08:45:04 +0100
Subject: NFS issue (?)
From: Gabriele Messineo <bpgm@libero.it>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Nov 2011 08:45:02 +0100
Message-ID: <1322466302.3441.1.camel@vaio>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm writing you to highlight a possible bug affecting the NFSv3 kernel
module.

I'm not experienced in using it, and the issue is really difficult to
reproduce, but it happened twice in a day and can be quite annoying for
the user.

So, here the description:
        - a multi core system (I have an intel i5 cpu so, 4 cores)
(that's my guess, I think it could be a concurrency issue)
        - a remote nfs mount
        - several processes that are copying and/or moving lots of GiBs
of data to the NFS storage

        Suddenly the system becomes unresponsive for several minutes
(like frozen: no mouse, no keyboard, no screen updates of any sort).

        [But when every nfs operation is successfully completed
everything is restored correctly]

Hints to debug it:
        - at the end of the mail I put the kernel log
in /var/log/messages
        - In both cases when the system hanged, the iowait of the system
was nearly at 3 full cores, and the running queue of the processes where
over 5 (so, more running processes than cpu cores) (monitored via munin)

It happened on the following versions:
        - 2.6.32
        - 3.1.0
on an AMD64 architecture.

Hope it could help.

Regards

Gabriele Messineo


PS: the kernel log:

Nov 25 11:35:07 vaio kernel: [10786.492648] ls              D
ffff880117c12f40     0  5152   5103 0x00000000
Nov 25 11:35:07 vaio kernel: [10786.492652]  ffff88002f8e48f0
0000000000000082 ffff88010fe79000 ffff88009fdce240
Nov 25 11:35:07 vaio kernel: [10786.492656]  0000000000012f40
ffff88001a3fdfd8 ffff88001a3fdfd8 ffff88002f8e48f0
Nov 25 11:35:07 vaio kernel: [10786.492659]  ffffffff81013255
ffffffff810654c7 ffff880026e5b130 ffff880117c13788
Nov 25 11:35:07 vaio kernel: [10786.492662] Call Trace:
Nov 25 11:35:07 vaio kernel: [10786.492670]  [<ffffffff81013255>] ?
read_tsc+0x5/0x14
Nov 25 11:35:07 vaio kernel: [10786.492675]  [<ffffffff810654c7>] ?
timekeeping_get_ns+0xd/0x2a
Nov 25 11:35:07 vaio kernel: [10786.492679]  [<ffffffff810afcdd>] ?
lock_page+0x20/0x20
Nov 25 11:35:07 vaio kernel: [10786.492684]  [<ffffffff8132c284>] ?
io_schedule+0x59/0x71
Nov 25 11:35:07 vaio kernel: [10786.492686]  [<ffffffff810afce3>] ?
sleep_on_page+0x6/0xa
Nov 25 11:35:07 vaio kernel: [10786.492688]  [<ffffffff8132c6c7>] ?
__wait_on_bit+0x3e/0x71
Nov 25 11:35:07 vaio kernel: [10786.492690]  [<ffffffff810afe32>] ?
wait_on_page_bit+0x6e/0x73
Nov 25 11:35:07 vaio kernel: [10786.492694]  [<ffffffff8105ec41>] ?
autoremove_wake_function+0x2a/0x2a
Nov 25 11:35:07 vaio kernel: [10786.492697]  [<ffffffff810aff0a>] ?
filemap_fdatawait_range+0x74/0x139
Nov 25 11:35:07 vaio kernel: [10786.492700]  [<ffffffff810b1722>] ?
filemap_write_and_wait+0x24/0x30
Nov 25 11:35:07 vaio kernel: [10786.492711]  [<ffffffffa0741c32>] ?
nfs_getattr+0x32/0xac [nfs]
Nov 25 11:35:07 vaio kernel: [10786.492715]  [<ffffffff810f72a4>] ?
vfs_fstatat+0x48/0x60
Nov 25 11:35:07 vaio kernel: [10786.492717]  [<ffffffff810f73e3>] ?
sys_newlstat+0x12/0x2b
Nov 25 11:35:07 vaio kernel: [10786.492721]  [<ffffffff81103a21>] ? dput
+0x52/0xee
Nov 25 11:35:07 vaio kernel: [10786.492730]  [<ffffffffa0751227>] ?
nfs3_proc_getacl+0x34b/0x34b [nfs]
Nov 25 11:35:07 vaio kernel: [10786.492734]  [<ffffffff811095f4>] ?
mntput_no_expire+0x1e/0xc9
Nov 25 11:35:07 vaio kernel: [10786.492737]  [<ffffffff8110cc4b>] ?
sys_lgetxattr+0x4e/0x5c
Nov 25 11:35:07 vaio kernel: [10786.492741]  [<ffffffff813322d2>] ?
system_call_fastpath+0x16/0x1b
Nov 25 11:35:08 vaio rsyslogd-2177: imuxsock lost 5530 messages from pid
8786 due to rate-limiting
Nov 25 11:35:08 vaio rsyslogd-2177: imuxsock begins to drop messages
from pid 8786 due to rate-limiting
Nov 25 11:37:07 vaio kernel: [10906.292897] ls              D
ffff880117c12f40     0  5152   5103 0x00000000
Nov 25 11:37:07 vaio kernel: [10906.292903]  ffff88002f8e48f0
0000000000000082 ffff88010fe79000 ffff88009fdce240
Nov 25 11:37:07 vaio kernel: [10906.292908]  0000000000012f40
ffff88001a3fdfd8 ffff88001a3fdfd8 ffff88002f8e48f0
Nov 25 11:37:07 vaio kernel: [10906.292912]  ffffffff81013255
ffffffff810654c7 ffff880026e5b130 ffff880117c13788
Nov 25 11:37:07 vaio kernel: [10906.292916] Call Trace:
Nov 25 11:37:07 vaio kernel: [10906.292926]  [<ffffffff81013255>] ?
read_tsc+0x5/0x14
Nov 25 11:37:07 vaio kernel: [10906.292932]  [<ffffffff810654c7>] ?
timekeeping_get_ns+0xd/0x2a
Nov 25 11:37:07 vaio kernel: [10906.292937]  [<ffffffff810afcdd>] ?
lock_page+0x20/0x20
Nov 25 11:37:07 vaio kernel: [10906.292942]  [<ffffffff8132c284>] ?
io_schedule+0x59/0x71
Nov 25 11:37:07 vaio kernel: [10906.292945]  [<ffffffff810afce3>] ?
sleep_on_page+0x6/0xa
Nov 25 11:37:07 vaio kernel: [10906.292949]  [<ffffffff8132c6c7>] ?
__wait_on_bit+0x3e/0x71
Nov 25 11:37:07 vaio kernel: [10906.292952]  [<ffffffff810afe32>] ?
wait_on_page_bit+0x6e/0x73
Nov 25 11:37:07 vaio kernel: [10906.292957]  [<ffffffff8105ec41>] ?
autoremove_wake_function+0x2a/0x2a
Nov 25 11:37:07 vaio kernel: [10906.292960]  [<ffffffff810aff0a>] ?
filemap_fdatawait_range+0x74/0x139
Nov 25 11:37:07 vaio kernel: [10906.292964]  [<ffffffff810b1722>] ?
filemap_write_and_wait+0x24/0x30
Nov 25 11:37:07 vaio kernel: [10906.292978]  [<ffffffffa0741c32>] ?
nfs_getattr+0x32/0xac [nfs]
Nov 25 11:37:07 vaio kernel: [10906.292983]  [<ffffffff810f72a4>] ?
vfs_fstatat+0x48/0x60
Nov 25 11:37:07 vaio kernel: [10906.292986]  [<ffffffff810f73e3>] ?
sys_newlstat+0x12/0x2b
Nov 25 11:37:07 vaio kernel: [10906.292989]  [<ffffffff81103a21>] ? dput
+0x52/0xee
Nov 25 11:37:07 vaio kernel: [10906.293002]  [<ffffffffa0751227>] ?
nfs3_proc_getacl+0x34b/0x34b [nfs]
Nov 25 11:37:07 vaio kernel: [10906.293006]  [<ffffffff811095f4>] ?
mntput_no_expire+0x1e/0xc9
Nov 25 11:37:07 vaio kernel: [10906.293010]  [<ffffffff8110cc4b>] ?
sys_lgetxattr+0x4e/0x5c
Nov 25 11:37:07 vaio kernel: [10906.293016]  [<ffffffff813322d2>] ?
system_call_fastpath+0x16/0x1b
Nov 25 11:39:07 vaio kernel: [11026.093402] ls              D
ffff880117c12f40     0  5152   5103 0x00000000
Nov 25 11:39:07 vaio kernel: [11026.093408]  ffff88002f8e48f0
0000000000000082 ffff88010fe79000 ffff88009fdce240
Nov 25 11:39:07 vaio kernel: [11026.093414]  0000000000012f40
ffff88001a3fdfd8 ffff88001a3fdfd8 ffff88002f8e48f0
Nov 25 11:39:07 vaio kernel: [11026.093420]  ffffffff81013255
ffffffff810654c7 ffff880026e5b130 ffff880117c13788
Nov 25 11:39:07 vaio kernel: [11026.093425] Call Trace:
Nov 25 11:39:07 vaio kernel: [11026.093436]  [<ffffffff81013255>] ?
read_tsc+0x5/0x14
Nov 25 11:39:07 vaio kernel: [11026.093444]  [<ffffffff810654c7>] ?
timekeeping_get_ns+0xd/0x2a
Nov 25 11:39:07 vaio kernel: [11026.093449]  [<ffffffff810afcdd>] ?
lock_page+0x20/0x20
Nov 25 11:39:07 vaio kernel: [11026.093456]  [<ffffffff8132c284>] ?
io_schedule+0x59/0x71
Nov 25 11:39:07 vaio kernel: [11026.093460]  [<ffffffff810afce3>] ?
sleep_on_page+0x6/0xa
Nov 25 11:39:07 vaio kernel: [11026.093464]  [<ffffffff8132c6c7>] ?
__wait_on_bit+0x3e/0x71
Nov 25 11:39:07 vaio kernel: [11026.093468]  [<ffffffff810afe32>] ?
wait_on_page_bit+0x6e/0x73
Nov 25 11:39:07 vaio kernel: [11026.093474]  [<ffffffff8105ec41>] ?
autoremove_wake_function+0x2a/0x2a
Nov 25 11:39:07 vaio kernel: [11026.093478]  [<ffffffff810aff0a>] ?
filemap_fdatawait_range+0x74/0x139
Nov 25 11:39:07 vaio kernel: [11026.093483]  [<ffffffff810b1722>] ?
filemap_write_and_wait+0x24/0x30
Nov 25 11:39:07 vaio kernel: [11026.093499]  [<ffffffffa0741c32>] ?
nfs_getattr+0x32/0xac [nfs]
Nov 25 11:39:07 vaio kernel: [11026.093505]  [<ffffffff810f72a4>] ?
vfs_fstatat+0x48/0x60
Nov 25 11:39:07 vaio kernel: [11026.093509]  [<ffffffff810f73e3>] ?
sys_newlstat+0x12/0x2b
Nov 25 11:39:07 vaio kernel: [11026.093513]  [<ffffffff81103a21>] ? dput
+0x52/0xee
Nov 25 11:39:07 vaio kernel: [11026.093528]  [<ffffffffa0751227>] ?
nfs3_proc_getacl+0x34b/0x34b [nfs]
Nov 25 11:39:07 vaio kernel: [11026.093533]  [<ffffffff811095f4>] ?
mntput_no_expire+0x1e/0xc9
Nov 25 11:39:07 vaio kernel: [11026.093539]  [<ffffffff8110cc4b>] ?
sys_lgetxattr+0x4e/0x5c
Nov 25 11:39:07 vaio kernel: [11026.093546]  [<ffffffff813322d2>] ?
system_call_fastpath+0x16/0x1b
Nov 25 11:39:27 vaio kernel: [11046.679054] nfs: server 192.168.1.5 not
responding, still trying
Nov 25 11:40:09 vaio rsyslogd-2177: imuxsock lost 5530 messages from pid
8786 due to rate-limiting
Nov 25 11:40:09 vaio rsyslogd-2177: imuxsock begins to drop messages
from pid 8786 due to rate-limiting
Nov 25 11:41:07 vaio kernel: [11145.893886] ls              D
ffff880117c12f40     0  5152   5103 0x00000000
Nov 25 11:41:07 vaio kernel: [11145.893893]  ffff88002f8e48f0
0000000000000082 ffff88010fe79000 ffff88009fdce240
Nov 25 11:41:07 vaio kernel: [11145.893900]  0000000000012f40
ffff88001a3fdfd8 ffff88001a3fdfd8 ffff88002f8e48f0
Nov 25 11:41:07 vaio kernel: [11145.893906]  ffffffff81013255
ffffffff810654c7 ffff880026e5b130 ffff880117c13788
Nov 25 11:41:07 vaio kernel: [11145.893912] Call Trace:
Nov 25 11:41:07 vaio kernel: [11145.893924]  [<ffffffff81013255>] ?
read_tsc+0x5/0x14
Nov 25 11:41:07 vaio kernel: [11145.893931]  [<ffffffff810654c7>] ?
timekeeping_get_ns+0xd/0x2a
Nov 25 11:41:07 vaio kernel: [11145.893937]  [<ffffffff810afcdd>] ?
lock_page+0x20/0x20
Nov 25 11:41:07 vaio kernel: [11145.893944]  [<ffffffff8132c284>] ?
io_schedule+0x59/0x71
Nov 25 11:41:07 vaio kernel: [11145.893948]  [<ffffffff810afce3>] ?
sleep_on_page+0x6/0xa
Nov 25 11:41:07 vaio kernel: [11145.893953]  [<ffffffff8132c6c7>] ?
__wait_on_bit+0x3e/0x71
Nov 25 11:41:07 vaio kernel: [11145.893957]  [<ffffffff810afe32>] ?
wait_on_page_bit+0x6e/0x73
Nov 25 11:41:07 vaio kernel: [11145.893964]  [<ffffffff8105ec41>] ?
autoremove_wake_function+0x2a/0x2a
Nov 25 11:41:07 vaio kernel: [11145.893969]  [<ffffffff810aff0a>] ?
filemap_fdatawait_range+0x74/0x139
Nov 25 11:41:07 vaio kernel: [11145.893974]  [<ffffffff810b1722>] ?
filemap_write_and_wait+0x24/0x30
Nov 25 11:41:07 vaio kernel: [11145.893990]  [<ffffffffa0741c32>] ?
nfs_getattr+0x32/0xac [nfs]
Nov 25 11:41:07 vaio kernel: [11145.893996]  [<ffffffff810f72a4>] ?
vfs_fstatat+0x48/0x60
Nov 25 11:41:07 vaio kernel: [11145.894000]  [<ffffffff810f73e3>] ?
sys_newlstat+0x12/0x2b
Nov 25 11:41:07 vaio kernel: [11145.894005]  [<ffffffff81103a21>] ? dput
+0x52/0xee
Nov 25 11:41:07 vaio kernel: [11145.894021]  [<ffffffffa0751227>] ?
nfs3_proc_getacl+0x34b/0x34b [nfs]
Nov 25 11:41:07 vaio kernel: [11145.894027]  [<ffffffff811095f4>] ?
mntput_no_expire+0x1e/0xc9
Nov 25 11:41:07 vaio kernel: [11145.894032]  [<ffffffff8110cc4b>] ?
sys_lgetxattr+0x4e/0x5c
Nov 25 11:41:07 vaio kernel: [11145.894038]  [<ffffffff813322d2>] ?
system_call_fastpath+0x16/0x1b
Nov 25 11:43:05 vaio kernel: [11263.722526] nfs: server 192.168.1.5 OK
Nov 25 11:43:07 vaio kernel: [11265.694332] ls              D
ffff880117c12f40     0  5152   5103 0x00000000
Nov 25 11:43:07 vaio kernel: [11265.694338]  ffff88002f8e48f0
0000000000000082 ffff88010fe79000 ffff88009fdce240
Nov 25 11:43:07 vaio kernel: [11265.694344]  0000000000012f40
ffff88001a3fdfd8 ffff88001a3fdfd8 ffff88002f8e48f0
Nov 25 11:43:07 vaio kernel: [11265.694350]  ffffffff81013255
ffffffff810654c7 ffff880026e5b130 ffff880117c13788
Nov 25 11:43:07 vaio kernel: [11265.694355] Call Trace:
Nov 25 11:43:07 vaio kernel: [11265.694366]  [<ffffffff81013255>] ?
read_tsc+0x5/0x14
Nov 25 11:43:07 vaio kernel: [11265.694373]  [<ffffffff810654c7>] ?
timekeeping_get_ns+0xd/0x2a
Nov 25 11:43:07 vaio kernel: [11265.694378]  [<ffffffff810afcdd>] ?
lock_page+0x20/0x20
Nov 25 11:43:07 vaio kernel: [11265.694385]  [<ffffffff8132c284>] ?
io_schedule+0x59/0x71
Nov 25 11:43:07 vaio kernel: [11265.694389]  [<ffffffff810afce3>] ?
sleep_on_page+0x6/0xa
Nov 25 11:43:07 vaio kernel: [11265.694393]  [<ffffffff8132c6c7>] ?
__wait_on_bit+0x3e/0x71
Nov 25 11:43:07 vaio kernel: [11265.694397]  [<ffffffff810afe32>] ?
wait_on_page_bit+0x6e/0x73
Nov 25 11:43:07 vaio kernel: [11265.694403]  [<ffffffff8105ec41>] ?
autoremove_wake_function+0x2a/0x2a
Nov 25 11:43:07 vaio kernel: [11265.694408]  [<ffffffff810aff0a>] ?
filemap_fdatawait_range+0x74/0x139
Nov 25 11:43:07 vaio kernel: [11265.694413]  [<ffffffff810b1722>] ?
filemap_write_and_wait+0x24/0x30
Nov 25 11:43:07 vaio kernel: [11265.694429]  [<ffffffffa0741c32>] ?
nfs_getattr+0x32/0xac [nfs]
Nov 25 11:43:07 vaio kernel: [11265.694434]  [<ffffffff810f72a4>] ?
vfs_fstatat+0x48/0x60
Nov 25 11:43:07 vaio kernel: [11265.694438]  [<ffffffff810f73e3>] ?
sys_newlstat+0x12/0x2b
Nov 25 11:43:07 vaio kernel: [11265.694443]  [<ffffffff81103a21>] ? dput
+0x52/0xee
Nov 25 11:43:07 vaio kernel: [11265.694459]  [<ffffffffa0751227>] ?
nfs3_proc_getacl+0x34b/0x34b [nfs]
Nov 25 11:43:07 vaio kernel: [11265.694464]  [<ffffffff811095f4>] ?
mntput_no_expire+0x1e/0xc9
Nov 25 11:43:07 vaio kernel: [11265.694470]  [<ffffffff8110cc4b>] ?
sys_lgetxattr+0x4e/0x5c
Nov 25 11:43:07 vaio kernel: [11265.694477]  [<ffffffff813322d2>] ?
system_call_fastpath+0x16/0x1b
Nov 25 11:45:07 vaio kernel: [11385.494800] ls              D
ffff880117c12f40     0  5152   5103 0x00000000
Nov 25 11:45:07 vaio kernel: [11385.494805]  ffff88002f8e48f0
0000000000000082 ffff88010fe79000 ffff88009fdce240
Nov 25 11:45:07 vaio kernel: [11385.494810]  0000000000012f40
ffff88001a3fdfd8 ffff88001a3fdfd8 ffff88002f8e48f0
Nov 25 11:45:07 vaio kernel: [11385.494814]  ffffffff81013255
ffffffff810654c7 ffff880026e5b130 ffff880117c13788
Nov 25 11:45:07 vaio kernel: [11385.494819] Call Trace:
Nov 25 11:45:07 vaio kernel: [11385.494828]  [<ffffffff81013255>] ?
read_tsc+0x5/0x14
Nov 25 11:45:07 vaio kernel: [11385.494834]  [<ffffffff810654c7>] ?
timekeeping_get_ns+0xd/0x2a
Nov 25 11:45:07 vaio kernel: [11385.494839]  [<ffffffff810afcdd>] ?
lock_page+0x20/0x20
Nov 25 11:45:07 vaio kernel: [11385.494845]  [<ffffffff8132c284>] ?
io_schedule+0x59/0x71
Nov 25 11:45:07 vaio kernel: [11385.494848]  [<ffffffff810afce3>] ?
sleep_on_page+0x6/0xa
Nov 25 11:45:07 vaio kernel: [11385.494851]  [<ffffffff8132c6c7>] ?
__wait_on_bit+0x3e/0x71
Nov 25 11:45:07 vaio kernel: [11385.494854]  [<ffffffff810afe32>] ?
wait_on_page_bit+0x6e/0x73
Nov 25 11:45:07 vaio kernel: [11385.494859]  [<ffffffff8105ec41>] ?
autoremove_wake_function+0x2a/0x2a
Nov 25 11:45:07 vaio kernel: [11385.494862]  [<ffffffff810aff0a>] ?
filemap_fdatawait_range+0x74/0x139
Nov 25 11:45:07 vaio kernel: [11385.494867]  [<ffffffff810b1722>] ?
filemap_write_and_wait+0x24/0x30
Nov 25 11:45:07 vaio kernel: [11385.494881]  [<ffffffffa0741c32>] ?
nfs_getattr+0x32/0xac [nfs]
Nov 25 11:45:07 vaio kernel: [11385.494885]  [<ffffffff810f72a4>] ?
vfs_fstatat+0x48/0x60
Nov 25 11:45:07 vaio kernel: [11385.494888]  [<ffffffff810f73e3>] ?
sys_newlstat+0x12/0x2b
Nov 25 11:45:07 vaio kernel: [11385.494892]  [<ffffffff81103a21>] ? dput
+0x52/0xee
Nov 25 11:45:07 vaio kernel: [11385.494903]  [<ffffffffa0751227>] ?
nfs3_proc_getacl+0x34b/0x34b [nfs]
Nov 25 11:45:07 vaio kernel: [11385.494908]  [<ffffffff811095f4>] ?
mntput_no_expire+0x1e/0xc9
Nov 25 11:45:07 vaio kernel: [11385.494912]  [<ffffffff8110cc4b>] ?
sys_lgetxattr+0x4e/0x5c
Nov 25 11:45:07 vaio kernel: [11385.494918]  [<ffffffff813322d2>] ?
system_call_fastpath+0x16/0x1b
Nov 25 11:45:08 vaio rsyslogd-2177: imuxsock lost 5530 messages from pid
8786 due to rate-limiting
Nov 25 11:45:08 vaio rsyslogd-2177: imuxsock begins to drop messages
from pid 8786 due to rate-limiting
Nov 25 11:47:07 vaio kernel: [11505.295246] ls              D
ffff880117c12f40     0  5152   5103 0x00000000
Nov 25 11:47:07 vaio kernel: [11505.295252]  ffff88002f8e48f0
0000000000000082 ffff88010fe79000 ffff88009fdce240
Nov 25 11:47:07 vaio kernel: [11505.295259]  0000000000012f40
ffff88001a3fdfd8 ffff88001a3fdfd8 ffff88002f8e48f0
Nov 25 11:47:07 vaio kernel: [11505.295264]  ffffffff81013255
ffffffff810654c7 ffff880026e5b130 ffff880117c13788
Nov 25 11:47:07 vaio kernel: [11505.295270] Call Trace:
Nov 25 11:47:07 vaio kernel: [11505.295280]  [<ffffffff81013255>] ?
read_tsc+0x5/0x14
Nov 25 11:47:07 vaio kernel: [11505.295288]  [<ffffffff810654c7>] ?
timekeeping_get_ns+0xd/0x2a
Nov 25 11:47:07 vaio kernel: [11505.295293]  [<ffffffff810afcdd>] ?
lock_page+0x20/0x20
Nov 25 11:47:07 vaio kernel: [11505.295300]  [<ffffffff8132c284>] ?
io_schedule+0x59/0x71
Nov 25 11:47:07 vaio kernel: [11505.295303]  [<ffffffff810afce3>] ?
sleep_on_page+0x6/0xa
Nov 25 11:47:07 vaio kernel: [11505.295308]  [<ffffffff8132c6c7>] ?
__wait_on_bit+0x3e/0x71
Nov 25 11:47:07 vaio kernel: [11505.295312]  [<ffffffff810afe32>] ?
wait_on_page_bit+0x6e/0x73
Nov 25 11:47:07 vaio kernel: [11505.295318]  [<ffffffff8105ec41>] ?
autoremove_wake_function+0x2a/0x2a
Nov 25 11:47:07 vaio kernel: [11505.295322]  [<ffffffff810aff0a>] ?
filemap_fdatawait_range+0x74/0x139
Nov 25 11:47:07 vaio kernel: [11505.295327]  [<ffffffff810b1722>] ?
filemap_write_and_wait+0x24/0x30
Nov 25 11:47:07 vaio kernel: [11505.295343]  [<ffffffffa0741c32>] ?
nfs_getattr+0x32/0xac [nfs]
Nov 25 11:47:07 vaio kernel: [11505.295349]  [<ffffffff810f72a4>] ?
vfs_fstatat+0x48/0x60
Nov 25 11:47:07 vaio kernel: [11505.295352]  [<ffffffff810f73e3>] ?
sys_newlstat+0x12/0x2b
Nov 25 11:47:07 vaio kernel: [11505.295358]  [<ffffffff81103a21>] ? dput
+0x52/0xee
Nov 25 11:47:07 vaio kernel: [11505.295373]  [<ffffffffa0751227>] ?
nfs3_proc_getacl+0x34b/0x34b [nfs]
Nov 25 11:47:07 vaio kernel: [11505.295379]  [<ffffffff811095f4>] ?
mntput_no_expire+0x1e/0xc9
Nov 25 11:47:07 vaio kernel: [11505.295385]  [<ffffffff8110cc4b>] ?
sys_lgetxattr+0x4e/0x5c
Nov 25 11:47:07 vaio kernel: [11505.295392]  [<ffffffff813322d2>] ?
system_call_fastpath+0x16/0x1b
Nov 25 11:49:07 vaio kernel: [11625.095732] ls              D
ffff880117c12f40     0  5152   5103 0x00000000
Nov 25 11:49:07 vaio kernel: [11625.095739]  ffff88002f8e48f0
0000000000000082 ffff88010fe79000 ffff88009fdce240
Nov 25 11:49:07 vaio kernel: [11625.095747]  0000000000012f40
ffff88001a3fdfd8 ffff88001a3fdfd8 ffff88002f8e48f0
Nov 25 11:49:07 vaio kernel: [11625.095753]  ffffffff81013255
ffffffff810654c7 ffff880026e5b130 ffff880117c13788
Nov 25 11:49:07 vaio kernel: [11625.095760] Call Trace:
Nov 25 11:49:07 vaio kernel: [11625.095772]  [<ffffffff81013255>] ?
read_tsc+0x5/0x14
Nov 25 11:49:07 vaio kernel: [11625.095780]  [<ffffffff810654c7>] ?
timekeeping_get_ns+0xd/0x2a
Nov 25 11:49:07 vaio kernel: [11625.095789]  [<ffffffff810afcdd>] ?
lock_page+0x20/0x20
Nov 25 11:49:07 vaio kernel: [11625.095794]  [<ffffffff8132c284>] ?
io_schedule+0x59/0x71
Nov 25 11:49:07 vaio kernel: [11625.095796]  [<ffffffff810afce3>] ?
sleep_on_page+0x6/0xa
Nov 25 11:49:07 vaio kernel: [11625.095798]  [<ffffffff8132c6c7>] ?
__wait_on_bit+0x3e/0x71
Nov 25 11:49:07 vaio kernel: [11625.095801]  [<ffffffff810afe32>] ?
wait_on_page_bit+0x6e/0x73
Nov 25 11:49:07 vaio kernel: [11625.095805]  [<ffffffff8105ec41>] ?
autoremove_wake_function+0x2a/0x2a
Nov 25 11:49:07 vaio kernel: [11625.095807]  [<ffffffff810aff0a>] ?
filemap_fdatawait_range+0x74/0x139
Nov 25 11:49:07 vaio kernel: [11625.095810]  [<ffffffff810b1722>] ?
filemap_write_and_wait+0x24/0x30
Nov 25 11:49:07 vaio kernel: [11625.095821]  [<ffffffffa0741c32>] ?
nfs_getattr+0x32/0xac [nfs]
Nov 25 11:49:07 vaio kernel: [11625.095825]  [<ffffffff810f72a4>] ?
vfs_fstatat+0x48/0x60
Nov 25 11:49:07 vaio kernel: [11625.095827]  [<ffffffff810f73e3>] ?
sys_newlstat+0x12/0x2b
Nov 25 11:49:07 vaio kernel: [11625.095830]  [<ffffffff81103a21>] ? dput
+0x52/0xee
Nov 25 11:49:07 vaio kernel: [11625.095838]  [<ffffffffa0751227>] ?
nfs3_proc_getacl+0x34b/0x34b [nfs]
Nov 25 11:49:07 vaio kernel: [11625.095841]  [<ffffffff811095f4>] ?
mntput_no_expire+0x1e/0xc9
Nov 25 11:49:07 vaio kernel: [11625.095844]  [<ffffffff8110cc4b>] ?
sys_lgetxattr+0x4e/0x5c
Nov 25 11:49:07 vaio kernel: [11625.095849]  [<ffffffff813322d2>] ?
system_call_fastpath+0x16/0x1b
Nov 25 11:50:07 vaio rsyslogd-2177: imuxsock lost 5530 messages from pid
8786 due to rate-limiting
Nov 25 11:50:07 vaio rsyslogd-2177: imuxsock begins to drop messages
from pid 8786 due to rate-limiting
Nov 25 11:55:07 vaio kernel: [11984.497133] flush-0:21      D
ffff880117c12f40     0   694      2 0x00000000
Nov 25 11:55:07 vaio kernel: [11984.497140]  ffff8800460c8200
0000000000000046 0000000000000001 ffff880054a0c240
Nov 25 11:55:07 vaio kernel: [11984.497148]  0000000000012f40
ffff88006f2b1fd8 ffff88006f2b1fd8 ffff8800460c8200
Nov 25 11:55:07 vaio kernel: [11984.497155]  ffff88006f2b1e28
ffffffff8107009d 0000000000000246 ffff88006f2b1d38
Nov 25 11:55:07 vaio kernel: [11984.497162] Call Trace:
Nov 25 11:55:07 vaio kernel: [11984.497175]  [<ffffffff8107009d>] ?
arch_local_irq_save+0x11/0x17
Nov 25 11:55:07 vaio kernel: [11984.497183]  [<ffffffff811056ca>] ?
inode_owner_or_capable+0x36/0x36
Nov 25 11:55:07 vaio kernel: [11984.497191]  [<ffffffff811056d0>] ?
inode_wait+0x6/0xa
Nov 25 11:55:07 vaio kernel: [11984.497196]  [<ffffffff8132c6c7>] ?
__wait_on_bit+0x3e/0x71
Nov 25 11:55:07 vaio kernel: [11984.497201]  [<ffffffff8110f83b>] ?
inode_wait_for_writeback+0x9b/0xc3
Nov 25 11:55:07 vaio kernel: [11984.497205]  [<ffffffff8105ec41>] ?
autoremove_wake_function+0x2a/0x2a
Nov 25 11:55:07 vaio kernel: [11984.497208]  [<ffffffff8111115b>] ?
wb_writeback+0x1ea/0x214
Nov 25 11:55:07 vaio kernel: [11984.497210]  [<ffffffff8111151f>] ?
wb_do_writeback+0x13e/0x19d
Nov 25 11:55:07 vaio kernel: [11984.497213]  [<ffffffff81111602>] ?
bdi_writeback_thread+0x84/0x1e5
Nov 25 11:55:07 vaio kernel: [11984.497215]  [<ffffffff8111157e>] ?
wb_do_writeback+0x19d/0x19d
Nov 25 11:55:07 vaio kernel: [11984.497217]  [<ffffffff8105e5d1>] ?
kthread+0x76/0x7e
Nov 25 11:55:07 vaio kernel: [11984.497223]  [<ffffffff81334434>] ?
kernel_thread_helper+0x4/0x10
Nov 25 11:55:07 vaio kernel: [11984.497225]  [<ffffffff8105e55b>] ?
kthread_worker_fn+0x139/0x139
Nov 25 11:55:07 vaio kernel: [11984.497228]  [<ffffffff81334430>] ?
gs_change+0x13/0x13
Nov 25 11:55:07 vaio kernel: [11984.497234] mv              D
ffff880117c12f40     0  2644   1981 0x00000000
Nov 25 11:55:07 vaio kernel: [11984.497237]  ffff88003d7a5160
0000000000000082 ffff88006f3ba080 ffff880054a0c240
Nov 25 11:55:07 vaio kernel: [11984.497240]  0000000000012f40
ffff880096ec9fd8 ffff880096ec9fd8 ffff88003d7a5160
Nov 25 11:55:07 vaio kernel: [11984.497243]  ffffffff81013255
ffffffff810654c7 ffff88011325aa60 ffff880117c13788
Nov 25 11:55:07 vaio kernel: [11984.497246] Call Trace:
Nov 25 11:55:07 vaio kernel: [11984.497250]  [<ffffffff81013255>] ?
read_tsc+0x5/0x14
Nov 25 11:55:07 vaio kernel: [11984.497255]  [<ffffffff810654c7>] ?
timekeeping_get_ns+0xd/0x2a
Nov 25 11:55:07 vaio kernel: [11984.497259]  [<ffffffff810afcdd>] ?
lock_page+0x20/0x20
Nov 25 11:55:07 vaio kernel: [11984.497261]  [<ffffffff8132c284>] ?
io_schedule+0x59/0x71
Nov 25 11:55:07 vaio kernel: [11984.497263]  [<ffffffff810afce3>] ?
sleep_on_page+0x6/0xa
Nov 25 11:55:07 vaio kernel: [11984.497265]  [<ffffffff8132c6c7>] ?
__wait_on_bit+0x3e/0x71
Nov 25 11:55:07 vaio kernel: [11984.497267]  [<ffffffff810afe32>] ?
wait_on_page_bit+0x6e/0x73
Nov 25 11:55:07 vaio kernel: [11984.497270]  [<ffffffff8105ec41>] ?
autoremove_wake_function+0x2a/0x2a
Nov 25 11:55:07 vaio kernel: [11984.497272]  [<ffffffff810aff0a>] ?
filemap_fdatawait_range+0x74/0x139
Nov 25 11:55:07 vaio kernel: [11984.497275]  [<ffffffff811109c0>] ?
writeback_single_inode+0x137/0x2d3
Nov 25 11:55:07 vaio kernel: [11984.497278]  [<ffffffff81110b98>] ?
sync_inode+0x3c/0x4f
Nov 25 11:55:07 vaio kernel: [11984.497291]  [<ffffffffa074ca7d>] ?
nfs_wb_all+0x39/0x3e [nfs]
Nov 25 11:55:07 vaio kernel: [11984.497298]  [<ffffffffa0741d37>] ?
nfs_setattr+0x8b/0xf3 [nfs]
Nov 25 11:55:07 vaio kernel: [11984.497301]  [<ffffffff8110725e>] ?
notify_change+0x18e/0x256
Nov 25 11:55:07 vaio kernel: [11984.497304]  [<ffffffff8103538b>] ?
should_resched+0x5/0x23
Nov 25 11:55:07 vaio kernel: [11984.497307]  [<ffffffff81114498>] ?
utimes_common+0x10c/0x135
Nov 25 11:55:07 vaio kernel: [11984.497312]  [<ffffffff8100d01d>] ?
paravirt_write_msr+0xb/0xe
Nov 25 11:55:07 vaio kernel: [11984.497314]  [<ffffffff8111454b>] ?
do_utimes+0x8a/0xd6
Nov 25 11:55:07 vaio kernel: [11984.497319]  [<ffffffff810f3e70>] ?
vfs_read+0x9f/0xe6
Nov 25 11:55:07 vaio kernel: [11984.497322]  [<ffffffff8103538b>] ?
should_resched+0x5/0x23
Nov 25 11:55:07 vaio kernel: [11984.497324]  [<ffffffff81114682>] ?
sys_utimensat+0x6e/0x77
Nov 25 11:55:07 vaio kernel: [11984.497327]  [<ffffffff813322d2>] ?
system_call_fastpath+0x16/0x1b









