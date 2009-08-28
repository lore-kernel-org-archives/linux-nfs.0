From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/5] NFSv4.1 DRC rewrite version 6
Date: Fri, 28 Aug 2009 18:42:48 -0400
Message-ID: <20090828224247.GG2462@fieldses.org>
References: <1251389264-3009-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39163 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712AbZH1Wmq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Aug 2009 18:42:46 -0400
In-Reply-To: <1251389264-3009-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 27, 2009 at 12:07:39PM -0400, andros@netapp.com wrote:
> 
> NFSv4.1 DRC Rewrite Version 6
> 
> These patches apply against git://linux-nfs.org/~bfields/linux: for-2.6.32
> branch and continue to rewrite the NFSv4.1 Sessions DRC. Besides some
> bug fixes:
> 
> 1) The bound on the fore channel per-session DRC size are rewritten.
> Instead of just using a maximum number of slots to bound the size,
> The server gives the client the number of ca_maxresponsesize_cached slots it
> requests bounded by NFSD_SLOT_CACHE_SIZE, NFSD_MAX_MEM_PER_SESSION and by
> nfsd_drc_max_mem. Do not allow more than NFSD_MAX_SLOTS_PER_SESSION.
> 
> This allows clients to tailor a session to usage.
> For example, an I/O session (READ/WRITE/COMMIT only) can have a much smaller
> ca_maxresponsesize_cached (for only WRITE/COMMIt compound responses) and a lot
> larger ca_maxresponses to service a large in-flight data window.
> 
> 2) the page-based DRC is replaced with a buffer based DRC with each
> slot table entry (struct nfsd4_slot + cache) allocated separately.
> This allocation prepares us for slot size re-negotiation via the SEQUENCE
> operation target and high slot id arguments.
> 
> Testing:
> 
> NFSv4.1 mount: pynfs tests - including the SEQUENCE replay cache tests.
> connectathon tests.

By the way, any hints on getting the 4.1 pynfs stuff running?

./nfs4.1/testserver.py pearlet1:/pynfs41test-root --rundeps --maketree
Traceback (most recent call last):
  File "./nfs4.1/testserver.py", line 38, in <module>
    import server41tests.environment as environment
  File "/root/pynfs41/nfs4.1/server41tests/environment.py", line 15, in <module>
    import rpc
  File "/root/pynfs41/rpc/__init__.py", line 1, in <module>
    from rpc import *
  File "/root/pynfs41/rpc/rpc.py", line 14, in <module>
    import security
  File "/root/pynfs41/rpc/security.py", line 11, in <module>
    import gssapi
ImportError: No module named gssapi

With the 4.0 pynfs I've always run

	/setup.py build_ext --inplace

before.  That gives me:

	This is currently broken...everything should already be set up.
	Just go into nfs4 and play.

The setup.py in nfs4.1/ complains about not finding xdrgen.

--b.
