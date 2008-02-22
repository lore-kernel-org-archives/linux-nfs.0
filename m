From: Rajesham Gajjela <rajeshamg@yahoo.com>
Subject: [NFS] ipv6 support on nfsv2/3 server support for linux-2.6.12-5
Date: Fri, 22 Feb 2008 14:18:01 -0800 (PST)
Message-ID: <833422.40516.qm@web30502.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: rajeshamg@yahoo.com
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:46938 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936514AbYBVWSZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2008 17:18:25 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JSgDl-000789-6y
	for linux-nfs@vger.kernel.org; Sat, 23 Feb 2008 09:18:21 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I wanted to test IPV6 support on nfs 
(nfs v2 and v3) for linux-2.6.12-5.
This is for nfs server side. I followed guideline at:
http://nfsv4.bullopensource.org/patches/nfs_ipv6-4/IPv6-test-plan.php

I was trying to pull in the CITI patches and apply to
2.6.12-5. For ipv6+nfsv3/2+nfs server, which patch
should I apply from "linux-2.6.12-rc6-001-NFS_ALL.dif"

and "linux-2.6.12-rc6-CITI_NFS4_ALL-1.dif" ?. I am
tending to say it must be
"linux-2.6.12-rc6-001-NFS_ALL.dif", but I am not
pretty
sure.

Thanks in advance for your help.

Please cc me, I am not part of this mailing list.
Rajesham


      ____________________________________________________________________________________
Never miss a thing.  Make Yahoo your home page. 
http://www.yahoo.com/r/hs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

