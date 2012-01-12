Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:32846 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835Ab2ALBLK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jan 2012 20:11:10 -0500
Received: by werm1 with SMTP id m1so989686wer.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jan 2012 17:11:09 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 11 Jan 2012 19:11:09 -0600
Message-ID: <CAE9DZUQTFA8qqNtphJe6NQYqbbdi_8aMyDBgbJF1-=1arW3rCw@mail.gmail.com>
Subject: Problems restarting nfsd
From: Dallas Clement <dallas.a.clement@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've got a home-brew linux 2.6.39 kernel and I'm having some problems
restarting nfsd.  If I stop it and wait > 10 seconds and then start
it, it seems to behave, but if I stop/start in rapid succession, it
will not start correctly and I see the following errors in dmesg:

[  182.130908] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state
recovery directory
[  182.130971] NFSD: starting 90-second grace period
[  441.501954] nfsd: last server has exited, flushing export cache
[  444.595519] svc: failed to register nfsdv2 RPC service (errno 111).
[  444.595598] svc: failed to register nfsaclv2 RPC service (errno 111).
[  444.595639] nfsd: last server has exited, flushing export cache
[  444.596145] svc: failed to register nfsdv2 RPC service (errno 111).
[  444.596201] svc: failed to register nfsaclv2 RPC service (errno 111).
[  444.596250] nfsd: last server has exited, flushing export cache
[  444.596494] nfsd: last server has exited, flushing export cache

Here is my kernel config:

CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFS_USE_NEW_IDMAPPER is not set
CONFIG_NFSD=y
CONFIG_NFSD_DEPRECATED=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V4=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y

I also have nfs-utils-1.2.5 installed on this system.

Any idea what could be going wrong?
