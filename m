Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.piware.de ([37.120.164.117]:56831 "EHLO mail.piware.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755365AbbCFLQA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Mar 2015 06:16:00 -0500
From: Martin Pitt <martin.pitt@ubuntu.com>
To: linux-nfs@vger.kernel.org
Cc: Steve Langasek <steve.langasek@ubuntu.com>,
        systemd-devel@lists.freedesktop.org
Subject: [PATCH 0/1] details for starting nfs-idmapd also on clients
Date: Fri,  6 Mar 2015 12:15:43 +0100
Message-Id: <1425640544-24230-1-git-send-email-martin.pitt@ubuntu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

Steve Langasek pointed out in [1] that idmapd is also necessary on the client
side. It isn't for my very simple NFSv4 test, but then again I don't know that
much about the various other modes of operation.

This patch starts nfs-idmapd.service on clients too.

Thanks,

Martin

[1] https://launchpad.net/bugs/1428961

