Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A5B2ECDE44
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 23:24:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E246320869
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 23:24:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="OYLVgtoo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E246320869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728856AbeJ0IDN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 04:03:13 -0400
Received: from mail-ed1-f67.google.com ([209.85.208.67]:39827 "EHLO
        mail-ed1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728839AbeJ0IDN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 04:03:13 -0400
Received: by mail-ed1-f67.google.com with SMTP id e5-v6so2645951eds.6
        for <linux-nfs@vger.kernel.org>; Fri, 26 Oct 2018 16:24:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=rasmusvillemoes.dk; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JEBobtHg1qgbOc630FYStYv8aN4/HB7o15k1W7ldVoc=;
        b=OYLVgtooq7ObuotGpIxgk8rxockKE76sRnIUI5hhbNEPQr5sYwOuDQ6Z8jJ1Y8Wukq
         LlOfv5pwxHVPPX8UWCN9yb417DGJ1PuPKzpY5wN8mTRM1jnj3Mnzuhx20ppRJ1jsUvQs
         H8Mez81Q0oVN6ipJU9vEY3h/PnfEABbRlQtNw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=JEBobtHg1qgbOc630FYStYv8aN4/HB7o15k1W7ldVoc=;
        b=quoNmZyXFsFU38rk57IbTkchVPlArxIJ8sYAO9D92UsXgOBnlqqO3xEVT59JMR1N5T
         5SplLwcoyfxn6ad7DD2SpXKSeEga7Et4zmKemyWLJHacBNtOtxKWRwdgEPJ2jwcNzEEW
         hCkGYEzJtjzJ1cF+gjawDfgmlo54fnFQ/MFnUa+xRYgVJkF2ZRPvnfzyRGynPtT8KUhb
         7Jc3rQN38nDkyF7Xs9FOxVmCJNfm9dF2fE2a4f7lf0B2ZqhlmxWB/uorgtyTGoNGbEF9
         hDgvx8zCjsSGwonxr7ETmPntkM8ZMKPIV2G+JgnWkPVGB8XipieB/M4vCr1xLSS4/agF
         qtbA==
X-Gm-Message-State: AGRZ1gLBo+9EFFS46jetawlcVM1j1vJfbngwSnrxBR+kt1kFz4w4jIXn
        zUyt2fBMcfk/nMVIXfnL+P0DxA==
X-Google-Smtp-Source: AJdET5en4qW4GcEmqKcIU6ys6vzhrxNJTPyQnLSiny8uDtCWsXC+TwfPcq7Q5NH36j9AAG+hsSQXMw==
X-Received: by 2002:a17:906:2111:: with SMTP id 17-v6mr3604087ejt.206.1540596252659;
        Fri, 26 Oct 2018 16:24:12 -0700 (PDT)
Received: from prevas-ravi.waoo.dk (dhcp-5-186-114-252.cgn.ip.fibianet.dk. [5.186.114.252])
        by smtp.gmail.com with ESMTPSA id o13-v6sm3986746edc.95.2018.10.26.16.24.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 16:24:11 -0700 (PDT)
From:   Rasmus Villemoes <linux@rasmusvillemoes.dk>
To:     Kees Cook <keescook@chromium.org>,
        Andrew Morton <akpm@linux-foundation.org>
Cc:     linux-kernel@vger.kernel.org,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        linux-hwmon@vger.kernel.org,
        Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>,
        "Steven Rostedt (VMware)" <rostedt@goodmis.org>,
        Jean Delvare <jdelvare@suse.com>,
        Guenter Roeck <linux@roeck-us.net>
Subject: [RFC PATCH 0/7] runtime format string checking
Date:   Sat, 27 Oct 2018 01:24:02 +0200
Message-Id: <20181026232409.16100-1-linux@rasmusvillemoes.dk>
X-Mailer: git-send-email 2.19.1.6.gbde171bbf5
In-Reply-To: <20171108223020.24487-1-linux@rasmusvillemoes.dk>
References: <20171108223020.24487-1-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is a resurrection of something I sent out about a year ago. In
the relatively few places where we use a non-literal as format string,
we can annotate the source with a fmtcheck() call that will (a) at
build time, allow the compiler to check the variadic arguments against
the template, and (b) at runtime, check that the format specifiers
present in the actual format string match those in the template (and
if not, WARN and use the template to ensure runtime type safety).

Finding places to annotate is just

  make -j8 KCFLAGS='-Wformat-nonliteral'

So far, in about half the places I looked, one might as well get
completely rid of the non-literal format string. Patches 5,6,7 are
some examples of where one might add fmtcheck() calls. I don't think
we can get to a state where we can unconditionally add
-Wformat-nonliteral to the build, but I think there's a lot of
low-hanging fruit.

This is on top of Miguel's compiler attributes series [1], which I
hope will land in mainline soon.

[1] https://github.com/ojeda/linux.git tags/compiler-attributes-for-linus-4.20-rc1

Rasmus Villemoes (7):
  compiler_attributes.h: add __attribute__((format_arg)) shorthand
  lib/vsprintf.c: add fmtcheck utility
  kernel.h: implement fmtmatch() wrapper around fmtcheck()
  lib/test_printf.c: add a few fmtcheck() test cases
  kernel/kthread.c: do runtime check of format string in
    kthread_create_on_cpu()
  nfs: use fmtcheck() in root_nfs_data
  drivers: hwmon: add runtime format string checking

 drivers/hwmon/hwmon.c               |  3 +-
 fs/nfs/nfsroot.c                    |  2 +-
 include/linux/compiler_attributes.h | 13 ++++++
 include/linux/kernel.h              | 25 +++++++++++
 kernel/kthread.c                    |  4 +-
 lib/Kconfig.debug                   |  9 ++++
 lib/test_printf.c                   | 43 +++++++++++++++++++
 lib/vsprintf.c                      | 65 +++++++++++++++++++++++++++++
 8 files changed, 160 insertions(+), 4 deletions(-)

-- 
2.19.1.6.gbde171bbf5

