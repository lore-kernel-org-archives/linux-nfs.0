From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [NFS] I am seeing a problem with a storm of mount requests to a
	server	from a single client
Date: Fri, 20 Mar 2009 11:13:55 -0700
Message-ID: <1237572835.4048.9.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52564 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbZCTSQk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2009 14:16:40 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LkjGm-0006wc-3R
	for linux-nfs@vger.kernel.org; Sat, 21 Mar 2009 05:16:36 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It appears what is happening is the client sends a bunch of mounts for
different, but similar paths to the server. They all have the same XID.
A bunch of mounts with a different similarity have a 2nd XID. This
occurs on boot (the mounts are in fstab).

This sounds like it may be a problem with the entropy and the random
number generator. Does anyone have a suggestion on how to fix this?

The problem is occurring on various kernels such as 2.6.16, 2.6.18, and
2.6.9 and various versions of nfs-utils.

Thanks

Frank Filz



------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

