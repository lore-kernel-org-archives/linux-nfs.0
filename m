Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from somacoma.net ([62.75.137.225]:59317 "EHLO vs137225.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155Ab1ADIxl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 03:53:41 -0500
Subject: Cache flush question.
From: Daniel Stodden <daniel.stodden@citrix.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 04 Jan 2011 00:44:09 -0800
Message-ID: <1294130649.3529.96.camel@ramone>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi anyone.

If somebody's got a sec to enlighten me, there's some phenomenon I
recently came across and found somewhat counterintuitive first.

Whenever I

 1. Dirty a bunch of pages backed by an NFS mount on some server.

 2. Block the traffic with iptables (TCP, assuming that mattered).
    Still plenty of writeback pending.

 3. Sync

I see #3 drive the dirty count in /proc/meminfo drop back to
almost-zero, immediately. The sync itself blocks, though.

So the pages are called clean the moment the write got queued, not
acked? Leaving the rest just to retransmits by the socket then? Is this
just done so because one can, or would that order rather matter for
consistency?

Thanks,
Daniel

