Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754919AbaIWQ0V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 12:26:21 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8NGQKNt015366
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 12:26:21 -0400
Received: from bcodding-csb.redhat.com (vpn-55-195.rdu2.redhat.com [10.10.55.195])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s8NGQKYO030580
	for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 12:26:20 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Statd port change recovery
Date: Tue, 23 Sep 2014 12:26:18 -0400
Message-Id: <cover.1411486371.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These two attempt to address the issue of the kernel not recovering from
a statd port change, which Bruce pointed out in

http://marc.info/?t=140865700700001&r=1&w=2

The second patch here re-attempts the call after doing rpc_force_rebind
which is basically copied from what NLM would do in the same case.  However,
while working on that I discovered that when the transport attempts to reuse
a socket in the first call after rpc_force_rebind, it calls kernel_connect
with AF_UNSPEC to disconnect, which wakes the task in xs_error_report.  The
change in the task's status causes the first call after rpc_force_rebind to
fail, and a soft task returns which would otherwise succeed if the
connection had already been up.

The first patch tries to remedy this by not waking the task if we end up in
xs_error_report while trying to reuse the connection.  We expect to end up
in xs_error_report with an error, but we don't want to wake the task yet
since we're already set up to immediately reconnect.

Benjamin Coddington (2):
  SUNRPC: Don't wake tasks during connection abort
  lockd: Try to reconnect if statd has moved

 fs/lockd/mon.c              |    6 ++++++
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprtsock.c       |    4 ++++
 3 files changed, 11 insertions(+), 0 deletions(-)

