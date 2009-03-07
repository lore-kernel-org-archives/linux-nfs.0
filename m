From: howard chen <howachen@gmail.com>
Subject: [NFS] Performance advise in intranet
Date: Sat, 7 Mar 2009 17:44:57 +0800
Message-ID: <b66ddc900903070144w6bb83d84r878aebe702bf57d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:39225 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752776AbZCGJrb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Mar 2009 04:47:31 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Lft7w-000616-57
	for linux-nfs@vger.kernel.org; Sat, 07 Mar 2009 20:47:28 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Consider I have using NFS in intranet enviornment, network is fast
(Gigabit) and stable/reliable.

My NFS server is connected to 6 hosts running as web server, the web
site files are stored in NFS.

I want to find some ways to enhance to performance

My Case:
a. Both read and write are intensive
b. File are small, normally less than 100KB
c. Server using NFS3, NFS getattr is around 40%

So..

1. Is setting of a a larger MTU always help? Some people say setting
very large MTU (e.g. 9000)  can help performance boost in giga
ethnernet.

2. Is using NFS4 help?


Thanks.

------------------------------------------------------------------------------
Open Source Business Conference (OSBC), March 24-25, 2009, San Francisco, CA
-OSBC tackles the biggest issue in open source: Open Sourcing the Enterprise
-Strategies to boost innovation and cut costs with open source participation
-Receive a $600 discount off the registration fee with the source code: SFAD
http://p.sf.net/sfu/XcvMzF8H
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

