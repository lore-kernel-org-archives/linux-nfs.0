From: Boaz Harrosh <bharrosh@panasas.com>
Subject: help: return_layout status: -10025 - NFS4ERR_BAD_STATEID
Date: Mon, 07 Jun 2010 14:51:13 +0300
Message-ID: <4C0CDD31.2050507@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:23336 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752239Ab0FGLvQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 07:51:16 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny hi.

Only With Panfs. On a pnfs-2.6.33 Kernel after very heavy IO (git clone linux)
on the client side I get:

Jun  7 14:30:42 tl2 kernel: <-- return_layout status: -10025
Jun  7 14:30:42 tl2 kernel: <-- _pnfs_return_layout status: -10025

On the server side at the FS level I see a normal:
Jun  7 14:30:42 tl1 kernel: pan_kernel_fs_client_pnfs_layout_return: Begin I-xD02005194137f000f-xGe401b24c-xUb7850bdbb6117413 iomode=3 offs
et=0x0 length=0xffffffffffffffff cookie=0x0
Jun  7 14:30:42 tl1 kernel: pan_kernel_fs_client_pnfs_layout_return: released 3 caps
Jun  7 14:30:42 tl1 kernel: pan_kernel_fs_client_pnfs_layout_return: Return 0

These happen for 5 6 different files that do need return at that particular point.
(After Read was done and file closed by git)

And then everything at client side *freezes*.

1. Why would the Server return NFS4ERR_BAD_STATEID?
2. Why would the Client freeze and do nothing after that?

I'll try to run with nfs Server debug on to see what happens. Did Bruce fix
something like this for 2.6.34? or it was something else?

Boaz
