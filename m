Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:54379 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaGNB5x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 21:57:53 -0400
Received: by mail-qa0-f47.google.com with SMTP id i13so2719733qae.6
        for <linux-nfs@vger.kernel.org>; Sun, 13 Jul 2014 18:57:52 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 0/7] sunrpc: sparse warning cleanups
Date: Sun, 13 Jul 2014 21:57:37 -0400
Message-Id: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes up all of the sparse warnings that I see when building
net/sunrpc. The only real substantive change is the second patch which
should fix the RCU handling for the gc_ctx field. That looks quite wrong
right now, though it may be that the refcounting and lifecycle of the
thing helps paper over it today.

There are still a few warnings that come from generic ipv6.h inlines.
I'll send a separate patch to the netdev folks to address those.

Trond, if these look OK then they should probably go via your tree as it
looks like you've already merged the gc_acceptor patches.

Jeff Layton (7):
  sunrpc: remove __rcu annotation from struct gss_cl_ctx->gc_gss_ctx
  sunrpc: fix RCU handling of gc_ctx field
  sunrpc: clean up endianness warnings in setup_token
  sunrpc: xdr_get_next_encode_buffer can be static
  sunrpc: clean up sparse endianness warnings in gss_krb5_seal.c
  sunrpc: clean up sparse endianness warnings in gss_krb5_wrap.c
  sunrpc: remove "ec" argument from encrypt_v2 operation

 include/linux/sunrpc/auth_gss.h       |  2 +-
 include/linux/sunrpc/gss_krb5.h       |  4 +--
 net/sunrpc/auth_gss/auth_gss.c        | 52 +++++++++++++++++++++++------------
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  9 ++----
 net/sunrpc/auth_gss/gss_krb5_seal.c   | 16 +++++------
 net/sunrpc/auth_gss/gss_krb5_wrap.c   | 10 +++----
 net/sunrpc/xdr.c                      |  3 +-
 7 files changed, 55 insertions(+), 41 deletions(-)

-- 
1.9.3

