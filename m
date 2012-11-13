Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:40875 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754564Ab2KMPpw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:45:52 -0500
Subject: [RFC PATCH 00/15] NFSd state containerization
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:48:13 +0300
Message-ID: <20121113154722.12577.57671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set is my first attempt to containerize NFSv4 state - i.e. make it
works in networks namespace context.
I admit, that some of this new code could be partially rewritten during future
NFSd containerization.
But the overall idea look more or less correct to me.
So, the main things here are:
1) making nfs4_client network namesapce aware.
2) Allocating all hashes (except file_hashtbl and reclaim_str_hashtbl) per
network namespace context on NFSd start (not init) and destroying on NFSd
state shutdown.
3) Allocating of reclaim_str_hashtbl on legacy tracker start and destroying on
legacy tracker stop.
4) Moving of client_lru and close_lru lists to per-net data.
5) Making lundromat network namespace aware.

The following series implements...

---

Stanislav Kinsbursky (15):
      nfsd: use service net instead of hard-coded net where possible
      nfsd: make nfs4_client network namespace dependent
      nfsd: make reclaim_str_hashtbl allocated per net
      nfsd: make conf_id_hashtbl allocated per net
      nfsd: make conf_str_hashtbl allocated per net
      nfsd: make unconf_str_hashtbl allocated per net
      nfsd: make unconf_str_hastbl allocated per net
      nfsd: make ownerstr_hashtbl allocated per net
      nfsd: make lockowner_ino_hashtbl allocated per net
      nfsd: make sessionid_hashtbl allocated per net
      nfsd: make client_lru list per net
      nfsd: make close_lru list per net
      nfsd: use service net instead of hard-coded init_net
      nfsd: pass nfsd_net instead of net to grace enders
      nfsd: make laundromat network namespace aware


 fs/nfsd/netns.h        |   41 ++++
 fs/nfsd/nfs4callback.c |    2 
 fs/nfsd/nfs4proc.c     |   13 +
 fs/nfsd/nfs4recover.c  |   85 +++++++--
 fs/nfsd/nfs4state.c    |  441 ++++++++++++++++++++++++++++--------------------
 fs/nfsd/state.h        |   11 +
 fs/nfsd/xdr4.h         |    2 
 7 files changed, 377 insertions(+), 218 deletions(-)

