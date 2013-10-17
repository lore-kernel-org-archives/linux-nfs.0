Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:46859 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726Ab3JQKhy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 06:37:54 -0400
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr [212.27.42.5])
	by smtpfb1-g21.free.fr (Postfix) with ESMTP id AC0EF2D507
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 12:37:50 +0200 (CEST)
Received: from harpe.intellique.com (unknown [82.225.196.72])
	by smtp5-g21.free.fr (Postfix) with ESMTP id 16E0AD48294
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 12:37:12 +0200 (CEST)
Date: Thu, 17 Oct 2013 12:37:13 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: nlockmgr freezing when using Ubuntu 13.04 (3.8 kernel) clients
Message-ID: <20131017123713.588319c2@harpe.intellique.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi list,
this is probably an Ubuntu bug, however it put two different servers in
the dumps, running different kernels so I send this in case it may help
someone.

Here is the sort of messages clogging the NFS servers logs:

statd: server rpc.statd not responding, timed out
lockd: cannot monitor ipntheo12
statd: server rpc.statd not responding, timed out
lockd: cannot unmonitor ipnnester13
statd: server rpc.statd not responding, timed out
lockd: cannot monitor ipngrid01.in2p3.fr
statd: server rpc.statd not responding, timed out
lockd: cannot monitor ipngrid01.in2p3.fr
statd: server rpc.statd not responding, timed out
lockd: cannot monitor ipngrid01.in2p3.fr
statd: server rpc.statd not responding, timed out
lockd: cannot monitor ipnweb2
statd: server rpc.statd not responding, timed out
lockd: cannot monitor ipnweb2
statd: server rpc.statd not responding, timed out
lockd: cannot monitor ipnweb2
lockd: server ipnweb2 not responding, timed out
lockd: server ipnweb2 not responding, timed out

There are about 80 NFS clients (home directories) on these. They worked
perfectly for years until 2 clients were upgraded to 13.04.


-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
