Return-Path: linux-nfs-owner@vger.kernel.org
Received: from intranet.asianux.com ([58.214.24.6]:10637 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab2JOEv0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Oct 2012 00:51:26 -0400
Message-ID: <507B968A.9090104@asianux.com>
Date: Mon, 15 Oct 2012 12:52:26 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [Bug fix] nfs-client: fix nfs_inode_attrs_need_update for async
 read_done comes during truncating to smaller size
References: <507B70F1.7040903@asianux.com> <4FA345DA4F4AE44899BD2B03EEEC2FA909236BB5@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA909236BB5@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

于 2012年10月15日 12:27, Myklebust, Trond 写道:
> nfs_size_need_update is not about performance. It is a heuristic that is
> entirely about ensuring correctness when faced with the fact that most
> Linux filesystems are utterly incapable of reporting with modifications
> that occur within < 1 second intervals because their mtime/ctime is
> limited to 1 second resolutions.
> 

if truly it was for correctness, why not use "!=" instead of '>' ?

> Now, what are the conditions of your test setup? The above bug report is
> meaningless unless it includes a description of what is being exported
> by the server (including a proper listing of the contents
> of /etc/exports and /proc/mounts). It should also include a description
> of the NFS client mount options (see /proc/mounts on the client).

they are below, if you need additional information, please tell me again.

for server:
(nfsx-linux using rsh auto exportfs in cmd line, not in /etc/exports)
--------------------------------------------------------------------
root@dhcp122:~# exportfs
/tmp/fsx18251.testdir
		<world>
/tmp          	<world>
root@dhcp122:~#
root@dhcp122:~# cat /etc/exports
# /etc/exports: the access control list for filesystems which may be
exported
#		to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check)
hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#
/tmp *(rw,sync,no_root_squash,no_subtree_check)
root@dhcp122:~#
root@dhcp122:~# cat /proc/mounts
rootfs / rootfs rw 0 0
sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev devtmpfs rw,relatime,size=1229628k,nr_inodes=189901,mode=755 0 0
devpts /dev/pts devpts
rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
tmpfs /run tmpfs rw,nosuid,relatime,size=516280k,mode=755 0 0
/dev/disk/by-uuid/e843c57e-98ce-44cc-8e02-6d8e8d8a01b6 / ext4
rw,relatime,errors=remount-ro,data=ordered 0 0
cgroup /sys/fs/cgroup tmpfs rw,relatime,mode=755 0 0
cgroup /sys/fs/cgroup/cpuset cgroup rw,relatime,cpuset 0 0
cgroup /sys/fs/cgroup/cpu cgroup rw,relatime,cpu 0 0
cgroup /sys/fs/cgroup/cpuacct cgroup rw,relatime,cpuacct 0 0
cgroup /sys/fs/cgroup/devices cgroup rw,relatime,devices 0 0
cgroup /sys/fs/cgroup/freezer cgroup rw,relatime,freezer 0 0
cgroup /sys/fs/cgroup/blkio cgroup rw,relatime,blkio 0 0
cgroup /sys/fs/cgroup/perf_event cgroup rw,relatime,perf_event 0 0
none /sys/fs/fuse/connections fusectl rw,relatime 0 0
none /sys/kernel/debug debugfs rw,relatime 0 0
none /sys/kernel/security securityfs rw,relatime 0 0
none /run/lock tmpfs rw,nosuid,nodev,noexec,relatime,size=5120k 0 0
none /run/shm tmpfs rw,nosuid,nodev,relatime 0 0
rpc_pipefs /run/rpc_pipefs rpc_pipefs rw,relatime 0 0
nfsd /proc/fs/nfsd nfsd rw,relatime 0 0
root@dhcp122:~#
-----------------------------------------------------------------------

for client:
-----------------------------------------------------------------------

root@dhcp159:/opt/ltp/testscripts# cat /proc/mounts
rootfs / rootfs rw 0 0
sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev devtmpfs rw,relatime,size=1103700k,nr_inodes=190392,mode=755 0 0
devpts /dev/pts devpts
rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
tmpfs /run tmpfs rw,nosuid,relatime,size=465908k,mode=755 0 0
/dev/disk/by-uuid/418ec1f1-ed9d-4cae-9336-6c742accf538 / ext4
rw,relatime,errors=remount-ro,data=ordered 0 0
cgroup /sys/fs/cgroup tmpfs rw,relatime,mode=755 0 0
cgroup /sys/fs/cgroup/cpuset cgroup rw,relatime,cpuset 0 0
cgroup /sys/fs/cgroup/cpu cgroup rw,relatime,cpu 0 0
cgroup /sys/fs/cgroup/cpuacct cgroup rw,relatime,cpuacct 0 0
cgroup /sys/fs/cgroup/devices cgroup rw,relatime,devices 0 0
cgroup /sys/fs/cgroup/freezer cgroup rw,relatime,freezer 0 0
cgroup /sys/fs/cgroup/blkio cgroup rw,relatime,blkio 0 0
cgroup /sys/fs/cgroup/perf_event cgroup rw,relatime,perf_event 0 0
none /sys/fs/fuse/connections fusectl rw,relatime 0 0
none /sys/kernel/debug debugfs rw,relatime 0 0
none /sys/kernel/security securityfs rw,relatime 0 0
none /run/lock tmpfs rw,nosuid,nodev,noexec,relatime,size=5120k 0 0
none /run/shm tmpfs rw,nosuid,nodev,relatime 0 0
rpc_pipefs /run/rpc_pipefs rpc_pipefs rw,relatime 0 0
nfsd /proc/fs/nfsd nfsd rw,relatime 0 0
/dev/sda1 /mnt/sda1 ext3
rw,relatime,errors=continue,user_xattr,acl,barrier=1,data=ordered 0 0
dhcp122.asianux.net:/tmp/fsx18251.testdir/
/opt/ltp/testcases/bin/fsx18251 nfs
rw,relatime,vers=2,rsize=8192,wsize=8192,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=10.1.0.139,mountvers=1,mountport=39973,mountproto=udp,local_lock=none,addr=10.1.0.139
0 0
root@dhcp159:/opt/ltp/testscripts#


-- 
Chen Gang

Asianux Corporation
