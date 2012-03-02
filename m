Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:58116 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539Ab2CBStS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 13:49:18 -0500
Received: from sim by peace.netnation.com with local (Exim 4.72)
	(envelope-from <sim@netnation.com>)
	id 1S3XXa-0005ut-3w
	for linux-nfs@vger.kernel.org; Fri, 02 Mar 2012 10:49:18 -0800
Date: Fri, 2 Mar 2012 10:49:18 -0800
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: [3.2.5] NFSv3 CLOSE_WAIT hang
Message-ID: <20120302184918.GA20702@hostway.ca>
References: <20110909194509.GB6195@hostway.ca> <1315610322.17611.112.camel@lade.trondhjem.org> <20111020190334.GA22772@hostway.ca> <20120301225524.GB27595@hostway.ca> <20120302002511.GA4495@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120302002511.GA4495@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's another CLOSE_WAIT hang, 3.2.5 client, 3.2.2 knfsd server, NFSv3.
Not sure why these are all happening again now. This cluster seems to
have a set of customers that are good at breaking things. ;)

The only other maybe weird thing we do on this partition is bind mount
some NFS paths to break through some chroots. Perhaps this is pegging
things in place (or expecting them to stay there) and causing problems?

export:

/home/logs 10.10.52.0/24(rw,async,no_root_squash,no_subtree_check,fsid=1)

mount:

10.10.52.15:/home/logs       /home/logs        nfs     rw,soft,intr,tcp,timeo=300,retrans=2,vers=3        0 0

current socket state:

tcp        0      0 10.10.52.11:719         10.10.52.15:2049        CLOSE_WAIT  -                off (0.00/0/0)

demsg:

[505238.409106] ------------[ cut here ]------------
[505238.409194] WARNING: at fs/dcache.c:2485 prepend_path+0x19c/0x1b0()
[505238.409269] Hardware name: PowerEdge 1950
[505238.409339] Root dentry has weird name <>
[505238.409409] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[505238.410107] Pid: 3461, comm: sftp-server Tainted: G        W    3.2.5-hw+ #3
[505238.410184] Call Trace:
[505238.410256]  [<ffffffff8113140c>] ? prepend_path+0x19c/0x1b0
[505238.410333]  [<ffffffff8105b0e0>] warn_slowpath_common+0x80/0xc0
[505238.410408]  [<ffffffff8105b219>] warn_slowpath_fmt+0x69/0x70
[505238.410485]  [<ffffffff8111bf89>] ? do_sync_read+0xd9/0x120
[505238.410560]  [<ffffffff81130db0>] ? prepend+0x30/0x40
[505238.410634]  [<ffffffff8113140c>] prepend_path+0x19c/0x1b0
[505238.410708]  [<ffffffff81131940>] sys_getcwd+0x100/0x1e0
[505238.410786]  [<ffffffff816e1392>] system_call_fastpath+0x16/0x1b
[505238.410861] ---[ end trace 3cedde7daf396ef5 ]---
[505238.461689] ------------[ cut here ]------------
[505238.461772] WARNING: at fs/dcache.c:2485 prepend_path+0x19c/0x1b0()
[505238.461846] Hardware name: PowerEdge 1950
[505238.461916] Root dentry has weird name <>
[505238.461986] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[505238.462680] Pid: 3461, comm: sftp-server Tainted: G        W    3.2.5-hw+ #3
[505238.462756] Call Trace:
[505238.462826]  [<ffffffff8113140c>] ? prepend_path+0x19c/0x1b0
[505238.462902]  [<ffffffff8105b0e0>] warn_slowpath_common+0x80/0xc0
[505238.462977]  [<ffffffff8105b219>] warn_slowpath_fmt+0x69/0x70
[505238.463053]  [<ffffffff8111bf89>] ? do_sync_read+0xd9/0x120
[505238.463128]  [<ffffffff81130db0>] ? prepend+0x30/0x40
[505238.463202]  [<ffffffff8113140c>] prepend_path+0x19c/0x1b0
[505238.463277]  [<ffffffff81131940>] sys_getcwd+0x100/0x1e0
[505238.463352]  [<ffffffff816e1392>] system_call_fastpath+0x16/0x1b
[505238.463427] ---[ end trace 3cedde7daf396ef6 ]---
[505526.997108] SUNRPC: xprt(ffff880081b48800) state=18, snd_task=0
[505526.997189] SUNRPC: xprt(ffff8802252a4800) state=18, snd_task=0
[505526.997264] SUNRPC: xprt(ffff880025b5b800) state=18, snd_task=0
[505526.997338] SUNRPC: xprt(ffff880223590000) state=18, snd_task=0
[505526.997412] SUNRPC: xprt(ffff880223590000) state=18, snd_task=0
[505526.997486] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505526.997560] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505526.997634] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505526.997708] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505526.997782] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505526.997856] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505526.997930] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505526.998004] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505526.998078] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505526.998152] SUNRPC: xprt(ffff8802251d3800) state=18, snd_task=0
[505526.998226] SUNRPC: xprt(ffff8802251d3800) state=18, snd_task=0
[505526.998300] SUNRPC: xprt(ffff88022344a000) state=18, snd_task=0
[505526.998374] SUNRPC: xprt(ffff880208c53800) state=16, snd_task=0
[505526.998448] SUNRPC: xprt(ffff8801cabf1000) state=16, snd_task=0
[505526.998523] SUNRPC: xprt(ffff8802235ac800) state=18, snd_task=0
[505526.998597] SUNRPC: xprt(ffff880208c53000) state=18, snd_task=0
[505526.998671] SUNRPC: xprt(ffff8802235a0800) state=18, snd_task=0
[505526.998745] SUNRPC: xprt(ffff880211b70000) state=18, snd_task=0
[505526.998819] SUNRPC: xprt(ffff88022503b800) state=18, snd_task=0
[505527.000640] SUNRPC: xprt(ffff88022360d000) state=18, snd_task=0
[505527.000715] SUNRPC: xprt(ffff880223650800) state=18, snd_task=0
[505527.000790] SUNRPC: xprt(ffff880223608800) state=16, snd_task=0
[505527.000864] SUNRPC: xprt(ffff8802257d2000) state=18, snd_task=0
[505527.000938] SUNRPC: xprt(ffff8802257d2000) state=18, snd_task=0
[505527.001012] SUNRPC: xprt(ffff8802257d2000) state=18, snd_task=0
[505527.001086] SUNRPC: xprt(ffff8802257d2000) state=18, snd_task=0
[505527.001160] SUNRPC: xprt(ffff8802257d2000) state=18, snd_task=0
[505527.001234] -pid- flgs status -client- --rqstp- -timeout ---ops--
[505527.001317]  7094 0880      0 ffff880223763000 ffff880224046400     7500 ffffffff8178b220 nfsv3 SETATTR a:call_status q:xprt_pending
[505527.001417] SUNRPC: xprt(ffff8802257d2000) state=18, snd_task=0
[505527.001522] SUNRPC: xprt(ffff8802257d2000) state=18, snd_task=0
[505527.001597] SUNRPC: xprt(ffff8802257d2000) state=18, snd_task=0
[505527.001671] SUNRPC: xprt(ffff8802235a1800) state=18, snd_task=0
[505527.001745] SUNRPC: xprt(ffff8802235a1800) state=18, snd_task=0
[505527.001824] 12105 0280    -11 ffff88022551c200   (null)        0 ffffffff8178b220 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
[505527.001926] 12106 0280    -11 ffff88022551c200   (null)        0 ffffffff8178b220 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
[505527.002028] 12125 0280    -11 ffff88022551c200   (null)        0 ffffffff8178b220 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
[505527.002130] 12126 0280    -11 ffff88022551c200   (null)        0 ffffffff8178b220 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
[505527.002231] 12129 0280    -11 ffff88022551c200   (null)        0 ffffffff8178b220 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
[505527.002332] 12167 0280    -11 ffff88022551c200   (null)        0 ffffffff8178b220 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
[505527.002434] 12176 0280    -11 ffff88022551c200   (null)        0 ffffffff8178b220 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
[505527.002535] 12188 0280    -11 ffff88022551c200   (null)        0 ffffffff8178b220 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
[505527.002637] 12189 0280    -11 ffff88022551c200   (null)        0 ffffffff8178b220 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
[505527.002736] SUNRPC: xprt(ffff88022510f800) state=27, snd_task->tk_pid=32732
[505527.002813] SUNRPC: xprt(ffff88022510f800) state=27, snd_task->tk_pid=32732
[505527.002889] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505527.002963] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505527.003036] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505527.003110] SUNRPC: xprt(ffff8802251d7800) state=18, snd_task=0
[505527.003184] SUNRPC: xprt(ffff8802251d3800) state=18, snd_task=0
[505527.003258] SUNRPC: xprt(ffff8802251d3800) state=18, snd_task=0
[505527.003334] SUNRPC: xprt(ffff8802251d3800) state=18, snd_task=0
[505527.003408] SUNRPC: xprt(ffff8802251d3800) state=18, snd_task=0
[505527.003482] SUNRPC: xprt(ffff8802251d3800) state=18, snd_task=0
[505527.003555] SUNRPC: xprt(ffff8802251d3800) state=18, snd_task=0
[505527.003629] SUNRPC: xprt(ffff8802252a5000) state=18, snd_task=0
[505527.003703] SUNRPC: xprt(ffff880225f05800) state=18, snd_task=0
[505527.003777] SUNRPC: xprt(ffff880225f05800) state=18, snd_task=0
[505527.003851] SUNRPC: xprt(ffff8802252a5000) state=18, snd_task=0
[505527.003925] SUNRPC: xprt(ffff8802252a5000) state=18, snd_task=0
[505527.004012] SUNRPC: xprt(ffff880223586800) state=18, snd_task=0
[505527.004089] SUNRPC: xprt(ffff880223586800) state=18, snd_task=0
[505527.004167] SUNRPC: xprt(ffff8802235a3800) state=18, snd_task=0
[505527.004243] SUNRPC: xprt(ffff8802235a3800) state=18, snd_task=0
[505527.004317] SUNRPC: xprt(ffff8802235ab800) state=18, snd_task=0
[505527.004393] SUNRPC: xprt(ffff8802235ab800) state=18, snd_task=0
[505527.004467] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.004544]  7708 0880      0 ffff880224080000 ffff88022557b400     7500 ffffffff8178b220 nfsv3 SETATTR a:call_status q:xprt_pending
[505527.004644] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.004718] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.004792] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.004868] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.004945] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.005019] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.005096]  7512 0801      0 ffff88022501f200 ffff880223695800     7500 ffffffff81714ee0 nfsv3 WRITE a:call_status q:xprt_pending
[505527.005198]  7516 0880      0 ffff88022501f200 ffff8802252e1200     7500 ffffffff8178b220 nfsv3 SETATTR a:call_status q:xprt_pending
[505527.005297] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.005372] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.005447] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.005521] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.005607] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.005682] SUNRPC: xprt(ffff8802236a3800) state=18, snd_task=0
[505527.005756] SUNRPC: xprt(ffff88022359e800) state=18, snd_task=0
[505527.005829] SUNRPC: xprt(ffff88022359e800) state=18, snd_task=0
[505527.005906]  7688 0880      0 ffff880225479a00 ffff880225019600     7500 ffffffff8178b220 nfsv3 GETATTR a:call_status q:xprt_pending
[505527.006005] SUNRPC: xprt(ffff88022359e800) state=18, snd_task=0
[505527.006079] SUNRPC: xprt(ffff88022359e800) state=18, snd_task=0
[505527.006153] SUNRPC: xprt(ffff88022359e800) state=18, snd_task=0
[505527.006227] SUNRPC: xprt(ffff88022359e800) state=18, snd_task=0
[505527.006301] SUNRPC: xprt(ffff88022359e800) state=18, snd_task=0
[505527.006375] SUNRPC: xprt(ffff88022359e800) state=18, snd_task=0
[505527.006448] SUNRPC: xprt(ffff8802235bf000) state=18, snd_task=0
[505527.006522] SUNRPC: xprt(ffff8802235bf000) state=18, snd_task=0
[505527.006596] SUNRPC: xprt(ffff8802235bf000) state=18, snd_task=0
[505527.006670] SUNRPC: xprt(ffff8802235bf000) state=18, snd_task=0
[505527.006744] SUNRPC: xprt(ffff8802235bf000) state=18, snd_task=0
[505527.006818] SUNRPC: xprt(ffff8802235bf000) state=18, snd_task=0
[505527.006891] SUNRPC: xprt(ffff8802235bf000) state=18, snd_task=0
[505527.006965] SUNRPC: xprt(ffff8802235bf000) state=18, snd_task=0
[505527.007039] SUNRPC: xprt(ffff88022344a000) state=18, snd_task=0
[505527.007113] SUNRPC: xprt(ffff88022344a000) state=18, snd_task=0
[505527.007187] SUNRPC: xprt(ffff88022344a000) state=18, snd_task=0
[505527.007261] SUNRPC: xprt(ffff88022344a000) state=18, snd_task=0
[505527.007335] SUNRPC: xprt(ffff88022344a000) state=18, snd_task=0
[505527.007409] SUNRPC: xprt(ffff88022344a000) state=18, snd_task=0
[505527.007483] SUNRPC: xprt(ffff8802236a2000) state=16, snd_task=0
[505527.007557] SUNRPC: xprt(ffff88022344a000) state=18, snd_task=0

Thanks,

Simon-
