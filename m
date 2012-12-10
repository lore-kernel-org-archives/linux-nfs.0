Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:34683 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753740Ab2LJJSa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2012 04:18:30 -0500
Subject: [PATCH 0/7] nfsd: cleanup "init_net" references
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 10 Dec 2012 12:18:59 +0300
Message-ID: <20121210091832.8855.26672.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hard-coded "init_net" pointer is widely used in NFSd code.
This patch replaces "init_net" references by passed struct net pointer where
requied.
In future, proper network namespace context will be taken from NFSd file
system superblock private data or, where it's impossible, from current.

The following series implements...

---

Stanislav Kinsbursky (7):
      nfsd: use "init_net" for portmapper
      nfsd: pass net to nfsd_init_socks()
      nfsd: pass net to nfsd_startup() and nfsd_shutdown()
      nfsd: pass net to nfsd_create_serv()
      nfsd: pass net to nfsd_svc()
      nfsd: pass net to nfsd_set_nrthreads()
      nfsd: pass net to __write_ports() and down


 fs/nfsd/nfsctl.c |   27 +++++++++++++++------------
 fs/nfsd/nfsd.h   |    6 +++---
 fs/nfsd/nfssvc.c |   35 ++++++++++++++---------------------
 3 files changed, 32 insertions(+), 36 deletions(-)

