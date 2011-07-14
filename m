Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:45051 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502Ab1GNLZ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 07:25:26 -0400
Date: Thu, 14 Jul 2011 07:25:19 -0400
From: Jim Rees <rees@umich.edu>
To: tao.peng@emc.com
Cc: bhalevy@tonian.com, linux-nfs@vger.kernel.org, honey@citi.umich.edu
Subject: Re: [PATCH 1/6] SQUASHME: pnfs-block: Remove write_begin/end hooks
Message-ID: <20110714112519.GA619@merit.edu>
References: <cover.1310055433.git.rees@umich.edu>
 <ce801968be38153f6d75dfe227eb03631eee1baa.1310055433.git.rees@umich.edu>
 <4E1D950D.4030404@tonian.com>
 <F19688880B763E40B28B2B462677FBF805BEFF0D64@MX09A.corp.emc.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F19688880B763E40B28B2B462677FBF805BEFF0D64@MX09A.corp.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

tao.peng@emc.com wrote:

  > > + * map_block:  map a requested I/0 block (isect) into an offset in the LVM
  > > + * meta block_device
  >
  > What's a "meta block_device"?
  We can remove the *meta* if you don't like the name.

I've been calling this the "mapped device."  It's produced by blkmapd, which
is short for "block map daemon."  In the kernel it's consistently called the
"meta device."  I'm not crazy about the name either but it needs to be
consistent.  Should I change it?

I just noticed too that there are some outdated comments left over from when
the mapping was done in the kernel:

		/* For each device returned in dlist, call GETDEVICEINFO, and
		 * decode the opaque topology encoding to create a flat
		 * volume topology, matching VOLUME_SIMPLE disk signatures
		 * to disks in the visible block disk list.
		 * Construct an LVM meta device from the flat volume topology.
		 */

What's really going on here is the devices are just being added to a list.
The device is constructed later by the daemon.  I will fix this comment.
