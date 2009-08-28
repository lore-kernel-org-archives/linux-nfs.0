Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48698 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbZH1XHZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Aug 2009 19:07:25 -0400
Date: Fri, 28 Aug 2009 19:07:27 -0400
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
Subject: Re: [pnfs] [PATCH 0/5] NFSv4.1 DRC rewrite version 6
Message-ID: <20090828230727.GI2462@fieldses.org>
References: <1251389264-3009-1-git-send-email-andros@netapp.com> <20090828224247.GG2462@fieldses.org> <20090828225608.GH2462@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20090828225608.GH2462@fieldses.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 28, 2009 at 06:56:08PM -0400, bfields wrote:
> On Fri, Aug 28, 2009 at 06:42:48PM -0400, J. Bruce Fields wrote:
> > On Thu, Aug 27, 2009 at 12:07:39PM -0400, andros@netapp.com wrote:
> > > 
> > > NFSv4.1 DRC Rewrite Version 6
> > > 
> > > These patches apply against git://linux-nfs.org/~bfields/linux: for-2.6.32
> > > branch and continue to rewrite the NFSv4.1 Sessions DRC. Besides some
> > > bug fixes:
> > > 
> > > 1) The bound on the fore channel per-session DRC size are rewritten.
> > > Instead of just using a maximum number of slots to bound the size,
> > > The server gives the client the number of ca_maxresponsesize_cached slots it
> > > requests bounded by NFSD_SLOT_CACHE_SIZE, NFSD_MAX_MEM_PER_SESSION and by
> > > nfsd_drc_max_mem. Do not allow more than NFSD_MAX_SLOTS_PER_SESSION.
> > > 
> > > This allows clients to tailor a session to usage.
> > > For example, an I/O session (READ/WRITE/COMMIT only) can have a much smaller
> > > ca_maxresponsesize_cached (for only WRITE/COMMIt compound responses) and a lot
> > > larger ca_maxresponses to service a large in-flight data window.
> > > 
> > > 2) the page-based DRC is replaced with a buffer based DRC with each
> > > slot table entry (struct nfsd4_slot + cache) allocated separately.
> > > This allocation prepares us for slot size re-negotiation via the SEQUENCE
> > > operation target and high slot id arguments.
> > > 
> > > Testing:
> > > 
> > > NFSv4.1 mount: pynfs tests - including the SEQUENCE replay cache tests.
> > > connectathon tests.
> > 
> > By the way, any hints on getting the 4.1 pynfs stuff running?
> 
> OK, solution seemed to be
> 
> 	cd gssapi
> 	python setup.py build_ext --inplace
> 
> But now almost everything fails.with SERVERFAULT.  Bah.

Does anyone have a list of which tests are expected to pass at this point?  If
I ask for "all" tests, I get "4 skipped, 103 failed, 0 warned, 26 passed--full
list available if anyone wants.  I seem to be passing connectathon tests
OK over 4.1.

--b.
