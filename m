From: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Subject: mount.nfs4 hangs when rpcbind is not reachable
Date: Fri, 23 Apr 2010 17:18:44 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004231717180.2242@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:60920 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab0DWPSq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Apr 2010 11:18:46 -0400
Received: from localhost (localhost [127.0.0.1])
	by borg.medozas.de (Postfix) with ESMTP id 15BF96501
	for <linux-nfs@vger.kernel.org>; Fri, 23 Apr 2010 17:18:44 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,


I just noticed that in a diskless-system initramfs, mount.nfs4 appears 
to hang whenever it cannot get a response (any response) from the 
rpcbind port. If there is no rpcbind running and thus, TCP RST is sent, 
fine. But if it's dropped, like when the "lo" device is not in the "up" 
state (as can easily happen at this stage of boot), mount.nfs4 waits 
forever.
