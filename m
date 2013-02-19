Return-Path: linux-nfs-owner@vger.kernel.org
Received: from knm.org ([173.10.24.5]:45195 "EHLO knm.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933408Ab3BSXhM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 18:37:12 -0500
Received: from [192.168.20.65] (account mark@knm.org HELO shell)
  by knm.org (CommuniGate Pro SMTP 5.4.8 _community_)
  with ESMTPSA id 9040134 for linux-nfs@vger.kernel.org; Tue, 19 Feb 2013 15:36:25 -0700
Date: Tue, 19 Feb 2013 15:36:25 -0700 (MST)
From: Mark Lehrer <mark@tpsit.com>
To: linux-nfs@vger.kernel.org
Subject: Time to declare war on "stale nfs file handle"
Message-ID: <alpine.DEB.1.00.1302191507240.5816@shell>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I set up a pair of servers with DRBD, Pacemaker, and a virtual IP address.  I am mounting with NFSv3 & TCP.  The /etc/exports entry looks like this:

/nfs/volume01   *(rw,no_root_squash,fsid=778,insecure,async)


Failing between nodes seems to work well whenever I am testing it.
However, it seems that whenever I get into a situation where it has
been running for awhile and then I fail over, clients get the dreaded
Stale NFS file handle error on any open files.  In this case they are
VM images, which means lots of rebooting.

What should I do to prevent this error from happening?  I didn't have any
luck with exportfs -f.  Unfortunately this is a tough one to duplicate so
I am just trying to prepare a few tests for the next time it happens.

Also, I understand that NFSv4 is not quite as stateless as the older versions.
Will this kind of arrangement have potential data loss issues on NFSv4?

Thanks,
Mark

