Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49703 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754018Ab2HDAIU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Aug 2012 20:08:20 -0400
Date: Fri, 3 Aug 2012 20:08:19 -0400
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: nfs4 mounts failing with 3.6.0-rc1
Message-ID: <20120804000819.GB25558@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm getting

	# mount -tnfs -onfsvers=4 pip1:/exports /mnt/

(OK, admittedly that's with 3.6.0-rc1 + a few experimental patches, but
I doubt they're related.)

Also:

	[root@pip2 ~]# modprobe nfs4
	[root@pip2 ~]# lsmod|grep nfs4
	[root@pip2 ~]# 

--b.
