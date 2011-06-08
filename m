Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:41125 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab1FHCSy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 22:18:54 -0400
Date: Tue, 7 Jun 2011 22:18:52 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
Message-ID: <20110608021852.GA20998@merit.edu>
References: <cover.1307464381.git.rees@umich.edu>
 <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
 <4DEED80A.4000102@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DEED80A.4000102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

  NAK.
  This affects all layout types.  In particular it is undesired
  for write layouts that extend the file with the objects layout.
  The server can extend the layout segments range
  over what the client requested so why would the client
  ask for artificially large layouts?

This has actually been the subject of some debate over Thursday night
beers.  The problem we're trying to solve is that the client is spending 98%
of its time in layoutget.  This patch gives us something like a 10x
speedup.  But many of us think it's not the right fix.  I suggest we discuss
next week.

But note that this patch doesn't change anything unless you set the sysctl.
