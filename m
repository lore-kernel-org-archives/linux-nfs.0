From: "Murata, Dennis" <DENNIS.MURATA-jTGLxe6cr0Q@public.gmane.org>
Subject: extremely long time for exportfs to display
Date: Thu, 22 May 2008 17:41:05 -0700
Message-ID: <620E93B2E5CC3B46BD811165E3335B87011F8E9C@0461-its-exmb02.us.saic.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cpmx.mail.saic.com ([139.121.17.160]:52663 "EHLO
	cpmx.mail.saic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756027AbYEWAxP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2008 20:53:15 -0400
Received: from 0461-its-ieg01.us.saic.com ([139.121.20.253] [139.121.20.253]) by cpmx.mail.saic.com id BT-MMP-461601 for linux-nfs@vger.kernel.org; Thu, 22 May 2008 17:38:07 -0700
Received: from 0599-its-exbh01.us.saic.com ([139.121.20.253])
 by 0461-its-ieg01.us.saic.com (SMSSMTP 4.0.5.66) with SMTP id M2008052217380610369
 for <linux-nfs@vger.kernel.org>; Thu, 22 May 2008 17:38:06 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Very recently we have seen a very serious slowdown with the exportfs
command on a file server.  Usually the exportfs -r command or even just
the exportfs command to display the exported directories is very quick.
Now it can take 20 minutes to display the exported directories.
An strace shows a lookup at /etc/hosts, from yp, and from dns.  The
hosts lookup in /etc/nsswitch is files nis dns, so this is as expected,
the time it is taking is not.
The yp slave that the server is bound to seems to be having some
problems, could this be the issue?

Wayne
