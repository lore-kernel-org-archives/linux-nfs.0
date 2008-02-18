From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/17] RFC: mount.nfs support for NFSv4 over IPv6
Date: Mon, 18 Feb 2008 13:35:20 -0500
Message-ID: <20080218180635.19060.35395.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:54394 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbYBRSf1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:35:27 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIZKOj015725
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:35:21 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIZKEw019294
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:35:20 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's a proposal for adding support in mount.nfs for mounting NFSv4
servers over IPv6.  It provides mount.nfs4 with the ability to resolve a
hostname to an IPv6 address and pass it to the kernel.  It can also pass an
IPv6 local address via clientaddr=.

Kernel level sunrpc support rpcbind protocol versions 3 and 4 must be
enabled via Kconfig.  Support for user-space rpcbind operations for IPv6
addresses is not needed with NFSv4, since the kernel handles rpcbind
operations for NFS version 4.

To support NFS version 2 and 3 mounts over IPv6, user level support for
rpcbind versions 3 and 4 will be required.  That is currently under
development.

Unmount support in umount.nfs4 for IPv6 is not needed for NFSv4 since
unmounting an nfs4 file system is a local client operation only.

This code is untested; it is posted for review only.

-- 
corporate:    <chuck dot lever at oracle dot com>
