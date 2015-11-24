Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43502 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233AbbKXRSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 12:18:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/5] fix nfs server handling of principal names
Date: Tue, 24 Nov 2015 12:18:12 -0500
Message-Id: <1448385497-23737-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Thanks to James Ralston for helping debug a problem with the server's
handling of kerberos principal names, which could cause 4.1 mount
failures when using Active Directory.

Along the way I noticed another bug and some opportunities for minor
cleanup.

--b.

J. Bruce Fields (5):
  svcrpc: move some initialization to common code
  nfsd: helper for dup of possibly NULL string
  nfsd: minor consolidation of mach_cred handling code
  nfsd: fix unlikely NULL deref in mach_creds_match
  nfsd4: fix gss-proxy 4.1 mounts for some AD principals

 fs/nfsd/nfs4state.c                  | 55 +++++++++++++++++++++++++++---------
 include/linux/sunrpc/svcauth.h       |  9 +++++-
 net/sunrpc/auth_gss/gss_rpc_upcall.c |  3 ++
 net/sunrpc/svcauth.c                 |  2 ++
 net/sunrpc/svcauth_unix.c            |  8 ------
 5 files changed, 55 insertions(+), 22 deletions(-)

-- 
2.5.0

