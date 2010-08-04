Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:34958 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757462Ab0HDL5t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 07:57:49 -0400
Date: Wed, 4 Aug 2010 07:57:46 -0400
From: Jim Rees <rees@umich.edu>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] Give hostname.c more support for IPv6
Message-ID: <20100804115746.GA16993@merit.edu>
References: <20100804064553.16641.92857.stgit@localhost.localdomain>
 <20100804064945.16641.71097.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100804064945.16641.71097.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Neil Brown wrote:

  +	if (inet_pton(AF_INET, paddr, &sin.sin_addr) == 0 &&
  +	    inet_pton(AF_INET6, paddr, &sin.sin_addr) == 0)
   		return NULL;

Having converted a few apps myself, I wish there were an equivalent to
inet_pton that instead of taking an AF argument, would return the AF that it
found.  Then you could do the above in a single call.
