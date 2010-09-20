Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:50761 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756890Ab0ITQc1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 12:32:27 -0400
Received: by gxk23 with SMTP id 23so1361234gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 09:32:27 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] The final patches for mountd IPv6 support
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 20 Sep 2010 12:32:23 -0400
Message-ID: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

Here's the last set of patches implementing basic IPv6 support for
mountd.  This set enables mountd to listen on IPv6 transports, if they
are available.

I've done a little re-arranging of Neil's recent changes to control
the MNT version, in order to make my changes easier; hopefully you
guys won't mind that.

Also included here is an overhaul of rpc.mountd(8).

As a last step, I enable IPv6 support in rpc.nfsd again.  This should
make NFS server-side IPv6 support, in both user space and in the
kernel, complete.

I'm sure there will be bug fixes, but hopefully this is the last of
these for a while.

---

Chuck Lever (7):
      nfsd: Enable IPv6 support in rpc.nfsd again.
      mountd: Update mountd/exportfs man pages to reflect IPv6 changes
      mountd: Use MNT status values instead of NFSERR
      mountd: Fix up version and usage messages
      mountd: Unregister mountd if my_svc_run() returns
      mountd: Support TI-RPC mountd listener
      mountd: Make NFS version checks more strict


 utils/exportfs/exportfs.man |  287 ++++++++++++++++++++++---------------------
 utils/exportfs/exports.man  |   88 ++++++++-----
 utils/mountd/mountd.c       |  136 ++++++++++++++------
 utils/mountd/mountd.man     |  240 +++++++++++++++++++++++-------------
 utils/nfsd/nfsd.c           |    9 -
 utils/nfsd/nfssvc.c         |    9 -
 6 files changed, 445 insertions(+), 324 deletions(-)

-- 
Chuck Lever
