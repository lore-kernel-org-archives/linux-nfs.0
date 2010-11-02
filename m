Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51760 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab0KBSAx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Nov 2010 14:00:53 -0400
Date: Tue, 2 Nov 2010 19:00:51 +0100
From: Andi Kleen <andi@firstfloor.org>
To: Trond.Myklebust@netapp.com, bjschuma@netapp.com,
        torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [regression] NFS readdir change break fully cached nfs root
Message-ID: <20101102180051.GA26089@basil.fritz.box>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


My NFS root test systems stopped booting with 2.6.37-rc1. It just
hangs after entering user space.

The NFS root setup uses a slightly fancy parameter setup to minimize 
network traffic:

nfsroot=10.23.204.1:/home/nfsroot/edwin,nocto,acregmin=86400,acregmax=86400,acdirmin=86400,acdirmax=86400 root=/dev/nfs

I bisected it down to this commit from Bryan.

Unfortunately it's not trivially revertable because that conflicts
with later patches.

commit d1bacf9eb2fd0e7ef870acf84b9e3b157dcfa7dc
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Fri Sep 24 14:48:42 2010 -0400

    NFS: add readdir cache array


-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
