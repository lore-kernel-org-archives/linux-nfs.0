Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:45924 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771Ab1JZD1E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2011 23:27:04 -0400
Message-ID: <4EA77E00.6090002@panasas.com>
Date: Tue, 25 Oct 2011 20:26:56 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <benny@tonian.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Final disposition of the pNFSD tree
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny what is the state of the PNFSD tree? Can you sign on it's stability for
a large scale testing or should I be using the nfsd-3.1 based tree?

As far as I could see. The last tree that did not have nfsd-3.2 
new state patches was pnfs-all-3.1-rc8-2011-10-06.

pnfs-all-3.1-rc9-2011-10-17 Had some of them, but I guess not the major
ones. (Should I test with this one?)

And pnfs-all-3.1-rc10-2011-10-18 (pnfs/pnfs-all-latest) has all of them.
Is it stable?

My last heavy testing was actually on pnfs-all-3.1-rc6-2011-09-20. If I diff
that with pnfs-all-3.1-rc8-2011-10-06 on fs/nfsd/ I can still see huge amount
of for-nfsd-v3.2 changes. I know you have found some bugs, So I guess I'll stick
with the v3.1-rc6-pnfs based tree for the Server and v3.1 release Kernel + ore-v3.2
patches.

Do you think you will release a 3.1 based pnfs tree that is completely based on
the v3.1-nfsd version and the old pnfs tree, without any for-v3.2-pnfsd patches?

Thanks
Boaz
