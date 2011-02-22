Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:49497 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547Ab1BVUF7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 15:05:59 -0500
Date: Tue, 22 Feb 2011 15:05:58 -0500
From: Jim Rees <rees@merit.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Subject: stripe definitions
Message-ID: <20110222200558.GC7545@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There's an inconsistency in rfc5663 that had me a bit confused:

   /// struct pnfs_block_stripe_volume_info4 {
   ///     length4  bsv_stripe_unit;      /* size of stripe in bytes */

The comment "size of stripe in bytes" fits the definition of "stripe width"
from rfc5661 section 13.2, but that's not what's meant here.  The field
name, "stripe_unit", is correct.
