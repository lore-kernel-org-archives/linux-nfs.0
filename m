Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.astim.si ([93.103.6.239]:50701 "EHLO mail.astim.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752489AbbD0GTM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Apr 2015 02:19:12 -0400
Received: from PCSaso ([192.168.10.2])
	by mail.astim.si (8.14.4/8.14.4) with ESMTP id t3R67F3N113463
	for <linux-nfs@vger.kernel.org>; Mon, 27 Apr 2015 08:07:16 +0200
From: "Saso Slavicic" <saso.linux@astim.si>
To: <linux-nfs@vger.kernel.org>
Subject: server_scope v4.1 lock reclaim
Date: Mon, 27 Apr 2015 08:07:12 +0200
Message-ID: <000601d080b0$687a2860$396e7920$@astim.si>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm doing a NFS HA setup for KVM and need lock reclaim to work. I've been
doing a lot of testing and reading in the past week and finally figured out
that for reclaims to work on a 4.1 mount (4.1 is preferable due to
RECLAIM_COMPLETE and thus faster failover), the server hostnames need to be
the same. RFC specifies that reclaim can succeed if server scope is the same
and in fact, the client will not even attempt a reclaim if the server scope
does not match.

But...there doesn't seem to be any way of setting server scope other than
changing server hostname? RFC states: "The purpose of the server scope is to
allow a group of servers to indicate to clients that a set of servers
sharing the same server scope value has arranged to use compatible values of
otherwise opaque identifiers." The nfsdcltrack directory is properly handed
over during failover so I'd need some way of configuring server scope on
this "set of servers"? From the code, the server scope is simply set to
utsname()->nodename in nfs4xdr.c.

What am I missing here, how can this work when Heartbeat needs different
names for nodes?

Thanks,
Saso Slavicic


