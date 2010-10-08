From: Jim Rees <rees@umich.edu>
Subject: oops, I sent that patch series to the wrong guy
Date: Fri, 8 Oct 2010 12:13:52 -0400
Message-ID: <20101008161352.GA17265@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:35368 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753378Ab0JHQOA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Oct 2010 12:14:00 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As you probably noticed, the patch series I just sent out should have gone
to you, not to Steve, since it's intended for the pnfs branch of nfs-utils.
Sorry about that.

Jim Rees (4):
  blkmapd: get rid of config file and instead examine all block devices
  blkmapd: don't rescan periodically
  blkmapd: don't use atomicio() where it's not needed
  blkmapd: don't try to distinguish between active/passive devices

...
