Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754010Ab1LANSI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 08:18:08 -0500
Message-ID: <4ED77E8E.2040304@RedHat.com>
Date: Thu, 01 Dec 2011 08:18:06 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Bruce Dubbs <bruce.dubbs@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs server issues
References: <4ED6BCEA.9050000@gmail.com>
In-Reply-To: <4ED6BCEA.9050000@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/30/2011 06:31 PM, Bruce Dubbs wrote:
> I am trying to document the installation of nfs for Linux From Scratch.  The client works, but the server does not and I'm looking for some help.   If this is the wrong place to ask for help, please redirect me.
> 
> For now, I am only trying to get nfs version 3 to work.
> 
> # mount -t nfs -o nfsvers=3 lfs6:/home/bdubbs /mnt/test
>    [ mounts OK ]
> # mount -t nfs -o nfsvers=3 localhost:/usr/src /mnt/tmp
> # mount.nfs: requested NFS version or transport protocol is not supported
The reason you getting the mounting error to localhost is because there are 
no NFS services registered with rpcbind. Note the lack of nfs entires in
your rpcinfo -p output. For the above mount to work you would need at least 
the following entry:
  100003    3   tcp   2049  nfs

Figure out why that is not happening and you find the problem...

steved.

> 
> Any pointers are appreciated.  Details of the procedures I've used are below.
> 
>   -- Bruce Dubbs
>      linuxfromscratch.org
> 
> 
> The packages I'm using:
> 
> linux-3.0.4
> libtirpc-0.2.2
> rpcbind-0.2.0
> nfs-utils-1.2.5
> glibc-2.14.1
> util-linux-2.20
> 
> The build procedures were as follows:
> 
> 1. Restore nfs/nis headers omitted by glibc-2.14.1
> 2. Build libtirpc
>    Remove auth_des.c authdes_prot.c des_crypt.c from Makefile
>    Comment out authdes_create() in rpc_soc.c
>    ./configure --prefix=/usr --libdir=/lib
> 3. Build rpcbind
>    ./configure --prefix=/usr --bindir=/sbin
>    Update /etc/services for rpcbind on port 111
> 4. Build nfs-utils
>    LIBS=-lpthread ./configure --prefix=/usr     \
>         --sysconfdir=/etc --disable-nfsv4 --disable-nfsv41  \
>         --disable-gss
> 
> Start rpcbind
> Start rpc.mountd
> Run   rpc.nfsd -p 2049 8
> Start rpc.statd
> Run   exportfs -ra
> 
> /etc/exports has:
> /usr/src 192.168.0.0/24(rw,async,no_root_squash,subtree_check)
> 
> rpcinfo -p gives:
>     100000    4   tcp    111  portmapper
>     100000    3   tcp    111  portmapper
>     100000    2   tcp    111  portmapper
>     100000    4   udp    111  portmapper
>     100000    3   udp    111  portmapper
>     100000    2   udp    111  portmapper
>     100005    1   udp  52645  mountd
>     100005    1   tcp  47533  mountd
>     100005    2   udp  60954  mountd
>     100005    2   tcp  56425  mountd
>     100005    3   udp  33939  mountd
>     100005    3   tcp  56892  mountd
>     100024    1   udp  34641  status
>     100024    1   tcp  50491  status
> 
> # ps -ef|grep 'nfs\|rpc\|lock'
> root       291     2  0 Nov26 ?        00:00:00 [kblockd]
> root       498     2  0 Nov26 ?        00:00:00 [rpciod]
> root       613     2  0 Nov26 ?        00:00:00 [nfsiod]
> root      1136     2  0 Nov28 ?        00:00:00 [lockd]
> root      1137     2  0 Nov28 ?        00:00:00 [nfsd]
> root      1138     2  0 Nov28 ?        00:00:00 [nfsd]
> root      1139     2  0 Nov28 ?        00:00:00 [nfsd]
> root      1140     2  0 Nov28 ?        00:00:00 [nfsd]
> root      1141     2  0 Nov28 ?        00:00:00 [nfsd]
> root      1142     2  0 Nov28 ?        00:00:00 [nfsd]
> root      1143     2  0 Nov28 ?        00:00:00 [nfsd]
> root      1144     2  0 Nov28 ?        00:00:00 [nfsd]
> root      1889     1  0 Nov28 ?        00:00:00 /usr/sbin/rpc.statd
> root     12615     1  0 Nov29 ?        00:00:00 rpc.statd --no-notify
> root     12618     1  0 Nov29 ?        00:00:00 rpc.statd --no-notify
> root     12685     1  0 Nov29 ?        00:00:00 rpc.statd --no-notify
> root     12711     1  0 Nov29 ?        00:00:00 rpc.statd --no-notify
> root     12923     1  0 Nov29 ?        00:00:00 rpc.statd --no-notify
> root     14127     1  0 Nov29 ?        00:00:00 rpc.statd --no-notify
> root     14494     1  0 Nov29 ?        00:00:00 rpc.statd --no-notify
> root     14861     1  0 Nov29 ?        00:00:00 rpc.statd --no-notify
> root     15248     1  0 Nov29 ?        00:00:00 rpc.statd --no-notify
> root     15819     1  0 Nov29 ?        00:00:00 /sbin/rpcbind
> root     16423     1  0 12:34 ?        00:00:00 /usr/sbin/rpc.mountd
> root     16432     1  0 12:36 ?        00:00:00 /usr/sbin/rpc.statd
> 
> Kernel configuration:
> 
> CONFIG_NETWORK_FILESYSTEMS=y
> CONFIG_NFS_FS=y
> CONFIG_NFS_V3=y
> CONFIG_NFS_V3_ACL=y
> CONFIG_NFS_V4=y
> # CONFIG_NFS_V4_1 is not set
> CONFIG_ROOT_NFS=y
> # CONFIG_NFS_USE_LEGACY_DNS is not set
> CONFIG_NFS_USE_KERNEL_DNS=y
> # CONFIG_NFS_USE_NEW_IDMAPPER is not set
> CONFIG_NFSD=y
> # CONFIG_NFSD_DEPRECATED is not set
> CONFIG_NFSD_V3=y
> # CONFIG_NFSD_V3_ACL is not set
> # CONFIG_NFSD_V4 is not set
> CONFIG_LOCKD=y
> CONFIG_LOCKD_V4=y
> CONFIG_NFS_ACL_SUPPORT=y
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=y
> CONFIG_SUNRPC_GSS=y
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
