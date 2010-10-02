Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:41857 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753462Ab0JBJEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Oct 2010 05:04:47 -0400
Date: Sat, 2 Oct 2010 05:04:44 -0400
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH] nfs4: fix channel attribute sanity-checks
Message-ID: <20101002090444.GB17395@merit.edu>
References: <20100525164224.GC4235@fieldses.org>
 <1274806624.11283.10.camel@heimdal.trondhjem.org>
 <20100525183223.GA6929@fieldses.org>
 <20100907223213.GA24707@fieldses.org>
 <20101002051949.GB18626@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101002051949.GB18626@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:

  +	 * Our requested max_ops is the minimum we need; we're not
  +	 * prepared to break up compounds into smaller pieces than that.
  +	 * So, not point even trying to continue if the server won't
  +	 * cooperate:

"not" should be "no".

Also seems odd that max_ops is actually the minimum, but I guess the code is
clear enough.
