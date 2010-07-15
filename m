Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32806 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933810Ab0GOR3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 13:29:04 -0400
Date: Thu, 15 Jul 2010 13:28:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Marc Eshel <eshel@almaden.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Linux pNFS status meeting 07/15
Message-ID: <20100715172836.GC15126@fieldses.org>
References: <OF01D34025.9BF2DCCC-ON88257760.007510C5-88257760.007530DA@us.ibm.com>
 <20100714212928.GD8161@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100714212928.GD8161@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Notes:

Bruce:
	- nothing to report (transitioning to new hardware, etc.)

Trond:
	- did some fsync cleanup
	- bugfixes to handling of ERR_DELAY on sequence operations.
	- preparing for rpc changes required for migration.
		(some discusison here of idempotency problems on
		migration/reboot)

Benny:
	- Included Trond's delay/sequence fix
	(missed some additional discussion)

Andy:
	- simplification of write_pagelist/read_pagelist prototypes
	- making sure layouts removed on server reboot
	- looking at layout commit/reclaim issues in preparation for
	  discussion at Maastricht.
	- wants to rename some structures; will mail proposal to list.

Jim Rees:
	- bugfixing complex-volume patches; not ready to submit to Benny
	  quite yet.

Steved:
	- Discussion of RHEL prospects.  When will we have some pnfs
	  patches that are ready to review?  Concensus seems to be
	  2.6.36 will be too early.  Ricardo, Benny think 2.6.37
	  possible to finish up remaining work, squash changes into a
	  single cleaned-up patch series.  Trond reminds that adequate
	  time is required before merge window for review, especially
	  for large change.  Benny volunteering to do squashing.

--b.
