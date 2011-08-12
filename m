Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:40195 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973Ab1HLAvb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 20:51:31 -0400
Message-ID: <4E44790A.8000106@panasas.com>
Date: Thu, 11 Aug 2011 17:51:22 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Grace period NEVER ends
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi

I have this weird problem with latest code. It is Benny's latest based
on 3.1-rc1 + linus/master of today + trond/linux-next.

For my testing I use a pNFS client mounted on localhost over a pNFS-nfsd on
the same machine. If I wait the 90 seconds or so and then mount all is well
but if I mount right away, or stop the server, then start and mount.
  The Grace period NEVER ends. On prints I see the server returning 100013
  continuously forever.

This is my usual test setup. In the passed it would wait the annoying grace
and continue. Now it never returns.

Before I start to bisect back to a good point I though I might ask for pointers
on what might have changed in this respect.

Thanks for any input
Boaz

