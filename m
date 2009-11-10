From: Norbert van Bolhuis <nvbolhuis-bYiImlzuGf1HoQZOM9yvow@public.gmane.org>
Subject: exportfs: Warning: /adir does not support NFS export.
Date: Tue, 10 Nov 2009 17:44:17 +0100
Message-ID: <4AF99861.7030103@aimvalley.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr6.xs4all.nl ([194.109.24.26]:1685 "EHLO
	smtp-vbr6.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756633AbZKJQoN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 11:44:13 -0500
Received: from mail3.aimsys.nl (a80-127-156-242.adsl.xs4all.nl [80.127.156.242])
	by smtp-vbr6.xs4all.nl (8.13.8/8.13.8) with ESMTP id nAAGiHZL027263
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2009 17:44:17 +0100 (CET)
	(envelope-from nvbolhuis-bYiImlzuGf1HoQZOM9yvow@public.gmane.org)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I get the following exportfs 1.2.0 warning:

exportfs: Warning: /adir does not support NFS export.

Although everything works fine, I'm worried about this.

The directoy "/adir" is the path to a ISOZFS loop mounted image.
The ISO(Z)FS image itself resides on a UBIFS filesystem (/flashfs/isozfs_image.iso).
The root dir ("/"), as well as "/adir" and "/flashfs" is initramfs.

So afaik I'm exporting a ISOFS, this is supported by nfsd (in the kernel), so
why is the warning there ?

I know UBIFS doesn't support to be (nfsd) exported by the kernel,
but ISO(Z)FS and initramfs do, right ?

Am I doing something illegal ?

any feedback is appreciated, please cc me in the reply as I am not subscribed.


