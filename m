Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:38469 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751786Ab0ITQQo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 12:16:44 -0400
Date: Mon, 20 Sep 2010 12:16:43 -0400
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfs-utils: Fix source code character encoding
Message-ID: <20100920161643.GA18339@merit.edu>
References: <20100920153714.2604.50581.stgit@ellison.1015granger.net>
 <20100920153957.2604.35091.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100920153957.2604.35091.stgit@ellison.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:

  Minor clean up.
  
  Most modern Linux distributions set UTF-8 locales.  Standardize the
  character encoding of source files on UTF-8, to squelch vim com-
  plaints.
  
  I probably missed a few spots.

Good catch.  My editor doesn't complain but it doesn't display them
correctly either.  There's also utils/spnfsd/cfg.[ch] on the pnfs branch.
Someone should patch these before the branch gets merged.  I'll put this on
my list if no one beats me to it.
