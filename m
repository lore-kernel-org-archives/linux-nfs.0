Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f43.google.com ([209.85.215.43]:33209 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756812AbbCCXU5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 18:20:57 -0500
Received: by lamq1 with SMTP id q1so17757331lam.0
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2015 15:20:55 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Andrew Morton <akpm@linux-foundation.org>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Subject: [PATCH v4 0/3] Two printf fixes
Date: Wed,  4 Mar 2015 00:20:32 +0100
Message-Id: <1425424836-17947-1-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both %pE and %ph are unusable in kasprintf(), since the occurrence of
either will trigger an oops during the first vsnprintf call where
kasprintf tries to find the correct size to allocate. These oopses
could be papered over with somewhat smaller patches than these, but
then the return value from vsnprintf would still not reflect the
actual size needed. For %pE, this requires a change of semantics of
string_escape_mem and hence an annoyingly large diffstat.

v4: Also update fs/proc/array.c, factor overflow test into separate
helper, minor stylistic changes.

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

 fs/proc/array.c                |   4 +-
 include/linux/string_helpers.h |   8 +-
 lib/string_helpers.c           | 193 +++++++++++++++++------------------------
 lib/test-string_helpers.c      |  38 ++++----
 lib/vsprintf.c                 |  24 +++--
 net/sunrpc/cache.c             |   8 +-
 6 files changed, 127 insertions(+), 148 deletions(-)

-- 
2.1.3

