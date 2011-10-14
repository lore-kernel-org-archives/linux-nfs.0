Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e33.co.us.ibm.com ([32.97.110.151]:37302 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754133Ab1JNRVe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 13:21:34 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 14 Oct 2011 11:21:33 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EHKIaK151452
	for <linux-nfs@vger.kernel.org>; Fri, 14 Oct 2011 11:20:26 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EHKIwR014868
	for <linux-nfs@vger.kernel.org>; Fri, 14 Oct 2011 11:20:18 -0600
Received: from malahal ([9.47.25.235])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id p9EHKHfF014846
	for <linux-nfs@vger.kernel.org>; Fri, 14 Oct 2011 11:20:17 -0600
Date: Fri, 14 Oct 2011 10:20:17 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: NFS client replication support for failover
Message-ID: <20111014172017.GA4624@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

We are interested in replication support in NFS client for fail over
purposes.  Were there any plans or efforts to implement it? We are
thinking it to implement in NFSv4 and make use of 'fs_locations'
attribute to store the alternate server(s) upfront. Would appreciate if
you know any patches/efforts/issues implementing it.

Thanks, Malahal.

