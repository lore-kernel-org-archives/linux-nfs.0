From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 1 of 4] cpumask: add highest_possible_node_id
Date: Mon, 16 Oct 2006 21:10:51 +1000
Message-ID: <20061016111051.GH8568@sgi.com>
References: <1154669719.21040.2351.camel@hole.melbourne.sgi.com> <20061016035644.1c99ad9b.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, neilb@suse.de, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751505AbWJPLLJ@vger.kernel.org>
To: Paul Jackson <pj@sgi.com>
In-Reply-To: <20061016035644.1c99ad9b.pj@sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, Oct 16, 2006 at 03:56:44AM -0700, Paul Jackson wrote:
> This patch (of August 3, 2006) added (after a bit of fixing) a nodemask
> related routine to lib/cpumask.c.  Granted, there is no lib/nodemask.c,
> and Andrew suggested lib/cpumask.c.
> 
> But at least it should have added
> 
> 	#include <linux/nodemask.h>
> 
> to lib/cpumask.c, no?

Sure.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
