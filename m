Return-Path: linux-nfs-owner@vger.kernel.org
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:46535 "EHLO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754598Ab3AaXHF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2013 18:07:05 -0500
Received: by mail-oa0-f51.google.com with SMTP id h2so1493216oag.10
        for <linux-nfs@vger.kernel.org>; Thu, 31 Jan 2013 15:07:03 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 31 Jan 2013 15:58:54 -0700
Message-ID: <CAO9q2D=aFEABgy98EazNuoP9f+0LdMa2Aw1SUwCXc8gAkZchcQ@mail.gmail.com>
Subject: v3 client processes hung in rpc_wait_bit_killable
From: Nathan Dauchy - NOAA Affiliate <nathan.dauchy@noaa.gov>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings,

On our Linux HPC cluster, one or more of the client nodes occasionally
has a problem with all access to an NFS mount hanging.  Can anyone
here point out a possible cause of the symptoms below or offer
suggestions for other tools or debugging steps I should try?  Any new
ideas or hints are appreciated!

The basic symptom is that all processes which access the NFS file
system hang in "D" state.  Dumping the call trace shows that they are
stuck in rpc_wait_bit_killable().  The processes can indeed be
terminated with "kill -9".  If I kill all hung processes, I can umount
the file system and remount it and then access works again.

We can run under "normal" user load for up to 3 days before 1-5 client
nodes experience a similar problem.   When it happens, the 100's of
other clients show no sign of a problem with their NFS mounts.  There
is no pattern to exactly which client will hang, though one complex
user workflow seems to trigger it more than others.

Here is an example of the hung processes:

# ps -eo pid,stat,args,wchan | grep D
   PID STAT COMMAND                     WCHAN
  2192 Ds   -bash                       rpc_wait_bit_killable
  2408 Ds   bash -c /home/ndauchy/bin/f rpc_wait_bit_killable
 15926 D    df -P                       rpc_wait_bit_killable
 36857 S+   grep D                      pipe_wait

By running "df" on each NFS mount one by one I was able to narrow down
which mount was hung to this one:

# mount | grep home
10.178.17.21:/vol/home on /misc/whome type nfs
(rw,relatime,vers=3,rsize=8192,wsize=8192,namlen=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.178.17.21,mountvers=3,mountport=4046,mountproto=udp,local_lock=all,addr=10.178.17.21)

There is no TCP connection to that server that I can see:

# netstat -atu
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address               Foreign Address    State
tcp        0      0 *:ssh                       *:*               LISTEN
tcp        0      0 s320-ib0:panasas            *:*               LISTEN
tcp        0      0 s320:panasas                *:*               LISTEN
tcp        0      0 *:15002                     *:*               LISTEN
tcp        0      0 *:15003                     *:*               LISTEN
tcp        0      0 localhost.localdomain:15005 *:*               LISTEN
tcp        0      0 s320-ib0:45637              panmgmt5:10622    ESTABLISHED
tcp        0      0 s320:ssh                    fe3:59631         ESTABLISHED
tcp        0      0 s320:849                    wms1314-nfs:nfs   ESTABLISHED
tcp        0      0 s320:ssh                    fe5:47363         ESTABLISHED
tcp        0      0 *:ssh                       *:*               LISTEN
udp        0      0 s320-ib0:ntp                *:*
udp        0      0 s320:ntp                    *:*
udp        0      0 localhost.localdomain:ntp   *:*
udp        0      0 *:ntp                       *:*
udp        0      0 *:52539                     *:*
udp        0      0 fe80::21e:6703:3c:f00d:ntp  *:*
udp        0      0 fe80::21e:67ff:fe3c:f008:ntp *:*
udp        0      0 ::1:ntp                     *:*
udp        0      0 *:ntp                       *:*


Here are the call traces:

# echo w > /proc/sysrq-trigger

SysRq : Show Blocked State
  task                        PC stack   pid father
bash          D 0000000000000000     0  2192      1 0x00000004
 ffff88042db47b28 0000000000000082 0000000000000000 ffff880400000000
 ffff88042db47ad8 ffff88042db47dd8 ffff88042db47b98 ffff88042db47b88
 ffff880121f7d098 ffff88042db47fd8 000000000000fb88 ffff880121f7d098
Call Trace:
 [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
 [<ffffffffa000b972>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
 [<ffffffff814feaaf>] __wait_on_bit+0x5f/0x90
 [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
 [<ffffffff814feb58>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff81092110>] ? wake_bit_function+0x0/0x50
 [<ffffffffa0000480>] ? call_reserve+0x0/0x60 [sunrpc]
 [<ffffffffa000beb5>] __rpc_execute+0xf5/0x350 [sunrpc]
 [<ffffffff81091f97>] ? bit_waitqueue+0x17/0xd0
 [<ffffffffa000c171>] rpc_execute+0x61/0xa0 [sunrpc]
 [<ffffffffa0002385>] rpc_run_task+0x75/0x90 [sunrpc]
 [<ffffffffa00024a2>] rpc_call_sync+0x42/0x70 [sunrpc]
 [<ffffffffa00c396d>] nfs3_rpc_wrapper.clone.0+0x3d/0xd0 [nfs]
 [<ffffffffa00c4707>] nfs3_proc_getattr+0x47/0x90 [nfs]
 [<ffffffffa00b23b3>] __nfs_revalidate_inode+0xe3/0x220 [nfs]
 [<ffffffffa00b2696>] nfs_revalidate_inode+0x36/0x60 [nfs]
 [<ffffffffa00b2776>] nfs_getattr+0x66/0x120 [nfs]
 [<ffffffff81180571>] vfs_getattr+0x51/0x80
 [<ffffffff81180600>] vfs_fstatat+0x60/0x80
 [<ffffffff8118074b>] vfs_stat+0x1b/0x20
 [<ffffffff81180774>] sys_newstat+0x24/0x50
 [<ffffffff8117cba5>] ? fput+0x25/0x30
 [<ffffffff811785cd>] ? filp_close+0x5d/0x90
 [<ffffffff811786a5>] ? sys_close+0xa5/0x100
 [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
bash          D 0000000000000000     0  2408      1 0x00000000
 ffff8802f1f4d898 0000000000000086 0000000000000082 0000000000000246
 ffff8802f1f4d838 ffff8802f1f4d898 ffff880028043718 0000000300000001
 ffff88043418b098 ffff8802f1f4dfd8 000000000000fb88 ffff88043418b098
Call Trace:
 [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
 [<ffffffffa000b972>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
 [<ffffffff814feaaf>] __wait_on_bit+0x5f/0x90
 [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
 [<ffffffff814feb58>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff81092110>] ? wake_bit_function+0x0/0x50
 [<ffffffffa0000480>] ? call_reserve+0x0/0x60 [sunrpc]
 [<ffffffffa000beb5>] __rpc_execute+0xf5/0x350 [sunrpc]
 [<ffffffff81091f97>] ? bit_waitqueue+0x17/0xd0
 [<ffffffffa000c171>] rpc_execute+0x61/0xa0 [sunrpc]
 [<ffffffffa0002385>] rpc_run_task+0x75/0x90 [sunrpc]
 [<ffffffffa00024a2>] rpc_call_sync+0x42/0x70 [sunrpc]
 [<ffffffffa00c396d>] nfs3_rpc_wrapper.clone.0+0x3d/0xd0 [nfs]
 [<ffffffffa00c3d4c>] nfs3_proc_access+0xbc/0x180 [nfs]
 [<ffffffffa00ab168>] nfs_do_access+0x198/0x420 [nfs]
 [<ffffffffa000e765>] ? generic_lookup_cred+0x15/0x20 [sunrpc]
 [<ffffffffa000d770>] ? rpcauth_lookupcred+0x70/0xc0 [sunrpc]
 [<ffffffffa00ab498>] nfs_permission+0xa8/0x1e0 [nfs]
 [<ffffffff8118995d>] __link_path_walk+0xad/0x1030
 [<ffffffff8118ab6a>] path_walk+0x6a/0xe0
 [<ffffffff8118ad3b>] do_path_lookup+0x5b/0xa0
 [<ffffffff8117c780>] ? get_empty_filp+0xa0/0x180
 [<ffffffff8118bc6b>] do_filp_open+0xfb/0xd60
 [<ffffffffa00af26a>] ? nfs_file_read+0xca/0x130 [nfs]
 [<ffffffff81213426>] ? security_prepare_creds+0x16/0x20
 [<ffffffff810996ef>] ? prepare_creds+0x8f/0xb0
 [<ffffffff81183943>] open_exec+0x33/0x100
 [<ffffffff81183aff>] do_execve+0xef/0x340
 [<ffffffff8127ea8a>] ? strncpy_from_user+0x4a/0x90
 [<ffffffff810095ea>] sys_execve+0x4a/0x80
 [<ffffffff8100b54a>] stub_execve+0x6a/0xc0
df            D 0000000000000000     0 15926  15915 0x00000000
 ffff8801898f5ae8 0000000000000082 ffff8801898f5a48 ffffffff81116967
 ffff8801898f5a68 ffffffff81116a25 ffff88032d29cdc0 ffffffffa00207a0
 ffff88042be765f8 ffff8801898f5fd8 000000000000fb88 ffff88042be765f8
Call Trace:
 [<ffffffff81116967>] ? mempool_free_slab+0x17/0x20
 [<ffffffff81116a25>] ? mempool_free+0x95/0xa0
 [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
 [<ffffffffa000b972>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
 [<ffffffff814feaaf>] __wait_on_bit+0x5f/0x90
 [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
 [<ffffffff814feb58>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff81092110>] ? wake_bit_function+0x0/0x50
 [<ffffffffa0000480>] ? call_reserve+0x0/0x60 [sunrpc]
 [<ffffffffa000beb5>] __rpc_execute+0xf5/0x350 [sunrpc]
 [<ffffffff81091f97>] ? bit_waitqueue+0x17/0xd0
 [<ffffffffa000c171>] rpc_execute+0x61/0xa0 [sunrpc]
 [<ffffffffa0002385>] rpc_run_task+0x75/0x90 [sunrpc]
 [<ffffffffa00024a2>] rpc_call_sync+0x42/0x70 [sunrpc]
 [<ffffffff8118a018>] ? __link_path_walk+0x768/0x1030
 [<ffffffffa00c396d>] nfs3_rpc_wrapper.clone.0+0x3d/0xd0 [nfs]
 [<ffffffffa00c4797>] nfs3_proc_statfs+0x47/0x90 [nfs]
 [<ffffffffa00b4cc6>] nfs_statfs+0x66/0x1a0 [nfs]
 [<ffffffff811abe64>] statfs_by_dentry+0x74/0xa0
 [<ffffffff811abf9b>] vfs_statfs+0x1b/0xb0
 [<ffffffff811ac260>] do_statfs_native+0x20/0xb0
 [<ffffffff811ac3f2>] sys_statfs+0x72/0xb0
 [<ffffffff81500a7e>] ? do_device_not_available+0xe/0x10
 [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b


When I tried "echo 1 > /proc/sys/sunrpc/rpc_debug" I got MANY messages
like the following, so quickly set it back to 0 again.  I don't know
how to tell whether the RPCs are for the hung mountpoint or a
different one on the client, but did notice that the "xid" numbers are
increasing, but the "req" number does not change.

Jan 31 01:13:11 s320 kernel: RPC: 55738 xprt_prepare_transmit
Jan 31 01:13:13 s320 kernel: RPC: 55743 reserved req ffff88042be25000
xid 4041e127
Jan 31 01:13:13 s320 kernel: RPC: 55743 xprt_prepare_transmit
Jan 31 01:13:13 s320 kernel: RPC: 55743 xprt_transmit(112)
Jan 31 01:13:13 s320 kernel: RPC: 55743 xmit complete
Jan 31 01:13:13 s320 kernel: RPC: 55743 xid 4041e127 complete (112
bytes received)
Jan 31 01:13:13 s320 kernel: RPC: 55743 release request ffff88042be25000
Jan 31 01:13:13 s320 kernel: RPC: 55744 reserved req ffff88042be25000
xid 4141e127
Jan 31 01:13:13 s320 kernel: RPC: 55744 xprt_prepare_transmit
Jan 31 01:13:13 s320 kernel: RPC: 55744 xprt_transmit(112)
Jan 31 01:13:13 s320 kernel: RPC: 55744 xmit complete
Jan 31 01:13:13 s320 kernel: RPC: 55744 xid 4141e127 complete (112
bytes received)
Jan 31 01:13:13 s320 kernel: RPC: 55744 release request ffff88042be25000
Jan 31 01:13:14 s320 kernel: RPC: 55745 reserved req ffff88042be25000
xid 4241e127
Jan 31 01:13:14 s320 kernel: RPC: 55745 xprt_prepare_transmit
Jan 31 01:13:14 s320 kernel: RPC: 55745 xprt_transmit(116)
Jan 31 01:13:14 s320 kernel: RPC: 55745 xmit complete
Jan 31 01:13:14 s320 kernel: RPC: 55745 xid 4241e127 complete (120
bytes received)
Jan 31 01:13:14 s320 kernel: RPC: 55745 release request ffff88042be25000
Jan 31 01:13:14 s320 kernel: RPC: 55746 reserved req ffff88042be25000
xid 4341e127
Jan 31 01:13:14 s320 kernel: RPC: 55746 xprt_prepare_transmit
Jan 31 01:13:14 s320 kernel: RPC: 55746 xprt_transmit(116)
Jan 31 01:13:14 s320 kernel: RPC: 55746 xmit complete
Jan 31 01:13:14 s320 kernel: RPC: 55746 xid 4341e127 complete (120
bytes received)
Jan 31 01:13:14 s320 kernel: RPC: 55746 release request ffff88042be25000
Jan 31 01:13:14 s320 kernel: RPC: 55747 reserved req ffff88042be25000
xid 4441e127


The clients are running CentOS-6.3, and we have tried both kernel
2.6.32-279.2.1.el6 and 2.6.32-279.19.1.el6, and are using
nfs-utils-1.2.3-26.el6.  We never saw the problem on the same hardware
when running CentOS-5.5 and kernel 2.6.18-194.11.4.el5.

The server in this example is a NetApp FAS3140, but mounts to other
servers (primarily running CentOS-5.7) have exhibited similar
problems.

Running "tcpdump" shows no NFS traffic to the server when running a
new command which should access the NFS mount.

We do not have a firewall in the way, and I don't believe that any
other routing problems are blocking network traffic since "ping" and
"showmount -e" from the client to the server respond normally.

Trying to create a new mount to any mountpoint on the same server
hangs as well.  The call trace shows it in __d_instantiate(), called
from rpc_wait_bit_killable().  Creating a new mount to a different
server works fine.

And finally, here are even more details that may be unique to our
configuration, and might confuse the issue, but I wanted to list them
here just in case they are relevant:

* These nodes are fully diskless, mounting their root file system via
NFS, and have no swap.

* We see similar hangs of processes accessing the root file system, as
indicated by the call trace generated by alt-sysrq-w from the console.
Unfortunately without a working root file system I can't login to the
nodes to get more debugging info, so have decided to concentrate on
the /home mount described above.

* Our site has 5 clusters all running the exact same (diskless) OS,
ranging from 250 to 850 nodes.  The problem is triggered most
frequently on a system with 8 cores/node + 24 GB memory, and very
rarely on one with 16 cores/node + 32 GB memory.  So it may have
something to do with memory pressure or with number of nodes used by a
user's application at a fixed core count.  Of course I can't rule out
differences in client NIC or cluster network capabilities impacting
frequency either.


Thanks for your time reading all this and any help you can offer!

-Nathan
