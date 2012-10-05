Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp4-g21.free.fr ([212.27.42.4]:51473 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756721Ab2JEQs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Oct 2012 12:48:58 -0400
Received: from harpe.intellique.com (unknown [82.225.196.72])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 9BEBB4C8119
	for <linux-nfs@vger.kernel.org>; Fri,  5 Oct 2012 18:48:52 +0200 (CEST)
Date: Fri, 5 Oct 2012 18:48:56 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: linux-nfs@vger.kernel.org
Subject: NFS daemon statistics in /proc/net/rpc/nfsd
Message-ID: <20121005184856.4472a72e@harpe.intellique.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I noticed a long time ago that the thread information in
/proc/net/rpc/nfsd isn't updated anymore since somewhere between the
2.629 (information present) and 2.6.32 (information missing). It's
quite easy to check:

# grep th /proc/net/rpc/nfsd
th 8 0 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000

All values are perpetually at zero. Unsurprising, because the
update_thread_usage function in fs/nfsd/nfssvc.c isn't present anymore.

I can't find any information about why this information was dropped; I
personnally found it useful to tune properly the number of nfs threads
on loaded servers. Did it use up too many resources? In that case,
could there be a mechanism to enable or disable therad information
gathering, for instance through writing to some /proc file?

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
