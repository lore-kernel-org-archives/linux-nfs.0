Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:26822 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588Ab2K0LJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 06:09:32 -0500
Subject: [PATCH 0/2] NFSd: NFSv4 state - lease and grace times per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 27 Nov 2012 14:11:38 +0300
Message-ID: <20121127111007.10271.54338.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This two variables are parts of NFSv4 state and should be containerized too.

The following series implements...

---

Stanislav Kinsbursky (2):
      nfsd: make NFSv4 lease time per net
      nfsd: make NFSv4 grace time per net


 fs/nfsd/netns.h        |    3 +++
 fs/nfsd/nfs4callback.c |    8 +++++---
 fs/nfsd/nfs4state.c    |   18 +++++++-----------
 fs/nfsd/nfs4xdr.c      |    4 +++-
 fs/nfsd/nfsctl.c       |    9 +++++++--
 fs/nfsd/nfsd.h         |    3 ---
 6 files changed, 25 insertions(+), 20 deletions(-)

