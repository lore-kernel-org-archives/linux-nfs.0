Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gurulabs.com ([64.245.157.7]:39856 "EHLO mail.gurulabs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272Ab1CNRAi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2011 13:00:38 -0400
Received: from [10.200.1.22] (fw.zlug.net [63.248.156.3])
	by mail.gurulabs.com (Postfix) with ESMTP id 7A2072EFD05
	for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2011 10:30:57 -0600 (MDT)
Subject: When did NFSv4 behavior change occur?
From: Dax Kelson <dkelson@gurulabs.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Mar 2011 10:30:56 -0600
Message-ID: <1300120256.3600.19.camel@mentorng>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In a quest to update our documentation, could someone please answer this
question?

What kernel version did the change occur where all the entries
in /etc/exports are shared as v4 (in addition to v2 and v3) as well as
the automatic psuedo-root creation if fsid=0 not exist?

Or maybe it was a combo of kernel version and nfs-utils version??

Dax Kelson
Guru Labs

