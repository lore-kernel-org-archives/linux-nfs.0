Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from xdsl-89-0-23-204.netcologne.de ([89.0.23.204]:53146 "EHLO
	horst.phuk.ath.cx" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab0HCCHq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Aug 2010 22:07:46 -0400
Received: from wald.localnet (wald.phuk.ath.cx [192.168.10.252])
	by horst.phuk.ath.cx (Postfix) with ESMTP id 32C2BC0084
	for <linux-nfs@vger.kernel.org>; Tue,  3 Aug 2010 04:01:33 +0200 (CEST)
From: Victor =?iso-8859-1?q?Matar=E9?= <dreck@vmsd.ath.cx>
To: linux-nfs@vger.kernel.org
Subject: numeric UIDs
Date: Tue, 3 Aug 2010 04:01:32 +0200
Content-Type: Text/Plain;
  charset="us-ascii"
Message-Id: <201008030401.33552.dreck@vmsd.ath.cx>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I still hope I'm mistaken in assuming I have to go back to NFSv3 if I want to 
skip NFSv4 UID mapping altogether and just use the numeric UIDs the way 
they're stored on-disk. However if that's actually true, I'd like to try and 
make a case for implementing an option to turn off UID mapping completely (or 
at least for unknown UIDs). If this is already work in progress, just ignore 
this mail.

Thing is, the forced UID mapping seems to make tasks like backing up data a 
little inconvenient. You might want to preserve UIDs that are only known to 
the client.
But when you copy an entire root filesystem, it becomes outright destructive, 
because the rootfs will probably have several accounts that the server can't 
be expected know. Just imagine a server that's used for maintenance (like 
backing up and replacing hard drives) of random (foreign) systems. Idmapd will 
map all unknown UIDs to a single value and thereby destroy that information.

I think I read somewhere that the Sun people already have a way of handling 
this. Any chance Linux could do that, too?

Please excuse me if I'm barking up the wrong tree. If this has already been 
discussed, I'd appreciate a pointer.

Thanks,
Victor
