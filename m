Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esrismtp2.esri.com ([198.102.62.103]:25057 "EHLO Vail.esri.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752400Ab0AVUF0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2010 15:05:26 -0500
Received: from leoray.esri.com (leoray.esri.com [10.27.102.12])
	by Vail.esri.com (8.13.7+Sun/8.13.7) with ESMTP id o0MK5Pa4002586
	for <linux-nfs@vger.kernel.org>; Fri, 22 Jan 2010 12:05:25 -0800 (PST)
Received: from leoray.esri.com (leoray.esri.com [127.0.0.1])
	by leoray.esri.com (8.14.3/8.14.3) with ESMTP id o0MK5Pmb026111
	for <linux-nfs@vger.kernel.org>; Fri, 22 Jan 2010 12:05:25 -0800
Received: (from ray5147@localhost)
	by leoray.esri.com (8.14.3/8.14.3/Submit) id o0MK5PKf026110
	for linux-nfs@vger.kernel.org; Fri, 22 Jan 2010 12:05:25 -0800
Date: Fri, 22 Jan 2010 12:05:25 -0800
From: Ray Van Dolson <rvandolson@esri.com>
To: linux-nfs@vger.kernel.org
Subject: Source address in server callbacks fix...
Message-ID: <20100122200525.GA26072@esri.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We're being bitten by the source address in server callbacks
issue[1][2].

The post above[1], mentions kernel fixes for this.  I'm having a hard
time locating this commit so I can determine if it has been backported
to the RHEL5 kernel yet.

Can anyone point me in the right direction?

Thanks,
Ray

[1] http://markmail.org/message/nd4lvfpiv6gkacio
[2] https://bugzilla.redhat.com/show_bug.cgi?id=557911
