Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx3.wp.pl ([212.77.101.7]:37993 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754394Ab3HANFq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 09:05:46 -0400
Received: from out.poczta.wp.pl ([212.77.101.240])
          (envelope-sender <neeo_xl@wp.pl>)
          by smtp.wp.pl (WP-SMTPD) with SMTP
          for <linux-nfs@vger.kernel.org>; 1 Aug 2013 15:05:43 +0200
Date: Thu, 01 Aug 2013 15:05:43 +0200
From: "Dawid Stawiarski" <neeo_xl@wp.pl>
To: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Problems with access to nfs shares
Message-ID: <51fa5d27e17595.86497708@wp.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We observe performance issues on Blade Linux NFS clients (Ubuntu 12.04 with kernel 3.8.0-23-generic).
Blade nodes are used in a shared hosting environment, and NFS is used to access client's data from Nexenta Storage (mostly small php files and/or images). Single node is running about 300-400 apache instances.
We use 10G on the whole path from nodes to storage with jumbo frames enabled. We didn't see any drops on
network interfaces (on nodes nor switches).
Once in a while, apache processes accesing data on NFS share stuck on IO (D state - stack trace below).
We've already tried different combinations of mount options and tuning sysctls and sunrpc module (we also tried NFSv4 and UDP transport - these only made things worse; without the local locks we had also lots of problems).
Hangs seems to happen under haeavy concurent operations (in production env); unfortunatelly we didn't manage
to reproduce it with benchmark utilities. When the number of nodes is decreased the problem happens more frequently (in this case we have about 600 apache instances per node). We didn't see any problems on the storage itself when one of the shares hangs (the cpu usage on load look normal).

1. client mount options we've tested:
noatime,nodiratime,noacl,nodev,nosuid,rsize=8192,wsize=8192,intr,bg,timeo=20,nfsvers=3,nolock
noatime,nodiratime,noacl,nodev,nosuid,rsize=8192,wsize=8192,intr,bg,acregmin=6,timeo=20,nfsvers=3,nolock

noatime,nodiratime,noacl,nodev,nosuid,rsize=1048576,wsize=1048576,intr,bg,acregmin=6,timeo=20,nfsvers=3,nolock
noatime,nodiratime,noacl,nodev,nosuid,rsize=1048576,wsize=1048576,intr,bg,acregmin=10,timeo=100,nfsvers=3,nolock
noatime,nodiratime,noacl,nodev,nosuid,rsize=1048576,wsize=1048576,intr,bg,acregmin=10,timeo=600,nfsvers=3,nolock

noatime,nodiratime,noacl,nodev,nosuid,rsize=1048576,wsize=1048576,intr,bg,acregmin=10,timeo=20,nfsvers=4,nolock

2. linux sysctl:
net.core.netdev_max_backlog = 30000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_timestamps = 0

3. linux module option:
options sunrpc tcp_slot_table_entries=128


With nfs timeout=2s we observed a huge loadavg (1000 or more) and lots of processes in "D" state waiting in
function "rpc_bit_killable". Everything "worked" but insanely slow. For example `find` on mountpoint printed ~1 line per second.
"avg RTT" and "avg exe" stats from nfsiostat increased to 500-800ms.

At first, we had 8 mounts from a single storage server (so basicly only one TCP connection was used).
However, we've also tried to add 8 virtual IPs to the storage, and use a separate IP to connect to
every share to distribute traffic among more TCP connections. At the same time we've
set nfs client timeout to 60s (the default). In this case we observed permanent hang
on random (single) mountpoint - and loadavg about 150. Other mountpoints from the same storage worked correctly. There was no
data traffic to hung mountpoint IP, only couple retransmissions (every 60 secs). After TCP reset and reconnect
everything starts to work correctly.

Now we decreased timeout to 10s.

/proc/PID/stack of a hung process (we have hundreds of these):
[<ffffffffa00eb019>] rpc_wait_bit_killable+0x39/0x90 [sunrpc]
[<ffffffffa00ec0fb>] __rpc_execute+0x15b/0x1b0 [sunrpc]
[<ffffffffa00ec87f>] rpc_execute+0x4f/0xb0 [sunrpc]
[<ffffffffa00e45a5>] rpc_run_task+0x75/0x90 [sunrpc]
[<ffffffffa00e46c3>] rpc_call_sync+0x43/0xa0 [sunrpc]
[<ffffffffa02595eb>] nfs3_rpc_wrapper.constprop.10+0x6b/0xb0 [nfsv3]
[<ffffffffa025a4ae>] nfs3_proc_getattr+0x3e/0x50 [nfsv3]
[<ffffffffa01452fd>] __nfs_revalidate_inode+0x8d/0x120 [nfs]
[<ffffffffa0141313>] nfs_lookup_revalidate+0x353/0x3a0 [nfs]
[<ffffffff811a79b3>] lookup_fast+0x173/0x230
[<ffffffff811a7cc6>] do_last+0x106/0x820
[<ffffffff811aa333>] path_openat+0xb3/0x4d0
[<ffffffff811ab152>] do_filp_open+0x42/0xa0
[<ffffffff8119adaa>] do_sys_open+0xfa/0x250
[<ffffffff811ed8cb>] compat_sys_open+0x1b/0x20
[<ffffffff816fc62c>] sysenter_dispatch+0x7/0x21
[<ffffffffffffffff>] 0xffffffffffffffff

nfsiostat on a problematic "slow" share (other shares from the SAME storage, but on separate TCP connection work correctly):
10.254.38.115:/volumes/DATA1/10/5 mounted on /home/10/5:

   op/s         rpc bklog
 420.50            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  1.000          30.736          30.736        0 (0.0%)          13.500         867.700
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.600           0.522           0.870        0 (0.0%)           0.667         872.333

mount options used on node:
10.254.38.115:/volumes/DATA1/10/5 /home/10/5 nfs rw,nosuid,nodev,noatime,nodiratime,vers=3,rsize=131072,wsize=131072,namlen=255,acregmin=10,hard,nolock,noacl,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.254.38.115,mountvers=3,mountport=63856,mountproto=udp,local_lock=all,addr=10.254.38.115 0 0


netstat:
- very slow access:
tcp        0      0 10.254.39.72:692        10.254.38.115:2049      ESTABLISHED -                off (0.00/0/0)

- completly not responding:
tcp        0 132902 10.254.39.74:719        10.254.38.115:2049      ESTABLISHED -                on (43.21/3/0)


Can anyone help us to investigate the problem or has any sugestions what to try/check? Any help will be appreciated.

cheers,
Dawid



