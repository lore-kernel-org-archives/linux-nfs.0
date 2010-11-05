Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4348 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753984Ab0KEXMm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Nov 2010 19:12:42 -0400
From: Joe Perches <joe@perches.com>
To: Jiri Kosina <trivial@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        cluster-devel@redhat.com, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Subject: [PATCH 0/7] Convert sprintf_symbol uses to %p[Ss]
Date: Fri,  5 Nov 2010 16:12:33 -0700
Message-Id: <1288998760-11775-1-git-send-email-joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Remove unnecessary declarations of temporary buffers.
Use %pS or %ps as appropriate.
Minor reformatting in a couple of places.

Compiled, but otherwise untested.

Joe Perches (7):
  arch/arm/kernel/traps.c: Convert sprintf_symbol to %pS
  arch/x86/kernel/pci-iommu_table.c: Convert sprintf_symbol to %pS
  fs/gfs2/glock.c: Convert sprintf_symbol to %pS
  fs/proc/base.c kernel/latencytop.c: Convert sprintf_symbol to %ps
  kernel/lockdep_proc.c: Convert sprintf_symbol to %pS
  mm: Convert sprintf_symbol to %pS
  net/sunrpc/clnt.c: Convert sprintf_symbol to %ps

 arch/arm/kernel/traps.c           |    5 +----
 arch/x86/kernel/pci-iommu_table.c |   18 ++++--------------
 fs/gfs2/glock.c                   |   15 +++++++--------
 fs/proc/base.c                    |   22 ++++++++--------------
 kernel/latencytop.c               |   23 +++++++++--------------
 kernel/lockdep_proc.c             |   16 ++++++----------
 mm/slub.c                         |   11 ++++-------
 mm/vmalloc.c                      |    9 ++-------
 net/sunrpc/clnt.c                 |   12 ++----------
 9 files changed, 43 insertions(+), 88 deletions(-)

-- 
1.7.3.2.146.gca209

