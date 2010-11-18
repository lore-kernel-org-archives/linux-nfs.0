Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:31818 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756653Ab0KRPWA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 10:22:00 -0500
Subject: Re: NFS problem after upgrade from 2.6.32 to 2.6.3[3-7]
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <x2e1v6i7wk2.fsf@anakin.ifi.uio.no>
Date: Thu, 18 Nov 2010 10:20:48 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <6B116440-2E1A-4E2A-9D56-EF30DAE5BD7E@oracle.com>
References: <x2e1v6i7wk2.fsf@anakin.ifi.uio.no>
To: Henrik Grindal Bakken <hgb@ifi.uio.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 18, 2010, at 5:31 AM, Henrik Grindal Bakken wrote:

> 
> Hi.  I'm running a (home-brew) linux distro on a powerpc, which
> exports a yaffs2 filesystem via nfs to some arm-linuxes.
> 
> This has worked fine with kernels up to and including 2.6.32, but when
> trying to upgrade further, we've been running into problems.
> 
> I didn't try 2.6.3[345] myself, but the reports were that nfs somehow
> didn't work.  I'm trying 2.6.37-rc2 now after trying 2.6.36 earlier,
> and I get the following problem:
> 
> $ grep -v '^#' /etc/netconfig 
> udp        tpi_clts      v     inet     udp     -       -
> udp6       tpi_clts      v     inet6    udp     -       -
> local      tpi_cots_ord  -     loopback  -      -       -
> $ rpcbind
> $ rpc.mountd --no-tcp
> $ rpc.nfsd -H ppc -N 4 -T
> svc: failed to register nfsdv2 RPC service (errno 111).
> nfsd: last server has exited, flushing export cache
> rpc.nfsd: writing fd to kernel failed: errno 111 (Connection refused)
> rpc.nfsd: unable to set any sockets for nfsd
> 
> I've tried to google the error message, to no avail.  The only hits I
> get are from commit messages.

One thing to note: the kernel uses TCP when performing rpcbind registration upcalls.  You might try adding back the TCP entries in /etc/netconfig to cause rpcbind to create TCP listeners.

> I'm running nfs-utils-1.2.3, configured with
> ./configure --with-tcp-wrappers=no --disable-nfsv4 --enable-uuid=no \
>    --disable-gss --enable-mount=no
> 
> NFS-related kernel configs:
> CONFIG_NFS_FS=y
> CONFIG_NFS_V3=y
> # CONFIG_NFS_V3_ACL is not set
> CONFIG_NFS_V4=y
> # CONFIG_NFS_V4_1 is not set
> CONFIG_ROOT_NFS=y
> CONFIG_NFS_USE_LEGACY_DNS=y
> CONFIG_NFSD=y
> CONFIG_NFSD_DEPRECATED=y
> CONFIG_NFSD_V3=y
> # CONFIG_NFSD_V3_ACL is not set
> CONFIG_NFSD_V4=y
> CONFIG_NFS_COMMON=y
> 
> Does anyone have any pointers?
> 
> 
> -- 
> Henrik Grindal Bakken <hgb@ifi.uio.no>
> PGP ID: 8D436E52
> Fingerprint: 131D 9590 F0CF 47EF 7963  02AF 9236 D25A 8D43 6E52
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




