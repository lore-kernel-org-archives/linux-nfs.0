Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49852 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853Ab3HANRZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 09:17:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/4] gss-proxy fixes for 3.11
Date: Thu,  1 Aug 2013 09:17:18 -0400
Message-Id: <1375363042-14440-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

These are few gss proxy bugfixes, two found during the original testing
that I mistakenly dropped, two more than I found during more recent
testing (the last a regression introduced in 3.11).

With these applied I can do a krb5 mount with either rpc.svcgssd or
gss-proxy.

I intend to submit them for 3.11.

--b.

J. Bruce Fields (4):
  svcrpc: fix gss_rpc_upcall create error
  svcrpc: fix gss-proxy xdr decoding oops
  svcrpc: fix kfree oops in gss-proxy code
  svcrpc: set cr_gss_mech from gss-proxy as well as legacy upcall

 net/sunrpc/auth_gss/gss_rpc_upcall.c |    3 +--
 net/sunrpc/auth_gss/gss_rpc_xdr.c    |    9 +++++----
 net/sunrpc/auth_gss/svcauth_gss.c    |    2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

-- 
1.7.9.5

