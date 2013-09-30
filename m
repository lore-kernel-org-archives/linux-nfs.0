Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49972 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756014Ab3I3WL3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 18:11:29 -0400
Date: Mon, 30 Sep 2013 18:11:27 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: Kernel NFS List <linux-nfs@vger.kernel.org>,
        "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>
Subject: Re: pynfs updates
Message-ID: <20130930221126.GD26382@fieldses.org>
References: <003301cebe09$5bf81090$13e831b0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <003301cebe09$5bf81090$13e831b0$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 30, 2013 at 02:17:43PM -0400, Frank Filz wrote:
> Bruce,
> 
> Please pull the following branch that contains the pynfs updates I made at
> BAT:
> 
> https://github.com/ffilz/pynfs/commits/master

Thanks!  A few questions:

	- "4.1 server tests: Fix some exception handling": could you
	  include in the changelog and explanation of what problem this
	  fixes?  (And ditto, maybe, for the following commit?)

	- "Fix SEQ9d to work in home directory instead of root": did you
	  intend to include the chunk in nfs4.1/nfs4lib.py?  It looks
	  irrelevant.

	- "Add two SECINFO_NO_NAME tests for SECINFO_STYLE4_PARENT":
		- SECNN3: is / required to have no parent?  (I'd assumed
		  here that it would also be OK to follow the convention
		  that / is its own parent, but I'll admit to not having
		  thought about this much.)
		- SECNN4: is env.home necessarily unequal to "/"?  Would
		  seem better to do the lookup in a subdirectory just to
		  be certain.

--b.
