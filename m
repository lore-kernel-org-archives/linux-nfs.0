Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:2332 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753891Ab1J0SCM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Oct 2011 14:02:12 -0400
Received: from [10.30.20.35] ([10.30.20.35])
	by relay.sw.ru (8.13.4/8.13.4) with ESMTP id p9RI29Mm014694
	for <linux-nfs@vger.kernel.org>; Thu, 27 Oct 2011 22:02:10 +0400 (MSD)
Message-ID: <4EA99CD8.2070100@parallels.com>
Date: Thu, 27 Oct 2011 22:03:04 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: SUNRPC: non-exclusive pipe creation
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.
I'm working on making RPC pipefs per network namespace in 3.1.kernel and I don't 
understand, why pipes are created in non-exclusive mode.
IOW we create pipes only in kernel, and, as I see it, each of them have unique 
name and created under unique directory name.
This code looks like obsolete and left from previous logic, which has been 
replaced a while ago.
Am I right? Or I missed something?

-- 
Best regards,
Stanislav Kinsbursky
