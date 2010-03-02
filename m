Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54589 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102Ab0CBXLn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 18:11:43 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1NmbGn-00037W-IZ
	for linux-nfs@vger.kernel.org; Tue, 02 Mar 2010 18:12:53 -0500
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Subject: grace period setting
Date: Tue,  2 Mar 2010 18:12:46 -0500
Message-Id: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The NFSv4 lease-time configuration interface we currently have doesn't
actually allow setting the grace period directly.

Mostly this is noticed by developers trying to set a smaller grace
period to speed testing.

However, it also makes it difficult to make reboot-recovery behavior
correct, since there's no way for userland to force the kernel to
observe the correct grace period on reboot if the previous server was
using something other than the default lease time.

So, add a grace-period setting interface as well.

Note if you actually want a shorter grace period you'll also need to
adjust the nlm_grace_period sysctl (/proc/sys/fs/nfs/nlm_grace_period),
since the server doesn't end grace until both have expired.

--b.


