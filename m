Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:18294 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753110Ab2KZMTm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 07:19:42 -0500
Subject: [PATCH 0/5] nfsd: more NFSv4 state containerization
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 26 Nov 2012 15:21:49 +0300
Message-ID: <20121126121907.955.25349.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set makes NFSv4 state created and destroyed per net and thus
completes it's containerization (the only exceprtion is client_mutex, but this
one a hard nut to crack).

Note: patch set depend on previously sent patch named "nfsd4: remove state
lock from nfs4_state_shutdown".

The following series implements...

---

Stanislav Kinsbursky (5):
      nfsd: make client_lock per net
      nfsd: make delegations shutdown network namespace aware
      nfsd: cleanup NFSd state shutdown a bit
      nfsd: cleanup NFSd state start a bit
      nfsd: call state init and shutdown twice


 fs/nfsd/netns.h     |    3 +
 fs/nfsd/nfs4state.c |  137 +++++++++++++++++++++++++++++----------------------
 fs/nfsd/nfsd.h      |    4 +
 fs/nfsd/nfssvc.c    |   15 +++++-
 4 files changed, 99 insertions(+), 60 deletions(-)

