Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:53945 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756000AbaGXAM1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jul 2014 20:12:27 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so1664371iec.2
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jul 2014 17:12:27 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 23 Jul 2014 17:12:27 -0700
Message-ID: <CAB7xdinUj4U3PAYVB7j3o+iWSTV7aNMBD5O-rAgnzj6vgmce0g@mail.gmail.com>
Subject: pNFS setup
From: sheng qiu <herbert1984106@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

does anyone can share your experience on setting up the pNFS of file
layout or block layout?
the wiki instruction :
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions does
not work for me on step

echo "/dev/sdc:192.168.0.1,192.168.0.2" >/proc/fs/nfsd/pnfs_dlm_device

since i do not have that directory entry after install the pNFS kernel
version. my system is ubuntu 14.

this is my config file related with nfs part:

CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V2=m
CONFIG_NFS_V3=m
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
CONFIG_NFS_SWAP=y
CONFIG_NFS_V4_1=y
CONFIG_NFS_V4_2=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_OBJLAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
CONFIG_NFS_V4_SECURITY_LABEL=y
CONFIG_NFS_FSCACHE=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DEBUG=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_NFSD_V4_SECURITY_LABEL=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_PNFSD=y
CONFIG_PNFSD_LOCAL_EXPORT=y
# CONFIG_PNFSD_LEXP_LAYOUT_SEGMENTS is not set
CONFIG_PNFSD_LEXP_RETURN_ON_CLOSE=y
# CONFIG_PNFSD_LEXP_COMMIT_THRU_MDS is not set
# CONFIG_PNFSD_LEXP_INJECT_IO_ERRORS is not set
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y


thanks a lot if anyone can help.
