Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:43088 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757373Ab1LWOyg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Dec 2011 09:54:36 -0500
Subject: [PATCH 0/3] SUNPRC: redundant XPT_CHNGBUF set removed
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 23 Dec 2011 18:53:23 +0300
Message-ID: <20111223145145.847.46221.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cleanup path set

The following series consists of:

---

Stanislav Kinsbursky (3):
      SUNPRC: remove marking service temporary sockets with XPT_CHNGBUF
      Lockd: don't mark freshly created sockets with XPT_CHNGBUF
      NFS: don't mark freshly created callback sockets with XPT_CHNGBUF


 fs/lockd/svc.c       |    1 -
 fs/nfs/callback.c    |    2 --
 net/sunrpc/svcsock.c |    2 --
 3 files changed, 0 insertions(+), 5 deletions(-)

-- 
Signature
