Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658AbcGHVfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2016 17:35:08 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B71829B0D4
	for <linux-nfs@vger.kernel.org>; Fri,  8 Jul 2016 21:35:07 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-38.rdu2.redhat.com [10.10.116.38])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u68LZ6Dx004230
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 8 Jul 2016 17:35:07 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] sunrpc: Fix reserved port range calculation and possible panic
Date: Fri,  8 Jul 2016 16:35:22 -0500
Message-Id: <1468013725-22835-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The range calculation for choosing the random reserved port will panic
with divide-by-zero when min_resvport == max_resvport, a range of one
port, not zero.

In addition, the sysctl and kernel module parameters only limit the
min_resvport and max_resvport values to the entire range of allowed
ports, so the min and max may become inverted, with max_resvport
set to a value lower than min_resvport.

These patches address both issues by correcting the port range
calculation and setting the min_resvport/max_resvport limits
to be dependent on each other.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>


[PATCH 1/3] sunrpc: Fix reserved port range calculation
[PATCH 2/3] sunrpc: Prevent resvport min/max inversion via sysctl
[PATCH 3/3] sunrpc: Prevent resvport min/max inversion via sysfs and
