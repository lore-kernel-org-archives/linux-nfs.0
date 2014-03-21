Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.windriver.com ([147.11.1.11]:35616 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbaCUURa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2014 16:17:30 -0400
Message-ID: <532C9E49.2030007@windriver.com>
Date: Fri, 21 Mar 2014 14:17:13 -0600
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
To: <bfields@fieldses.org>, <neilb@suse.de>, <linux-nfs@vger.kernel.org>
Subject: race-free exportfs and unmount?
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

There was a linux-nfs thread in July 2012 with the subject "Linux NFS 
and cached properties".  It discussed the fact that you can't reliably do

exportfs -u 192.168.1.11:/mnt
umount /mnt

since there could be rpc users still running when exportfs returns, so 
the umount fails thinking the filesystem is busy.

I'm running into this on a production system.

Was anything ever done to resolve this issue?
If not are there any workarounds?

Please cc me, I'm not subscribed to the list.

Chris
