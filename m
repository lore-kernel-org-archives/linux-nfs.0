From: Geoffrey Leach <geoff-1srLxb0qcfWsTnJN9+BGXg@public.gmane.org>
Subject: mount.nfs: Unknown error 521
Date: Sun, 24 Jan 2010 15:09:30 -0800
Message-ID: <1264374570.1828.0@mtranch.mtranch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0121.b.hostedemail.com ([64.98.42.121]:48626 "EHLO
	smtprelay.b.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750784Ab0AXX2e convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Jan 2010 18:28:34 -0500
Received: from smtprelay.b.hostedemail.com (b-bigip1 [10.5.19.254])
	by smtpgrave06.b.hostedemail.com (Postfix) with ESMTP id DC97439511CB
	for <linux-nfs@vger.kernel.org>; Sun, 24 Jan 2010 23:10:48 +0000 (UTC)
Received: from filter.hostedemail.com (b-bigip1 [10.5.19.254])
	by smtprelay04.b.hostedemail.com (Postfix) with SMTP id C1A2D819702
	for <linux-nfs@vger.kernel.org>; Sun, 24 Jan 2010 23:10:04 +0000 (UTC)
Received: from mtranch.mtranch.com (unknown [72.169.46.176])
	(Authenticated sender: geoff-1srLxb0qcfWsTnJN9+BGXg@public.gmane.org)
	by omf12.b.hostedemail.com (Postfix) with ESMTP
	for <linux-nfs@vger.kernel.org>; Sun, 24 Jan 2010 23:09:51 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've got a simple network, systems 'A' and 'B' connected via wireless. 
B wants to mount A's /, /home and /usr/local. The fstab entries on B 
are:

A:/               /A                nfs	defaults	0 0
A:/home           /A-home           nfs	defaults	0 0
A:/usr/local      /A-ul             nfs	defaults	0 0

With this, B should do the mounts at boot time, assuming A is on line, 
which it is. (A:/home and A:/usr/local) are in seperate partitions)

The curious thing is that the mount of A:/ works fine. mounts of A:/
home and A:/usr/local fail with "mount.nfs: Unknown error 521"

FWIW, B is running Fedora 10 nfs-utils-1.1.4-8.fc10.i386, 
while A is running up-to-date Fedora 12, nfs-utils-1.2.1-4.fc12.i686.
This worked find prior to reloading F12 on A. 

Turns out that the problem was transient, but I'd like to know what was 
going on, if that's possible.

Thanks.
