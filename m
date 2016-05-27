Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.sciencehorizons.net ([71.41.210.147]:26887 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S932168AbcE0D3s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2016 23:29:48 -0400
Date: 26 May 2016 23:29:46 -0400
Message-ID: <20160527032946.12751.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
To: bfields@fieldses.org, linux@horizon.com, linux@sciencehorizons.net
Subject: Re: [PATCH RESEND 03/10] <linux/sunrpc/svcauth.h>: Define hash_str() in terms of hash_string()
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org
In-Reply-To: <20160527015605.7083.qmail@ns.sciencehorizons.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Okay, it's now okay to re-pull.  I renamed mine to hashlen_string(),
since that's what it returns (the hash and the length), which both
solves the problem,and is frankly a better name.

Thank you for prodding me to wade through the GCC 6 warning
spam.  Thre were some problems hiding there.

I discovered that adding #include <linux/bug.h> breaks the tools.perf
build.  It makes local copies of some kernel headers under control of
a MANIFEST file, and I can't be arsed to figure it out.

So I deleted the BUILD_BUG_ON entirely, and it's now (finally!) finished
an allyesconfig build without any warnings that look new.
