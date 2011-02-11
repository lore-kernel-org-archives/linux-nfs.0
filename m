Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17119 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757328Ab1BKQy7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 11:54:59 -0500
Received: from localhost.localdomain (manjua-lxp.hq.netapp.com [10.58.49.248] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p1BGshZ3002533
	for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 08:54:43 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/7] pnfs wave 4 proposal
Date: Fri, 11 Feb 2011 11:54:32 -0500
Message-Id: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These apply on top of Andy's wave3-on-nfs-for-next-rev4.

These patches give write functionality to the pnfs file layout driver.
The primary limitation is that we have not yet modified the commit
code, so we can not yet handle COMMITs to the data server.  We get
around this for the moment by sending any WRITE to a data server which
does not have commit-to-mds set as a SYNCH write.

Fred

