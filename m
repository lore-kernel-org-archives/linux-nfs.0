Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:6224 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755301Ab1LZMvP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Dec 2011 07:51:15 -0500
Received: from [10.30.20.35] ([10.30.20.35])
	by relay.sw.ru (8.13.4/8.13.4) with ESMTP id pBQCpCbZ024356
	for <linux-nfs@vger.kernel.org>; Mon, 26 Dec 2011 15:51:13 +0300 (MSK)
Message-ID: <4EF86DAF.9040804@parallels.com>
Date: Mon, 26 Dec 2011 16:50:55 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RFC: rpcbind start/stop scripts affects all nested pid namespaces
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When trying to start and stop rpcbind in different pid namespaces I've noticed, 
that rpcbind stop command kills all rpcbind processes in nested pid namespaces.
This is caused by "/sbin/pidof rpcbind" call on rpcbind start. IOW file 
"/var/run/rpcbind.pid" contains pids of all nested rpcbind processes.
The simplest solution I see for now is to add "-c" options to "pidof" command. 
But I'm not sure about quality of solution and probably "killall5" have to be 
updated with new option to work only in current pid namespace.
Would be glad to hear any opinion about this problem.

-- 
Best regards,
Stanislav Kinsbursky
