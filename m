Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.trendhosting.net ([195.8.117.5]:43464 "EHLO
	mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbbASV3V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jan 2015 16:29:21 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail1.trendhosting.net (Postfix) with ESMTP id 84C44156B0
	for <linux-nfs@vger.kernel.org>; Mon, 19 Jan 2015 21:23:46 +0000 (GMT)
Received: from mail1.trendhosting.net ([127.0.0.1])
	by localhost (thp003.trendhosting.net [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id x8aN5JVH7ZRQ for <linux-nfs@vger.kernel.org>;
	Mon, 19 Jan 2015 21:23:44 +0000 (GMT)
Message-ID: <54BD75DF.9010702@pocock.pro>
Date: Mon, 19 Jan 2015 22:23:43 +0100
From: Daniel Pocock <daniel@pocock.pro>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: storage controllers for use with NFS+BtrFs
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



I've been looking into the issue of which storage controllers are
suitable for use with NFS + BtrFs (or NFS + ZFS) and put some comments
about it on my blog[1] today.

I understand that for NFS it is generally desirable to have non-volatile
write cache if you want good write performance.

On the other hand, self-healing file systems (BtrFs and ZFS) like having
direct access to disks and those RAID cards with caches don't always
give the same level of access to the volume.

Can anybody give any practical suggestions about how to reconcile these
requirements and experience good NFS write performance onto these
filesystems given the type of HBA and RAID cards available?



1. http://danielpocock.com/storage-controllers-for-small-linux-nfs-networks
