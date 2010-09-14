Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:53970 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753588Ab0INKwl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 06:52:41 -0400
Message-ID: <4C8F53FA.5060308@panasas.com>
Date: Tue, 14 Sep 2010 12:52:42 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [RFC 0/4] move layout get/return synchronization to rpc prepare
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following patchset introduces a per-inode rpc wait queue
to be used to synchronize layout gets and returns during
their respective rpc prepare phase.

Essentially, layout gets wait on layout segments marked as invalid,
currently meaning there is a layout return in progress.
It should be ok to send the layout get anyway but waiting avoids
the race rather than having to possibly resolve it on the done path.

In the future layout gets could insert the layout segment they ask
for as "invalid" so that parallel layout gets would wait too.
However, since the server may return a different segment than
requested (bigger or smaller), there's no guarantee that the
parallel layoutget will overlap the one in progress.

Layout returns wait on layout segments while they are being used
(e.g. for I/O operations).

[PATCH 1/4] SQUASHME: pnfs-post-submit: remove take_ref and only_valid params from pnfs_has_layout
[PATCH 2/4] pnfs: allow nfs4_proc_layoutget to sleep on invalid lsegs
[PATCH 3/4] pnfs: allow nfs4_proc_layoutreturn to sleep on barrier
[PATCH 4/4] SQUASHME: pnfs: get rid of lo_waitq
