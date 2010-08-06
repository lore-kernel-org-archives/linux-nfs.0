Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:57266 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828Ab0HFN0W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 09:26:22 -0400
Date: Fri, 6 Aug 2010 09:26:20 -0400
From: Jim Rees <rees@umich.edu>
To: Matthew Hodgson <matthew@mxtelecom.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Tuning NFS client write pagecache
Message-ID: <20100806132620.GA2921@merit.edu>
References: <4C5BFE47.8020905@mxtelecom.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C5BFE47.8020905@mxtelecom.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Matthew Hodgson wrote:

  Is there any way to tune the linux NFSv3 client to prefer to write
  data straight to an async-mounted server, rather than having large
  writes to a file stack up in the local pagecache before being synced
  on close()?

It's been a while since I've done this, but I think you can tune this with
vm.dirty_writeback_centisecs and vm.dirty_background_ratio sysctls.  The
data will still go through the page cache but you can reduce the amount that
stacks up.

There are other places where the data can get buffered, like the rpc layer,
but it won't sit there any longer than it takes for it to go out the wire.
