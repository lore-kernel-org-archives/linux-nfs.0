Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:57025 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950Ab1CAW5R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2011 17:57:17 -0500
Received: from sim by peace.netnation.com with local (Exim 4.69)
	(envelope-from <sim@netnation.com>)
	id 1PuYBe-0005OP-I1
	for linux-nfs@vger.kernel.org; Tue, 01 Mar 2011 14:36:58 -0800
Date: Tue, 1 Mar 2011 14:36:58 -0800
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: RPC slots count exported to userland
Message-ID: <20110301223658.GA9759@hostway.ca>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Is there a place where a summary of the same table which gets dumped out
by "echo 0 > /proc/sys/sunrpc/debug" is exported normally to userland?

"nfsstat" accesses /proc/net/rpc/nfs and /proc/net/rpc/nfsd but they just
seem to be running counts. It would be nice to set up a way to monitor
when the system is close to running out of RPC slots so we can try to
kick out whatever mount might be stuck or similar to avoid an entire
outage.

Cheers,

Simon-
