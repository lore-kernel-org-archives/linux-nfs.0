Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47789 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754606Ab1ALRgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jan 2011 12:36:53 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1Pd4cu-0002of-Tf
	for linux-nfs@vger.kernel.org; Wed, 12 Jan 2011 12:36:52 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: break leases on nfsd rename, setattr, etc.
Date: Wed, 12 Jan 2011 12:36:47 -0500
Message-Id: <1294853809-10732-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

NFSv4 read delegations should be broken on anything that modifies file
metadata, or modifies (by rename, link, or unlink) any of the links that
point to the file.

It's going to take a while longer to finish vfs patches that solve the
problem completely; for now I wonder if an (incomplete) nfsd-only fix
would be worthwhile?

--b.

