Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:33472 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab0K1OX0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Nov 2010 09:23:26 -0500
Received: from localhost (localhost [127.0.0.1])
	by borg.medozas.de (Postfix) with ESMTP id 54A6664E2
	for <linux-nfs@vger.kernel.org>; Sun, 28 Nov 2010 15:23:23 +0100 (CET)
Date: Sun, 28 Nov 2010 15:23:23 +0100 (CET)
From: Jan Engelhardt <jengelh@medozas.de>
To: linux-nfs@vger.kernel.org
Subject: NFS: server error: fileid changed
Message-ID: <alpine.LNX.2.01.1011281518090.14665@obet.zrqbmnf.qr>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,


Sometime between 2.6.33 and 2.6.36 it seems, knfsd has become really 
unreliable, having clients start to emit messages like

(nfsv3)
[42306.521225] NFS: server nova error: fileid changed
[42306.521226] fsid 0:10: expected fileid 0x1b007be, got 0x1b006b0

On nfsv4, it is even worse, as updates on the server are not immediately 
reflected on the client like it was the case on nfsv3.
Unfortunately, that is all the information I currently have.
(Server is on 2.6.36-rc8, client on 2.6.37-rc1.)

thanks,
Jan
