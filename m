Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:49089 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965301Ab2JZQhu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Oct 2012 12:37:50 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1TRmIu-0001kG-N8
	for linux-nfs@vger.kernel.org; Fri, 26 Oct 2012 17:58:36 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1TRmIs-0000X0-8I
	for linux-nfs@vger.kernel.org; Fri, 26 Oct 2012 17:58:34 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Date: Fri, 26 Oct 2012 15:58:34 +0000 (UTC)
Message-ID: <k6ebva$1kf$1@ultimate100.geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

after updating the kernel of my NFS4-Server (because of 3.5.x EOL) I ended
up with NFS4 stopped working.

Kernel config is more or less the same as with 3.5.7, as I used "make
oldconfig". The only new stuff in the NFS area seems to be swap over NFS
which is disabled.

So starting from a working setup with 3.5.7 on the server (client uses
kernel 3.6.3) NFS4 stops working after upgrading the server to 3.6.3.

What happens is that mounting seems to hang infinitely when trying to mount
the server using the following command:
mount -v -t nfs4 -o sec=krb5 <server>:/<dir> /mnt/

However everything works fine again when the server has been rebooted into kernel
3.5.7.

Here is the relevant part of .config:
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V2=m
CONFIG_NFS_V3=m
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DEBUG=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_RPCSEC_GSS_KRB5=y
CONFIG_SUNRPC_DEBUG=y


Sven

P.S.: The system is using nfs-utils 1.2.6 on debian wheezy if this should be
relevant.

-- 
"Those who do not understand Unix are condemned to reinvent it, poorly"
(Henry Spencer)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
