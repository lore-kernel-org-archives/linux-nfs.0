From: Henrik Grindal Bakken <hgb-6miFZF/5cTBuMpJDpNschA@public.gmane.org>
Subject: NFS problem after upgrade from 2.6.32 to 2.6.3[3-7]
Date: Thu, 18 Nov 2010 11:31:09 +0100
Message-ID: <x2e1v6i7wk2.fsf@anakin.ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:39582 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713Ab0KRKfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Nov 2010 05:35:08 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1PJ1pY-0000CO-E6
	for linux-nfs@vger.kernel.org; Thu, 18 Nov 2010 11:35:04 +0100
Received: from anakin.ifi.uio.no ([129.240.64.199])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 11:35:04 +0100
Received: from hgb by anakin.ifi.uio.no with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 11:35:04 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi.  I'm running a (home-brew) linux distro on a powerpc, which
exports a yaffs2 filesystem via nfs to some arm-linuxes.

This has worked fine with kernels up to and including 2.6.32, but when
trying to upgrade further, we've been running into problems.

I didn't try 2.6.3[345] myself, but the reports were that nfs somehow
didn't work.  I'm trying 2.6.37-rc2 now after trying 2.6.36 earlier,
and I get the following problem:

$ grep -v '^#' /etc/netconfig 
udp        tpi_clts      v     inet     udp     -       -
udp6       tpi_clts      v     inet6    udp     -       -
local      tpi_cots_ord  -     loopback  -      -       -
$ rpcbind
$ rpc.mountd --no-tcp
$ rpc.nfsd -H ppc -N 4 -T
svc: failed to register nfsdv2 RPC service (errno 111).
nfsd: last server has exited, flushing export cache
rpc.nfsd: writing fd to kernel failed: errno 111 (Connection refused)
rpc.nfsd: unable to set any sockets for nfsd

I've tried to google the error message, to no avail.  The only hits I
get are from commit messages.

I'm running nfs-utils-1.2.3, configured with
./configure --with-tcp-wrappers=no --disable-nfsv4 --enable-uuid=no \
    --disable-gss --enable-mount=no

NFS-related kernel configs:
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_V4_1 is not set
CONFIG_ROOT_NFS=y
CONFIG_NFS_USE_LEGACY_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_DEPRECATED=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
CONFIG_NFSD_V4=y
CONFIG_NFS_COMMON=y

Does anyone have any pointers?


-- 
Henrik Grindal Bakken <hgb-6miFZF/5cTBuMpJDpNschA@public.gmane.org>
PGP ID: 8D436E52
Fingerprint: 131D 9590 F0CF 47EF 7963  02AF 9236 D25A 8D43 6E52

