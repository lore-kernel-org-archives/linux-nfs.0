From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/4] NFSv4.1 DRC Rewrite Version 7
Date: Tue, 1 Sep 2009 23:12:20 -0400
Message-ID: <20090902031220.GB4028@fieldses.org>
References: <1251463504-3376-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41695 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764AbZIBDMS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 23:12:18 -0400
In-Reply-To: <1251463504-3376-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 28, 2009 at 08:45:00AM -0400, andros@netapp.com wrote:
> NFSv4.1 DRC Rewrite Version 7
> 
> These patches apply against git://linux-nfs.org/~bfields/linux: for-2.6.32
> branch and continue to rewrite the NFSv4.1 Sessions DRC.

All applied.  Thanks, Andy!--b.

> 
> Responded to comments on Version 6.
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
> 
> NFSv4.0 mount: connectathon tests.
> 
> -->Andy
> 
> 0001-nfsd41-bound-forechannel-drc-size-by-memory-usage.patch
> 0002-nfsd41-use-session-maxreqs-for-sequence-target-and.patch
> 0003-nfsd41-replace-nfserr_resource-in-pure-nfs41-respon.patch
> 0004-nfsd41-replace-page-based-DRC-with-buffer-based-DRC.patch
> 
