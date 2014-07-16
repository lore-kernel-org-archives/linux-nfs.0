Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:33338 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756244AbaGPKw3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 06:52:29 -0400
Received: by mail-qa0-f43.google.com with SMTP id w8so534283qac.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 03:52:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/5] sunrpc: sparse warning cleanups
Date: Wed, 16 Jul 2014 06:52:17 -0400
Message-Id: <1405507942-12256-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- reworked the gss_krb5_seal.c and gss_krb5_wrap.c patches to be less
  ugly
- squashed the setup_token patch into the gss_krb5_seal.c patch
- dropped patch to make xdr_get_next_encode_buffer static since Trond
  proposed the same fix

This fixes up all of the sparse warnings that I see when building
net/sunrpc. The only real substantive change is the second patch which
should fix the RCU handling for the gc_ctx field. That looks quite wrong
right now, though it may be that the refcounting and lifecycle of the
thing helps paper over it today.

There are still a few warnings that come from generic ipv6.h inlines.
I'll send a separate patch to the netdev folks to address those.

Trond, if these look OK then they should probably go via your tree as it
looks like you've already merged the gc_acceptor patches and the RCU
fixes in patch #2 should apply on top of those.

Jeff Layton (5):
  sunrpc: remove __rcu annotation from struct gss_cl_ctx->gc_gss_ctx
  sunrpc: fix RCU handling of gc_ctx field
  sunrpc: clean up sparse endianness warnings in gss_krb5_seal.c
  sunrpc: clean up sparse endianness warnings in gss_krb5_wrap.c
  sunrpc: remove "ec" argument from encrypt_v2 operation

 include/linux/sunrpc/auth_gss.h       |  2 +-
 include/linux/sunrpc/gss_krb5.h       |  4 +--
 net/sunrpc/auth_gss/auth_gss.c        | 52 +++++++++++++++++++++++------------
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  9 ++----
 net/sunrpc/auth_gss/gss_krb5_seal.c   | 28 +++++++++++--------
 net/sunrpc/auth_gss/gss_krb5_wrap.c   | 20 +++++++++-----
 6 files changed, 70 insertions(+), 45 deletions(-)

-- 
1.9.3

