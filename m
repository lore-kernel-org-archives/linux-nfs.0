From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Better error/warning message while exporting ramfs
Date: Thu, 13 Dec 2007 18:22:56 +0530
Message-ID: <47612B28.4040103@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:56169 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759873AbXLMMqr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2007 07:46:47 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While trying to export non-device filesystems like tmpfs and ramfs,
nfs-utils version < 1.1.0 didn't report any error or warning message. So
the users were left clueless by the "Permission denied" message on the
Client, though it was possible to export tmpfs by setting
'fsid=<somenum>' option.

nfs-utils 1.1.0 and greater reported a much better warning:

"exportfs: Warning: /mnt/js requires fsid= for NFS export"

However, this warning message is reported only while exporting tmpfs and
not while exporting ramfs.

#mount -t ramfs ramfs /mnt/js
#exportfs -v -o rw,sync,no_subtree_check localhost:/mnt/js
exporting localhost:/mnt/js
exportfs: Warning: /mnt/js does not support NFS export.."

I think this is because trail export '-test-client-' with fsid 1 fails
in case of ramfs. Iam not sure about the differences between ramfs and
tmpfs but, "df -h" lists the tmpfs mounts while listing ramfs one. Not
sure whether this has something to do with this behaviour.

It would help if we report the same warning message while exporting
ramfs also.

Also, http://nfs.sourceforge.net/#faq_c6 needs an update?

Thanks,

-- 
Suresh Jayaraman
