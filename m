Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:5542 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134Ab2KZNOJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 08:14:09 -0500
Subject: [PATCH 0/2] nfsd: containerise NFSv4 recovery state
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 26 Nov 2012 16:16:18 +0300
Message-ID: <20121126131404.8822.65870.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set makes rec_file and in_grace global static variables allocated
per network namespace.
Both of them are a part of client tracking engine, which is containerised
already.

The following series implements...

---

Stanislav Kinsbursky (2):
      nfsd: recovery - make rec_file per net
      nfsd: recovery - make in_grace per net


 fs/nfsd/netns.h       |    3 ++
 fs/nfsd/nfs4recover.c |   79 ++++++++++++++++++++++++-------------------------
 2 files changed, 42 insertions(+), 40 deletions(-)

