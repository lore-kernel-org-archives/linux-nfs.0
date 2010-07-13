Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515Ab0GMKRP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jul 2010 06:17:15 -0400
Date: Tue, 13 Jul 2010 06:16:51 -0400
From: Xiaotian Feng <dfeng@redhat.com>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl,
        Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org,
        lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org,
        davem@davemloft.net
Message-Id: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Subject: [PATCH -mmotm 00/30] [RFC] swap over nfs -v21
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hi,

Here's the latest version of swap over NFS series since -v20 last October. We decide to push
this feature as it is useful for NAS or virt environment.

The patches are against the mmotm-2010-07-01. We can split the patchset into following parts:

Patch 1 - 12: provides a generic reserve framework. This framework
could also be used to get rid of some of the __GFP_NOFAIL users.

Patch 13 - 15: Provide some generic network infrastructure needed later on.

Patch 16 - 21: reserve a little pool to act as a receive buffer, this allows us to
inspect packets before tossing them.

Patch 22 - 23: Generic vm infrastructure to handle swapping to a filesystem instead of a block
device.

Patch 24 - 27: convert NFS to make use of the new network and vm infrastructure to
provide swap over NFS.

Patch 28 - 30: minor bug fixing with latest -mmotm.

[some history]
v19: http://lwn.net/Articles/301915/
v20: http://lwn.net/Articles/355350/

Changes since v20:
	- rebased to mmotm-2010-07-01
	- dropped the null pointer deref patch for the root cause is wrong SWP_FILE enum
	- some minor build fixes
	- fix a null pointer deref with mmotm-2010-07-01
	- fix a bug when swap with multi files on the same nfs server

Regards
Xiaotian
