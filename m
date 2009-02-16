From: Arto Jantunen <viiru@debian.org>
Subject: Timeout issue (similar to bugs 11061 and 11154), bisected
Date: Mon, 16 Feb 2009 13:11:17 +0200
Message-ID: <87ab8m7i22.fsf@viiru.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.dt-link.fi ([217.152.200.15]:52733 "EHLO mail2.dt-link.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947AbZBPLhc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Feb 2009 06:37:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail2.dt-link.fi (Postfix) with ESMTP id BAFFF2C1E6820
	for <linux-nfs@vger.kernel.org>; Mon, 16 Feb 2009 13:11:23 +0200 (EET)
Received: from mail2.dt-link.fi ([127.0.0.1])
	by localhost (mail2.dt-link.fi [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rxTGSWqN16Rr for <linux-nfs@vger.kernel.org>;
	Mon, 16 Feb 2009 13:11:23 +0200 (EET)
Received: from ryoko (ryoko.zyrain.org [217.152.200.219])
	by mail2.dt-link.fi (Postfix) with ESMTP id AD2DC2C1A5B2C
	for <linux-nfs@vger.kernel.org>; Mon, 16 Feb 2009 13:11:17 +0200 (EET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


(I'm not subscribed, so please CC me on any replies)

I seem to have hit a NFS bug while upgrading a machine from Debian
Etch to Debian Lenny. I have a NFS server running FreeBSD 7.0 RC1 and
a bunch of clients running Linux. The ones running kernel 2.6.18 work
perfectly, as do the ones running 2.6.24. The one I upgraded to 2.6.26
fails. After 5-15 minutes of working normally the mount dies and I get
the usual "nfs: server <server> not responding, still trying" in
dmesg. The only way I have found to get the mount back is umount -f &&
mount, waiting does not bring it back.

I have tested quite a bunch of different kernel versions, and starting
from 25 and ending at the git tree last week they all fail in the same
way. Bisecting tracks the problem to commit
e06799f958bf7f9f8fae15f0c6f519953fb0257c

I originally thought that it was the same as bug 11154, but the
patches attached to that bug do not fix this issue.

Any thoughts, patches, ideas?

-- 
Arto Jantunen
