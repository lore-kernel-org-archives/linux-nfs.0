Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f176.google.com ([209.85.217.176]:54901 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759672AbbBIXpM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 18:45:12 -0500
Received: by mail-lb0-f176.google.com with SMTP id u10so19712610lbd.7
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 15:45:10 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Andrew Morton <akpm@linux-foundation.org>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Subject: [PATCH v3 0/3] Two printf fixes
Date: Tue, 10 Feb 2015 00:44:47 +0100
Message-Id: <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both %pE and %ph are unusable in kasprintf(), since the occurrence of
either will trigger an oops during the first vsnprintf call where
kasprintf tries to find the correct size to allocate. These oopses
could be papered over with somewhat smaller patches than these, but
then the return value from vsnprintf would still not reflect the
actual size needed. For %pE, this requires a change of semantics of
string_escape_mem and hence an annoyingly large diffstat.

Not changed in v3: The test_string_escape_nomem helper is still gone,
and the overflow test done in test_string_escape. I also kept the "if
(out + 1 < end)" conditionals that way.

Changed in v3:

* Add Andy's ack to 1/3.

* Ensure that string_escape_mem doesn't output partial escape
  sequences after 2/3, while still preparing for it to do exactly that
  in 3/3.

* Leave the return value of string_escape_mem as int.

v2: Suggestions from Andy Shevchenko:

* Simpler fix of hex_string().

* The string_escape_mem change is split in two, 2/3 updating the
  internal helpers and 3/3 then changing the external interface.


Rasmus Villemoes (3):
  lib/vsprintf.c: Fix potential NULL deref in hex_string
  lib/string_helpers.c: Refactor string_escape_mem
  lib/string_helpers.c: Change semantics of string_escape_mem

 include/linux/string_helpers.h |   8 +-
 lib/string_helpers.c           | 189 ++++++++++++++++-------------------------
 lib/test-string_helpers.c      |  35 ++++----
 lib/vsprintf.c                 |  24 ++++--
 net/sunrpc/cache.c             |   8 +-
 5 files changed, 113 insertions(+), 151 deletions(-)

-- 
2.1.3

