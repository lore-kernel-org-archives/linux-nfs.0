Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:50019 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988Ab0L1D0f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Dec 2010 22:26:35 -0500
Date: Mon, 27 Dec 2010 22:26:32 -0500
From: Jim Rees <rees@umich.edu>
To: Jeff Hanson <jhansonxi@gmail.com>
Cc: Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: NFS and firewalls
Message-ID: <20101228032632.GA10718@merit.edu>
References: <AANLkTi=67a4C7Wx1zhoB-gAV_uXyzizenLmaEnbruy9i@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTi=67a4C7Wx1zhoB-gAV_uXyzizenLmaEnbruy9i@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff Hanson wrote:

  The random port usage of NFS makes it difficult to use with NAT/firewalls.

Assuming you mean v3, I've done this by setting nolock in the mount options
and bypassing the mount protocol by configuring the root file handle on the
client manually.

Others have noted that v4 solves this problem.  IPv6 eliminates the need for
NAT, if your client and server support it and your network will pass the
packets.
