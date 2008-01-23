From: Sev Binello <sev-IGkKxAqZmp0@public.gmane.org>
Subject: [NFS] nfs_statfs: statfs error = 512 ?
Date: Wed, 23 Jan 2008 10:57:32 -0500
Message-ID: <479763EC.3090601@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:33700 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751397AbYAWP6v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2008 10:58:51 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JHi00-00078N-PZ
	for linux-nfs@vger.kernel.org; Thu, 24 Jan 2008 02:58:48 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi -

  Can anyone explain the following error message...

         Jan 22 11:03:28 acnmcr5s kernel: nfs_statfs: statfs error = 512

    We seem to be getting it way too frequently,
    and was wondering if it was correlated to systems becoming 
unresponsive at times.
   
     Out clients are running 2.6.9-55.0.9.ELsmp, Redhat WS4 U5
     while nfs servers are still at  2.4.21-47.ELsmp Rhat WS 3 U8
     We are using UDP.

Thanks
-Sev

-- 

Sev Binello
Brookhaven National Laboratory
Upton, New York
631-344-5647
sev-IGkKxAqZmp0@public.gmane.org


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

