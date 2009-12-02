From: Kelly Anderson <kelly-lACMDn57031vQQPgy9v2K1aTQe2KTcn/@public.gmane.org>
Subject: [NFS] Nfs4 over Ipv6 patch to fix ipv6 subnetting in /etc/exports
Date: Wed, 02 Dec 2009 15:50:49 -0700
Message-ID: <4B16EF49.8040106@silka.with-linux.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060700060003030603020707"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:41374 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754349AbZLBXIe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2009 18:08:34 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NFyJL-0001lL-GZ
	for linux-nfs@vger.kernel.org; Thu, 03 Dec 2009 10:08:39 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060700060003030603020707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hopefully this mail gets through to someone who can apply this patch to 
NfsUtils git.

I have been trying on and off for a year or so to get Nfs4 mounts to 
work over Ipv6.  Finally with the latest git it seemed to work.  That 
is, it worked when you wildcard all internet addresses.

/home/nfs4  *(rw,fsid=0,sync,root_squash,no_all_squash,no_subtree_check)

Unfortunately subnetting wasn't working, so I dug into the code to 
figure out why.  It turned out that it was something simple (once I 
managed to get my head into the code).  I've attached a patch against 
the current git that fixes it.  With the patch applied, ipv6 subnetting 
such as the following works.

/home/nfs4  
2001:470:b:3e::/64(rw,fsid=0,sync,root_squash,no_all_squash,no_subtree_check)
/home/nfs4  
2001:470:b:3e::/ffff:ffff:ffff:ffff::(rw,fsid=0,sync,root_squash,no_all_squash,no_subtree_check)

Regards,

Kelly Anderson

--------------060700060003030603020707
Content-Type: text/x-patch;
 name="NfsUtils-check_subnet_v6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="NfsUtils-check_subnet_v6.patch"

--- ./support/export/client.c.orig	2009-11-30 08:06:18.000000000 -0700
+++ ./support/export/client.c	2009-12-02 15:16:55.361725808 -0700
@@ -505,16 +505,16 @@ check_subnet_v6(const struct sockaddr_in
 			continue;
 
 		if (mask_match(address->sin6_addr.s6_addr32[0],
-				sin6->sin6_addr.s6_addr[0],
+				sin6->sin6_addr.s6_addr32[0],
 		      		mask->sin6_addr.s6_addr32[0]) &&
 		    mask_match(address->sin6_addr.s6_addr32[1],
-				sin6->sin6_addr.s6_addr[1],
+				sin6->sin6_addr.s6_addr32[1],
 		      		mask->sin6_addr.s6_addr32[1]) &&
 		    mask_match(address->sin6_addr.s6_addr32[2],
-				sin6->sin6_addr.s6_addr[2],
+				sin6->sin6_addr.s6_addr32[2],
 		      		mask->sin6_addr.s6_addr32[2]) &&
 		    mask_match(address->sin6_addr.s6_addr32[3],
-				sin6->sin6_addr.s6_addr[3],
+				sin6->sin6_addr.s6_addr32[3],
 		      		mask->sin6_addr.s6_addr32[3]))
 			return 1;
 	}

--------------060700060003030603020707
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Join us December 9, 2009 for the Red Hat Virtual Experience,
a free event focused on virtualization and cloud computing. 
Attend in-depth sessions from your desk. Your couch. Anywhere.
http://p.sf.net/sfu/redhat-sfdev2dev
--------------060700060003030603020707
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--------------060700060003030603020707--


