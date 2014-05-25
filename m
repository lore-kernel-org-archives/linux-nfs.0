Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:58014
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751075AbaEYTEa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 May 2014 15:04:30 -0400
Message-ID: <53823B52.2080201@earthlink.net>
Date: Sun, 25 May 2014 14:49:54 -0400
From: Felix Miata <mrmazda@earthlink.net>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: system updating routinely umounts "manual" nfs mounts
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This has been happening here for several months or more in devel distro 
versions Factory and IIRC Cauldron and Rawhide.

Maybe others' manual nfs mounts are more "manual" than mine are. Mine are 
actually a group of noauto fstab entries I enable via script when I want them 
active. All of my installations are on real x86 hardware, some 32 and others 
64 bit. I'm guessing what's going on is systemd updates syncing /proc/mounts 
to fstab, oblivious to the manual post-init mount processes having taken 
place, but this certainly could be nfs evolutionary fallout or something else 
I know nothing about. Is this happening to others? Expected? My search of nfs 
component @bugzilla.kernel.org produced nothing on apparent point.
-- 
"The wise are known for their understanding, and pleasant
words are persuasive." Proverbs 16:21 (New Living Translation)

  Team OS/2 ** Reg. Linux User #211409 ** a11y rocks!

Felix Miata  ***  http://fm.no-ip.com/
