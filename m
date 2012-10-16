Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47185 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255Ab2JPM6d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 08:58:33 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TO6jA-0001l1-T9
	for linux-nfs@vger.kernel.org; Tue, 16 Oct 2012 08:58:32 -0400
Date: Tue, 16 Oct 2012 08:58:32 -0400
To: linux-nfs@vger.kernel.org
Subject: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
Message-ID: <20121016125832.GC30649@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3.7-rc1:

	client# mount -tnfs -osec=krb5,vers=3 server:/exports/ext4 /mnt/

		server# ls -l /exports/ext4|grep TMP
		server#

	# mkdir /mnt/TMP
	mkdir: cannot create directory `/mnt/TMP': Permission denied

		server# ls -l /exports/ext4|grep TMP
		drwxr-xr-x  2 nfsnobody nfsnobody 4096 Oct 16 08:56 TMP
		server#

Wireshark also shows that the create succeeds.

--b.
