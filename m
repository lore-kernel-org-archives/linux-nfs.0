Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:27995 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753703Ab0G0KHH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Jul 2010 06:07:07 -0400
Date: Tue, 27 Jul 2010 13:07:04 +0300 (IDT)
From: Or Gerlitz <ogerlitz@voltaire.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org
Subject: iostat "await" like counter for measuring nfs latency
Message-ID: <Pine.LNX.4.64.1007271300180.2110@zuben.voltaire.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Doing some iscsi and nfs performance testing, I realized that iostat(1)
doesn't support an "await" (*) like counter for measuring nfs latency.

Can tracking nfs latency be done in other means? is there a plan to
extend the nfs iostats code to include such/similar counter?

thanks,

Or.


(*) await - The average time (in milliseconds) for I/O requests issued
    to the device to be served. This includes the time spent by the
    requests in queue and the time spent servicing them.


