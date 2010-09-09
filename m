Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39083 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624Ab0IIP72 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 11:59:28 -0400
Date: Thu, 9 Sep 2010 11:58:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix race corrupting rpc upcall list
Message-ID: <20100909155835.GD8597@fieldses.org>
References: <20100828170953.GB5104@fieldses.org>
 <20100830175728.GA18764@fieldses.org>
 <20100907050142.GA14584@fieldses.org>
 <20100907051241.GB14584@fieldses.org>
 <20100907051336.GC14584@fieldses.org>
 <20100908220528.GD816@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100908220528.GD816@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 08, 2010 at 06:05:28PM -0400, J. Bruce Fields wrote:
> This happened during the pynfs DELEG9 test over krb5i, but I can't reproduce it
> reliably.

I was wrong, this isn't one of the delegation tests.

Running my default pynfs tests over krb5i a few times gets it in a few
minutes.

One factor may be that the callback address the pynfs client gives us is
0.0.0.0, which may be exercising an error path somewhere.

Anyway, I think I'm close to having this.

--b.
