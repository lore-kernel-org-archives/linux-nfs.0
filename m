Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmpop108.cox.net ([68.230.240.50]:54230 "EHLO
	eastrmpop108.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259Ab1BGUEF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Feb 2011 15:04:05 -0500
Received: from eastrmimpo02.cox.net ([68.1.16.120])
          by eastrmmtao102.cox.net
          (InterMail vM.8.01.04.00 201-2260-137-20101110) with ESMTP
          id <20110207195545.DDZ2814.eastrmmtao102.cox.net@eastrmimpo02.cox.net>
          for <linux-nfs@vger.kernel.org>; Mon, 7 Feb 2011 14:55:45 -0500
Received: from adept.internal.excfb.com (localhost.localdomain [127.0.0.1])
	by adept.internal.excfb.com (8.14.4/8.14.4) with ESMTP id p17JuA0T013237
	for <linux-nfs@vger.kernel.org>; Mon, 7 Feb 2011 13:56:10 -0600
Received: (from tdh@localhost)
	by adept.internal.excfb.com (8.14.4/8.14.4/Submit) id p17Ju9Nd013235
	for linux-nfs@vger.kernel.org; Mon, 7 Feb 2011 13:56:09 -0600
Date: Mon, 7 Feb 2011 13:56:09 -0600
From: Tom Haynes <tdh@excfb.com>
To: linux-nfs@vger.kernel.org
Subject: Debugging mount failure with netgroup
Message-ID: <20110207195609.GA13225@adept.internal.excfb.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trying to mount:

[root@wont ~]# mount -o vers=3,hard,intr adept:/fooper /t/adept
mount.nfs: access denied by server while mounting adept:/fooper
[root@wont ~]# uname -a
Linux wont.internal.excfb.com 2.6.35.10-74.fc14.x86_64 #1 SMP Thu Dec 23 16:04:50 UTC 2010 x86_64 x86_64 x86_64 GNU/Linux
[root@wont ~]# showmount -e adept
Export list for adept:
/fooper @adeptya

The server tells us:

[root@adept log]# more /etc/exports 
/fooper   @titan(rw)
[root@adept log]# vi /etc/exports 
[root@adept log]# more /etc/exports 
/fooper   @adeptya(rw)
[root@adept log]# exportfs -au
[root@adept log]# exportfs -a
[root@adept log]# exportfs
/fooper       	@adeptya
[root@adept log]# ypmatch adeptya netgroup
(adept,,) (adept.internal.excfb.com,,) (wont,,) (wont.internal.excfb.com,,)
[root@adept log]# host wont.internal.excfb.com
wont.internal.excfb.com has address 192.168.2.105
[root@adept log]# host 192.168.2.105
105.2.168.192.in-addr.arpa domain name pointer wont.internal.excfb.com.
[root@adept log]# tail messages
Feb  7 13:33:41 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
Feb  7 13:34:58 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
Feb  7 13:36:02 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
Feb  7 13:36:32 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
Feb  7 13:37:14 adept mountd[13050]: authenticated mount request from 192.168.2.105:698 for /fooper (/fooper)
Feb  7 13:38:12 adept mountd[13050]: authenticated unmount request from 192.168.2.105:657 for /fooper (/fooper)
Feb  7 13:39:06 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
Feb  7 13:43:52 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
Feb  7 13:45:24 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
Feb  7 13:48:17 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host

The success at 13:37:14 was from when I changed the export to:

[root@adept ~]# exportfs
/fooper       	192.168.2.0/255.255.255.0

to verify that NFS was working. At that point I was able to mount,
create a file, etc.

Oh yeah, the NFS server is also the NIS and DNS server, so there
shouldn't be any connectivity issues.

What can I do to further triage this?


Thanks!




-- 
Tom Haynes
ex-cfb
